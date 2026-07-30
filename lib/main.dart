import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:trip_ledger/pages/ledger_photo/ledger_photo_preview.dart';
import 'package:trip_ledger/pages/ledger_record/ledger_record_binding.dart';
import 'package:trip_ledger/pages/ledger_record/ledger_record_view.dart';
import 'db/ledger_db.dart';
import '../pages/ledger_tab/ledger_tab_binding.dart';
import '../pages/ledger_tab/ledger_tab_view.dart';
import '../pages/ledger_detail/ledger_detail_binding.dart';
import '../pages/ledger_detail/ledger_detail_view.dart';
import '../pages/ledger_edit/ledger_edit_binding.dart';
import '../pages/ledger_edit/ledger_edit_view.dart';
import '../pages/ledger_photo/ledger_photo_binding.dart';
import '../pages/ledger_photo/ledger_photo_view.dart';
const Color primaryColor = Color(0xFF1A3C34);
const Color bgColor = Color(0xFFFAFAFA);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Get.putAsync(() => LedgerDB().init());
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          getPages: TripRecord,
          initialRoute: '/',
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: primaryColor,
            scaffoldBackgroundColor: bgColor,
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              surface: Color(0xFFFFFFFF),
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(size: 22, color: Color(0xFF1A1A1A)),
            ),
          ),
          builder: (context, child) {
            return GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: child,
            );
          },
        );
      },
    );
  }
}
List<GetPage<dynamic>> TripRecord = [
  GetPage(
    name: '/',
    page: () => const LedgerRecordView(),
    binding: LedgerRecordBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/tab',
    page: () => const LedgerTabView(),
    binding: LedgerTabBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/journey/detail',
    page: () => const LedgerDetailView(),
    binding: LedgerDetailBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/journey/edit',
    page: () => const LedgerEditView(),
    binding: LedgerEditBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/photo/view',
    page: () => const LedgerPhotoView(),
    binding: LedgerPhotoBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/photo/preview',
    page: () => const LedgerPhotoPreview(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
];