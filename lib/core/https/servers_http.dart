import 'dart:convert';
import 'package:ndvpn/core/https/http_connection.dart';
import 'package:ndvpn/core/models/api_req/base_model.dart';
import 'package:ndvpn/core/models/earn_point.dart';
import 'package:ndvpn/core/models/ip_detail.dart';
import 'package:ndvpn/core/models/vpn_config.dart';
import 'package:ndvpn/core/models/vpn_server.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';

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

  Future<List<VpnServer>> allTrueServers() async {
    List<VpnServer> vpnServerList = [];
    vpnServerList.addAll(await fetchData(key: "frs"));
    vpnServerList.addAll(await fetchData(key: "prs"));
    return vpnServerList;
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

  bool _handleStatus(Map<String, dynamic> jsonData) {
    if (jsonData.containsKey("status")) {
      final status = jsonData["status"];
      final message = jsonData["message"];

      if (status == "-2") {
        replaceScreen(context, const LoginScreen());
        alertBox(message, false, context);
      } else {
        alertBox(message, false, context);
      }
      return false;
    }
    return true;
  }

  Future<List<EarnPoint>> rewardPoint() async {
    BaseModel req = BaseModel(methodName: 'points_details');
    final response = await postRequest(body: req.toJson());
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (_handleStatus(jsonData)) {
        final data = jsonData[AppConstants.tag];
        return data
            .map<EarnPoint>((object) =>
                EarnPoint(title: object['title'], points: object['point']))
            .toList();
      }
    }
    return [];
  }

  Future<String> referenceCode() async {
    BaseModel req = BaseModel(methodName: 'user_profile');
    final response = await postRequest(body: req.toJson());
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (_handleStatus(jsonData)) {
        final data = jsonData[AppConstants.tag];
        String success = "${data['success']}";
        if (success == "1") {
          return data["user_code"];
        }
      }
    }
    return '';
  }
}
