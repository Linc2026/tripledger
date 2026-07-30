import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../models/journey_entity.dart';
import '../../models/template_block.dart';
import '../../models/template_model.dart';
import 'ledger_detail_logic.dart';
class LedgerDetailView extends GetView<LedgerDetailLogic> {
  const LedgerDetailView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Obx(() {
        if (controller.isTemplate.value) {
          return _buildTemplateDetail(context);
        }
        return _buildJournalDetail(context);
      }),
    );
  }
  Widget _buildLoadError({required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: controller.onBackTap,
            child: const Text(
              'Go Back',
              style: TextStyle(
                color: Color(0xFF1A3C34),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildJournalDetail(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final journal = controller.journey.value;
      if (journal == null) {
        return _buildLoadError(message: 'Failed to load journal');
      }
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildCover(
              context: context,
              title: journal.title,
              coverPath: journal.coverImagePath,
              imageUrl: null,
              isTemplate: false,
            ),
            _buildJournalContent(journal),
          ],
        ),
      );
    });
  }
  Widget _buildTemplateDetail(BuildContext context) {
    return Obx(() {
      final tmpl = controller.template.value;
      if (tmpl == null) {
        return _buildLoadError(message: 'Failed to load template');
      }
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildCover(
              context: context,
              title: tmpl.title,
              coverPath: null,
              imageUrl: tmpl.imageUrl,
              isTemplate: true,
            ),
            _buildTemplateContent(tmpl),
          ],
        ),
      );
    });
  }
  Widget _buildCoverImage({String? coverPath, String? imageUrl}) {
    if (coverPath != null && coverPath.isNotEmpty) {
      return FutureBuilder<String>(
        future: controller.resolvePhotoPath(coverPath),
        builder: (_, snap) {
          if (snap.hasData && File(snap.data!).existsSync()) {
            return Image.file(File(snap.data!), fit: BoxFit.cover);
          }
          return _buildPlaceholderGradient();
        },
      );
    }
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _a, _b) => _buildPlaceholderGradient(),
      );
    }
    return _buildPlaceholderGradient();
  }
  Widget _buildPlaceholderGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A3C34), Color(0xFF2D5A4E)],
        ),
      ),
    );
  }
  Widget _buildCover({
    required BuildContext context,
    required String title,
    required String? coverPath,
    required String? imageUrl,
    required bool isTemplate,
  }) {
    final canTapCover =
        !isTemplate && coverPath != null && coverPath.isNotEmpty;
    return SizedBox(
      height: 260.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: canTapCover ? controller.onCoverTap : null,
            child: _buildCoverImage(coverPath: coverPath, imageUrl: imageUrl),
          ),
          IgnorePointer(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x6B000000),
                    Colors.transparent,
                    Color(0xB8000000),
                  ],
                  stops: [0.0, 0.38, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIconButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: controller.onBackTap,
                    ),
                    if (isTemplate)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9A84C).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.bookmark_rounded,
                              color: Colors.white,
                              size: 12.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'TEMPLATE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18.w, 24.h, 18.w, 18.h),
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.35),
        ),
        child: Icon(icon, color: Colors.white, size: 16.sp),
      ),
    );
  }
  Widget _buildJournalContent(JourneyEntity journal) {
    final hasMeta =
        journal.tripStartDate != null ||
        (journal.tags != null && journal.tags!.isNotEmpty) ||
        journal.tripSpend != null;
    final anniversary = controller.anniversaryBannerText;
    final fillGaps = controller.fillGapsBannerText;
    return Container(
      color: const Color(0xFFFAFAFA),
      padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (anniversary != null) ...[
            _buildAnniversaryBanner(anniversary),
            SizedBox(height: 14.h),
          ],
          if (fillGaps != null) ...[
            _buildFillGapsBanner(fillGaps),
            SizedBox(height: 14.h),
          ],
          if (hasMeta) ...[
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                if (journal.tripStartDate != null)
                  _buildChip(
                    icon: Icons.calendar_month_rounded,
                    text: _buildTripDateStr(journal),
                    bgColor: const Color(0xFFF2F5F3),
                    textColor: const Color(0xFF1A3C34),
                  ),
                if (controller.tripDaysLabel.isNotEmpty)
                  _buildChip(
                    icon: Icons.access_time_rounded,
                    text: controller.tripDaysLabel,
                    bgColor: const Color(0xFFF7EFDA),
                    textColor: const Color(0xFFA88A2E),
                  ),
                if (journal.tags != null && journal.tags!.isNotEmpty)
                  _buildChip(
                    icon: Icons.mood_rounded,
                    text: journal.tags!,
                    bgColor: const Color(0xFFF2F5F3),
                    textColor: const Color(0xFF1A3C34),
                  ),
                if (journal.tripSpend != null)
                  _buildChip(
                    icon: Icons.attach_money_rounded,
                    text: '\$${journal.tripSpend!.toStringAsFixed(2)}',
                    bgColor: const Color(0xFFF2F5F3),
                    textColor: const Color(0xFF1A3C34),
                  ),
              ],
            ),
            SizedBox(height: 14.h),
          ],
          _buildTripPulse(),
          SizedBox(height: 14.h),
          Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                size: 13.sp,
                color: const Color(0xFF9CA3AF),
              ),
              SizedBox(width: 4.w),
              Text(
                'Created ${controller.formatCreatedAt(journal.createdAt)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Container(height: 1, color: const Color(0xFFE8EBE9)),
          SizedBox(height: 18.h),
          if (controller.imageRelativePaths.isNotEmpty) ...[
            _buildPhotoStrip(),
            SizedBox(height: 18.h),
          ],
          _buildStoryBlocks(journal),
          SizedBox(height: 32.h),
          Row(
            children: [
              Expanded(
                child: _buildActionBtn(
                  label: 'Edit',
                  icon: Icons.edit_rounded,
                  bgColor: const Color(0xFFF2F5F3),
                  textColor: const Color(0xFF1A3C34),
                  onTap: controller.onEditTap,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Obx(
                  () => _buildActionBtn(
                    label: controller.isDuplicating.value
                        ? 'Duplicating…'
                        : 'Duplicate',
                    icon: Icons.copy_rounded,
                    bgColor: const Color(0xFFF2F5F3),
                    textColor: const Color(0xFF1A3C34),
                    onTap: controller.isDuplicating.value
                        ? null
                        : controller.onDuplicateTap,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(
            () => _buildActionBtn(
              label: controller.isDeleting.value ? 'Deleting…' : 'Delete',
              icon: Icons.delete_rounded,
              bgColor: const Color(0xFFFEF2F2),
              textColor: const Color(0xFFD94F4F),
              onTap: controller.isDeleting.value
                  ? null
                  : controller.onDeleteTap,
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
  Widget _buildFillGapsBanner(String text) {
    return GestureDetector(
      onTap: controller.onFillGapsTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFF5D0A9)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.edit_note_rounded,
              size: 18.sp,
              color: const Color(0xFFC2410C),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Finish your template',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFC2410C),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: const Color(0xFFC2410C),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildAnniversaryBanner(String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFF7EFDA), Color(0xFFFFF8E8)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE8D5A3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 18.sp,
            color: const Color(0xFFC9A84C),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Relive this trip',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFA88A2E),
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTripPulse() {
    final days = controller.tripDays;
    final photos = controller.photoCount;
    final words = controller.wordCount;
    final perDay = controller.spendPerDayLabel;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5F3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPulseItem(
              label: 'Days',
              value: days != null ? '$days' : '—',
            ),
          ),
          _buildPulseDivider(),
          Expanded(
            child: _buildPulseItem(label: 'Photos', value: '$photos'),
          ),
          _buildPulseDivider(),
          Expanded(
            child: _buildPulseItem(label: 'Words', value: '$words'),
          ),
          _buildPulseDivider(),
          Expanded(
            child: _buildPulseItem(
              label: '\$/day',
              value: perDay != null ? perDay.replaceAll('/day', '') : '—',
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPulseDivider() {
    return Container(width: 1, height: 28.h, color: const Color(0xFFD8E0DC));
  }
  Widget _buildPulseItem({required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A3C34),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
  Widget _buildPhotoStrip() {
    final rels = controller.imageRelativePaths;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.photo_library_rounded,
              size: 15.sp,
              color: const Color(0xFFC9A84C),
            ),
            SizedBox(width: 6.w),
            Text(
              'Photos · ${rels.length}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const Spacer(),
            Text(
              'Tap to jump',
              style: TextStyle(
                fontSize: 11.sp,
                color: const Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 72.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: rels.length,
            separatorBuilder: (_, _) => SizedBox(width: 8.w),
            itemBuilder: (_, index) {
              return GestureDetector(
                onTap: () => controller.onPhotoStripTap(index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: SizedBox(
                    width: 72.w,
                    height: 72.h,
                    child: FutureBuilder<String>(
                      future: controller.resolvePhotoPath(rels[index]),
                      builder: (_, snap) {
                        if (snap.hasData && File(snap.data!).existsSync()) {
                          return Image.file(
                            File(snap.data!),
                            fit: BoxFit.cover,
                          );
                        }
                        return ColoredBox(
                          color: const Color(0xFFD8E8E2),
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: const Color(0xFF9CA3AF),
                            size: 22.sp,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  Widget _buildTemplateContent(TemplateModel tmpl) {
    return Container(
      color: const Color(0xFFFAFAFA),
      padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7EFDA),
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Row(
              children: [
                Icon(
                  Icons.visibility_rounded,
                  size: 16.sp,
                  color: const Color(0xFFC9A84C),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'This is a read-only template. Use it to start your own journal.',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFFA88A2E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          ..._buildTemplateBlocks(tmpl.blocks),
          SizedBox(height: 24.h),
          if (tmpl.suggestedDuration != null || tmpl.estBudget != null)
            Container(height: 1, color: const Color(0xFFE8EBE9)),
          if (tmpl.suggestedDuration != null || tmpl.estBudget != null) ...[
            SizedBox(height: 24.h),
            Row(
              children: [
                if (tmpl.suggestedDuration != null)
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.calendar_month_rounded,
                      iconColor: const Color(0xFF1A3C34),
                      label: 'Suggested Duration',
                      value: tmpl.suggestedDuration!,
                    ),
                  ),
                if (tmpl.suggestedDuration != null && tmpl.estBudget != null)
                  SizedBox(width: 10.w),
                if (tmpl.estBudget != null)
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.attach_money_rounded,
                      iconColor: const Color(0xFFC9A84C),
                      label: 'Est. Budget',
                      value: tmpl.estBudget!,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 24.h),
          ],
          GestureDetector(
            onTap: controller.onUseTemplateTap,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3C34),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A3C34).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_rounded, color: Colors.white, size: 16.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Use This Template',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
  List<Widget> _buildTemplateBlocks(List<TemplateBlock> blocks) {
    final children = <Widget>[];
    for (var i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      if (i > 0) children.add(SizedBox(height: 16.h));
      if (block.isText) {
        children.add(
          Text(
            block.text,
            style: TextStyle(
              fontSize: 15.sp,
              color: const Color(0xFF1A1A1A),
              height: 1.75,
              letterSpacing: 0.1,
            ),
          ),
        );
      } else {
        children.add(_buildTemplateBlockImage(block));
        if (block.text.isNotEmpty) {
          children.add(SizedBox(height: 8.h));
          children.add(
            Text(
              block.text,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF6B7280),
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }
      }
    }
    return children;
  }
  Widget _buildTemplateBlockImage(TemplateBlock block) {
    Widget image;
    if (block.imageAsset != null) {
      image = Image.asset(
        block.imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholderGradient(),
      );
    } else if (block.imageUrl != null) {
      image = Image.network(
        block.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholderGradient(),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return ColoredBox(
            color: const Color(0xFFE8EBE9),
            child: Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: const Color(0xFF1A3C34),
              ),
            ),
          );
        },
      );
    } else {
      image = _buildPlaceholderGradient();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: SizedBox(width: double.infinity, height: 200.h, child: image),
    );
  }
  Widget _buildChip({
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
  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5F3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 18.sp),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  Widget _buildActionBtn({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.sp, color: textColor),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  String _buildTripDateStr(JourneyEntity journal) {
    if (journal.tripStartDate == null) return '';
    final start = journal.tripStartDate!.replaceAll('-', '.');
    if (journal.tripEndDate != null && journal.tripEndDate!.isNotEmpty) {
      final end = journal.tripEndDate!.replaceAll('-', '.');
      return '$start – $end';
    }
    return 'From $start';
  }
  Widget _buildStoryBlocks(JourneyEntity journal) {
    final blocks = journal.resolvedBlocks;
    if (blocks.isEmpty) {
      return Text(
        'No story yet...',
        style: TextStyle(
          fontSize: 15.sp,
          color: const Color(0xFF9CA3AF),
          height: 1.75,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    final children = <Widget>[];
    var photoIdx = 0;
    for (var i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      if (block.isImage) {
        Key? anchorKey;
        if (block.imagePath.isNotEmpty) {
          if (photoIdx < controller.storyImageKeys.length) {
            anchorKey = controller.storyImageKeys[photoIdx];
          }
          photoIdx++;
        }
        children.add(
          KeyedSubtree(
            key: anchorKey ?? ValueKey('story-img-$i'),
            child: GestureDetector(
              onTap: () => controller.onStoryImageTap(i),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: SizedBox(
                  width: double.infinity,
                  height: 160.h,
                  child: FutureBuilder<String>(
                    future: block.imagePath.isEmpty
                        ? Future.value('')
                        : controller.resolvePhotoPath(block.imagePath),
                    builder: (_, snap) {
                      if (snap.hasData &&
                          snap.data!.isNotEmpty &&
                          File(snap.data!).existsSync()) {
                        return Image.file(File(snap.data!), fit: BoxFit.cover);
                      }
                      return ColoredBox(
                        color: const Color(0xFFD8E8E2),
                        child: Icon(
                          Icons.broken_image_rounded,
                          color: const Color(0xFF9CA3AF),
                          size: 32.sp,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
        if (block.text.trim().isNotEmpty) {
          children.add(SizedBox(height: 10.h));
          children.add(
            Text(
              block.text.trim(),
              style: TextStyle(
                fontSize: 15.sp,
                color: const Color(0xFF1A1A1A),
                height: 1.75,
                letterSpacing: 0.1,
              ),
            ),
          );
        }
      } else if (block.text.trim().isNotEmpty) {
        children.add(
          Text(
            block.text.trim(),
            style: TextStyle(
              fontSize: 15.sp,
              color: const Color(0xFF1A1A1A),
              height: 1.75,
              letterSpacing: 0.1,
            ),
          ),
        );
      }
      if (i < blocks.length - 1) {
        children.add(SizedBox(height: 18.h));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
