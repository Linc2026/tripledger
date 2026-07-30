import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../components/text_field.dart';
import '../../data/writing_scaffolds.dart';
import 'ledger_edit_blocks_view.dart';
import 'ledger_edit_logic.dart';
class LedgerEditView extends GetView<LedgerEditLogic> {
  const LedgerEditView({super.key});
  static const _primary = Color(0xFF1A3C34);
  static const _primaryLight = Color(0xFF2D5A4E);
  static const _surfaceVariant = Color(0xFFF2F5F3);
  static const _secondaryContainer = Color(0xFFF7EFDA);
  static const _secondaryDark = Color(0xFFA88A2E);
  static const _textPrimary = Color(0xFF1A1A1A);
  static const _textSecondary = Color(0xFF6B7280);
  static const _textHint = Color(0xFF9CA3AF);
  static const _divider = Color(0xFFE8EBE9);
  static const _outline = Color(0xFFD1D5DB);
  static const _error = Color(0xFFD94F4F);
  static const _success = Color(0xFF2F9E6A);
  static const _bg = Color(0xFFFAFAFA);
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        controller.onSystemBack();
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            _buildStatusBar(context),
            _buildNavBar(context),
            Expanded(
              child: Obx(
                () => controller.isPreviewMode.value
                    ? _buildPreviewMode()
                    : _buildEditMode(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildStatusBar(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).padding.top,
      color: Colors.white,
    );
  }
  Widget _buildNavBar(BuildContext context) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: _divider, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: controller.onCancelTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 2.w),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: _error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => Center(
                child: Text(
                  controller.navTitle,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Obx(
                () => _buildNavPill(
                  label: controller.isPreviewMode.value ? 'Edit' : 'Preview',
                  filled: false,
                  onTap: controller.onPreviewToggle,
                ),
              ),
              SizedBox(width: 8.w),
              Obx(() {
                final loading = controller.isLoading.value ||
                    controller.isPreparingTemplate.value;
                return _buildNavPill(
                  label: 'Save',
                  filled: true,
                  loading: loading,
                  onTap: loading ? null : controller.onSaveTap,
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildNavPill({
    required String label,
    required bool filled,
    bool loading = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: filled
              ? (loading ? _primary.withOpacity(0.55) : _primary)
              : Colors.transparent,
          border: filled ? null : Border.all(color: _primary),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: loading
            ? SizedBox(
                width: 14.w,
                height: 14.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: filled ? Colors.white : _primary,
                ),
              ),
      ),
    );
  }
  Widget _buildEditMode(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCoverArea(),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleField(),
                SizedBox(height: 12.h),
                _buildSlotsSection(),
                _buildWritingPrompt(),
                const LedgerEditBlocksSection(),
                SizedBox(height: 12.h),
                _buildMoodSection(),
                SizedBox(height: 12.h),
                _buildSpendSection(),
                SizedBox(height: 12.h),
                _buildTripDatesSection(context),
                SizedBox(height: 12.h),
                _buildProgressMeter(),
                SizedBox(height: 10.h),
                _buildAutoSaveNotice(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCoverArea() {
    return Obx(() {
      final path = controller.coverImagePath.value;
      final hasImage = path.isNotEmpty && File(path).existsSync();
      return GestureDetector(
        onTap: controller.onCoverImageTap,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
          height: 140.h,
          child: _DashedRoundRect(
            radius: 16.r,
            color: hasImage ? Colors.transparent : _outline,
            strokeWidth: hasImage ? 0 : 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned.fill(
                          child: Image.file(File(path), fit: BoxFit.cover),
                        ),
                        Positioned.fill(
                          child: ColoredBox(
                            color: Colors.black.withOpacity(0.32),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Change Cover',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ColoredBox(
                      color: _surfaceVariant,
                      child: SizedBox.expand(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48.w,
                              height: 48.w,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.camera_alt_rounded,
                                size: 22.sp,
                                color: _primary,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'Tap to add cover',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: _textHint,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      );
    });
  }
  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: _textHint,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
  Widget _buildTextAction(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: _surfaceVariant,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12.sp, color: _primary),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: _primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildFieldLabel('TITLE *')),
            _buildTextAction(
              'Suggest',
              Icons.auto_awesome_rounded,
              controller.onSuggestTitleTap,
            ),
          ],
        ),
        Obx(() {
          final hasError = controller.titleError.value;
          final errorBorder = OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: _error, width: 1.5),
          );
          final normalBorder = OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: _divider, width: 1.5),
          );
          final focusedBorder = OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: hasError ? _error : _primary,
              width: 1.5,
            ),
          );
          return TextField(
            controller: controller.titleController,
            maxLength: 50,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Give your journey a title',
              hintStyle: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: _textHint,
              ),
              filled: true,
              fillColor: hasError ? _error.withOpacity(0.04) : Colors.white,
              counterText: '',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
              border: hasError ? errorBorder : normalBorder,
              enabledBorder: hasError ? errorBorder : normalBorder,
              focusedBorder: focusedBorder,
            ),
          );
        }),
      ],
    );
  }
  Widget _buildSlotsSection() {
    return Obx(() {
      final slots = controller.openSlots;
      if (slots.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: _secondaryContainer,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE8D5A3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    size: 15.sp,
                    color: _secondaryDark,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Template slots to fill',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: _secondaryDark,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: slots
                    .map(
                      (slot) => GestureDetector(
                        onTap: () => controller.onFillSlotTap(slot),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: const Color(0xFFE8D5A3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            '{{$slot}}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: _secondaryDark,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      );
    });
  }
  Widget _buildWritingPrompt() {
    return Obx(() {
      final prompt = controller.writingPrompt;
      if (prompt == null) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(12.w, 10.h, 8.w, 10.h),
          decoration: BoxDecoration(
            color: _surfaceVariant,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFD8E8E2)),
          ),
          child: Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 15.sp,
                  color: _primary,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  prompt,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _primary,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: controller.onInsertPromptTap,
                child: Container(
                  margin: EdgeInsets.only(right: 4.w),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Insert',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: controller.onDismissPrompt,
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16.sp,
                    color: _textHint,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
  Widget _buildSpendSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('TRIP SPEND (USD)'),
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _divider, width: 1.5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: MyTextField(
              value: controller.tripSpend.value,
              onChange: controller.onSpendChanged,
              isNumber: true,
              maxDecimalLength: 2,
              maxValue: 999999,
              maxLength: 10,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              hintText: '0.00',
              prefixIcon: Icons.attach_money_rounded,
              bgColor: Colors.transparent,
              textStyle: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
              padding: EdgeInsets.symmetric(vertical: 10.h),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildMoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('MOOD'),
        Obx(() {
          final selected = controller.selectedMood.value;
          return Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: kMoodOptions.map((mood) {
              final active = selected == mood;
              return GestureDetector(
                onTap: () => controller.onMoodTap(mood),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: active ? _primary : Colors.white,
                    border: Border.all(
                      color: active ? _primary : _divider,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: _primary.withOpacity(0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    mood,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : _textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
  Widget _buildProgressMeter() {
    return Obx(() {
      final items = [
        ('Title', controller.progressHasTitle),
        ('Story', controller.progressHasStory),
        ('Photos', controller.progressHasMedia),
        ('Dates', controller.progressHasDates),
      ];
      final done = controller.progressDoneCount;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: _surfaceVariant,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Journal checklist',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: done == 4 ? const Color(0xFFE8F5EE) : Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '$done / 4',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: done == 4 ? _success : _textHint,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: LinearProgressIndicator(
                value: done / 4,
                minHeight: 7.h,
                backgroundColor: Colors.white,
                color: _primary,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: items.map((item) {
                final ok = item.$2;
                return Expanded(
                  child: Column(
                    children: [
                      Icon(
                        ok
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 18.sp,
                        color: ok ? _success : _outline,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        item.$1,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: ok ? _textPrimary : _textHint,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }
  Widget _buildTripDatesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('TRIP DATES'),
        Column(
          children: [
            _buildDateRow(
              icon: Icons.flight_takeoff_rounded,
              label: 'Departure',
              dateObs: controller.tripStartDate,
              onTap: () => controller.onDepartureDateTap(context),
              onClear: controller.onClearDepartureDate,
            ),
            SizedBox(height: 8.h),
            _buildDateRow(
              icon: Icons.flight_land_rounded,
              label: 'Return',
              dateObs: controller.tripEndDate,
              onTap: () => controller.onReturnDateTap(context),
              onClear: controller.onClearReturnDate,
            ),
          ],
        ),
        Obx(() {
          final label = controller.tripLengthLabel;
          if (label.isEmpty) return const SizedBox.shrink();
          final isPartial = label == 'Start set';
          return Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isPartial ? _surfaceVariant : _secondaryContainer,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 13.sp,
                    color: isPartial ? _primary : _secondaryDark,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isPartial ? _primary : _secondaryDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
  Widget _buildDateRow({
    required IconData icon,
    required String label,
    required RxString dateObs,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _divider, width: 1.5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: _surfaceVariant,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: _primary, size: 15.sp),
                ),
                SizedBox(width: 10.w),
                Text(
                  label,
                  style: TextStyle(fontSize: 14.sp, color: _textSecondary),
                ),
              ],
            ),
            Obx(
              () => Row(
                children: [
                  Text(
                    dateObs.value.isNotEmpty
                        ? dateObs.value.replaceAll('-', '.')
                        : '–',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: dateObs.value.isNotEmpty
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: dateObs.value.isNotEmpty
                          ? _textPrimary
                          : _textHint,
                    ),
                  ),
                  if (dateObs.value.isNotEmpty) ...[
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: onClear,
                      child: Icon(
                        Icons.cancel_rounded,
                        size: 14.sp,
                        color: _textHint,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildAutoSaveNotice() {
    return Obx(() {
      if (controller.isEditMode.value) return const SizedBox.shrink();
      final justSaved = controller.draftJustSaved.value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: justSaved ? const Color(0xFFE8F5EE) : _surfaceVariant,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Icon(
              justSaved
                  ? Icons.check_circle_rounded
                  : Icons.cloud_done_outlined,
              size: 14.sp,
              color: _success,
            ),
            SizedBox(width: 6.w),
            Text(
              justSaved ? 'Saved just now' : 'Draft saved automatically',
              style: TextStyle(fontSize: 12.sp, color: _textSecondary),
            ),
          ],
        ),
      );
    });
  }
  Widget _buildPreviewMode() {
    return ColoredBox(
      color: _bg,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildPreviewCover(),
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final hasDates = controller.tripStartDate.value.isNotEmpty;
                    final mood = controller.selectedMood.value;
                    final spend = controller.tripSpend.value.trim();
                    if (!hasDates && mood.isEmpty && spend.isEmpty) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          if (hasDates)
                            _buildPreviewChip(
                              icon: Icons.calendar_month_rounded,
                              text: _buildPreviewDateStr(),
                              bgColor: _surfaceVariant,
                              textColor: _primary,
                            ),
                          if (controller.tripEndDate.value.isNotEmpty)
                            _buildPreviewChip(
                              icon: Icons.access_time_rounded,
                              text: _calcPreviewDays(),
                              bgColor: _secondaryContainer,
                              textColor: _secondaryDark,
                            ),
                          if (mood.isNotEmpty)
                            _buildPreviewChip(
                              icon: Icons.mood_rounded,
                              text: mood,
                              bgColor: _surfaceVariant,
                              textColor: _primary,
                            ),
                          if (spend.isNotEmpty)
                            _buildPreviewChip(
                              icon: Icons.attach_money_rounded,
                              text: '\$$spend',
                              bgColor: _surfaceVariant,
                              textColor: _primary,
                            ),
                        ],
                      ),
                    );
                  }),
                  const LedgerEditBlocksPreview(),
                  SizedBox(height: 28.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPreviewCover() {
    return Obx(() {
      final coverPath = controller.coverImagePath.value;
      final hasImage = coverPath.isNotEmpty && File(coverPath).existsSync();
      return SizedBox(
        height: 240.h,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            hasImage
                ? Image.file(File(coverPath), fit: BoxFit.cover)
                : const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_primary, _primaryLight],
                      ),
                    ),
                  ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x33000000),
                    Colors.transparent,
                    Color(0xB3000000),
                  ],
                  stops: [0.0, 0.35, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(18.w, 24.h, 18.w, 18.h),
                child: Obx(() {
                  final title = controller.titleText.value.trim();
                  return Text(
                    title.isEmpty ? 'Your Journal Title' : title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      );
    });
  }
  Widget _buildPreviewChip({
    required IconData icon,
    required String text,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: textColor),
          SizedBox(width: 5.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
  String _buildPreviewDateStr() {
    final start = controller.tripStartDate.value.replaceAll('-', '.');
    if (controller.tripEndDate.value.isNotEmpty) {
      final end = controller.tripEndDate.value.replaceAll('-', '.');
      return '$start – $end';
    }
    return start;
  }
  String _calcPreviewDays() {
    try {
      final s = DateTime.parse(controller.tripStartDate.value);
      final e = DateTime.parse(controller.tripEndDate.value);
      final diff = e.difference(s).inDays + 1;
      return '$diff days';
    } catch (_) {
      return '';
    }
  }
}
class _DashedRoundRect extends StatelessWidget {
  final Widget child;
  final double radius;
  final Color color;
  final double strokeWidth;
  const _DashedRoundRect({
    required this.child,
    required this.radius,
    required this.color,
    this.strokeWidth = 1.5,
  });
  @override
  Widget build(BuildContext context) {
    final clipped = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: child,
    );
    if (strokeWidth <= 0 || color == Colors.transparent) {
      return sized(clipped);
    }
    return sized(
      CustomPaint(
        foregroundPainter: _DashedRRectPainter(
          radius: radius,
          color: color,
          strokeWidth: strokeWidth,
        ),
        child: clipped,
      ),
    );
  }
  Widget sized(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth =
            constraints.hasBoundedWidth &&
            constraints.maxWidth < double.infinity;
        final hasBoundedHeight =
            constraints.hasBoundedHeight &&
            constraints.maxHeight < double.infinity;
        return SizedBox(
          width: hasBoundedWidth ? constraints.maxWidth : null,
          height: hasBoundedHeight ? constraints.maxHeight : null,
          child: child,
        );
      },
    );
  }
}
class _DashedRRectPainter extends CustomPainter {
  final double radius;
  final Color color;
  final double strokeWidth;
  _DashedRRectPainter({
    required this.radius,
    required this.color,
    required this.strokeWidth,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final dashed = _dashPath(path, dashLength: 5, gapLength: 4);
    canvas.drawPath(dashed, paint);
  }
  Path _dashPath(
    Path source, {
    required double dashLength,
    required double gapLength,
  }) {
    final metrics = source.computeMetrics();
    final dashed = Path();
    for (final metric in metrics) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final len = draw ? dashLength : gapLength;
        if (draw) {
          dashed.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dashed;
  }
  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
