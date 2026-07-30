import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../models/template_model.dart';
import '../../models/journey_entity.dart';
import '../../utils/index.dart';
import '../ledger_tab/ledger_tab_view.dart';
import 'ledger_home_logic.dart';
class LedgerHomeView extends GetView<LedgerHomeLogic> {
  const LedgerHomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFAFAFA),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF1A3C34),
              onRefresh: controller.onRefreshTap,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(child: _buildTemplateSection()),
                  Obx(() {
                    if (!controller.isLoading.value ||
                        controller.journeys.isNotEmpty) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1A3C34),
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    );
                  }),
                  Obx(() {
                    if (controller.journeys.isEmpty) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                    return SliverToBoxAdapter(child: _buildTripSnapshot());
                  }),
                  SliverToBoxAdapter(
                    child: Container(
                      height: 1,
                      color: const Color(0xFFE8EBE9),
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildMyJournalsHeader()),
                  Obx(() {
                    final show = controller.showDraftCard;
                    final _ = controller.draftTitle.value;
                    if (!show) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                    return SliverToBoxAdapter(child: _buildDraftCard());
                  }),
                  Obx(() {
                    final isList = controller.viewMode.value == 'list';
                    final isEmpty =
                        isList && controller.filteredJourneys.isEmpty;
                    controller.selectedMoodFilters.length;
                    controller.filterHasSpend.value;
                    return SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildSearchBar(),
                          if (isList && controller.journeys.isNotEmpty)
                            _buildFilterChips(),
                          if (!isEmpty)
                            isList ? _buildListView() : _buildCalendarView(),
                        ],
                      ),
                    );
                  }),
                  Obx(() {
                    final isEmpty =
                        controller.viewMode.value == 'list' &&
                        controller.filteredJourneys.isEmpty;
                    final tabInset = LedgerTabView.tabOverlayInset(context);
                    if (isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: tabInset),
                          child: Center(child: _buildListEmptyState()),
                        ),
                      );
                    }
                    return SliverToBoxAdapter(
                      child: SizedBox(height: tabInset),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTemplateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Explore Templates',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              GestureDetector(
                onTap: controller.onSeeAllTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
                  child: Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFC9A84C),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            itemCount: controller.templates.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (_, i) => _buildTemplateCard(controller.templates[i]),
          ),
        ),
      ],
    );
  }
  Widget _buildTemplateCard(TemplateModel template) {
    return GestureDetector(
      onTap: () => controller.onTemplateTap(template),
      child: Container(
        width: 144.w,
        height: 180.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                template.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _buildGradientPlaceholder(template.id),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xC7000000), Colors.transparent],
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(10.w, 48.h, 10.w, 10.h),
                  child: Text(
                    template.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildGradientPlaceholder(int id) {
    final colors = [
      [const Color(0xFF1A3C34), const Color(0xFF2D5A4E)],
      [const Color(0xFF4A1942), const Color(0xFF7B2D6E)],
      [const Color(0xFF1A2F4A), const Color(0xFF2E5380)],
      [const Color(0xFF4A3000), const Color(0xFF7A5200)],
      [const Color(0xFF2E1A4A), const Color(0xFF512E7A)],
    ];
    final pair = colors[id % colors.length];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: pair,
        ),
      ),
    );
  }
  Widget _buildTripSnapshot() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1A3C34),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.insights_rounded,
              size: 18.sp,
              color: const Color(0xFFC9A84C),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trip Snapshot',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    controller.snapshotLabel,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildDraftCard() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Material(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: controller.onResumeDraftTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 8.w, 12.h),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9A84C).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
                    size: 20.sp,
                    color: const Color(0xFF8A6A1A),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resume draft',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        controller.draftTitle.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Resume',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC9A84C),
                  ),
                ),
                IconButton(
                  onPressed: controller.onDraftDismiss,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildFilterChips() {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: SizedBox(
        height: 32.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          children: [
            ...controller.moodOptions.map((mood) {
              final active = controller.selectedMoodFilters.contains(mood);
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _buildFilterChip(
                  label: mood,
                  active: active,
                  onTap: () => controller.onMoodFilterTap(mood),
                ),
              );
            }),
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: _buildFilterChip(
                label: 'Has spend',
                active: controller.filterHasSpend.value,
                onTap: controller.onHasSpendFilterTap,
              ),
            ),
            if (controller.hasActiveFilters)
              _buildFilterChip(
                label: 'Clear',
                active: false,
                onTap: controller.onClearFiltersTap,
                isClear: true,
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildFilterChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
    bool isClear = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isClear
              ? Colors.transparent
              : active
              ? const Color(0xFF1A3C34)
              : const Color(0xFFF2F5F3),
          borderRadius: BorderRadius.circular(20.r),
          border: isClear ? Border.all(color: const Color(0xFFE8EBE9)) : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
            height: 1.0,
            fontWeight: FontWeight.w600,
            color: isClear
                ? const Color(0xFF6B7280)
                : active
                ? Colors.white
                : const Color(0xFF1A1A1A),
          ),
        ),
      ),
    );
  }
  Widget _buildMyJournalsHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Journals',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          Row(
            children: [
              _buildViewToggle(),
              SizedBox(width: 8.w),
              _buildAddButton(),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildListEmptyState() {
    if (controller.searchKeyword.value.isNotEmpty ||
        controller.hasActiveFilters) {
      return _buildSearchEmpty();
    }
    return _buildJournalsEmpty();
  }
  Widget _buildViewToggle() {
    return Obx(() {
      final isList = controller.viewMode.value == 'list';
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F5F3),
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.all(2.w),
        child: Row(
          children: [
            _buildToggleBtn(
              isList,
              Icons.format_list_bulleted_rounded,
              () => isList ? null : controller.onViewToggle(),
            ),
            SizedBox(width: 2.w),
            _buildToggleBtn(
              !isList,
              Icons.calendar_month_rounded,
              () => !isList ? null : controller.onViewToggle(),
            ),
          ],
        ),
      );
    });
  }
  Widget _buildToggleBtn(bool active, IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1A3C34) : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(
          icon,
          size: 13.sp,
          color: active ? Colors.white : const Color(0xFF6B7280),
        ),
      ),
    );
  }
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: controller.onAddTap,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: const Color(0xFF1A3C34),
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.add, color: Colors.white, size: 15.sp),
      ),
    );
  }
  Widget _buildSearchBar() {
    return Obx(
      () => Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F5F3),
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: 14.sp,
              color: const Color(0xFF9CA3AF),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF1A1A1A),
                ),
                decoration: InputDecoration(
                  hintText: 'Search journals...',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (controller.searchKeyword.value.isNotEmpty)
              GestureDetector(
                onTap: controller.onSearchClear,
                child: Icon(
                  Icons.cancel_rounded,
                  size: 14.sp,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildListView() {
    return Column(
      children: controller.filteredJourneys.map(_buildJournalCard).toList(),
    );
  }
  Widget _buildJournalCard(JourneyEntity journal) {
    final dateStr = _buildDateStr(journal);
    final mood = (journal.tags ?? '').trim();
    final spend = journal.tripSpend;
    return GestureDetector(
      onTap: () => controller.onJournalTap(journal.id!),
      onLongPress: () => controller.onJournalLongPress(journal),
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
        height: 190.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildJournalCoverImage(journal),
              if (mood.isNotEmpty || spend != null)
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: _buildCardInsights(mood, spend),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xD1000000),
                        Color(0x1A000000),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.65, 1.0],
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(16.w, 64.h, 16.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        journal.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 12.sp,
                            color: Colors.white.withOpacity(0.75),
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              dateStr,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildCardInsights(String mood, double? spend) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mood.isNotEmpty) ...[
            Icon(
              Icons.mood_rounded,
              size: 12.sp,
              color: const Color(0xFFC9A84C),
            ),
            SizedBox(width: 4.w),
            Text(
              mood,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (mood.isNotEmpty && spend != null) SizedBox(width: 8.w),
          if (spend != null) ...[
            Text(
              LedgerHomeLogic.formatSpend(spend),
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildJournalCoverImage(JourneyEntity journal) {
    final coverPath = journal.coverImagePath;
    if (coverPath != null && coverPath.isNotEmpty) {
      return FutureBuilder<String>(
        future: controller.resolvePhotoPath(coverPath),
        builder: (_, snap) {
          if (snap.hasData && File(snap.data!).existsSync()) {
            return Image.file(File(snap.data!), fit: BoxFit.cover);
          }
          return Container(color: const Color(0xFFD8E8E2));
        },
      );
    }
    return Container(color: const Color(0xFFD8E8E2));
  }
  String _buildDateStr(JourneyEntity j) {
    if (j.tripStartDate != null && j.tripStartDate!.isNotEmpty) {
      final start = extractDateFromDateTime(
        j.tripStartDate!,
      ).replaceAll('-', '.');
      if (j.tripEndDate != null && j.tripEndDate!.isNotEmpty) {
        final end = extractDateFromDateTime(
          j.tripEndDate!,
        ).replaceAll('-', '.');
        return '$start – $end';
      }
      return start;
    }
    return extractDateFromDateTime(j.createdAt).replaceAll('-', '.');
  }
  Widget _buildJournalsEmpty() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F5F3),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.book_outlined,
              size: 32.sp,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No journals yet.',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Start your first trip!',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
          ),
          SizedBox(height: 24.h),
          GestureDetector(
            onTap: controller.onAddTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3C34),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Create Journal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSearchEmpty() {
    final keyword = controller.searchKeyword.value.trim();
    final message = keyword.isNotEmpty
        ? 'No results for "$keyword"'
        : 'No journals match these filters';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 40.sp,
            color: const Color(0xFF9CA3AF),
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
          if (controller.hasActiveFilters) ...[
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: controller.onClearFiltersTap,
              child: Text(
                'Clear filters',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFC9A84C),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildCalendarView() {
    return Obx(() {
      final dayCounts = controller.getMarkedDayCounts();
      final daysInMonth = controller.daysInCurrentMonth;
      final firstWeekday = controller.firstWeekdayOfCurrentMonth;
      final totalCells = ((daysInMonth + firstWeekday) / 7).ceil() * 7;
      final monthCount = controller.getJournalsThisMonthCount();
      final selected = controller.selectedCalendarDay.value;
      final showPopup = selected > 0;
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFE8EBE9)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A3C34).withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 16.h),
              child: Column(
                children: [
                  _buildCalendarHeader(),
                  SizedBox(height: 14.h),
                  _buildCalendarWeekdays(),
                  SizedBox(height: 6.h),
                  _buildCalendarGrid(
                    totalCells,
                    firstWeekday,
                    daysInMonth,
                    dayCounts,
                  ),
                  SizedBox(height: 14.h),
                  _buildCalendarMonthSummary(monthCount, dayCounts.length),
                ],
              ),
            ),
            if (showPopup) _buildCalendarDayPopup(),
          ],
        ),
      );
    });
  }
  Widget _buildCalendarHeader() {
    return Row(
      children: [
        _buildCalendarNavBtn(
          Icons.chevron_left_rounded,
          controller.onPreviousMonth,
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                controller.calendarMonthTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Tap a day with a trip',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
        _buildCalendarNavBtn(
          Icons.chevron_right_rounded,
          controller.onNextMonth,
        ),
      ],
    );
  }
  Widget _buildCalendarNavBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F5F3),
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 20.sp, color: const Color(0xFF1A3C34)),
      ),
    );
  }
  Widget _buildCalendarWeekdays() {
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F8),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: List.generate(days.length, (i) {
          final isWeekend = i == 0 || i == 6;
          return Expanded(
            child: Center(
              child: Text(
                days[i],
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: isWeekend
                      ? const Color(0xFFC9A84C)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
  Widget _buildCalendarGrid(
    int totalCells,
    int firstWeekday,
    int daysInMonth,
    Map<int, int> dayCounts,
  ) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.92,
        mainAxisSpacing: 4.h,
        crossAxisSpacing: 4.w,
      ),
      itemCount: totalCells,
      itemBuilder: (_, index) {
        final day = index - firstWeekday + 1;
        if (day <= 0 || day > daysInMonth) return const SizedBox();
        final count = dayCounts[day] ?? 0;
        final isMarked = count > 0;
        final isToday = controller.isToday(day);
        final isSelected = controller.selectedCalendarDay.value == day;
        return GestureDetector(
          onTap: () => controller.onCalendarDaySelected(day),
          behavior: HitTestBehavior.opaque,
          child: _buildCalendarDayCell(
            day: day,
            isToday: isToday,
            isSelected: isSelected,
            isMarked: isMarked,
            count: count,
          ),
        );
      },
    );
  }
  Widget _buildCalendarDayCell({
    required int day,
    required bool isToday,
    required bool isSelected,
    required bool isMarked,
    required int count,
  }) {
    Color bg = Colors.transparent;
    Color fg = const Color(0xFF1A1A1A);
    BoxBorder? border;
    List<BoxShadow>? shadows;
    if (isSelected) {
      bg = const Color(0xFFC9A84C);
      fg = Colors.white;
      shadows = [
        BoxShadow(
          color: const Color(0xFFC9A84C).withOpacity(0.35),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    } else if (isToday) {
      bg = const Color(0xFF1A3C34);
      fg = Colors.white;
    } else if (isMarked) {
      bg = const Color(0xFFE8F3EE);
      fg = const Color(0xFF1A3C34);
      border = Border.all(color: const Color(0xFFB8D4C8));
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
        border: border,
        boxShadow: shadows,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$day',
            style: TextStyle(
              fontSize: 13.sp,
              color: fg,
              fontWeight: isMarked || isToday || isSelected
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
          SizedBox(height: 3.h),
          _buildDayDots(count, isSelected || isToday),
        ],
      ),
    );
  }
  Widget _buildDayDots(int count, bool onDark) {
    if (count <= 0) {
      return SizedBox(height: 4.h);
    }
    final shown = count > 3 ? 3 : count;
    final color = onDark
        ? Colors.white.withOpacity(0.9)
        : const Color(0xFFC9A84C);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(shown, (i) {
        return Container(
          width: 4.w,
          height: 4.w,
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
      }),
    );
  }
  Widget _buildCalendarMonthSummary(int journalCount, int activeDays) {
    final journalWord = journalCount == 1 ? 'journal' : 'journals';
    final dayWord = activeDays == 1 ? 'day' : 'days';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3C34), Color(0xFF2D5A4E)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month_rounded,
            size: 16.sp,
            color: const Color(0xFFC9A84C),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '$journalCount $journalWord · $activeDays travel $dayWord',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCalendarDayPopup() {
    return Obx(() {
      final day = controller.selectedCalendarDay.value;
      final journals = controller.calendarDayJournals;
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
      final monthName = months[controller.calendarMonth.value - 1];
      return Container(
        margin: EdgeInsets.only(top: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: const Color(0xFFE8EBE9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A3C34).withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F5F3),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '$monthName $day',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A3C34),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  journals.isEmpty
                      ? 'No journals'
                      : '${journals.length} journal${journals.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            if (journals.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Text(
                  'No trip journals on this day.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              )
            else
              ...journals.map(
                (j) => GestureDetector(
                  onTap: () => controller.onJournalTap(j.id!),
                  onLongPress: () => controller.onJournalLongPress(j),
                  child: Container(
                    margin: EdgeInsets.only(top: 10.h),
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9F8),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: SizedBox(
                            width: 44.w,
                            height: 44.w,
                            child: _buildJournalCoverImage(j),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                j.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                _buildDateStr(j),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18.sp,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
