import 'package:ndvpn/core/utils/constant.dart';

class ContactUSMsgReq {
  static String sign = AppConstants.sign;
  static String salt = AppConstants.randomSalt.toString();
  static String packageName = AppConstants.packageName;
  static String methodName = "user_contact_us";
  final String sendEmail;
  final String sendName;
  final String sendMessage;
  final String contactSubject;

  ContactUSMsgReq({
    required this.sendEmail,
    required this.sendName,
    required this.sendMessage,
    required this.contactSubject,
  });

  Map<String, dynamic> toJson() {
    return {
      'sign': sign,
      'salt': salt,
      'package_name': packageName,
      'method_name': methodName,
      'contact_email': sendEmail,
      'contact_name': sendName,
      'contact_msg': sendMessage,
      'contact_subject': contactSubject,
    };
  }
}
