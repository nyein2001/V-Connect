import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/preferences.dart';

class ReqWithUserId {
  static String sign = AppConstants.sign;
  static String salt = AppConstants.randomSalt.toString();
  static String packageName = AppConstants.packageName;
  static String userId = Preferences.getProfileId();
  final String methodName;

  ReqWithUserId({
    required this.methodName,
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
