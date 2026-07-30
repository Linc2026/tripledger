import 'package:get/get.dart';
import 'ledger_settings_logic.dart';
class LedgerSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LedgerSettingsLogic>(() => LedgerSettingsLogic());
  }
}
