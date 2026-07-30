import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'ledger_edit_logic.dart';
class LedgerEditBlocksSection extends GetView<LedgerEditLogic> {
  const LedgerEditBlocksSection({super.key});
  static const _primary = Color(0xFF1A3C34);
  static const _surfaceVariant = Color(0xFFF2F5F3);
  static const _textPrimary = Color(0xFF1A1A1A);
  static const _textSecondary = Color(0xFF6B7280);
  static const _textHint = Color(0xFF9CA3AF);
  static const _divider = Color(0xFFE8EBE9);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('STORY',
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _textHint,
                      letterSpacing: 0.6)),
            ),
            GestureDetector(
              onTap: controller.onOutlineTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: _surfaceVariant,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.view_agenda_outlined,
                        size: 12.sp, color: _primary),
                    SizedBox(width: 4.w),
                    Text('Outline',
                        style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: _primary)),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Obx(() {
          final blocks = controller.storyBlocks;
          return Column(
            children: [
              for (var i = 0; i < blocks.length; i++) ...[
                _buildBlockCard(i),
                if (i < blocks.length - 1) SizedBox(height: 12.h),
              ],
            ],
          );
        }),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildAddBtn(
                icon: Icons.notes_rounded,
                label: 'Add Text',
                onTap: controller.onAddTextSectionTap,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Obx(() => _buildAddBtn(
                    icon: Icons.add_photo_alternate_outlined,
                    label: 'Add Photo (${controller.imageCount}/9)',
                    onTap: controller.onAddImageSectionTap,
                  )),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Obx(() => Align(
              alignment: Alignment.centerRight,
              child: Text(
                  '${controller.contentLength.value} / ${LedgerEditLogic.maxStoryLength}',
                  style: TextStyle(fontSize: 11.sp, color: _textHint)),
            )),
        Obx(() {
          final tip = controller.datePhotoTip;
          if (tip.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(tip,
                style: TextStyle(
                    fontSize: 11.sp, color: _textHint, height: 1.35)),
          );
        }),
      ],
    );
  }
  Widget _buildAddBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 9.h),
        decoration: BoxDecoration(
          color: _surfaceVariant,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15.sp, color: _textSecondary),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildBlockCard(int index) {
    final block = controller.storyBlocks[index];
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _divider, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10.w, 8.h, 6.w, 0),
            child: Row(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: _surfaceVariant,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    block.isImage ? 'Photo + Text' : 'Text',
                    style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: _primary),
                  ),
                ),
                const Spacer(),
                if (index > 0)
                  _iconBtn(Icons.keyboard_arrow_up_rounded,
                      () => controller.onMoveBlockUp(index)),
                if (index < controller.storyBlocks.length - 1)
                  _iconBtn(Icons.keyboard_arrow_down_rounded,
                      () => controller.onMoveBlockDown(index)),
                if (block.isImage)
                  _iconBtn(Icons.image_rounded,
                      () => controller.onSetBlockAsCover(index)),
                _iconBtn(Icons.close_rounded,
                    () => controller.onRemoveBlock(index)),
              ],
            ),
          ),
          if (block.isImage) ...[
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () => controller.onChangeBlockImage(index),
              child: Obx(() {
                final path = block.imagePath.value;
                final exists = path.isNotEmpty && File(path).existsSync();
                final isCover = path.isNotEmpty &&
                    path == controller.coverImagePath.value;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  height: 140.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _surfaceVariant,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      exists
                          ? Image.file(File(path), fit: BoxFit.cover)
                          : Center(
                              child: Text('Tap to add photo',
                                  style: TextStyle(
                                      fontSize: 13.sp, color: _textHint)),
                            ),
                      if (exists)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            color: Colors.black38,
                            child: Center(
                              child: Text('Tap to change photo',
                                  style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ),
                          ),
                        ),
                      if (isCover)
                        Positioned(
                          left: 8,
                          top: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: _primary,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text('Cover',
                                style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
          Padding(
            padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
            child: TextField(
              controller: block.textController,
              maxLines: null,
              minLines: block.isImage ? 2 : 3,
              style: TextStyle(
                  fontSize: 14.sp, color: _textPrimary, height: 1.6),
              decoration: InputDecoration(
                hintText: block.isImage
                    ? 'Write about this photo...'
                    : 'Write your story here...',
                hintStyle: TextStyle(fontSize: 14.sp, color: _textHint),
                filled: true,
                fillColor: _surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Icon(icon, size: 18.sp, color: _textHint),
      ),
    );
  }
}
class LedgerEditBlocksPreview extends GetView<LedgerEditLogic> {
  const LedgerEditBlocksPreview({super.key});
  static const _textPrimary = Color(0xFF1A1A1A);
  static const _textHint = Color(0xFF9CA3AF);
  static const _textSecondary = Color(0xFF6B7280);
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final blocks = controller.previewBlocks();
      if (blocks.isEmpty) {
        return Text(
          'No story yet...',
          style: TextStyle(
              fontSize: 15.sp,
              color: _textHint,
              height: 1.75,
              fontStyle: FontStyle.italic),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < blocks.length; i++) ...[
            if (blocks[i].isImage) ...[
              _buildImage(blocks[i].imagePath),
              if (blocks[i].text.trim().isNotEmpty) ...[
                SizedBox(height: 10.h),
                Text(
                  blocks[i].text.trim(),
                  style: TextStyle(
                      fontSize: 15.sp, color: _textPrimary, height: 1.75),
                ),
              ],
            ] else if (blocks[i].text.trim().isNotEmpty)
              Text(
                blocks[i].text.trim(),
                style: TextStyle(
                    fontSize: 15.sp, color: _textPrimary, height: 1.75),
              ),
            if (i < blocks.length - 1) SizedBox(height: 18.h),
          ],
        ],
      );
    });
  }
  Widget _buildImage(String path) {
    final exists = path.isNotEmpty && File(path).existsSync();
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: SizedBox(
        width: double.infinity,
        height: 160.h,
        child: exists
            ? Image.file(File(path), fit: BoxFit.cover)
            : ColoredBox(
                color: const Color(0xFFD8E8E2),
                child: Icon(Icons.broken_image_rounded,
                    color: _textSecondary, size: 28.sp),
              ),
      ),
    );
  }
}
