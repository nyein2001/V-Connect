import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/models/api_req/base_model.dart';
import 'package:ndvpn/core/models/earn_point.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:http/http.dart' as http;
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';

class EarnPointScreen extends StatefulWidget {
  const EarnPointScreen({super.key});

  @override
  State<EarnPointScreen> createState() => EarnPointScreenState();
}

class EarnPointScreenState extends State<EarnPointScreen> {
  List<EarnPoint> earnPointLists = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("earn_point").tr(),
      ),
      body: FutureBuilder(
          future: rewardPoint(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 150);
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Unexpected Error Occur!'),
              );
            } else {
              List<EarnPoint> earnPointLists = snapshot.data ?? [];
              if (earnPointLists.isEmpty) {
                return Column(
                  children: [
                    const SizedBox(
                      child: Icon(
                        Icons.not_listed_location,
                        size: 80,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Text(
                      'empty_earnpoint',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ).tr(),
                    const SizedBox(height: 8),
                    const Text(
                      'empty_earnpoint_msg',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ).tr(),
                    const SizedBox(height: 16),
                  ],
                );
              } else {
                return ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      EarnPoint rewardPoint = earnPointLists[index];
                      return ListTile(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              rewardPoint.title,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Text(
                                rewardPoint.points,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        visualDensity: VisualDensity.compact,
                        contentPadding: const EdgeInsets.all(12),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                    itemCount: earnPointLists.length);
              }
            }
          }),
    );
  }

  Future<List<EarnPoint>> rewardPoint() async {
    BaseModel req = BaseModel(methodName: 'points_details');
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
          return earnPointLists;
        }
      }
      return [];
    } catch (error) {
      return [];
    }
  }
}
