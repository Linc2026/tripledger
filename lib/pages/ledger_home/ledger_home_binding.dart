import 'package:get/get.dart';
import 'ledger_home_logic.dart';
class LedgerHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LedgerHomeLogic>(() => LedgerHomeLogic());
  }
}
