part of '../register_screen.dart';

mixin _RegisterScreenMixin on State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _referenceCodeController =
      TextEditingController();
  String status = '';

  @override
  void initState() {
    checkOtp();
    super.initState();
  }

  void checkOtp() async {
    String methodBody = jsonEncode({
      'sign': AppConstants.sign,
      'salt': AppConstants.randomSalt.toString(),
      'package_name': AppConstants.packageName,
      'method_name': 'otp_status',
    });

    try {
      http.Response response = await http.post(
        Uri.parse(AppConstants.baseURL),
        body: {'data': base64Encode(utf8.encode(methodBody))},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('status')) {
          String message = jsonResponse['message'];
          showAlertBox(message);
        } else {
          Map<String, dynamic> data = jsonResponse[AppConstants.tag];
          status = data['otp_status'];
        }
      } else {
        showAlertBox('Failed. Try again.');
      }
    } catch (e) {
      showAlertBox('Server timeout');
    }
  }

  void showAlertBox(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _referenceCodeController.dispose();

    super.dispose();
  }

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void setPassVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void setConfirmPassVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  bool validate() {
    _formKey.currentState?.save();
    if (_formKey.currentState!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  String? isNameValid(String? value) {
    if (value?.isEmpty == true) {
      return 'Please enter your name';
    } else if ((value?.length ?? 0) < 3) {
      return 'Name must be at least 3 characters long';
    } else {
      return null;
    }
  }

  String? isEmailValid(String? value) {
    if (value?.isEmpty == true) {
      return 'Please enter your email';
    } else if (!_checkEmail(value ?? '')) {
      return 'Please enter a valid email';
    } else {
      return null;
    }
  }

  String? isPasswordValid(String? value) {
    if (value?.isEmpty == true) {
      return 'Please enter your password';
    } else if ((value?.length ?? 0) < 3) {
      return 'Password must be at least 3 characters long';
    } else {
      return null;
    }
  }

  String? isConfirmPasswordValid(String? value) {
    if (value?.isEmpty == true) {
      return 'Please enter your password';
    } else if ((value?.length ?? 0) < 3) {
      return 'Password must be at least 3 characters long';
    } else if (_passwordController.text != _confirmPasswordController.text) {
      return 'Password does not match';
    } else {
      return null;
    }
  }

  String? isPhoneValid(String? value) {
    if (value?.isEmpty == true) {
      return 'Please enter your phone number';
    } else if ((value?.length ?? 0) < 10) {
      return 'Phone number must be at least 10 characters long';
    } else {
      return null;
    }
  }

  bool _checkEmail(String email) {
    String pattern = r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  Future<void> register() async {
    if (status == "true") {
      verificationCall(_emailController.text, generateOTP().toString());
    } else {
      addToRegistation(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
          _phoneController.text,
          _referenceCodeController.text);
    }
  }

  void verificationCall(String sentEmail, String otp) async {
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
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('status')) {
          String message = jsonResponse['message'];
          showAlertBox(message);
        } else {
          Map<String, dynamic> data = jsonResponse[AppConstants.tag];
          String msg = data['msg'];
          String success = data['success'];
          if (success == '1') {
          } else {
            showAlertBox(msg);
          }
        }

//         "

//  {
//     "ANDROID_REWARDS_APP": {
//         "msg": "OTP has been sent on your mail.",
//         "success": "1"
//     }
// }"
      }
    } on Exception catch (_) {}
  }

  void addToRegistation(String name, String email, String password,
      String phone, String reference) async {
    String deviceId = '';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
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
    } catch (e) {
      deviceId = 'Not Found';
    }
    String methodBody = jsonEncode({
      'sign': AppConstants.sign,
      'salt': AppConstants.randomSalt.toString(),
      'package_name': AppConstants.packageName,
      'method_name': 'user_register',
      'type': 'normal',
      'name': name, //naing
      'email': email, //naingthurakyaw6@gmail.com
      'password': password, //naingnaing
      'phone': phone,
      'device_id': deviceId,
      'user_refrence_code': reference
    });
    http.Response response = await http.post(
      Uri.parse(AppConstants.baseURL),
      body: {'data': base64Encode(utf8.encode(methodBody))},
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('status')) {
        String message = jsonResponse['message'];
        showAlertBox(message);
      } else {
        Map<String, dynamic> data = jsonResponse[AppConstants.tag];
        String msg = data['msg'];
        String success = data['success'];
        if (success == '1') {
          replaceScreen(context, const LoginScreen());
        } else {
          showAlertBox(msg);
        }
      }
//         "

//  {
//     "ANDROID_REWARDS_APP": {
//         "msg": "Registration successfully.",
//         "success": "1"
//     }
// }"
    }
  }

  int generateOTP() {
    Random random = Random();
    return random.nextInt(9000) + 1000;
  }

  Future<void> verifyEmail() async {
    if (validate()) {
      await RegisterHttp(context)
          .verifyEmail(body: getVerificationEmailData())
          .then((value) {
        debugPrint('value: $value');
      });
    }
  }

  getVerificationEmailData() {
    final data = json.encode({
      'method_name': 'user_register_verify_email',
      'email': _emailController.text.trim(),
      'otp_code': '123456'
    });

    String jsonString = jsonEncode(data);
    // Encode the string to base64
    String base64String = base64Encode(utf8.encode(jsonString));

    return ({'data': base64String});
  }
}
