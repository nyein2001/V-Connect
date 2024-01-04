import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:ndvpn/core/models/get_profile_req.dart';
import 'package:ndvpn/core/resources/colors.dart';
import 'package:ndvpn/core/utils/config.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/network_available.dart';
import 'package:ndvpn/core/utils/utils.dart';
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
  NetworkInfo networkInfo = NetworkInfo(Connectivity());
  String accountType = "Free";

  @override
  void initState() {
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
      alertBox("Internet connection not available", false, context);
    }
  }

  void getProfile() async {
    UserProfileReq req = UserProfileReq(userId: Preferences.getProfileId());
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
          String success = data['success'];
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
        title: const Text(
          'Profile',
          textAlign: TextAlign.center,
        ),
        automaticallyImplyLeading: true,
        centerTitle: true,
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
                                      color: Colors.white,
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
                                        border: Border.all(color: Colors.white),
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
                      const Text('Account Type:',
                          style: TextStyle(
                              fontSize: 16,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w400)),
                      Text(
                          Config.allSubscription && Config.premiumServersAccess
                              ? 'Premium'
                              : 'Free',
                          style: const TextStyle(
                              fontSize: 16,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600))
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
