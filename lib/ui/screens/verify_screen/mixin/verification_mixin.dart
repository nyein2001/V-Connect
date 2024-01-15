part of '../verification_screen.dart';

mixin _VerificationMixin on State<VerificationScreen> {
  final TextEditingController optController = TextEditingController();
  String name = '';
  String email = '';
  String password = '';
  String phoneNO = '';
  String reference = '';
  String pinText = '';
  String deviceId = Preferences.getDeviceId();
  late CustomProgressDialog customProgressDialog;

  @override
  void initState() {
    customProgressDialog =
        CustomProgressDialog(context, dismissable: false, onDismiss: () {});
    if (widget.name != null) {
      name = widget.name!;
      email = widget.email!;
      password = widget.password!;
      phoneNO = widget.phoneNO!;
      reference = widget.reference!;
    } else {
      name = Preferences.getName();
      email = Preferences.getEmail();
      password = Preferences.getPassword();
      phoneNO = Preferences.getPhoneNo();
      reference = Preferences.getReference();
    }
    super.initState();
  }

  @override
  void dispose() {
    optController.dispose();
    super.dispose();
  }

  void vertification() async {
    pinText = optController.text;
    if (pinText == '' || pinText.isEmpty) {
      alertBox('enter_verification_code_msg'.tr(), false, context);
    } else {
      bool isConnected = await networkInfo.isConnected;
      if (isConnected) {
        optController.clear();
        String text = Preferences.getOtp();
        if (pinText == text) {
          customProgressDialog.show();
          register(name, email, password, phoneNO, reference);
        } else {
          alertBox('verfication_not_match'.tr(), false, context);
        }
      } else {
        alertBox("no_internet_msg".tr(), false, context);
      }
    }
  }

  void register(String sendName, String sendEmail, String sendPassword,
      String sendPhone, String reference) async {
    String methodBody = jsonEncode({
      'sign': AppConstants.sign,
      'salt': AppConstants.randomSalt.toString(),
      'package_name': AppConstants.packageName,
      'method_name': 'user_register',
      'type': 'normal',
      'name': sendName,
      'email': sendEmail,
      'password': sendPassword,
      'phone': sendPhone,
      'device_id': deviceId,
      'user_refrence_code': reference
    });

    http.Response response = await http.post(
      Uri.parse(AppConstants.baseURL),
      body: {'data': base64Encode(utf8.encode(methodBody))},
    ).then((value) {
      customProgressDialog.dismiss();
      return value;
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('status')) {
        String message = jsonResponse['message'];
        alertBox(message, false, context);
      } else {
        Map<String, dynamic> data = jsonResponse[AppConstants.tag];
        String msg = data['msg'];
        String success = "${data['success']}";
        Preferences.setVerification(isVerification: false);
        if (success == '1') {
          startScreen(context, const LoginScreen());
        } else {
          startScreen(context, const RegisterScreen());
        }
        Fluttertoast.showToast(
          msg: msg,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    }
  }

  void resendVerification() {
    String? emailString = Preferences.getEmail();
    if (emailString.isNotEmpty) {
      verificationCall(emailString, generateOTP().toString());
    }
  }

  void verificationCall(String sentEmail, String otp) async {
    customProgressDialog.show();
    optController.clear();
    String methodBody = jsonEncode({
      'sign': AppConstants.sign,
      'salt': AppConstants.randomSalt.toString(),
      'package_name': AppConstants.packageName,
      'method_name': 'user_register_verify_email',
      'email': sentEmail,
      'otp_code': otp
    });

    try {
      http.Response response = await http.post(
        Uri.parse(AppConstants.baseURL),
        body: {'data': base64Encode(utf8.encode(methodBody))},
      ).then((value) {
        customProgressDialog.dismiss();
        return value;
      });
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey(AppConstants.status)) {
          String message = jsonResponse['message'];
          alertBox(message, false, context);
        } else {
          Map<String, dynamic> data = jsonResponse[AppConstants.tag];
          String msg = data['msg'];
          String success = "${data['success']}";
          if (success == '1') {
            Preferences.setOtp(verificationCode: otp);
          }
          alertBox(msg, false, context);
        }
      }
    } on Exception catch (_) {}
  }

  int generateOTP() {
    Random random = Random();
    return random.nextInt(9000) + 1000;
  }
}
