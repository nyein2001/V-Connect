// ignore_for_file: library_private_types_in_public_api
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ndvpn/core/models/login_with_userid.dart';
import 'package:ndvpn/core/providers/globals/iap_provider.dart';
import 'package:ndvpn/core/resources/environment.dart';
import 'package:ndvpn/core/utils/config.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';
import 'package:ndvpn/ui/screens/main_screen.dart';
import 'package:ndvpn/ui/screens/verify_screen/verification_screen.dart';
import 'core/providers/globals/ads_provider.dart';
import 'ui/screens/splash_screen.dart';
import 'package:http/http.dart' as http;

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> with WidgetsBindingObserver {
  bool _ready = false;
  AppOpenAd? _appOpenAd;
  Timer? openAdTimeout;
  DateTime _lastShownTime = DateTime.now();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceid = '';

  @override
  void initState() {
    if (Preferences.getDeviceId() == "unknown") {
      if (Platform.isAndroid) {
        deviceInfo.androidInfo.then((AndroidDeviceInfo androidInfo) {
          deviceid = androidInfo.serialNumber;
          Preferences.setDeviceId(deviceid: deviceid);
        });
      } else if (Platform.isIOS) {
        deviceInfo.iosInfo.then((IosDeviceInfo iosInfo) {
          deviceid = iosInfo.identifierForVendor!;
          Preferences.setDeviceId(deviceid: deviceid);
        });
      }
    }
    WidgetsBinding.instance.addObserver(this);
    if (Preferences.showLogin()) {
      Preferences.setShowLogin(showLogin: false);
    }
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      Future.delayed(const Duration(seconds: 5)).then((value) {
        if (!_ready) {
          if (Preferences.isLogin()) {
            loginFun();
          } else {
            setState(() {
              _ready = true;
            });
          }
        }
      });
      await IAPProvider.read(context).initialize().catchError((_) {});
      await loadAppOpenAd()
          .then((value) => _appOpenAd?.showIfNotPro(context))
          .catchError((_) {});
      if (Preferences.isLogin()) {
        loginFun();
      } else {
        setState(() {
          _ready = true;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    openAdTimeout?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_lastShownTime.difference(DateTime.now()).inMinutes > 5) {
        _appOpenAd?.showIfNotPro(context);
        _lastShownTime = DateTime.now();
      }
    } else if (state == AppLifecycleState.paused) {
      loadAppOpenAd();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return _ready
        ? Preferences.showLogin()
            ? const LoginScreen()
            : Preferences.isVerification()
                ? const VerificationScreen()
                : const MainScreen()
        : const SplashScreen();
  }

  void loginFun() async {
    LoginWithUserid req = LoginWithUserid(userid: Preferences.getProfileId());
    String requestBody = jsonEncode(req.toJson());
    try {
      http.Response response = await http.post(
        Uri.parse(AppConstants.baseURL),
        body: {'data': base64Encode(utf8.encode(requestBody))},
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey(AppConstants.status)) {
          String status = jsonResponse['status'];
          String message = jsonResponse['message'];
          if (status == "-2") {
            alertBox(message, context);
          } else {
            alertBox(message, context);
          }
        } else {
          Map<String, dynamic> data = jsonResponse[AppConstants.tag];
          String success = data['success'];
          String noAds = data["no_ads"];
          String premiumServers = data["premium_servers"];
          String isPremium = data["is_premium"];
          String perks = data["perks"];
          String exp = data["exp"];

          Config.noAds = noAds == "1";
          Config.premiumServersAccess = premiumServers == "1";
          Config.isPremium = isPremium == "1";
          Config.perks = perks;
          Config.expiration = exp;

          if (success == '1') {
            replaceScreen(context, const MainScreen());
          } else {
            Preferences.setLogin(isLogin: false);
            replaceScreen(context, const LoginScreen());
          }
        }
      }
    } catch (e) {
      replaceScreen(context, const MainScreen());
    }
  }

  Future loadAppOpenAd() async {
    openAdTimeout?.cancel();
    return AdsProvider.read(context).loadOpenAd(openAdUnitID).then((value) {
      if (value != null) {
        _appOpenAd = value;
        _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            _appOpenAd!.dispose();
            _appOpenAd = null;
            loadAppOpenAd();
          },
        );
      } else {
        openAdTimeout = Timer(const Duration(minutes: 1), loadAppOpenAd);
      }
      return value;
    });
  }
}
