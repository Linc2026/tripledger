import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/templates.dart';
import '../../data/writing_scaffolds.dart';
import '../../db/ledger_db.dart';
import '../../models/journey_entity.dart';
import '../../models/template_model.dart';
import '../../utils/index.dart';
class LedgerHomeLogic extends GetxController {
  final journeys = <JourneyEntity>[].obs;
  final filteredJourneys = <JourneyEntity>[].obs;
  final List<TemplateModel> templates = kTemplates;
  final searchKeyword = ''.obs;
  final viewMode = 'list'.obs;
  final calendarYear = DateTime.now().year.obs;
  final calendarMonth = DateTime.now().month.obs;
  final selectedCalendarDay = (-1).obs;
  final calendarDayJournals = <JourneyEntity>[].obs;
  final isLoading = false.obs;
  final searchController = TextEditingController();
  final hasDraft = false.obs;
  final draftTitle = ''.obs;
  final draftDismissed = false.obs;
  final selectedMoodFilters = <String>[].obs;
  final filterHasSpend = false.obs;
  final List<String> moodOptions = kMoodOptions;
  final _db = Get.find<LedgerDB>();
  Future<String> resolvePhotoPath(String relative) =>
      _db.resolvePhotoPath(relative);
  bool get showDraftCard => hasDraft.value && !draftDismissed.value;
  bool get hasActiveFilters =>
      selectedMoodFilters.isNotEmpty || filterHasSpend.value;
  int get journalCount => journeys.length;
  double get totalSpend =>
      journeys.fold<double>(0, (sum, j) => sum + (j.tripSpend ?? 0));
  String get snapshotSpendLabel => formatSpend(totalSpend);
  String get snapshotLabel {
    final n = journalCount;
    final journalWord = n == 1 ? 'journal' : 'journals';
    return '$n $journalWord · $snapshotSpendLabel';
  }
  static String formatSpend(double value) {
    if (value == value.roundToDouble()) {
      return '\$${value.toInt()}';
    }
    return '\$${value.toStringAsFixed(2)}';
  }
  @override
  void onInit() {
    super.onInit();
    loadJourneys();
  }
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
  Future<void> loadJourneys() async {
    isLoading.value = true;
    try {
      final list = await _db.getJourneys();
      journeys.assignAll(list);
      _recomputeFiltered();
      _refreshCalendarDayJournals();
      await loadDraftStatus();
    } catch (_) {
      errorToast('Failed to load journals');
      filteredJourneys.clear();
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> onRefreshTap() => loadJourneys();
  Future<void> loadDraftStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final title = prefs.getString('draft_title') ?? '';
      final blocks = prefs.getString('draft_body_blocks') ?? '';
      final legacy = prefs.getString('draft_content') ?? '';
      final exists =
          title.trim().isNotEmpty || blocks.isNotEmpty || legacy.isNotEmpty;
      hasDraft.value = exists;
      draftTitle.value = title.trim().isEmpty ? 'Untitled draft' : title.trim();
      if (!exists) draftDismissed.value = false;
    } catch (_) {
      hasDraft.value = false;
    }
  }
  void _recomputeFiltered() {
    final keyword = searchKeyword.value.trim().toLowerCase();
    final moods = selectedMoodFilters.toSet();
    final needSpend = filterHasSpend.value;
    filteredJourneys.assignAll(
      journeys.where((j) {
        if (keyword.isNotEmpty) {
          final inTitle = j.title.toLowerCase().contains(keyword);
          final inContent = j.content?.toLowerCase().contains(keyword) ?? false;
          if (!inTitle && !inContent) return false;
        }
        if (moods.isNotEmpty) {
          final tag = (j.tags ?? '').trim();
          if (!moods.contains(tag)) return false;
        }
        if (needSpend && (j.tripSpend == null || j.tripSpend! <= 0)) {
          return false;
        }
        return true;
      }),
    );
    _refreshCalendarDayJournals();
  }
  void onViewToggle() {
    if (viewMode.value == 'list') {
      viewMode.value = 'calendar';
      _selectTodayIfCurrentMonth();
    } else {
      viewMode.value = 'list';
    }
  }
  void _selectTodayIfCurrentMonth() {
    final now = DateTime.now();
    if (calendarYear.value != now.year || calendarMonth.value != now.month) {
      return;
    }
    selectedCalendarDay.value = now.day;
    calendarDayJournals.assignAll(_journalsOnDay(now.day));
  }
  void onSearchChanged(String keyword) {
    searchKeyword.value = keyword;
    _recomputeFiltered();
  }
  void onSearchClear() {
    searchController.clear();
    searchKeyword.value = '';
    _recomputeFiltered();
  }
  void onMoodFilterTap(String mood) {
    if (selectedMoodFilters.contains(mood)) {
      selectedMoodFilters.clear();
    } else {
      selectedMoodFilters
        ..clear()
        ..add(mood);
    }
    selectedMoodFilters.refresh();
    _recomputeFiltered();
  }
  void onHasSpendFilterTap() {
    filterHasSpend.toggle();
    _recomputeFiltered();
  }
  void onClearFiltersTap() {
    selectedMoodFilters.clear();
    filterHasSpend.value = false;
    _recomputeFiltered();
  }
  void onDraftDismiss() {
    draftDismissed.value = true;
  }
  void onResumeDraftTap() {
    Get.toNamed(
      '/journey/edit',
      arguments: {'resumeDraft': true},
    )?.then((_) => loadJourneys());
  }
  void onAddTap() {
    Get.toNamed('/journey/edit')?.then((_) => loadJourneys());
  }
  void onJournalTap(int id) {
    Get.toNamed(
      '/journey/detail',
      arguments: {'id': id},
    )?.then((_) => loadJourneys());
  }
  void onJournalLongPress(JourneyEntity journal) {
    if (journal.id == null) return;
    Get.dialog(_HomeDeleteDialog(onConfirm: () => onDeleteTap(journal.id!)));
  }
  Future<void> onDeleteTap(int id) async {
    try {
      await _db.deleteJourney(id);
      successToast('Journal deleted');
      await loadJourneys();
    } catch (_) {
      errorToast('Delete failed, please try again');
    }
  }
  void onTemplateTap(TemplateModel template) {
    Get.toNamed(
      '/journey/detail',
      arguments: {'templateId': template.id},
    )?.then((_) => loadJourneys());
  }
  void onSeeAllTemplateTap(TemplateModel template) {
    Get.back();
    onTemplateTap(template);
  }
  void onSeeAllTap() {
    Get.bottomSheet(
      _TemplatesSeeAllSheet(
        templates: templates,
        onTemplateTap: onSeeAllTemplateTap,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
  void onPreviousMonth() {
    if (calendarMonth.value == 1) {
      calendarMonth.value = 12;
      calendarYear.value--;
    } else {
      calendarMonth.value--;
    }
    selectedCalendarDay.value = -1;
    calendarDayJournals.clear();
  }
  void onNextMonth() {
    if (calendarMonth.value == 12) {
      calendarMonth.value = 1;
      calendarYear.value++;
    } else {
      calendarMonth.value++;
    }
    selectedCalendarDay.value = -1;
    calendarDayJournals.clear();
  }
  void _refreshCalendarDayJournals() {
    final day = selectedCalendarDay.value;
    if (day <= 0) return;
    calendarDayJournals.assignAll(_journalsOnDay(day));
  }
  List<JourneyEntity> _journalsOnDay(int day) {
    return filteredJourneys.where((j) {
      final dateStr = j.tripStartDate ?? j.createdAt;
      final parts = extractDateFromDateTime(dateStr).split('-');
      if (parts.length < 3) return false;
      return int.tryParse(parts[0]) == calendarYear.value &&
          int.tryParse(parts[1]) == calendarMonth.value &&
          int.tryParse(parts[2]) == day;
    }).toList();
  }
  List<int> getMarkedDays() => getMarkedDayCounts().keys.toList();
  Map<int, int> getMarkedDayCounts() {
    final counts = <int, int>{};
    for (final j in filteredJourneys) {
      final dateStr = j.tripStartDate ?? j.createdAt;
      final parts = extractDateFromDateTime(dateStr).split('-');
      if (parts.length < 3) continue;
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y == calendarYear.value && m == calendarMonth.value && d != null) {
        counts[d] = (counts[d] ?? 0) + 1;
      }
    }
    return counts;
  }
  int getJournalsThisMonthCount() {
    var count = 0;
    for (final n in getMarkedDayCounts().values) {
      count += n;
    }
    return count;
  }
  void onCalendarDaySelected(int day) {
    if (selectedCalendarDay.value == day) {
      selectedCalendarDay.value = -1;
      calendarDayJournals.clear();
      return;
    }
    selectedCalendarDay.value = day;
    calendarDayJournals.assignAll(_journalsOnDay(day));
  }
  String get calendarMonthTitle {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[calendarMonth.value - 1]} ${calendarYear.value}';
  }
  int get daysInCurrentMonth {
    return DateTime(calendarYear.value, calendarMonth.value + 1, 0).day;
  }
  int get firstWeekdayOfCurrentMonth {
    return DateTime(calendarYear.value, calendarMonth.value, 1).weekday % 7;
  }
  bool isToday(int day) {
    final now = DateTime.now();
    return now.year == calendarYear.value &&
        now.month == calendarMonth.value &&
        now.day == day;
  }
}
class _HomeDeleteDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const _HomeDeleteDialog({required this.onConfirm});
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
              child: const Icon(
                Icons.delete_rounded,
                size: 26,
                color: Color(0xFFD94F4F),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delete this journal?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This will delete the journal and all associated photos. This cannot be undone.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
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
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
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
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
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
class _TemplatesSeeAllSheet extends StatelessWidget {
  final List<TemplateModel> templates;
  final void Function(TemplateModel) onTemplateTap;
  const _TemplatesSeeAllSheet({
    required this.templates,
    required this.onTemplateTap,
  });
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EBE9),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 8.w, 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'All Templates',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close_rounded,
                    size: 22.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h + bottom),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 0.78,
              ),
              itemCount: templates.length,
              itemBuilder: (_, i) {
                final t = templates[i];
                return GestureDetector(
                  onTap: () => onTemplateTap(t),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          t.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: const Color(0xFFD8E8E2)),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Color(0xC7000000), Colors.transparent],
                              ),
                            ),
                            padding: EdgeInsets.fromLTRB(
                              10.w,
                              36.h,
                              10.w,
                              10.h,
                            ),
                            child: Text(
                              t.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
