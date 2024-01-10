part of '../fragment/reward_current_fragment.dart';

mixin _RewardCurrentMixin on State<RewardCurrentFragment> {
  NetworkInfo networkInfo = NetworkInfo(Connectivity());
  List<RewardPoint> rewardPointLists = [];
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
    ReqWithUserId req = ReqWithUserId(
        methodName: 'user_rewads_point', userId: Preferences.getProfileId());
    String methodBody = jsonEncode(req.toJson());
    try {
      http.Response response = await http.post(
        Uri.parse(AppConstants.baseURL),
        body: {'data': base64Encode(utf8.encode(methodBody))},
      ).then((value) {
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
          final data = jsonData[AppConstants.tag];
          for (var i = 0; i < data.length; i++) {
            final object = data[i];
            final jsonArrayReward = object['user_rewads_point'];

            for (var j = 0; j < jsonArrayReward.length; j++) {
              final objectReward = jsonArrayReward[j];
              final id = objectReward['id'];
              final title = objectReward['title'];
              final statusThumbnail = objectReward['status_thumbnail'];
              final userId = objectReward['user_id'];
              final activityType = objectReward['activity_type'];
              final points = objectReward['points'];
              final date = objectReward['date'];
              final time = objectReward['time'];

              rewardPointLists.add(RewardPoint(
                id: id,
                title: title,
                statusThumbnail: statusThumbnail,
                userId: userId,
                activityType: activityType,
                points: points,
                date: date,
                time: time,
              ));
            }
          }
          if (rewardPointLists.isEmpty) {
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
