import 'package:ndvpn/core/utils/constant.dart';

class PaymentReq {
  static String sign = AppConstants.sign;
  static String salt = AppConstants.randomSalt.toString();
  static String packageName = AppConstants.packageName;
  static String methodName = "user_redeem_request";
  final String userId;
  final String userPoints;
  final String paymentMode;
  final String detail;

  PaymentReq({
    required this.userId,
    required this.userPoints,
    required this.paymentMode,
    required this.detail,
  });

  Map<String, dynamic> toJson() {
    return {
      'sign': sign,
      'salt': salt,
      'package_name': packageName,
      'method_name': methodName,
      'user_id': userId,
      'user_points': userPoints,
      'payment_mode': paymentMode,
      'bank_details': detail,
    };
  }
}
