import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/models/get_req_with_userid.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:http/http.dart' as http;
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/components/custom_card.dart';
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';
import 'dart:core';

import 'package:url_launcher/url_launcher.dart';
part 'mixin/about_us_mixin.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => AboutUsScreenState();
}

class AboutUsScreenState extends State<AboutUsScreen> with _AboutUsMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("about").tr(),
        ),
        body: ListView(children: [
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CustomCard(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 25,
                              child: ClipRRect(
                                child: CachedNetworkImage(
                                  imageUrl: appLogo,
                                  placeholder: (context, url) => Image.asset(
                                    "${AssetsPath.iconpath}logo_android.png",
                                    fit: BoxFit.cover,
                                    height: 125,
                                    width: 125,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    "${AssetsPath.iconpath}logo_android.png",
                                    fit: BoxFit.cover,
                                    height: 125,
                                    width: 125,
                                  ),
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    height: 125,
                                    width: 125,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(50)),
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  height: 125,
                                  width: 125,
                                ),
                              ),
                            ),
                            title: Text(appName),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CustomCard(
                          child: ListTile(
                        leading: const Icon(
                          Icons.info_outline_rounded,
                        ),
                        title: const Text('Version').tr(),
                        subtitle: Text(appVersion),
                      )),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CustomCard(
                            child: ListTile(
                          leading: const Icon(Icons.business),
                          title: const Text('Company').tr(),
                          subtitle: Text(appAuthor),
                        ))),
                    Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CustomCard(
                            child: ListTile(
                          leading: const Icon(Icons.email),
                          title: const Text('Email').tr(),
                          subtitle: Text(appEmail),
                          onTap: () => launchEmail(),
                        ))),
                    Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CustomCard(
                            child: ListTile(
                          leading: const Icon(Icons.language),
                          title: const Text('Website').tr(),
                          subtitle: Text(appWebsite),
                          onTap: () => launchWebsite(),
                        ))),
                    Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CustomCard(
                            child: ListTile(
                          leading: const Icon(Icons.phone),
                          title: const Text(
                            'Contact',
                          ).tr(),
                          subtitle: Text(appContact),
                          onTap: () => makePhoneCall(),
                        ))),
                    Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CustomCard(
                            child: ListTile(
                                title: const Text('About').tr(),
                                subtitle: text == ''
                                    ? Container()
                                    : SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: InAppWebView(
                                          key: key,
                                          initialOptions:
                                              InAppWebViewGroupOptions(
                                                  crossPlatform:
                                                      InAppWebViewOptions(
                                                          transparentBackground:
                                                              true)),
                                          initialUrlRequest: URLRequest(
                                              url: Uri.parse(
                                                  'https://www.youtube.com/')),
                                          onWebViewCreated: (controller) async {
                                            await controller.loadData(
                                                data: text,
                                                mimeType: 'text/html',
                                                encoding: 'utf-8');
                                          },
                                        ),
                                      )))),
                  ]))
        ]));
  }

  void launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: appEmail,
    );

    try {
      await launchUrl(emailLaunchUri);
    } catch (e) {
      alertBox('Something went wrong.', false, context);
    }
  }

  void launchWebsite() async {
    String url = appWebsite;
    if (!url.startsWith("http://") && !url.startsWith("https://")) {
      url = "http://$url";
    }

    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      alertBox('Something went wrong.', false, context);
    }
  }

  void makePhoneCall() async {
    if (appContact != "Not Available") {
      final Uri phoneCallUri = Uri(scheme: 'tel', path: appContact);

      try {
        if (await canLaunchUrl(phoneCallUri)) {
          await launchUrl(phoneCallUri);
        }
      } catch (e) {
        alertBox('Something went wrong.', false, context);
      }
    }
  }
}
