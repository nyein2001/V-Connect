import 'package:ndvpn/core/utils/constant.dart';

class UserProfileReq {
  static String sign = AppConstants.sign;
  static String salt = AppConstants.randomSalt.toString();
  static String packageName = AppConstants.packageName;
  static String methodName = 'user_profile';
  final String userId;

  UserProfileReq({
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'sign': sign,
      'salt': salt,
      'package_name': packageName,
      'method_name': methodName,
      'user_id': userId,
    };
  }
}
