import 'package:ndvpn/core/utils/constant.dart';

class LoginWithUserid {
  static String sign = AppConstants.sign;
  static String salt = AppConstants.randomSalt.toString();
  static String packageName = AppConstants.packageName;
  static const String methodName = 'user_login';
  final String userid;

  LoginWithUserid({required this.userid});

  Map<String, dynamic> toJson() {
    return {
      'sign': sign,
      'salt': salt,
      'package_name': packageName,
      'method_name': methodName,
      'user_id': userid
    };
  }
}
