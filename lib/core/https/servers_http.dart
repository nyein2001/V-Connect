import 'package:ndvpn/core/https/http_connection.dart';
import 'package:ndvpn/core/models/vpn_config.dart';

import '../models/ip_detail.dart';

class ServersHttp extends HttpConnection {
  ///All serveres request api
  ServersHttp(super.context);

  ///Get all servers from backend
  Future<List<VpnConfig>> allServers() async {
    ApiResponse<List> resp = await get<List>("allservers");
    if (resp.success ?? false) {
      return resp.data!.map<VpnConfig>((e) => VpnConfig.fromJson(e)).toList();
    }
    return [];
  }

  ///Get all free servers from backend
  Future<List<VpnConfig>> allFree() async {
    ApiResponse<List> resp = await get<List>("allservers/free");
    if (resp.success ?? false) {
      return resp.data!.map<VpnConfig>((e) => VpnConfig.fromJson(e)).toList();
    }
    return [];
  }

  ///Get all pro servers from backend
  Future<List<VpnConfig>> allPro() async {
    ApiResponse<List> resp = await get<List>("allservers/pro");
    if (resp.success ?? false) {
      return resp.data!.map<VpnConfig>((e) => VpnConfig.fromJson(e)).toList();
    }
    return [];
  }

  ///Randomly get server
  Future<VpnConfig?> random() async {
    ApiResponse<Map<String, dynamic>> resp =
        await get<Map<String, dynamic>>("detail/random");
    if (resp.success ?? false) {
      return VpnConfig.fromJson(resp.data!);
    }
    return null;
  }

  ///Fetch server's detail by slug
  Future<VpnConfig?> serverDetail(String slug) async {
    ApiResponse<Map<String, dynamic>> resp =
        await get<Map<String, dynamic>>("detail/$slug");
    if (resp.success ?? false) {
      return VpnConfig.fromJson(resp.data!);
    }
    return null;
  }

  ///Get IP informations
  Future<IpDetail?> getPublicIP() async {
    var resp = await get("https://myip.wtf/json", pure: true);
    return resp != null ? IpDetail.fromJson(resp) : null;
  }
}
