import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/models/get_req_with_userid.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/network_available.dart';
import 'package:http/http.dart' as http;
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';
import 'dart:core';
part 'mixin/faq_mixin.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => FaqScreenState();
}

class FaqScreenState extends State<FaqScreen> with _FaqMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("faq").tr(),
        automaticallyImplyLeading: true,
        centerTitle: false,
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
