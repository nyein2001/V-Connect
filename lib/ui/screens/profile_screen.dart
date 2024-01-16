import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/models/get_req_with_userid.dart';
import 'package:ndvpn/core/models/purchase_history.dart';
import 'package:ndvpn/core/providers/globals/iap_provider.dart';
import 'package:ndvpn/core/resources/colors.dart';
import 'package:ndvpn/core/utils/config.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/components/custom_card.dart';
import 'package:ndvpn/ui/screens/edit_profile/edit_profile_screen.dart';
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = Preferences.getName();
  String email = Preferences.getEmail();
  String phone = Preferences.getPhoneNo();
  String userImage = Preferences.getUserImage();
  String accountType = "Free";
  List<PurchaseHistory> phList = [];
  String tvRenewDate = "";

  @override
  void initState() {
    fetchPurchaseHistory();
    setRenewDate();
    callData();
    super.initState();
  }

  callData() async {
    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      if (Preferences.isLogin()) {
        getProfile();
      }
    } else {
      alertBox("no_internet_msg".tr(), false, context);
    }
  }

  void fetchPurchaseHistory() async {
    ReqWithUserId req = ReqWithUserId(methodName: "fetch_purchase_history");
    String methodBody = jsonEncode(req.toJson());

    try {
      http.Response response = await http.post(
        Uri.parse(AppConstants.baseURL),
        body: {'data': base64Encode(utf8.encode(methodBody))},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        Map<String, dynamic> jsonResponse = jsonData[AppConstants.tag];

        if (jsonResponse.containsKey('list') && jsonResponse['list'] != null) {
          dynamic listData = jsonResponse['list'];
          if (listData != null) {
            if (listData is String) {
              List<dynamic> decodedList = json.decode(listData);
              if (decodedList.isNotEmpty) {
                phList = List<PurchaseHistory>.from(
                    decodedList.map((item) => PurchaseHistory.fromJson(item)));
              }
            }
          }
        }
      }
      setState(() {});
    } catch (error) {
      print("Error updateUIWithData  $error");
    }
  }

  void setRenewDate() {
    if (Config.stripeRenewDate.isEmpty) {
      return;
    }
    int unixSeconds = int.parse(Config.stripeRenewDate);
    DateTime date = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
    var formatter = DateFormat('yyyy-MM-dd', 'en_US');
    tvRenewDate = formatter.format(date);
    setState(() {});
  }

  void getProfile() async {
    ReqWithUserId req = ReqWithUserId(methodName: "user_profile");
    String methodBody = jsonEncode(req.toJson());

    try {
      http.Response response = await http.post(
        Uri.parse(AppConstants.baseURL),
        body: {'data': base64Encode(utf8.encode(methodBody))},
      );

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
          String success = "${data['success']}";
          if (success == "1") {
            name = data["name"];
            email = data["email"];
            phone = data["phone"];
            userImage = data["user_image"];

            String stripeJson = data["stripe"];
            if (stripeJson != '') {
              Map<String, dynamic> stripeObject = jsonDecode(stripeJson);

              if (stripeObject["status"] == "active") {
                Config.stripeRenewDate = stripeObject["current_period_end"];
                Config.stripeStatus = "active";
                accountType = "Premium";
                // setRenewDate();
              } else {
                accountType = "Free";
              }
            }
            setState(() {});
          }
        }
      }
    } catch (error) {
      print("Error updateUIWithData  $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('profile').tr(),
        ),
        body: Column(
          children: [
            Card(
              color: Theme.of(context).cardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            startScreen(context, const EditProfileScreen())
                                .then((value) {
                              name = value.name;
                              email = value.email;
                              setState(() {});
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(60),
                                      border: Border.all(
                                        // color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(60.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                        ),
                                        child: userImage == ''
                                            ? Image.asset(
                                                "${AssetsPath.imagepath}user2.jpg",
                                                fit: BoxFit.cover,
                                                height: 120,
                                                width: 120,
                                              )
                                            : CachedNetworkImage(
                                                imageUrl: userImage,
                                                placeholder: (context, url) =>
                                                    Image.asset(
                                                  "${AssetsPath.imagepath}user2.jpg",
                                                  fit: BoxFit.cover,
                                                  height: 120,
                                                  width: 120,
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  "${AssetsPath.imagepath}user2.jpg",
                                                  fit: BoxFit.cover,
                                                  height: 120,
                                                  width: 120,
                                                ),
                                                height: 120,
                                                width: 120,
                                              ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      top: 5,
                                      right: -3,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: primaryColor,
                                          border:
                                              Border.all(color: Colors.white),
                                        ),
                                        child: const Icon(Icons.edit,
                                            color: Colors.white, size: 12),
                                      ))
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 5),
                            Text(email,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w400)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('account_type',
                                style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w400))
                            .tr(),
                        Text(
                            Config.allSubscription &&
                                    Config.premiumServersAccess
                                ? 'Premium'
                                : 'Free',
                            style: const TextStyle(
                                fontSize: 16,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w600))
                      ],
                    ),
                    Visibility(
                        visible: tvRenewDate.isNotEmpty,
                        child: const SizedBox(
                          height: 15,
                        )),
                    Visibility(
                        visible: tvRenewDate.isNotEmpty,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('renew_on',
                                    style: TextStyle(
                                        fontSize: 16,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.w400))
                                .tr(),
                            const Text("",
                                style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w600))
                          ],
                        )),
                    Visibility(
                        visible: Config.allSubscription &&
                            Config.premiumServersAccess,
                        child: const SizedBox(
                          height: 20,
                        )),
                    Visibility(
                        visible: Config.allSubscription &&
                            Config.premiumServersAccess,
                        child: InkWell(
                          onTap: () => _cancelClick(),
                          child: Container(
                            width: double.infinity,
                            height: 45,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.blueAccent),
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                              child: Text('cancel_subscription',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: const Color(0xffDDDDDD),
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 1,
                                      )).tr(),
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text('purchase_history',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600))
                      .tr()
                ],
              ),
            ),
            phList.isEmpty
                ? Card(
                    color: Theme.of(context).cardColor,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 8,
                            ),
                            const SizedBox(
                                child: Icon(
                              Icons.history,
                              size: 80,
                              color: Colors.blue,
                            )),
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 16,
                            ),
                            const Text(
                              'no_purchase',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ).tr(),
                            const SizedBox(height: 8),
                            const Text(
                              'no_purchase_msg',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ).tr(),
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 8,
                            ),
                          ],
                        ))))
                : Expanded(
                    child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          PurchaseHistory rewardPoint = phList[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: CustomCard(
                              child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 25,
                                    child: ClipOval(
                                      child: Image.asset(
                                        "${AssetsPath.iconpath}logo_android.png",
                                        fit: BoxFit.cover,
                                        height: 125,
                                        width: 125,
                                      ),
                                    ),
                                  ),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        rewardPoint.type,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12),
                                        child: Text(
                                          rewardPoint.amount,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                  subtitle: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      rewardPoint.createDate,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  contentPadding:
                                      const EdgeInsets.only(left: 5, right: 5)),
                            ),
                          );
                        },
                        shrinkWrap: true,
                        itemCount: phList.length),
                  ))
          ],
        ));
  }

  void _cancelClick() async {
    return NAlertDialog(
      blur: 10,
      title: const Text("confirm_cancellation").tr(),
      content: const Text("confirm_cancellation_msg").tr(),
      actions: [
        TextButton(
          child: const Text("Yes"),
          onPressed: () {
            cancelStripeSubscription();
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text("No"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ).show(context);
  }

  void cancelStripeSubscription() async {
    ReqWithUserId req = ReqWithUserId(methodName: "cancel_stripe_subscription");
    String methodBody = jsonEncode(req.toJson());

    try {
      http.Response response = await http.post(
        Uri.parse(AppConstants.baseURL),
        body: {'data': base64Encode(utf8.encode(methodBody))},
      );

      if (response.statusCode == 200) {
        Config.stripeStatus = "";
        Config.stripeJson = "";
        Config.stripeRenewDate = "";
        Config.vipSubscription = false;
        Config.allSubscription = false;
        IAPProvider.read(context).updateProStatus();
        tvRenewDate = "";
        setState(() {});
      }
    } catch (e) {}
  }
}
