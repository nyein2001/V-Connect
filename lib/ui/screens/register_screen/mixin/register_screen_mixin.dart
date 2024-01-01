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
  String deviceid = Preferences.getDeviceId();
  String status = '';
  String name = '';
  String email = '';
  String password = '';
  String phoneNo = '';
  String reference = '';
  String otp = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkOtp();
    });
  }

  void checkOtp() async {
    loadingBox(context);
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
          status = data['otp_status'];
        }
      } else {
        alertBox('Failed. Try again.', context);
      }
    } catch (e) {
      alertBox('Server timeout', context);
    }
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
    name = _nameController.text;
    email = _emailController.text;
    password = _passwordController.text;
    phoneNo = _phoneController.text;
    reference = _referenceCodeController.text;
    if (name == '' || name.isEmpty) {
      validate();
    } else if (!_checkEmail(email) || email.isEmpty) {
      validate();
    } else if (password == '' || password.isEmpty) {
      validate();
    } else if (phoneNo == '' || phoneNo.isEmpty) {
      validate();
    } else if (reference == '' || reference.isEmpty) {
      validate();
    } else {
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _phoneController.clear();
      _referenceCodeController.clear();
      bool isConnected = await networkInfo.isConnected;
      if (isConnected) {
        if (status == "true") {
          loadingBox(context);
          // verificationCall(email, generateOTP().toString());
          otp = generateOTP().toString();
          BlocProvider.of<RegisterBloc>(context)
              .add(VerificationCall(email: email, otp: otp));
        } else {
          // addToRegistation(name, email, password, phoneNo, reference);
          BlocProvider.of<RegisterBloc>(context).add(RegistationCall(
              deviceid: deviceid,
              name: name,
              email: email,
              passwrod: password,
              phoneNo: phoneNo,
              reference: reference));
        }
      } else {
        alertBox("Internet connection not available", context);
      }
    }
  }

  void verificationCall(String sentEmail, String otp) async {
    loadingBox(context);
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
        if (jsonResponse.containsKey('status')) {
          String message = jsonResponse['message'];
          alertBox(message, context);
        } else {
          Map<String, dynamic> data = jsonResponse[AppConstants.tag];
          String msg = data['msg'];
          String success = data['success'];
          if (success == '1') {
            Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_SHORT);
            Preferences.setVerification(isVerification: true);
            Preferences.setName(name: name);
            Preferences.setEmail(email: email);
            Preferences.setPassword(password: password);
            Preferences.setPhone(phoneNO: phoneNo);
            Preferences.setReference(reference: reference);
            Preferences.setOtp(verificationCode: otp);
            startScreen(
                context,
                VerificationScreen(
                  name: name,
                  email: email,
                  password: password,
                  phoneNO: phoneNo,
                  reference: reference,
                ));
          } else {
            alertBox(msg, context);
          }
        }
      }
    } on Exception catch (_) {}
  }

  void addToRegistation(String name, String email, String password,
      String phone, String reference) async {
    String deviceId = Preferences.getDeviceId();
    loadingBox(context);
    String methodBody = jsonEncode({
      'sign': AppConstants.sign,
      'salt': AppConstants.randomSalt.toString(),
      'package_name': AppConstants.packageName,
      'method_name': 'user_register',
      'type': 'normal',
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
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
        if (success == '1') {
          replaceScreen(context, const LoginScreen());
        }
        Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_SHORT);
      }
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
