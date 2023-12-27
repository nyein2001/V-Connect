import 'package:ndvpn/core/utils/constant.dart';

class UserLoginReq {
  static String sign = AppConstants.sign;
  static String salt = AppConstants.randomSalt.toString();
  static String packageName = AppConstants.packageName;
  static const String methodName = 'user_login';
  static const String playerId = '123';
  final String email;
  final String password;

  UserLoginReq({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'sign': sign,
      'salt': salt,
      'package_name': packageName,
      'method_name': methodName,
      'email': email,
      'password': password,
      'player_id': playerId
    };
  }
}
