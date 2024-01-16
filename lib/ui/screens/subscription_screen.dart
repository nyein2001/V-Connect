import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/modules.dart';
import 'package:lottie/lottie.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/providers/globals/iap_provider.dart';
import 'package:ndvpn/core/resources/colors.dart';
import 'package:ndvpn/core/resources/environment.dart';
import 'package:ndvpn/core/utils/config.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/components/custom_card.dart';
import 'package:ndvpn/ui/components/custom_divider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: primaryGradient.colors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: const CloseButton(),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/background_world.png',
                fit: BoxFit.fitHeight, color: primaryColor),
            Consumer<IAPProvider>(
              builder: (context, value, child) {
                return Center(
                  child: ListView(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        "subscription_title",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Colors.white),
                      ).tr(),
                      const ColumnDivider(),
                      LottieBuilder.asset("assets/animations/crown_pro.json",
                          width: 100, height: 100),
                      const ColumnDivider(),
                      Text(
                        "subscription_description",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Colors.grey.shade300),
                      ).tr(),
                      const ColumnDivider(space: 20),
                      ...value.productItems.map((e) => _subsButton(value, e)),
                      if (Platform.isIOS) ...[
                        const ColumnDivider(space: 20),
                        _restoreButton(value)
                      ]
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _subsButton(IAPProvider provider, IAPItem e) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        provider.purchase(e).then((value) => savePayment(e.productId!));
      },
      child: SizedBox(
        height: 100,
        child: CustomCard(
          margin: const EdgeInsets.symmetric(vertical: 5),
          showOnOverflow: false,
          child: Stack(
            children: [
              if (subscriptionIdentifier[e.productId]!["featured"])
                const Positioned(
                  right: 0,
                  child: Banner(
                    message: "featured",
                    location: BannerLocation.topEnd,
                    color: primaryColor,
                  ),
                ),
              Center(
                child: ListTile(
                  title: Text(subscriptionIdentifier[e.productId]!["name"]),
                  subtitle: Text(e.description ?? ""),
                  trailing: Text(e.localizedPrice ?? ""),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _restoreButton(IAPProvider provider) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        provider
            .restorePurchase()
            .showCustomProgressDialog(context)
            .then((value) {
          if (!(value ?? false)) {
            NAlertDialog(
              title: Text("no_restore_title".tr()),
              content: Text("no_restore_description".tr()),
              actions: [
                TextButton(
                    onPressed: () => closeScreen(context),
                    child: Text("understand".tr()))
              ],
            ).show(context);
          }
        });
      },
      child: Text("restore_purchase".tr()),
    );
  }

  void savePayment(String productId) async {
    Config.vipSubscription = true;
    Config.allSubscription = true;
    Config.stripeStatus = "active";
    IAPProvider.read(context).updateProStatus();
    CustomProgressDialog customProgressDialog =
        CustomProgressDialog(context, dismissable: false, onDismiss: () {});
    customProgressDialog.show();
    String url = "https://vpn.truetest.xyz/includes/api.php";

    Map<String, String> headers = {
      "Content-Type": "application/x-www-form-urlencoded",
    };

    Map<String, String> body = {
      "payment_method": "Stripe",
      "product_id": productId,
      "user_id": Preferences.getProfileId(),
      "method_name": "savePayment",
    };

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        customProgressDialog.dismiss();
      } else {
        customProgressDialog.dismiss();
      }
    } catch (error) {
      customProgressDialog.dismiss();
    }
  }
}
