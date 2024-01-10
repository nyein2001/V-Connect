import 'package:ndvpn/core/utils/constant.dart';

class RedeemReq {
  static String sign = AppConstants.sign;
  static String salt = AppConstants.randomSalt.toString();
  static String packageName = AppConstants.packageName;
  final String methodName;
  final String userId;
  final String code;

  RedeemReq(
      {required this.methodName, required this.userId, required this.code});

  Map<String, dynamic> toJson() {
    return {
      'sign': sign,
      'salt': salt,
      'package_name': packageName,
      'method_name': methodName,
      'user_id': userId,
      'code': code
    };
  }
}
