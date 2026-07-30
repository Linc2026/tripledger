import 'package:get/get.dart';
import 'ledger_photo_logic.dart';
class LedgerPhotoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LedgerPhotoLogic>(() => LedgerPhotoLogic());
  }
}
