import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'ledger_photo_logic.dart';
class LedgerPhotoView extends GetView<LedgerPhotoLogic> {
  const LedgerPhotoView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [_buildPageView(), _buildTopBar(context), _buildBottomBar()],
      ),
    );
  }
  Widget _buildPageView() {
    if (controller.photos.isEmpty) {
      return const Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          color: Colors.white54,
          size: 64,
        ),
      );
    }
    return PageView.builder(
      controller: controller.pageController,
      onPageChanged: controller.onPageChanged,
      itemCount: controller.photos.length,
      itemBuilder: (_, index) {
        final path = controller.photos[index];
        final file = File(path);
        return InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Center(
            child: file.existsSync()
                ? Image.file(file, fit: BoxFit.contain)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image_rounded,
                        color: Colors.white54,
                        size: 64.sp,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Image not found',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xB3000000), Colors.transparent],
          ),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SizedBox(height: 4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: controller.onCloseTap,
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),
                  Obx(
                    () => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        controller.pageCounterLabel,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 36.w),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildBottomBar() {
    if (controller.photos.length <= 1) return const SizedBox();
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xA6000000), Colors.transparent],
          ),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 48.h),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              controller.photos.length,
              (i) => Container(
                width: 6.w,
                height: 6.w,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.currentIndex.value == i
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
