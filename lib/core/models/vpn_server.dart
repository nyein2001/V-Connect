import 'package:ndvpn/core/models/model.dart';

class VpnServer extends Model {
  String id;
  String serverName;
  String server;
  String flagUrl;
  String ovpnConfiguration;
  String vpnUserName;
  String vpnPassword;
  String isFree;

  VpnServer(
      {required this.id,
      required this.serverName,
      required this.server,
      required this.flagUrl,
      required this.ovpnConfiguration,
      required this.vpnUserName,
      required this.vpnPassword,
      required this.isFree});

  factory VpnServer.fromJson(Map<String, dynamic> json) {
    return VpnServer(
      id: json['id'] ?? "",
      serverName: json['serverName'] ?? "",
      server: json['server'] ?? "",
      flagUrl: json['flag_url'] ?? "",
      ovpnConfiguration: json['ovpnConfiguration'] ?? "",
      vpnUserName: json['vpnUserName'] ?? "",
      vpnPassword: json['vpnPassword'] ?? "",
      isFree: json['isFree'] ?? "1",
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "serverName": serverName,
        "server": server,
        "flag_url": flagUrl,
        "ovpnConfiguration": ovpnConfiguration,
        "vpnUserName": vpnUserName,
        "vpnPassword": vpnPassword,
        "isFree": isFree,
      };
}
