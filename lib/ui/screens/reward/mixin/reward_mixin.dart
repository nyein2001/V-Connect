part of '../reward_screen.dart';

mixin _RewardScreenMixin on State<RewardScreen> {
  // final PageController _pageController = PageController(initialPage: 0);
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  NetworkInfo networkInfo = NetworkInfo(Connectivity());
  bool noData = false;
  String totalPoint = '0';
  String money = '';

  @override
  void initState() {
    super.initState();
    callData();
  }

  void callData() async {
    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      if (Preferences.isLogin()) {
        userData();
      }
    } else {
      alertBox("Internet connection not available", false, context);
    }
  }

  Future<void> userData() async {
    ReqWithUserId req = ReqWithUserId(
        methodName: 'reward_points', userId: Preferences.getProfileId());
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
          Map<String, dynamic> data = jsonData[AppConstants.tag];
          String success = '${data['success']}';
          if (success == "1") {
            totalPoint = data["total_point"];
            String redeemPoints = '${data["redeem_points"]}';
            String redeemMoney = '${data["redeem_money"]}';
            money = "$redeemPoints Point = $redeemMoney";
            setState(() {});
          }
        }
      }
    } catch (error) {
      print("Error updateUIWithData  $error");
    }
  }
}
