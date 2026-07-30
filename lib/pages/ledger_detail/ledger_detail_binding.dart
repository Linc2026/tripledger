import 'package:get/get.dart';
import 'ledger_detail_logic.dart';
class LedgerDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LedgerDetailLogic>(() => LedgerDetailLogic());
  }
}
