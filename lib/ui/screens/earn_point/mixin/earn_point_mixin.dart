part of '../earn_point_screen.dart';

mixin _EarnPointMixin on State<EarnPointScreen> {
  NetworkInfo networkInfo = NetworkInfo(Connectivity());
  List<EarnPoint> earnPointLists = [];
  bool noData = false;

  @override
  void initState() {
    super.initState();
    callData();
  }

  void callData() async {
    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      if (Preferences.isLogin()) {
        rewardPoint();
      }
    } else {
      alertBox("Internet connection not available", false, context);
    }
  }

  Future<void> rewardPoint() async {
    PointsDetailsReq req = PointsDetailsReq(methodName: 'points_details');
    String methodBody = jsonEncode(req.toJson());
    CustomProgressDialog customProgressDialog =
        CustomProgressDialog(context, dismissable: false, onDismiss: () {});
    customProgressDialog.show();
    try {
      http.Response response = await http.post(
        Uri.parse(AppConstants.baseURL),
        body: {'data': base64Encode(utf8.encode(methodBody))},
      ).then((value) {
        customProgressDialog.dismiss();
        return value;
      }).onError((error, stackTrace) {
        customProgressDialog.dismiss();
        throw 'Unexpected Error';
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);

        if (jsonData.containsKey("status")) {
          String status = jsonData["status"];
          String message = jsonData["message"];

          if (status == "-2") {
            replaceScreen(context, const LoginScreen());
            alertBox(message, false, context);
          } else {
            alertBox(message, false, context);
          }
        } else {
          final data = jsonData[AppConstants.tag];
          for (var i = 0; i < data.length; i++) {
            final object = data[i];
            final title = object['title'];
            final point = object['point'];

            earnPointLists.add(EarnPoint(title: title, points: point));
          }
          if (earnPointLists.isEmpty) {
            noData = true;
          }
          setState(() {});
          // String success = data['success'];
          // if (success == "1") {

          // }
        }
      }
    } catch (error) {
      print("Error updateUIWithData  $error");
    }
  }
}
