import 'package:ndvpn/core/models/model.dart';

class AppSettings extends Model {
  final String appUpdateStatus;
  final String appUpdateDesc;
  final String appRedirectUrl;
  final String cancelUpdateStatus;
  final String appNewVersion;

  AppSettings({
    required this.appUpdateStatus,
    required this.appUpdateDesc,
    required this.appRedirectUrl,
    required this.cancelUpdateStatus,
    required this.appNewVersion,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
        appUpdateStatus: json["app_update_status"],
        appUpdateDesc: json["app_update_desc"],
        appRedirectUrl: json["app_redirect_url"],
        cancelUpdateStatus: json["cancel_update_status"],
        appNewVersion: json["app_new_version"]);
  }

  @override
  Map<String, dynamic> toJson() => {
        "app_update_status": appUpdateStatus,
        "app_update_desc": appUpdateDesc,
        "app_redirect_url": appRedirectUrl,
        "cancel_update_status": cancelUpdateStatus,
        "app_new_version": appNewVersion,
      };
}
