import 'package:get/get.dart';
import 'ledger_edit_logic.dart';
class LedgerEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LedgerEditLogic>(() => LedgerEditLogic());
  }
}
