import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:ndvpn/core/utils/config.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/main.dart';
import 'package:ndvpn/ui/screens/main_screen.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  GoogleSignInButtonState createState() => GoogleSignInButtonState();
}

class GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceid = '';

  @override
  void initState() {
    if (Platform.isAndroid) {
      deviceInfo.androidInfo.then((AndroidDeviceInfo androidInfo) {
        deviceid = androidInfo.serialNumber;
      });
    } else if (Platform.isIOS) {
      deviceInfo.iosInfo.then((IosDeviceInfo iosInfo) {
        deviceid = iosInfo.identifierForVendor!;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: _isSigningIn
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : OutlinedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Theme.of(context).cardColor),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              onPressed: () async {
                setState(() {
                  _isSigningIn = true;
                });
                googleSignIn();
                setState(() {
                  _isSigningIn = false;
                });
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 10, 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.g_mobiledata),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Login With Gmail',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> googleSignIn() async {
    if (Platform.isAndroid) {
      deviceInfo.androidInfo.then((AndroidDeviceInfo androidInfo) {
        deviceid = androidInfo.serialNumber;
      });
    } else if (Platform.isIOS) {
      deviceInfo.iosInfo.then((IosDeviceInfo iosInfo) {
        deviceid = iosInfo.identifierForVendor!;
      });
    }
    await authService.signInWithGoogle(context).then((value) async {
      registerSocialNetwork("${value!.userData!.id}", value.userData!.username!,
          value.userData!.email!, 'google');
    }).catchError((e) {
      print('Error in googleSignIn : $e');
    });
  }

  void registerSocialNetwork(
      String id, String sendName, String sendEmail, String type) async {
    alertBox('Loading...', context);
    String deviceId = '';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        deviceInfo.androidInfo.then((AndroidDeviceInfo androidInfo) {
          deviceId = androidInfo.serialNumber;
        });
      } else if (Platform.isIOS) {
        deviceInfo.iosInfo.then((IosDeviceInfo iosInfo) {
          deviceId = iosInfo.identifierForVendor!;
        });
      }
    } catch (e) {
      deviceId = 'Not Found';
    }
    String methodBody = jsonEncode({
      'sign': AppConstants.sign,
      'salt': AppConstants.randomSalt.toString(),
      'package_name': AppConstants.packageName,
      'method_name': 'user_register',
      'type': type,
      'auth_id': id,
      'name': sendName,
      'email': sendEmail,
      'player_id': "123",
      'device_id': deviceId
    });
    http.Response response = await http.post(
      Uri.parse(AppConstants.baseURL),
      body: {'data': base64Encode(utf8.encode(methodBody))},
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('status')) {
        String message = jsonResponse['message'];
        alertBox(message, context);
      } else {
        try {
          Map<String, dynamic> data = jsonResponse[AppConstants.tag];
          String msg = data['msg'];
          String success = data['success'];
          if (success == '1') {
            String userId = data["user_id"];
            String email = data["email"];
            String name = data["name"];
            String stripeJson = data["stripe"];

            if (stripeJson != "") {
              Map<String, dynamic> stripeObject = jsonDecode(stripeJson);
              print("CHECKSTRIPE ${data["stripe"]}");
              Config.stripeJson = data["stripe"];

              if (stripeObject["status"] == "active") {
                Config.stripeRenewDate = stripeObject["current_period_end"];
                Config.vipSubscription = true;
                Config.allSubscription = true;
                Config.stripeStatus = "active";
              }
              Preferences.setEmail(email: email);
              Preferences.setName(name: name);
              Preferences.setLogin(isLogin: true);
              Preferences.setProfileId(profileId: userId);
              Preferences.setLoginType(loginType: type);

              if (Config.loginBack) {
              } else {
                if (data.containsKey("no_ads")) {
                  int noAds = data["no_ads"];
                  int premiumServers = data["premium_servers"];
                  int isPremium = data["is_premium"];
                  String perks = data["perks"];
                  String exp = data["exp"];

                  Config.noAds = noAds == 1;
                  Config.premiumServersAccess = premiumServers == 1;
                  Config.isPremium = isPremium == 1;
                  Config.perks = perks;
                  Config.expiration = exp;
                }
                replaceScreen(context, const MainScreen());
              }
            }
          }
          Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_SHORT);
        } catch (e) {
          print('Error $e');
        }
      }
    }
    Navigator.of(context).pop();
  }
}
