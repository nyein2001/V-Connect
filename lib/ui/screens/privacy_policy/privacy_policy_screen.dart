import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/models/api_req/get_req_with_userid.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:http/http.dart' as http;
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';
import 'dart:core';
part 'mixin/privacy_policy_mixin.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => PrivacyPolicyScreenState();
}

class PrivacyPolicyScreenState extends State<PrivacyPolicyScreen>
    with _PrivacyPolicyMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("privacy_policy").tr(),
      ),
      body: text == ''
          ? Container()
          : InAppWebView(
              key: key,
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform:
                      InAppWebViewOptions(transparentBackground: true)),
              initialUrlRequest:
                  URLRequest(url: Uri.parse('https://www.youtube.com/')),
              onWebViewCreated: (controller) async {
                await controller.loadData(
                    data: text, mimeType: 'text/html', encoding: 'utf-8');
              },
            ),
    );
  }
}
