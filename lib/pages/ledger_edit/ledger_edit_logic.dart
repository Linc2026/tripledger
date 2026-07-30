import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/writing_scaffolds.dart';
import '../../db/ledger_db.dart';
import '../../models/content_block.dart';
import '../../models/journey_entity.dart';
import '../../utils/index.dart';
import '../ledger_home/ledger_home_logic.dart';
import 'edit_story_block.dart';
import 'ledger_edit_widgets.dart';
class LedgerEditLogic extends GetxController {
  final titleController = TextEditingController();
  final coverImagePath = ''.obs;
  final storyBlocks = <EditStoryBlock>[].obs;
  final tripStartDate = ''.obs;
  final tripEndDate = ''.obs;
  final tripSpend = ''.obs;
  final contentLength = 0.obs;
  final titleText = ''.obs;
  final contentText = ''.obs;
  final selectedMood = ''.obs;
  final isPreviewMode = false.obs;
  final isEditMode = false.obs;
  final isLoading = false.obs;
  final isPreparingTemplate = false.obs;
  final titleError = false.obs;
  final draftJustSaved = false.obs;
  final promptDismissed = false.obs;
  int editJourneyId = 0;
  String originalCreatedAt = '';
  bool hasChanges = false;
  bool _suppressChangeFlag = false;
  final List<String> _blockTextSnapshots = [];
  Future<void>? _templateImagesFuture;
  final _db = Get.find<LedgerDB>();
  final _picker = ImagePicker();
  Timer? _draftTimer;
  Timer? _draftPulseTimer;
  static const int maxImages = 9;
  static const int maxStoryLength = 3000;
  String get navTitle => isEditMode.value ? 'Edit Journal' : 'New Journal';
  int get imageCount => storyBlocks
      .where((b) => b.isImage && b.imagePath.value.isNotEmpty)
      .length;
  List<String> get photos => storyBlocks
      .where((b) => b.isImage && b.imagePath.value.isNotEmpty)
      .map((b) => b.imagePath.value)
      .toList();
  String get tripLengthLabel {
    if (tripStartDate.value.isEmpty) return '';
    if (tripEndDate.value.isEmpty) return 'Start set';
    try {
      final s = DateTime.parse(tripStartDate.value);
      final e = DateTime.parse(tripEndDate.value);
      final diff = e.difference(s).inDays + 1;
      if (diff <= 0) return '';
      return diff == 1 ? '1 day' : '$diff days';
    } catch (_) {
      return '';
    }
  }
  bool get progressHasTitle => titleText.value.trim().isNotEmpty;
  bool get progressHasStory => contentLength.value >= 50;
  bool get progressHasMedia =>
      coverImagePath.value.isNotEmpty || imageCount > 0;
  bool get progressHasDates => tripStartDate.value.isNotEmpty;
  int get progressDoneCount {
    var n = 0;
    if (progressHasTitle) n++;
    if (progressHasStory) n++;
    if (progressHasMedia) n++;
    if (progressHasDates) n++;
    return n;
  }
  String? get writingPrompt {
    if (promptDismissed.value) return null;
    return resolveWritingPrompt(
      content: contentText.value,
      tripStartDate: tripStartDate.value,
      tripEndDate: tripEndDate.value,
      mood: selectedMood.value,
      hasPhotos: imageCount > 0,
    );
  }
  List<String> get openSlots => extractTemplateSlots(contentText.value);
  String get datePhotoTip {
    if (tripStartDate.value.isEmpty) return '';
    final start = tripStartDate.value.replaceAll('-', '.');
    if (tripEndDate.value.isNotEmpty) {
      final end = tripEndDate.value.replaceAll('-', '.');
      return 'Tip: Look for photos from $start – $end in your camera roll.';
    }
    return 'Tip: Look for photos from $start in your camera roll.';
  }
  @override
  void onInit() {
    super.onInit();
    titleController.addListener(() {
      titleText.value = titleController.text;
      if (titleError.value && titleController.text.trim().isNotEmpty) {
        titleError.value = false;
      }
      if (!_suppressChangeFlag) hasChanges = true;
    });
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (args.containsKey('id')) {
        isEditMode.value = true;
        editJourneyId = args['id'] as int;
        _loadJourney(editJourneyId);
      } else if (args.containsKey('duplicateFromId')) {
        final srcId = args['duplicateFromId'] as int;
        _loadDuplicateFrom(srcId);
        _startDraftTimer();
      } else if (args.containsKey('templateTitle')) {
        _setTitle(args['templateTitle'] as String? ?? '');
        final blocksJson = args['templateBlocks'] as String? ?? '[]';
        _loadTemplateBlocks(blocksJson);
        _startDraftTimer();
      } else if (args['resumeDraft'] == true) {
        _ensureDefaultBlock();
        _resumeDraftDirectly();
        _startDraftTimer();
      } else {
        _ensureDefaultBlock();
        _checkDraft();
        _startDraftTimer();
      }
    } else {
      _ensureDefaultBlock();
      _checkDraft();
      _startDraftTimer();
    }
  }
  void _ensureDefaultBlock() {
    if (storyBlocks.isEmpty) {
      _replaceBlocks([EditStoryBlock.text()]);
    }
  }
  void _setTitle(String title) {
    _suppressChangeFlag = true;
    titleController.text = title;
    titleText.value = title;
    _suppressChangeFlag = false;
  }
  void _replaceBlocks(List<EditStoryBlock> next) {
    for (final b in storyBlocks) {
      b.dispose();
    }
    storyBlocks.assignAll(next);
    for (final b in storyBlocks) {
      b.textController.addListener(_onBlockTextChanged);
    }
    _syncContentFromBlocks();
    _captureTextSnapshots();
  }
  void _captureTextSnapshots() {
    _blockTextSnapshots
      ..clear()
      ..addAll(storyBlocks.map((b) => b.textController.text));
  }
  String _joinedStoryText() {
    return storyBlocks
        .map((b) => b.textController.text.trim())
        .where((t) => t.isNotEmpty)
        .join('\n\n');
  }
  void _onBlockTextChanged() {
    if (_suppressChangeFlag) {
      _syncContentFromBlocks();
      return;
    }
    final joined = _joinedStoryText();
    if (joined.length > maxStoryLength) {
      errorToast('Story is too long (max $maxStoryLength)');
      _suppressChangeFlag = true;
      for (var i = 0; i < storyBlocks.length; i++) {
        final snap = i < _blockTextSnapshots.length
            ? _blockTextSnapshots[i]
            : '';
        final c = storyBlocks[i].textController;
        if (c.text != snap) {
          c.text = snap;
          c.selection = TextSelection.collapsed(offset: snap.length);
        }
      }
      _suppressChangeFlag = false;
      _syncContentFromBlocks();
      return;
    }
    _captureTextSnapshots();
    contentText.value = joined;
    contentLength.value = joined.length;
    storyBlocks.refresh();
    hasChanges = true;
  }
  void _syncContentFromBlocks() {
    final joined = _joinedStoryText();
    contentText.value = joined;
    contentLength.value = joined.length;
    storyBlocks.refresh();
  }
  List<ContentBlock> _toContentBlocks() {
    return storyBlocks
        .map((b) {
          if (b.isImage) {
            return ContentBlock(
              type: ContentBlock.typeImage,
              text: b.textController.text.trim(),
              imagePath: b.imagePath.value.isEmpty
                  ? ''
                  : _db.toRelativePhotoPath(b.imagePath.value),
            );
          }
          return ContentBlock(
            type: ContentBlock.typeText,
            text: b.textController.text.trim(),
          );
        })
        .where((b) {
          if (b.isImage) return b.imagePath.isNotEmpty || b.text.isNotEmpty;
          return b.text.isNotEmpty;
        })
        .toList();
  }
  @override
  void onClose() {
    titleController.dispose();
    for (final b in storyBlocks) {
      b.dispose();
    }
    _draftTimer?.cancel();
    _draftPulseTimer?.cancel();
    super.onClose();
  }
  void _startDraftTimer() {
    _draftTimer?.cancel();
    _draftTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!isEditMode.value) _saveDraft();
    });
  }
  bool _hasDraftContent(SharedPreferences prefs) {
    final draftTitle = prefs.getString('draft_title') ?? '';
    final draftBlocks = prefs.getString('draft_body_blocks') ?? '';
    final legacy = prefs.getString('draft_content') ?? '';
    return draftTitle.trim().isNotEmpty ||
        draftBlocks.isNotEmpty ||
        legacy.trim().isNotEmpty;
  }
  Future<void> _checkDraft() async {
    final prefs = await SharedPreferences.getInstance();
    if (!_hasDraftContent(prefs)) return;
    Get.dialog(
      LedgerEditDraftDialog(
        onResume: () {
          Get.back();
          _loadDraft(prefs);
        },
        onDiscard: () {
          Get.back();
          _clearDraft();
        },
      ),
      barrierDismissible: false,
    );
  }
  Future<void> _resumeDraftDirectly() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!_hasDraftContent(prefs)) return;
      await _loadDraft(prefs);
    } catch (_) {
      errorToast('Failed to load draft');
    }
  }
  Future<void> _loadDraft(SharedPreferences prefs) async {
    _setTitle(prefs.getString('draft_title') ?? '');
    coverImagePath.value = prefs.getString('draft_cover') ?? '';
    tripStartDate.value = prefs.getString('draft_trip_start') ?? '';
    tripEndDate.value = prefs.getString('draft_trip_end') ?? '';
    selectedMood.value = prefs.getString('draft_mood') ?? '';
    tripSpend.value = prefs.getString('draft_spend') ?? '';
    final raw = prefs.getString('draft_body_blocks');
    final blocks = ContentBlock.listFromJson(raw);
    if (blocks.isEmpty) {
      final legacy = prefs.getString('draft_content') ?? '';
      _replaceBlocks([EditStoryBlock.text(text: legacy)]);
    } else {
      await _applyContentBlocks(blocks);
    }
    hasChanges = false;
  }
  Future<void> _saveDraft() async {
    if (isEditMode.value) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('draft_title', titleController.text);
      await prefs.setString('draft_cover', coverImagePath.value);
      await prefs.setString('draft_trip_start', tripStartDate.value);
      await prefs.setString('draft_trip_end', tripEndDate.value);
      await prefs.setString('draft_mood', selectedMood.value);
      await prefs.setString('draft_spend', tripSpend.value);
      final blocks = _toContentBlocks();
      await prefs.setString(
        'draft_body_blocks',
        ContentBlock.listToJson(blocks),
      );
      await prefs.setString('draft_content', ContentBlock.joinedText(blocks));
      _pulseDraftSaved();
    } catch (_) {
      errorToast('Failed to save draft');
    }
  }
  void _pulseDraftSaved() {
    draftJustSaved.value = true;
    _draftPulseTimer?.cancel();
    _draftPulseTimer = Timer(const Duration(seconds: 3), () {
      draftJustSaved.value = false;
    });
  }
  Future<void> _clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('draft_title');
      await prefs.remove('draft_content');
      await prefs.remove('draft_cover');
      await prefs.remove('draft_photos');
      await prefs.remove('draft_trip_start');
      await prefs.remove('draft_trip_end');
      await prefs.remove('draft_mood');
      await prefs.remove('draft_spend');
      await prefs.remove('draft_captions');
      await prefs.remove('draft_body_blocks');
    } catch (_) {}
  }
  Future<void> _applyContentBlocks(List<ContentBlock> blocks) async {
    final editBlocks = <EditStoryBlock>[];
    for (final b in blocks) {
      if (b.isImage) {
        final abs = b.imagePath.isEmpty
            ? ''
            : await _db.resolvePhotoPath(b.imagePath);
        editBlocks.add(EditStoryBlock.image(path: abs, text: b.text));
      } else {
        editBlocks.add(EditStoryBlock.text(text: b.text));
      }
    }
    if (editBlocks.isEmpty) {
      editBlocks.add(EditStoryBlock.text());
    }
    _replaceBlocks(editBlocks);
  }
  Future<void> _loadJourney(int id) async {
    isLoading.value = true;
    try {
      final entity = await _db.getJourney(id);
      if (entity == null) {
        errorToast('Journal not found');
        Get.back();
        return;
      }
      originalCreatedAt = entity.createdAt;
      _setTitle(entity.title);
      tripStartDate.value = entity.tripStartDate ?? '';
      tripEndDate.value = entity.tripEndDate ?? '';
      selectedMood.value = entity.tags ?? '';
      tripSpend.value = entity.tripSpend == null
          ? ''
          : entity.tripSpend!.toStringAsFixed(2);
      if (entity.coverImagePath != null && entity.coverImagePath!.isNotEmpty) {
        coverImagePath.value = await _db.resolvePhotoPath(
          entity.coverImagePath!,
        );
      }
      await _applyContentBlocks(entity.resolvedBlocks);
      hasChanges = false;
    } catch (_) {
      errorToast('Failed to load journal');
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> _loadDuplicateFrom(int id) async {
    isLoading.value = true;
    try {
      final src = await _db.getJourney(id);
      if (src == null) {
        errorToast('Journal not found');
        Get.back();
        return;
      }
      isEditMode.value = false;
      _setTitle(_copyTitle(src.title));
      tripStartDate.value = src.tripStartDate ?? '';
      tripEndDate.value = src.tripEndDate ?? '';
      selectedMood.value = src.tags ?? '';
      tripSpend.value = src.tripSpend == null
          ? ''
          : src.tripSpend!.toStringAsFixed(2);
      final copiedRels = <String, String>{};
      Future<String?> copyRel(String? relative) async {
        if (relative == null || relative.isEmpty) return null;
        final cached = copiedRels[relative];
        if (cached != null) return cached;
        final next = await _db.duplicatePhotoRelative(relative);
        if (next != null) copiedRels[relative] = next;
        return next;
      }
      final blocks = <ContentBlock>[];
      for (final b in src.resolvedBlocks) {
        if (b.isImage && b.imagePath.isNotEmpty) {
          final newPath = await copyRel(b.imagePath);
          if (newPath == null) continue;
          blocks.add(b.copyWith(imagePath: newPath));
        } else {
          blocks.add(
            ContentBlock(type: b.type, text: b.text, imagePath: b.imagePath),
          );
        }
      }
      String? cover = await copyRel(src.coverImagePath);
      if ((cover == null || cover.isEmpty)) {
        final imgs = ContentBlock.imagePaths(blocks);
        if (imgs.isNotEmpty) cover = imgs.first;
      }
      if (cover != null && cover.isNotEmpty) {
        coverImagePath.value = await _db.resolvePhotoPath(cover);
      }
      await _applyContentBlocks(blocks);
      hasChanges = true;
    } catch (_) {
      errorToast('Duplicate failed, please try again');
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }
  String _copyTitle(String title) {
    const suffix = ' (Copy)';
    if (title.length + suffix.length <= 50) return '$title$suffix';
    final maxBase = 50 - suffix.length;
    if (maxBase <= 0) return 'Copy';
    return '${title.substring(0, maxBase)}$suffix';
  }
  void onPreviewToggle() => isPreviewMode.toggle();
  void onCancelTap() {
    if (!hasChanges) {
      Get.back();
      return;
    }
    Get.dialog(
      LedgerEditDiscardDialog(
        onDiscard: () {
          Get.back();
          if (!isEditMode.value) _clearDraft();
          Get.back();
        },
        onKeep: () => Get.back(),
      ),
    );
  }
  void onSystemBack() => onCancelTap();
  Future<void> onSaveTap() async {
    if (titleController.text.trim().isEmpty) {
      titleError.value = true;
      errorToast('Please enter a title');
      return;
    }
    if (contentLength.value > maxStoryLength) {
      errorToast('Story is too long (max $maxStoryLength)');
      return;
    }
    if (isPreparingTemplate.value) {
      errorToast('Please wait for template photos to finish loading');
      return;
    }
    if (openSlots.isNotEmpty) {
      final proceed = await Get.dialog<bool>(
        LedgerEditConfirmDialog(
          title: 'Unfilled slots',
          message:
              'Some template slots are still empty (${openSlots.join(', ')}). Save anyway?',
          confirmLabel: 'Save',
          onCancel: () => Get.back(result: false),
          onConfirm: () => Get.back(result: true),
        ),
      );
      if (proceed != true) return;
    }
    if (isLoading.value) return;
    titleError.value = false;
    isLoading.value = true;
    _draftTimer?.cancel();
    try {
      if (_templateImagesFuture != null) {
        await _templateImagesFuture;
      }
      final droppedEmptyImages = _dropEmptyImageBlocks();
      if (droppedEmptyImages > 0) {
        errorToast('Some template photos failed to load and were skipped');
      }
      final now = _nowStr();
      final blocks = _toContentBlocks();
      final imageRels = ContentBlock.imagePaths(blocks);
      String cover = coverImagePath.value;
      if (cover.isEmpty && imageRels.isNotEmpty) {
        cover = await _db.resolvePhotoPath(imageRels.first);
      }
      final coverRelative = cover.isNotEmpty
          ? _db.toRelativePhotoPath(cover)
          : null;
      final joined = ContentBlock.joinedText(blocks);
      final captions = <String, String>{};
      for (final b in blocks) {
        if (b.isImage && b.imagePath.isNotEmpty && b.text.isNotEmpty) {
          captions[p.basename(b.imagePath)] = b.text;
        }
      }
      final mood = selectedMood.value.trim().isEmpty
          ? null
          : selectedMood.value.trim();
      final spend = double.tryParse(tripSpend.value.trim());
      final entity = JourneyEntity(
        id: isEditMode.value ? editJourneyId : null,
        title: titleController.text.trim(),
        content: joined.isEmpty ? null : joined,
        photos: imageRels.isEmpty ? null : imageRels.join(','),
        coverImagePath: coverRelative,
        tripStartDate: tripStartDate.value.isEmpty ? null : tripStartDate.value,
        tripEndDate: tripEndDate.value.isEmpty ? null : tripEndDate.value,
        tags: mood,
        tripSpend: spend,
        photoCaptions: captions.isEmpty ? null : jsonEncode(captions),
        bodyBlocks: blocks.isEmpty ? null : ContentBlock.listToJson(blocks),
        createdAt: isEditMode.value && originalCreatedAt.isNotEmpty
            ? originalCreatedAt
            : now,
        updatedAt: now,
      );
      if (isEditMode.value) {
        final updated = await _db.updateJourney(entity);
        if (updated <= 0) {
          errorToast('Journal not found');
          isLoading.value = false;
          _startDraftTimer();
          return;
        }
        isLoading.value = false;
        hasChanges = false;
        await _showSavedDialogThenLeave(isEdit: true);
      } else {
        await _db.insertJourney(entity);
        await _clearDraft();
        isLoading.value = false;
        hasChanges = false;
        await _showSavedDialogThenLeave(isEdit: false);
      }
    } catch (_) {
      errorToast('Save failed, please try again');
      isLoading.value = false;
      _startDraftTimer();
    }
  }
  String buildShareSummary() {
    final title = titleController.text.trim();
    final days = tripLengthLabel;
    String datePart;
    if (tripStartDate.value.isNotEmpty && tripEndDate.value.isNotEmpty) {
      datePart =
          '${tripStartDate.value.replaceAll('-', '.')} – ${tripEndDate.value.replaceAll('-', '.')}';
      if (days.isNotEmpty && days != 'Start set') {
        datePart = '$datePart ($days)';
      }
    } else if (tripStartDate.value.isNotEmpty) {
      datePart = 'From ${tripStartDate.value.replaceAll('-', '.')}';
    } else {
      datePart = 'No dates';
    }
    final content = contentText.value.trim();
    var firstLine = '';
    if (content.isNotEmpty) {
      firstLine = content.split('\n').first.trim();
      if (firstLine.length > 80) {
        firstLine = '${firstLine.substring(0, 80)}…';
      }
    }
    final mood = selectedMood.value.isEmpty ? '' : ' · ${selectedMood.value}';
    final spend = tripSpend.value.trim().isEmpty
        ? ''
        : ' · \$${tripSpend.value.trim()}';
    final body = firstLine.isEmpty ? '' : '\n$firstLine';
    return '$title · $datePart$mood$spend$body';
  }
  void onSpendChanged(String value) {
    tripSpend.value = value;
    hasChanges = true;
  }
  void onDismissPrompt() => promptDismissed.value = true;
  void onInsertPromptTap() {
    final prompt = writingPrompt;
    if (prompt == null) return;
    _appendTextToStory(prompt);
    promptDismissed.value = true;
  }
  void onFillSlotTap(String slot) {
    Get.dialog(
      LedgerEditInputDialog(
        title: 'Fill {{$slot}}',
        hintText: 'Enter $slot',
        initialValue: '',
        maxLength: 60,
        onCancel: () => Get.back(),
        onSubmit: (value) {
          Get.back();
          if (value.isEmpty) return;
          _suppressChangeFlag = true;
          for (final b in storyBlocks) {
            b.textController.text = replaceTemplateSlot(
              b.textController.text,
              slot,
              value,
            );
          }
          _suppressChangeFlag = false;
          _syncContentFromBlocks();
          hasChanges = true;
          successToast('Slot filled');
        },
      ),
    );
  }
  Future<void> _showSavedDialogThenLeave({required bool isEdit}) async {
    final summary = buildShareSummary();
    await Get.dialog(
      LedgerEditSavedDialog(
        summary: summary,
        onShare: () async {
          try {
            await SharePlus.instance.share(ShareParams(text: summary));
          } catch (_) {
            errorToast('Share failed, please try again');
          }
        },
        onDone: () => Get.back(),
      ),
      barrierDismissible: false,
    );
    _refreshHomeList();
    if (isEdit) {
      Get.back();
    } else {
      Get.until((route) => route.settings.name == '/tab');
    }
  }
  void _refreshHomeList() {
    if (Get.isRegistered<LedgerHomeLogic>()) {
      Get.find<LedgerHomeLogic>().loadJourneys();
    }
  }
  void onMoodTap(String mood) {
    selectedMood.value = selectedMood.value == mood ? '' : mood;
    hasChanges = true;
  }
  void onOutlineTap() {
    showLedgerEditSheet(
      LedgerEditSheetScaffold(
        title: 'Writing Outline',
        children: kWritingScaffolds
            .map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LedgerEditSourceTile(
                  icon: Icons.view_agenda_outlined,
                  label: s.title,
                  onTap: () {
                    Get.back();
                    insertScaffold(s.body);
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }
  void insertScaffold(String body) {
    if (contentText.value.trim().isNotEmpty) {
      Get.dialog(
        LedgerEditConfirmDialog(
          title: 'Insert outline?',
          message: 'This will add a new text section with the outline.',
          confirmLabel: 'Insert',
          onCancel: () => Get.back(),
          onConfirm: () {
            Get.back();
            _addTextBlock(body);
          },
        ),
      );
      return;
    }
    if (storyBlocks.length == 1 && storyBlocks.first.isText) {
      storyBlocks.first.textController.text = body;
      _syncContentFromBlocks();
      hasChanges = true;
      successToast('Outline inserted');
      return;
    }
    _addTextBlock(body);
  }
  void _appendTextToStory(String text) {
    EditStoryBlock? lastText;
    for (final b in storyBlocks.reversed) {
      if (b.isText) {
        lastText = b;
        break;
      }
    }
    if (lastText != null) {
      final current = lastText.textController.text;
      final next = current.trim().isEmpty ? text : '$current\n\n$text';
      final others =
          contentLength.value -
          (current.trim().isEmpty ? 0 : current.trim().length);
      final sep = current.trim().isEmpty || contentLength.value == 0 ? 0 : 2;
      if (others + sep + next.trim().length > maxStoryLength) {
        errorToast('Story is too long (max $maxStoryLength)');
        return;
      }
      lastText.textController.text = next;
    } else {
      _addTextBlock(text);
    }
    hasChanges = true;
  }
  void _addTextBlock(String text) {
    final extra = text.trim().isEmpty
        ? 0
        : (contentLength.value == 0
              ? text.trim().length
              : text.trim().length + 2);
    if (contentLength.value + extra > maxStoryLength) {
      errorToast('Story is too long (max $maxStoryLength)');
      return;
    }
    final block = EditStoryBlock.text(text: text);
    block.textController.addListener(_onBlockTextChanged);
    storyBlocks.add(block);
    _syncContentFromBlocks();
    _captureTextSnapshots();
    hasChanges = true;
    successToast('Text section added');
  }
  void onAddTextSectionTap() => _addTextBlock('');
  Future<void> onAddImageSectionTap() async {
    if (imageCount >= maxImages) {
      errorToast('Maximum $maxImages photos allowed');
      return;
    }
    final source = await _showImageSourceSheet(title: 'Add Photo Section');
    if (source == null) return;
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return;
      final local = await _copyImageToLocal(picked.path);
      final block = EditStoryBlock.image(path: local);
      block.textController.addListener(_onBlockTextChanged);
      storyBlocks.add(block);
      _syncContentFromBlocks();
      _captureTextSnapshots();
      hasChanges = true;
      successToast('Photo section added');
    } on Exception catch (e) {
      _handleImageError(e);
    }
  }
  void onRemoveBlock(int index) {
    if (index < 0 || index >= storyBlocks.length) return;
    if (storyBlocks.length == 1) {
      errorToast('Keep at least one section');
      return;
    }
    final removed = storyBlocks.removeAt(index);
    final removedPath = removed.isImage ? removed.imagePath.value : '';
    if (removed.isImage && removedPath == coverImagePath.value) {
      coverImagePath.value = '';
    }
    removed.dispose();
    _syncContentFromBlocks();
    _captureTextSnapshots();
    hasChanges = true;
    if (removedPath.isNotEmpty) {
      _deleteLocalPhotoIfUnused(removedPath);
    }
  }
  void onMoveBlockUp(int index) {
    if (index <= 0 || index >= storyBlocks.length) return;
    final item = storyBlocks.removeAt(index);
    storyBlocks.insert(index - 1, item);
    hasChanges = true;
  }
  void onMoveBlockDown(int index) {
    if (index < 0 || index >= storyBlocks.length - 1) return;
    final item = storyBlocks.removeAt(index);
    storyBlocks.insert(index + 1, item);
    hasChanges = true;
  }
  Future<void> onChangeBlockImage(int index) async {
    if (index < 0 || index >= storyBlocks.length) return;
    final block = storyBlocks[index];
    if (!block.isImage) return;
    final source = await _showImageSourceSheet(title: 'Change Photo');
    if (source == null) return;
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return;
      final oldPath = block.imagePath.value;
      final local = await _copyImageToLocal(picked.path);
      if (oldPath == coverImagePath.value) {
        coverImagePath.value = local;
      }
      block.imagePath.value = local;
      storyBlocks.refresh();
      hasChanges = true;
      if (oldPath.isNotEmpty && oldPath != local) {
        _deleteLocalPhotoIfUnused(oldPath);
      }
    } on Exception catch (e) {
      _handleImageError(e);
    }
  }
  void onSetBlockAsCover(int index) {
    if (index < 0 || index >= storyBlocks.length) return;
    final block = storyBlocks[index];
    if (!block.isImage || block.imagePath.value.isEmpty) return;
    coverImagePath.value = block.imagePath.value;
    hasChanges = true;
    successToast('Cover updated');
  }
  Future<void> onCoverImageTap() async {
    final source = await _showImageSourceSheet(title: 'Cover Photo');
    if (source == null) return;
    await _pickCoverImage(source);
  }
  Future<ImageSource?> _showImageSourceSheet({required String title}) {
    return showLedgerEditSheet<ImageSource>(
      LedgerEditSheetScaffold(
        title: title,
        children: [
          LedgerEditSourceTile(
            icon: Icons.photo_camera_rounded,
            label: 'Camera',
            onTap: () => Get.back(result: ImageSource.camera),
          ),
          const SizedBox(height: 8),
          LedgerEditSourceTile(
            icon: Icons.photo_library_rounded,
            label: 'Photo Library',
            onTap: () => Get.back(result: ImageSource.gallery),
          ),
        ],
      ),
    );
  }
  Future<void> _pickCoverImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return;
      final oldPath = coverImagePath.value;
      final local = await _copyImageToLocal(picked.path);
      coverImagePath.value = local;
      hasChanges = true;
      if (oldPath.isNotEmpty &&
          oldPath != local &&
          !storyBlocks.any((b) => b.isImage && b.imagePath.value == oldPath)) {
        _deleteLocalPhotoIfUnused(oldPath);
      }
    } on Exception catch (e) {
      _handleImageError(e);
    }
  }
  void _handleImageError(Exception e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('permission') ||
        msg.contains('access') ||
        msg.contains('denied')) {
      errorToast('Please allow photo access in Settings');
    } else {
      errorToast('Failed to save photo, please try again');
    }
  }
  List<String> buildTitleSuggestions() {
    final result = <String>[];
    final content = contentText.value.trim();
    if (content.isNotEmpty) {
      final first = content
          .split(RegExp(r'[\n.!?]'))
          .map((e) => e.trim())
          .firstWhere((e) => e.isNotEmpty, orElse: () => '');
      if (first.isNotEmpty) {
        result.add(first.length > 50 ? first.substring(0, 50) : first);
      }
    }
    final days = tripLengthLabel;
    if (days.isNotEmpty &&
        days != 'Start set' &&
        !result.contains('$days Trip')) {
      result.add('$days Trip');
    } else if (!result.contains('My Travel Journal')) {
      result.add('My Travel Journal');
    }
    if (!result.contains('Travel Memories')) {
      result.add('Travel Memories');
    }
    return result.take(3).toList();
  }
  void onSuggestTitleTap() {
    final suggestions = buildTitleSuggestions();
    if (suggestions.isEmpty) {
      errorToast('Write a bit of your story first');
      return;
    }
    showLedgerEditSheet(
      LedgerEditSheetScaffold(
        title: 'Suggested Titles',
        children: suggestions
            .map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LedgerEditSourceTile(
                  icon: Icons.title_rounded,
                  label: s,
                  onTap: () {
                    Get.back();
                    applyTitleSuggestion(s);
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }
  void applyTitleSuggestion(String title) {
    _suppressChangeFlag = true;
    titleController.text = title;
    titleText.value = title;
    titleError.value = false;
    _suppressChangeFlag = false;
    hasChanges = true;
  }
  void onDepartureDateTap(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: tripStartDate.value.isNotEmpty
          ? DateTime.tryParse(tripStartDate.value) ?? DateTime.now()
          : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      tripStartDate.value = getDateString(picked);
      if (tripEndDate.value.isNotEmpty) {
        final end = DateTime.tryParse(tripEndDate.value);
        if (end != null && end.isBefore(picked)) {
          tripEndDate.value = '';
          errorToast('Return date must be after departure');
        }
      }
      hasChanges = true;
    }
  }
  void onClearDepartureDate() {
    tripStartDate.value = '';
    hasChanges = true;
  }
  void onReturnDateTap(BuildContext context) async {
    final firstDate = tripStartDate.value.isNotEmpty
        ? DateTime.tryParse(tripStartDate.value) ?? DateTime(2000)
        : DateTime(2000);
    final picked = await showDatePicker(
      context: context,
      initialDate: tripEndDate.value.isNotEmpty
          ? DateTime.tryParse(tripEndDate.value) ?? firstDate
          : firstDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      if (tripStartDate.value.isNotEmpty) {
        final start = DateTime.tryParse(tripStartDate.value);
        if (start != null && picked.isBefore(start)) {
          errorToast('Return date must be after departure');
          return;
        }
      }
      tripEndDate.value = getDateString(picked);
      hasChanges = true;
    }
  }
  void onClearReturnDate() {
    tripEndDate.value = '';
    hasChanges = true;
  }
  Future<String> _copyImageToLocal(String sourcePath) =>
      _db.copyPhotoToLocal(sourcePath);
  int _dropEmptyImageBlocks() {
    var removed = 0;
    for (var i = storyBlocks.length - 1; i >= 0; i--) {
      final b = storyBlocks[i];
      if (!b.isImage || b.imagePath.value.isNotEmpty) continue;
      storyBlocks.removeAt(i);
      b.dispose();
      removed++;
    }
    if (removed > 0) {
      if (storyBlocks.isEmpty) {
        _replaceBlocks([EditStoryBlock.text()]);
      } else {
        _syncContentFromBlocks();
        _captureTextSnapshots();
      }
    }
    return removed;
  }
  Future<void> _deleteLocalPhotoIfUnused(String absolutePath) async {
    if (absolutePath.isEmpty) return;
    if (coverImagePath.value == absolutePath) return;
    if (storyBlocks.any(
      (b) => b.isImage && b.imagePath.value == absolutePath,
    )) {
      return;
    }
    try {
      final rel = _db.toRelativePhotoPath(absolutePath);
      if (!rel.startsWith('journey_photos/')) return;
      final file = File(absolutePath);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
  Future<void> _loadTemplateBlocks(String blocksJson) async {
    List<dynamic> decoded;
    try {
      decoded = jsonDecode(blocksJson) as List<dynamic>;
    } catch (_) {
      decoded = [];
    }
    final newBlocks = <EditStoryBlock>[];
    final imageJobs = <int, Map<String, dynamic>>{};
    for (final item in decoded) {
      final map = Map<String, dynamic>.from(item as Map);
      final type = (map['type'] as String?) ?? 'text';
      final text = (map['text'] as String?) ?? '';
      if (type == 'image') {
        imageJobs[newBlocks.length] = map;
        newBlocks.add(EditStoryBlock.image(path: '', text: text));
      } else {
        newBlocks.add(EditStoryBlock.text(text: text));
      }
    }
    final joinedText = newBlocks
        .where((b) => b.isText)
        .map((b) => b.textController.text)
        .join('\n\n');
    if (!joinedText.contains('{{')) {
      final lastTextIdx = newBlocks.lastIndexWhere((b) => b.isText);
      if (lastTextIdx >= 0) {
        newBlocks[lastTextIdx].textController.text += kTemplateSlotSuffix;
      } else {
        newBlocks.add(EditStoryBlock.text(text: kTemplateSlotSuffix));
      }
    }
    _replaceBlocks(newBlocks);
    if (imageJobs.isEmpty) {
      isPreparingTemplate.value = false;
      return;
    }
    isPreparingTemplate.value = true;
    final future = _fillTemplateImages(imageJobs);
    _templateImagesFuture = future;
    try {
      await future;
    } finally {
      if (identical(_templateImagesFuture, future)) {
        _templateImagesFuture = null;
        isPreparingTemplate.value = false;
      }
    }
  }
  Future<void> _fillTemplateImages(
    Map<int, Map<String, dynamic>> imageJobs,
  ) async {
    for (final entry in imageJobs.entries) {
      final blockIdx = entry.key;
      final item = entry.value;
      if (blockIdx >= storyBlocks.length) continue;
      final block = storyBlocks[blockIdx];
      if (!block.isImage) continue;
      final imageAsset = item['imageAsset'] as String?;
      final imageUrl = item['imageUrl'] as String?;
      final localPath = imageAsset != null
          ? await _assetToLocalPath(imageAsset)
          : imageUrl != null
          ? await _downloadToLocalPath(imageUrl)
          : null;
      if (localPath != null) {
        block.imagePath.value = localPath;
        storyBlocks.refresh();
        hasChanges = true;
        if (coverImagePath.value.isEmpty) {
          coverImagePath.value = localPath;
        }
      }
    }
  }
  Future<String?> _assetToLocalPath(String assetPath) async {
    try {
      final bytes = await rootBundle.load(assetPath);
      final dest = await _db.newPhotoAbsolutePath();
      final file = File(dest);
      await file.writeAsBytes(bytes.buffer.asUint8List());
      if (await file.exists() && await file.length() > 0) return dest;
    } catch (_) {}
    return null;
  }
  Future<String?> _downloadToLocalPath(String url) async {
    try {
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != 200) {
        httpClient.close();
        return null;
      }
      final dest = await _db.newPhotoAbsolutePath();
      final file = File(dest);
      final sink = file.openWrite();
      await response.pipe(sink);
      await sink.flush();
      await sink.close();
      httpClient.close();
      if (await file.exists() && await file.length() > 0) return dest;
    } catch (_) {}
    return null;
  }
  String _nowStr() {
    final now = DateTime.now();
    final date = getDateString(now);
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final ss = now.second.toString().padLeft(2, '0');
    return '$date $hh:$mm:$ss';
  }
  Future<String> resolvePhotoPath(String relative) =>
      _db.resolvePhotoPath(relative);
  List<ContentBlock> previewBlocks() {
    return storyBlocks.map((b) {
      if (b.isImage) {
        return ContentBlock(
          type: ContentBlock.typeImage,
          text: b.textController.text,
          imagePath: b.imagePath.value,
        );
      }
      return ContentBlock(
        type: ContentBlock.typeText,
        text: b.textController.text,
      );
    }).toList();
  }
}
