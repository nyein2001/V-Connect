import 'package:ndvpn/core/utils/constant.dart';

class UserProfileUpdate {
  static String sign = AppConstants.sign;
  static String salt = AppConstants.randomSalt.toString();
  static String packageName = AppConstants.packageName;
  static const String methodName = 'user_profile_update';
  final String userId;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String userYoutube;
  final String userInstagram;

  UserProfileUpdate(
      {required this.userId,
      required this.name,
      required this.email,
      required this.password,
      required this.phone,
      required this.userYoutube,
      required this.userInstagram});

  Map<String, String> toJson() {
    return {
      'sign': sign,
      'salt': salt,
      'package_name': packageName,
      'method_name': methodName,
      'user_id': userId,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'user_youtube': userYoutube,
      'user_instagram': userInstagram
    };
  }
}
