import 'package:get/get.dart';
import '../ledger_home/ledger_home_logic.dart';
import '../ledger_settings/ledger_settings_logic.dart';
class LedgerTabLogic extends GetxController {
  final currentIndex = 0.obs;
  void onTabTap(int index) {
    if (index == 1) {
      Get.toNamed('/journey/edit')?.then((_) {
        if (Get.isRegistered<LedgerHomeLogic>()) {
          Get.find<LedgerHomeLogic>().loadJourneys();
        }
      });
      return;
    }
    currentIndex.value = index == 2 ? 1 : 0;
    if (currentIndex.value == 1 && Get.isRegistered<LedgerSettingsLogic>()) {
      Get.find<LedgerSettingsLogic>().loadStorageStats();
    }
  }
}
