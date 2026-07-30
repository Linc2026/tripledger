import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../db/ledger_db.dart';
import '../../models/content_block.dart';
import '../../utils/index.dart';
import '../ledger_home/ledger_home_logic.dart';
class LedgerSettingsLogic extends GetxController {
  static const appVersionLabel = 'v1.0.0';
  final journalCount = 0.obs;
  final photoCount = 0.obs;
  final storageMB = 0.0.obs;
  final isClearing = false.obs;
  final _db = Get.find<LedgerDB>();
  static const _draftKeys = [
    'draft_title',
    'draft_content',
    'draft_cover',
    'draft_photos',
    'draft_trip_start',
    'draft_trip_end',
    'draft_mood',
    'draft_spend',
    'draft_captions',
    'draft_body_blocks',
  ];
  @override
  void onInit() {
    super.onInit();
    loadStorageStats();
  }
  Future<void> loadStorageStats() async {
    try {
      final journals = await _db.getJourneys();
      journalCount.value = journals.length;
      var photos = 0;
      for (final j in journals) {
        final fromBlocks =
            ContentBlock.imagePaths(j.resolvedBlocks).toSet();
        photos += fromBlocks.length;
        final cover = j.coverImagePath;
        if (cover != null &&
            cover.isNotEmpty &&
            !fromBlocks.contains(cover)) {
          photos += 1;
        }
      }
      photoCount.value = photos;
      final dir = Directory(await _db.getPhotosDirectory());
      var totalBytes = 0.0;
      if (await dir.exists()) {
        await for (final entity in dir.list(recursive: true)) {
          if (entity is File) {
            try {
              totalBytes += await entity.length();
            } catch (_) {}
          }
        }
      }
      storageMB.value = totalBytes / (1024 * 1024);
    } catch (_) {
      errorToast('Failed to load storage info');
    }
  }
  void onClearAllTap() {
    if (isClearing.value) return;
    Get.dialog(
      _ClearDialog(onConfirm: _clearAllData),
    );
  }
  Future<void> _clearAllData() async {
    if (isClearing.value) return;
    isClearing.value = true;
    try {
      await _db.clearJourneys();
      await _clearDrafts();
      await loadStorageStats();
      if (Get.isRegistered<LedgerHomeLogic>()) {
        await Get.find<LedgerHomeLogic>().loadJourneys();
      }
      successToast('All journals deleted');
    } catch (_) {
      errorToast('Failed to clear data, please try again');
    } finally {
      isClearing.value = false;
    }
  }
  Future<void> _clearDrafts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final key in _draftKeys) {
        await prefs.remove(key);
      }
    } catch (_) {
    }
  }
}
class _ClearDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const _ClearDialog({required this.onConfirm});
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
              child: const Icon(Icons.warning_rounded,
                  size: 26, color: Color(0xFFD94F4F)),
            ),
            const SizedBox(height: 16),
            const Text('Clear All Data?',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A))),
            const SizedBox(height: 8),
            const Text(
                'This will delete all your journals, photos, and unsaved drafts. This cannot be undone.',
                style: TextStyle(
                    fontSize: 14, color: Color(0xFF6B7280), height: 1.55),
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
                        child: Text('Delete All',
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
