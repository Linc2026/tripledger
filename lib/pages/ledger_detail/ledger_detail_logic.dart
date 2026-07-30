import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/templates.dart';
import '../../data/writing_scaffolds.dart';
import '../../db/ledger_db.dart';
import '../../models/content_block.dart';
import '../../models/journey_entity.dart';
import '../../models/template_block.dart';
import '../../models/template_model.dart';
import '../../utils/index.dart';
import '../ledger_home/ledger_home_logic.dart';
class LedgerDetailLogic extends GetxController {
  final journey = Rx<JourneyEntity?>(null);
  final template = Rx<TemplateModel?>(null);
  final isTemplate = false.obs;
  final isLoading = true.obs;
  final isDeleting = false.obs;
  final isDuplicating = false.obs;
  final List<GlobalKey> storyImageKeys = [];
  final _db = Get.find<LedgerDB>();
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (args.containsKey('templateId')) {
        isTemplate.value = true;
        final id = args['templateId'] as int;
        final found = kTemplates.firstWhereOrNull((t) => t.id == id);
        if (found == null) {
          errorToast('Failed to load template');
        }
        template.value = found;
        isLoading.value = false;
      } else if (args.containsKey('id')) {
        isTemplate.value = false;
        final id = args['id'] as int;
        loadJourney(id);
      } else {
        errorToast('Failed to load journal');
        isLoading.value = false;
      }
    } else {
      errorToast('Failed to load journal');
      isLoading.value = false;
    }
  }
  Future<void> loadJourney(int id) async {
    isLoading.value = true;
    try {
      final result = await _db.getJourney(id);
      if (result != null) {
        journey.value = result;
        _syncStoryImageKeys(result);
      } else {
        errorToast('Failed to load journal');
      }
    } catch (_) {
      errorToast('Failed to load journal');
    } finally {
      isLoading.value = false;
    }
  }
  void _syncStoryImageKeys(JourneyEntity journal) {
    final count = ContentBlock.imagePaths(journal.resolvedBlocks).length;
    storyImageKeys
      ..clear()
      ..addAll(List.generate(count, (_) => GlobalKey()));
  }
  List<String> get imageRelativePaths {
    final j = journey.value;
    if (j == null) return const [];
    return ContentBlock.imagePaths(j.resolvedBlocks);
  }
  int get photoCount {
    final j = journey.value;
    if (j == null) return 0;
    final set = imageRelativePaths.toSet();
    final cover = j.coverImagePath;
    if (cover != null && cover.isNotEmpty) set.add(cover);
    return set.length;
  }
  String get tripDaysLabel {
    final days = tripDays;
    if (days == null) return '';
    return days == 1 ? '1 day' : '$days days';
  }
  int get wordCount {
    final j = journey.value;
    if (j == null) return 0;
    final text = ContentBlock.joinedText(j.resolvedBlocks).trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }
  int? get tripDays {
    final j = journey.value;
    if (j == null) return null;
    final start = j.tripStartDate;
    final end = j.tripEndDate;
    if (start == null || start.isEmpty) return null;
    try {
      final s = DateTime.parse(start);
      if (end == null || end.isEmpty) return 1;
      final e = DateTime.parse(end);
      final days = e.difference(s).inDays + 1;
      return days > 0 ? days : null;
    } catch (_) {
      return null;
    }
  }
  String? get spendPerDayLabel {
    final j = journey.value;
    final spend = j?.tripSpend;
    final days = tripDays;
    if (spend == null || days == null || days <= 0) return null;
    return '\$${(spend / days).toStringAsFixed(2)}/day';
  }
  String? get anniversaryBannerText {
    final j = journey.value;
    if (j == null) return null;
    final raw = (j.tripEndDate != null && j.tripEndDate!.isNotEmpty)
        ? j.tripEndDate!
        : j.tripStartDate;
    if (raw == null || raw.isEmpty) return null;
    try {
      final trip = DateTime.parse(raw);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final years = now.year - trip.year;
      if (years < 1) return null;
      var anniversary = DateTime(now.year, trip.month, trip.day);
      if (anniversary.month != trip.month) {
        anniversary = DateTime(now.year, trip.month + 1, 0);
      }
      final diff = anniversary.difference(today).inDays;
      final yearLabel = years == 1 ? '1 year' : '$years years';
      if (diff == 0) return '$yearLabel ago today';
      if (diff > 0 && diff <= 3) {
        return '$yearLabel anniversary in $diff day${diff == 1 ? '' : 's'}';
      }
      if (diff < 0 && diff >= -3) {
        final ago = -diff;
        return '$yearLabel anniversary was $ago day${ago == 1 ? '' : 's'} ago';
      }
      return null;
    } catch (_) {
      return null;
    }
  }
  List<String> get openSlots {
    final j = journey.value;
    if (j == null) return const [];
    return extractTemplateSlots(ContentBlock.joinedText(j.resolvedBlocks));
  }
  String? get fillGapsBannerText {
    final slots = openSlots;
    if (slots.isEmpty) return null;
    final n = slots.length;
    final label = n == 1 ? '1 slot left' : '$n slots left';
    final names = slots.take(3).map((s) => '{{$s}}').join(', ');
    final more = slots.length > 3 ? '…' : '';
    return '$label · $names$more';
  }
  void onFillGapsTap() => onEditTap();
  void onBackTap() => Get.back();
  Future<void> onDuplicateTap() async {
    final src = journey.value;
    if (src?.id == null || isDuplicating.value) return;
    isDuplicating.value = true;
    try {
      await Get.toNamed(
        '/journey/edit',
        arguments: {'duplicateFromId': src!.id},
      );
      if (Get.isRegistered<LedgerHomeLogic>()) {
        Get.find<LedgerHomeLogic>().loadJourneys();
      }
    } catch (_) {
      errorToast('Duplicate failed, please try again');
    } finally {
      isDuplicating.value = false;
    }
  }
  Future<void> onPhotoStripTap(int photoIndex) async {
    final paths = imageRelativePaths;
    if (photoIndex < 0 || photoIndex >= paths.length) return;
    try {
      if (photoIndex < storyImageKeys.length) {
        final ctx = storyImageKeys[photoIndex].currentContext;
        if (ctx != null) {
          await Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            alignment: 0.12,
          );
        }
      }
      final absPaths = await Future.wait(paths.map(resolvePhotoPath));
      onPhotoTap(photoIndex, absPaths);
    } catch (_) {
      errorToast('Failed to open photo');
    }
  }
  Future<String> resolvePhotoPath(String relative) =>
      _db.resolvePhotoPath(relative);
  void onEditTap() {
    if (journey.value == null) return;
    Get.toNamed('/journey/edit', arguments: {'id': journey.value!.id})
        ?.then((_) {
      if (journey.value?.id != null) {
        loadJourney(journey.value!.id!);
      }
    });
  }
  void onDeleteTap() {
    if (isDeleting.value) return;
    _showDeleteDialog();
  }
  void _showDeleteDialog() {
    Get.dialog(
      _DeleteDialog(onConfirm: _deleteJourney),
    );
  }
  Future<void> _deleteJourney() async {
    if (journey.value?.id == null || isDeleting.value) return;
    isDeleting.value = true;
    try {
      await _db.deleteJourney(journey.value!.id!);
      successToast('Journal deleted');
      Get.until((route) => route.settings.name == '/tab');
    } catch (_) {
      errorToast('Delete failed, please try again');
    } finally {
      isDeleting.value = false;
    }
  }
  Future<void> onStoryImageTap(int blockIndex) async {
    final journal = journey.value;
    if (journal == null) return;
    try {
      final blocks = journal.resolvedBlocks;
      if (blockIndex < 0 || blockIndex >= blocks.length) return;
      final block = blocks[blockIndex];
      if (!block.isImage || block.imagePath.isEmpty) return;
      final imageRels = ContentBlock.imagePaths(blocks);
      final index = imageRels.indexOf(block.imagePath);
      if (index < 0) return;
      final paths = await Future.wait(
        imageRels.map((r) => resolvePhotoPath(r)),
      );
      onPhotoTap(index, paths);
    } catch (_) {
      errorToast('Failed to open photo');
    }
  }
  Future<void> onCoverTap() async {
    if (isTemplate.value) return;
    final cover = journey.value?.coverImagePath;
    if (cover == null || cover.isEmpty) return;
    try {
      final path = await resolvePhotoPath(cover);
      onPhotoTap(0, [path]);
    } catch (_) {
      errorToast('Failed to open photo');
    }
  }
  void onPhotoTap(int index, List<String> photos) {
    Get.toNamed('/photo/view',
        arguments: {'photos': photos, 'initialIndex': index});
  }
  void onUseTemplateTap() {
    final tmpl = template.value;
    if (tmpl == null) return;
    Get.toNamed('/journey/edit', arguments: {
      'templateTitle': tmpl.title,
      'templateBlocks': _encodeBlocks(tmpl.blocks),
    });
  }
  String _encodeBlocks(List<TemplateBlock> blocks) {
    return jsonEncode(blocks.map((b) {
      return {
        'type': b.type,
        'text': b.text,
        if (b.imageAsset != null) 'imageAsset': b.imageAsset,
        if (b.imageUrl != null) 'imageUrl': b.imageUrl,
      };
    }).toList());
  }
  String formatCreatedAt(String createdAt) {
    return extractDateFromDateTime(createdAt).replaceAll('-', '.');
  }
}
class _DeleteDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const _DeleteDialog({required this.onConfirm});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_rounded,
                  size: 26, color: Color(0xFFD94F4F)),
            ),
            const SizedBox(height: 16),
            const Text('Delete this journal?',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A))),
            const SizedBox(height: 8),
            const Text(
                'This will delete the journal and all associated photos. This cannot be undone.',
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.5),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F5F3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('Cancel',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A))),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      onConfirm();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD94F4F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('Delete',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
