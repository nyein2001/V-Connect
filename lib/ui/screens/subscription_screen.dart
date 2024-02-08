import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/modules.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/models/subscription_plan.dart';
import 'package:ndvpn/core/providers/globals/iap_provider.dart';
import 'package:ndvpn/core/resources/colors.dart';
import 'package:ndvpn/core/resources/environment.dart';
import 'package:ndvpn/core/utils/config.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/components/custom_card.dart';
import 'package:ndvpn/ui/components/custom_divider.dart';
import 'package:pay/pay.dart';
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
        // backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("subscription").tr(),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          actions: const [CloseButton()],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Image.asset('assets/images/background_world.png',
            //     fit: BoxFit.fitHeight, color: primaryColor),
            Consumer<IAPProvider>(
              builder: (context, value, child) {
                return Center(
                  child: ListView(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Unlock Premium Servers',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'With No Ads',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 5.0),
                              width: 240.0,
                              child: const Text(
                                'By the Premium Plan and Get Ride of Fastest Servers in the world.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...value.subscriptionItems
                          .map((e) => _subsItem(value, e)),
                      ...value.productItems.map((e) => _subsButton(value, e)),
                      if (Platform.isIOS) ...[
                        const ColumnDivider(space: 20),
                        _restoreButton(value)
                      ],
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25, right: 25),
                        child: SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () => value.subscriptionItem == null
                                ? null
                                : _showPaymentDialog(
                                    context: context, controller: value),
                            child: ElevatedButton(
                              onPressed: () => _showPaymentDialog(
                                  context: context, controller: value),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: value.subscriptionItem != null
                                    ? const Color(0xffff2e93)
                                    : Colors.grey,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: const StadiumBorder(),
                              ),
                              child: Text(
                                'BECOME PREMIUM NOW',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.w400,
                                    ),
                              ).tr(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: Text.rich(TextSpan(
                          text:
                              'Recurring Billing , Cancel Any Time on Google Play Store',
                          style: Theme.of(context).textTheme.bodySmall,
                        )),
                      ),
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

  Widget _subsItem(IAPProvider provider, SubscriptionPlan e) {
    return CupertinoButton(
      padding: const EdgeInsets.only(bottom: 10),
      onPressed: () {
        provider.subscriptionPlan = e;
      },
      child: SizedBox(
        height: 60,
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: const Color(0xFF2A3875),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  e.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '\$${e.price}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Radio(
                  value: e,
                  groupValue: provider.subscriptionItem,
                  onChanged: (value) {},
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  activeColor: Colors.white,
                ),
              ],
            ),
          ),
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

  _showPaymentDialog(
      {required BuildContext context, required IAPProvider controller}) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Select Payment Method",
                  style: TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(
                  color: Color(0xFFEAEAEA),
                  height: 1,
                ),
                const SizedBox(height: 15),
                Card(
                  child: ListTile(
                    leading: Image.asset(
                      'assets/icons/stripe_logo.png',
                    ),
                    title: const Text("Stripe"),
                    trailing: const Icon(Icons.arrow_forward_ios_outlined),
                    onTap: () {
                      controller.makePayment();
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _gAndApplePay(controller: controller)
              ],
            ),
          );
        });
  }

  _gAndApplePay({required IAPProvider controller}) {
    return Expanded(
      child: Column(
        children: [
          _gpayPayment(controller: controller),
          _applePayPayment(controller: controller),
        ],
      ),
    );
  }

  _applePayPayment({required IAPProvider controller}) {
    return FutureBuilder<PaymentConfiguration>(
        future: controller.applePayConfigFuture,
        builder: (context, snapshot) => snapshot.hasData
            ? ApplePayButton(
                height: 12.00 * 3.6,
                paymentConfiguration: snapshot.data!,
                paymentItems: controller.paymentItems,
                style: ApplePayButtonStyle.black,
                type: ApplePayButtonType.plain,
                margin: const EdgeInsets.only(top: 15.0),
                onPaymentResult: controller.onApplePayResult,
                loadingIndicator: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : const SizedBox.shrink());
  }

  _gpayPayment({required IAPProvider controller}) {
    return FutureBuilder<PaymentConfiguration>(
        future: controller.googlePayConfigFuture,
        builder: (context, snapshot) => snapshot.hasData
            ? GooglePayButton(
                height: 200,
                paymentConfiguration: snapshot.data!,
                paymentItems: controller.paymentItems,
                type: GooglePayButtonType.plain,
                margin: const EdgeInsets.only(top: 15.0),
                onPaymentResult: controller.onGooglePayResult,
                loadingIndicator: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : const SizedBox.shrink());
  }
}
