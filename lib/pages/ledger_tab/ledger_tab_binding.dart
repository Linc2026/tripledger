import 'package:get/get.dart';
import 'ledger_tab_logic.dart';
import '../ledger_home/ledger_home_logic.dart';
import '../ledger_settings/ledger_settings_logic.dart';
class LedgerTabBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LedgerTabLogic>(() => LedgerTabLogic());
    Get.lazyPut<LedgerHomeLogic>(() => LedgerHomeLogic());
    Get.lazyPut<LedgerSettingsLogic>(() => LedgerSettingsLogic());
  }
}
