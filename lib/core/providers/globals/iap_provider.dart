import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:ndvpn/core/models/subscription_plan.dart';
import 'package:ndvpn/core/utils/config.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../resources/environment.dart';

class IAPProvider with ChangeNotifier {
  late StreamSubscription<PurchasedItem?> _subscription;

  FlutterInappPurchase get _engine => FlutterInappPurchase.instance;

  final List<IAPItem> _productItems = [];
  List<IAPItem> get productItems => _productItems;

  final List<PaymentItem> _paymentItems = [];
  List<PaymentItem> get paymentItems => _paymentItems;

  final List<SubscriptionPlan> _subscriptionItems = [];
  List<SubscriptionPlan> get subscriptionItems => _subscriptionItems;

  SubscriptionPlan? _subscriptionItem;
  SubscriptionPlan? get subscriptionItem => _subscriptionItem;
  set subscriptionPlan(SubscriptionPlan item) {
    _subscriptionItem = item;
    notifyListeners();
  }

  bool _isPro = false;
  bool get isPro => _isPro;

  bool _inGracePeriod = false;
  bool get inGracePeriod => _inGracePeriod;

  Map<String, dynamic>? paymentIntentData;

  String stripeSecretKey = '';
  String stripePublicKey = '';

  late String paymentProfile;

  ///Initialize IAP and handler all purchase functions
  Future initialize() {
    return _engine.initialize().then((value) async {
      _subscription = FlutterInappPurchase.purchaseUpdated
          .listen((item) => item != null ? _verifyPurchase(item) : null);
      await _loadPurchaseItems();
      await _verifyPreviousPurchase();
    });
  }

  Future _fetchStripeSecretKey() async {
    try {
      http.Response response = await http.get(
        Uri.parse('${AppConstants.baseURL}?stripe_secret_key'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        stripeSecretKey = data['stripe_secret_key'];
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future _fetchStripePublicKey() async {
    try {
      http.Response response = await http.get(
        Uri.parse('${AppConstants.baseURL}?stripe_public_key'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        stripePublicKey = data['stripe_public_key'];
        Preferences.setPublicStripeKey(stripeKey: stripePublicKey);
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future _fetchSubscription() async {
    try {
      http.Response response = await http.get(
        Uri.parse('https://vpn.truetest.xyz/includes/api.php?get_subscription'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        Map<String, dynamic> set = data['set'];
        dynamic subObject = set['sub'];

        if (subObject is Map<String, dynamic>) {
          subObject = [subObject];
        }

        List object = subObject;
        Map<String, dynamic> itemMap = object.first;

        _subscriptionItems.clear();
        for (String key in itemMap.keys) {
          SubscriptionPlan plan = SubscriptionPlan.fromJson(itemMap[key]);
          PaymentItem paymentItem = PaymentItem(
              amount: plan.price,
              label: plan.name,
              status: PaymentItemStatus.final_price);
          _subscriptionItems.add(plan);
          _paymentItems.add(paymentItem);
          subscriptionIdentifier[plan.productId] = {
            "name": plan.name,
            "price": plan.price,
            "currency": plan.currency,
            "status": plan.status,
          };
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> makePayment() async {
    try {
      if (subscriptionItem != null) {
        debugPrint("Start Payment");
        paymentIntentData = await createPaymentIntent(
            subscriptionItem!.price, subscriptionItem!.currency);

        debugPrint("After payment intent");

        if (paymentIntentData != null) {
          debugPrint(" payment intent is not null .........");
          await Stripe.instance.initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
            merchantDisplayName: 'Prospects',
            customerId: paymentIntentData!['customer'],
            paymentIntentClientSecret: paymentIntentData!['client_secret'],
            // applePay: const PaymentSheetApplePay(merchantCountryCode: '+92'),
            // googlePay: const PaymentSheetGooglePay(merchantCountryCode: '+92', testEnv: true),
            style: ThemeMode.dark,
          ));
          debugPrint(" initPaymentSheet  .........");
          displayPaymentSheet(paymentIntentData!['client_secret']);
        }
      } else {
        showToast('choose_one_item'.tr());
      }
    } catch (e, s) {
      debugPrint("After payment intent Error: ${e.toString()}");
      debugPrint("After payment intent s Error: ${s.toString()}");
    }
  }

  displayPaymentSheet(clientSecret) async {
    try {
      await Stripe.instance.presentPaymentSheet();

      // final paymentIntentResult = await Stripe.instance.confirmPayment(
      //     paymentIntentClientSecret: clientSecret,
      // );
      // print("on a fini confirmpayment");
      // print(paymentIntentResult.status);

      showToast('payment_success'.tr());
      savePayment();
    } on Exception catch (e) {
      if (e is StripeException) {
        debugPrint("Error from Stripe: ${e.error.localizedMessage}");
      } else {
        debugPrint("Unforcen Error: $e");
      }
    } catch (e) {
      debugPrint("Exception $e");
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculate(amount),
        'currency': "usd",
        'payment_method_types[]': 'card',
      };

      debugPrint("Start Payment Intent http rwq post method $stripeSecretKey");

      var response = await http
          .post(Uri.parse(AppConstants.stripeUrl), body: body, headers: {
        "Authorization": "Bearer $stripeSecretKey",
        "Content-Type": 'application/x-www-form-urlencoded'
      });
      debugPrint("End Payment Intent http rwq post method");
      debugPrint(response.body.toString());

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('err charging user: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> fetchPaymentIntentClientSecret() async {
    final url = Uri.parse('https://api.stripe.com/v1/create-payment-intent');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': 'example@gmail.com',
        'currency': 'usd',
        'items': ['id-1'],
        'request_three_d_secure': 'any',
      }),
    );
    return json.decode(response.body);
  }

  String createPaymentProfile() {
    return '''
    {
      "provider": "google_pay",
      "data": {
        "environment": "TEST",
        "apiVersion": 2,
        "apiVersionMinor": 0,
        "allowedPaymentMethods": [
          {
            "type": "CARD",
            "tokenizationSpecification": {
              "type": "PAYMENT_GATEWAY",
              "parameters": {
                "gateway": "stripe",
                "stripe:version": "2020-08-27",
                "stripe:publishableKey": "$stripeSecretKey"
              }
            },
            "parameters": {
              "allowedCardNetworks": ["VISA", "MASTERCARD"],
              "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
              "billingAddressRequired": true,
              "billingAddressParameters": {
                "format": "FULL",
                "phoneNumberRequired": true
              }
            }
          }
        ],
        "merchantInfo": {
          "merchantId": "01234567890123456789",
          "merchantName": "Example Merchant Name"
        },
        "transactionInfo": {
          "countryCode": "US",
          "currencyCode": "USD"
        }
      }
    }
    ''';
  }

  void savePayment() async {
    Config.vipSubscription = true;
    Config.allSubscription = true;
    Config.stripeStatus = "active";
    updateProStatus();

    Map<String, String> headers = {
      "Content-Type": "application/x-www-form-urlencoded",
    };

    Map<String, String> body = {
      "payment_method": "Stripe",
      "product_id": _subscriptionItem!.productId,
      "user_id": Preferences.getProfileId(),
      "method_name": "savePayment",
    };

    try {
      var response = await http.post(
        Uri.parse(AppConstants.baseURL),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // customProgressDialog.dismiss();
      } else {
        // customProgressDialog.dismiss();
      }
    } catch (error) {
      // customProgressDialog.dismiss();
    }
  }

  calculate(String amount) {
    final a = (double.parse(amount).toInt()) * 100;
    return a.toString();
  }

  // void onGooglePayResult(paymentResult) {
  //   debugPrint(paymentResult.toString());
  // }

  void onApplePayResult(paymentResult) {
    debugPrint(paymentResult.toString());
  }

  ///Load purchased item, in this case subscription
  Future _loadPurchaseItems() async {
    await _fetchSubscription();
    await _fetchStripeSecretKey();
    await _fetchStripePublicKey();
    return _engine
        .getSubscriptions(subscriptionIdentifier.keys.toList())
        .then((value) {
      if (value.isNotEmpty) {
        productItems.addAll(value);
      }
    });
  }

  ///Verify previous purchase, so you'll know if subscription still occurs
  Future _verifyPreviousPurchase() async {
    return _engine.getAvailablePurchases().then((value) async {
      for (var item in value ?? []) {
        await _verifyPurchase(item);
      }
    });
  }

  ///Verify the purchase that made
  Future<bool> _verifyPurchase(PurchasedItem item) async {
    if (Platform.isAndroid) {
      if (item.purchaseStateAndroid == PurchaseState.purchased) {
        if (item.productId != null) {
          _isPro =
              _productItems.map((e) => e.productId).contains(item.productId);
        }
      }
    } else {
      if (item.transactionStateIOS == TransactionState.purchased ||
          item.transactionStateIOS == TransactionState.restored) {
        if (item.productId != null) {
          _isPro = await _engine.checkSubscribed(
            sku: item.productId!,
            duration: subscriptionIdentifier[item.productId!]?["duration"] ??
                Duration.zero,
            grace: subscriptionIdentifier[item.productId!]?["grace_period"] ??
                Duration.zero,
          );
        }
      }
    }

    if (item.transactionDate != null) {
      var different = DateTime.now().difference(item.transactionDate!);
      var subbscriptionDuration =
          subscriptionIdentifier[item.productId!]?["duration"] ?? Duration.zero;
      var graceDuration = subscriptionIdentifier[item.productId!]
              ?["grace_period"] ??
          Duration.zero;
      if (different.inDays > subbscriptionDuration.inDays &&
          different.inDays <
              (subbscriptionDuration.inDays + graceDuration.inDays)) {
        _inGracePeriod = true;
      }
    }
    notifyListeners();
    return _isPro;
  }

  ///Purchasing items
  Future purchase(IAPItem item) {
    return _engine.requestPurchase(item.productId!,
        offerTokenAndroid: item.subscriptionOffersAndroid?.first.offerToken);
  }

  Future<bool> restorePurchase() {
    return _engine.getAvailablePurchases().then((value) async {
      if (value?.isNotEmpty ?? false) {
        for (var element in value!) {
          await _verifyPurchase(element);
        }
        return true;
      }
      return false;
    });
  }

  void updateProStatus() {
    _isPro = (Config.vipSubscription && Config.allSubscription) ||
        Config.noAds ||
        Config.isPremium;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  static IAPProvider read(BuildContext context) => context.read();
  static IAPProvider watch(BuildContext context) => context.read();
}
