import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/models/get_req_with_userid.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:http/http.dart' as http;
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';

class ReferenceCodeScreen extends StatefulWidget {
  const ReferenceCodeScreen({super.key});

  @override
  State<ReferenceCodeScreen> createState() => ReferenceCodeScreenState();
}

class ReferenceCodeScreenState extends State<ReferenceCodeScreen> {
  String userCode = 'Reference Code';

  @override
  void initState() {
    super.initState();
    callData();
  }

  void callData() async {
    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      if (Preferences.isLogin()) {
        getRefCode();
      }
    } else {
      alertBox("Internet connection not available", false, context);
    }
  }

  Future<void> getRefCode() async {
    ReqWithUserId req = ReqWithUserId(methodName: 'user_profile');
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
          String success = data['success'];
          if (success == "1") {
            userCode = data["user_code"];
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
        title: Text(
          'reference_code'.tr(),
          style: const TextStyle(
              fontSize: 20, letterSpacing: 1, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: const Text(
              'reference_title',
              style: TextStyle(
                  color: Color(0xff6C6C6C),
                  fontSize: 22,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600),
            ).tr(),
          ),
          SafeArea(
            child: Stack(
              children: <Widget>[
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    height: MediaQuery.of(context).size.height / 10,
                    child: const FractionallySizedBox(
                      heightFactor: 1.0,
                      widthFactor: 1.0,
                      //for full screen set heightFactor: 1.0,widthFactor: 1.0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/code_bg.png"),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 50),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(userCode,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff424242))),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text('copy',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xfff20056)))
                            .tr()
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Center(
              child: const Text(
                "reference_desc",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xff6C6C6C),
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ).tr(),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Center(
            child: Container(
              height: MediaQuery.of(context).size.width / 2,
              width: MediaQuery.of(context).size.width / 2,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/reference_code_img.jpg"),
                    fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
