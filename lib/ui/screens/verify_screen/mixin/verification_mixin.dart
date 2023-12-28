part of '../verification_screen.dart';

mixin _VerificationMixin on State<VerificationScreen> {
  final TextEditingController optController = TextEditingController();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String name = '';
  String email = '';
  String password = '';
  String phoneNO = '';
  String reference = '';
  String deviceId = '';
  String pinText = '';

  @override
  void initState() {
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
    } on Exception catch (_) {
      deviceId = 'Not Found';
    }
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
      alertBox('Please enter verification code', context);
    } else {
      bool isConnected = await networkInfo.isConnected;
      if (isConnected) {
        optController.clear();
        if (pinText == Preferences.getOtp()) {
          loadingBox(context);
          register(name, email, password, phoneNO, reference);
        } else {
          alertBox('Verification code does not match', context);
        }
      } else {
        alertBox("Internet connection not available", context);
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
      closeScreen(context);
      return value;
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('status')) {
        String message = jsonResponse['message'];
        alertBox(message, context);
      } else {
        Map<String, dynamic> data = jsonResponse[AppConstants.tag];
        String msg = data['msg'];
        String success = data['success'];
        Preferences.setVerification(isVerification: false);
        if (success == '1') {
          replaceScreen(context, const LoginScreen());
        } else {
          replaceScreen(context, const RegisterScreen());
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
    loadingBox(context);
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
        closeScreen(context);
        return value;
      });
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey(AppConstants.status)) {
          String message = jsonResponse['message'];
          alertBox(message, context);
        } else {
          Map<String, dynamic> data = jsonResponse[AppConstants.tag];
          String msg = data['msg'];
          String success = data['success'];
          if (success == '1') {
            Preferences.setOtp(verificationCode: otp);
          }
          alertBox(msg, context);
        }
      }
    } on Exception catch (_) {}
  }

  int generateOTP() {
    Random random = Random();
    return random.nextInt(9000) + 1000;
  }
}
