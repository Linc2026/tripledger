import 'package:flutter/material.dart';
import 'package:get/get.dart';
class LedgerPhotoLogic extends GetxController {
  List<String> photos = [];
  final currentIndex = 0.obs;
  late PageController pageController;
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      photos = List<String>.from(args['photos'] as List? ?? []);
      var initial = args['initialIndex'] as int? ?? 0;
      if (photos.isEmpty) {
        initial = 0;
      } else {
        initial = initial.clamp(0, photos.length - 1);
      }
      currentIndex.value = initial;
      pageController = PageController(initialPage: initial);
    } else {
      pageController = PageController();
    }
  }
  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
  void onPageChanged(int index) {
    currentIndex.value = index;
  }
  void onCloseTap() => Get.back();
  String get pageCounterLabel {
    if (photos.isEmpty) return '0 / 0';
    return '${currentIndex.value + 1} / ${photos.length}';
  }
}
