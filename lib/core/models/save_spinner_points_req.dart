import 'package:ndvpn/core/utils/constant.dart';

class SaveSpinnerPointsReq {
  static String sign = AppConstants.sign;
  static String salt = AppConstants.randomSalt.toString();
  static String packageName = AppConstants.packageName;
  static String methodName = 'save_spinner_points';
  final String userId;
  final String points;

  SaveSpinnerPointsReq({
    required this.userId,
    required this.points,
  });

  Map<String, dynamic> toJson() {
    return {
      'sign': sign,
      'salt': salt,
      'package_name': packageName,
      'method_name': methodName,
      'user_id': userId,
      'ponints': points,
    };
  }
}
