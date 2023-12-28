import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class AppConstants {
  static const String baseURL = "https://vpn.truetest.xyz/api.php";
  static const LOGIN_TYPE_GOOGLE = 'google';
  static const USER_NOT_CREATED = "User not created";
  static const tag = "ANDROID_REWARDS_APP";
  static const status = "status";
  static const int serviceConnectionTimeOut = 60;

  static String apiKey = 'dev';
  static int randomSalt = getRandomSalt();
  static String sign = mD5(apiKey + randomSalt.toString());
  static String packageName = 'com.ndvpn.app';

  static int getRandomSalt() {
    Random random = Random();
    return random.nextInt(900);
  }

  static String mD5(String input) {
    var bytes = utf8.encode(input);
    var digest = md5.convert(bytes);
    return digest.toString();
  }
}
