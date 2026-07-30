import 'package:get/get.dart';

import 'ledger_record_logic.dart';

class LedgerRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      LedgerRecordLogic(),
      permanent: true,
    );
  }
}
