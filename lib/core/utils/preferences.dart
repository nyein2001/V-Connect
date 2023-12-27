import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/vpn_config.dart';

class Preferences {
  final SharedPreferences shared;

  static late SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static void _setValue<T>(String key, T value) {
    if (value is String) {
      _preferences.setString(key, value);
    } else if (value is double) {
      _preferences.setDouble(key, value);
    } else if (value is bool) {
      _preferences.setBool(key, value);
    } else if (value is int) {
      _preferences.setInt(key, value);
    }
  }

  static T? _getValue<T>(String key) {
    return _preferences.containsKey(key) ? _preferences.get(key) as T? : null;
  }

  Preferences(this.shared);

  set token(String? value) => shared.setString("token", value!);

  String? get token => shared.getString("token");

  static Future<Preferences> instance() =>
      SharedPreferences.getInstance().then((value) => Preferences(value));

  void saveServers({required List<VpnConfig> value}) {
    shared.setString(
        "server_cache", jsonEncode(value.map((e) => e.toJson()).toList()));
  }

  void setServer(VpnConfig? value) {
    if (value == null) {
      shared.remove("server");
      return;
    }
    shared.setString("server", jsonEncode(value.toJson()));
  }

  VpnConfig? getServer() {
    final server = shared.getString("server");
    if (server != null) {
      return VpnConfig.fromJson(jsonDecode(server));
    }
    return null;
  }

  List<VpnConfig> loadServers() {
    var data = shared.getString("server_cache");
    if (data != null) {
      return (jsonDecode(data) as List)
          .map((e) => VpnConfig.fromJson(e))
          .toList();
    }
    return [];
  }

  static const String profileIdKey = 'profileIdKey';
  static void setProfileId({required String profileId}) {
    _setValue<String>(profileIdKey, profileId);
  }

  static String getProfileId() {
    return _getValue<String>(profileIdKey) ?? '';
  }

  static const String nameKey = 'nameKey';
  static void setName({required String name}) {
    _setValue<String>(nameKey, name);
  }

  static String getName() {
    return _getValue<String>(nameKey) ?? '';
  }

  static const String emailKey = 'emailKey';
  static void setEmail({required String email}) {
    _setValue<String>(emailKey, email);
  }

  static String getEmail() {
    return _getValue<String>(emailKey) ?? '';
  }

  static const String passwordKey = 'passwordKey';
  static void setPassword({required String password}) {
    _setValue<String>(passwordKey, password);
  }

  static String getPassword() {
    return _getValue<String>(passwordKey) ?? '';
  }

  static const String isCheckKey = 'isCheckKey';
  static void setCheck({required bool isCheck}) {
    _setValue<bool>(isCheckKey, isCheck);
  }

  static bool isCheck() {
    return _getValue<bool>(isCheckKey) ?? false;
  }

  static const String isLoginKey = 'isLoginKey';
  static void setLogin({required bool isLogin}) {
    _setValue<bool>(isLoginKey, isLogin);
  }

  static bool isLogin() {
    return _getValue<bool>(isLoginKey) ?? false;
  }

  static const String isVerificationKey = 'isVerificationKey';
  static void setVerification({required bool isVerification}) {
    _setValue<bool>(isVerificationKey, isVerification);
  }

  static bool isVerification() {
    return _getValue<bool>(isVerificationKey) ?? false;
  }

  static const String showLoginKey = 'showLoginKey';
  static void setShowLogin({required bool showLogin}) {
    _setValue<bool>(showLoginKey, showLogin);
  }

  static bool showLogin() {
    return _getValue<bool>(showLoginKey) ?? false;
  }
}
