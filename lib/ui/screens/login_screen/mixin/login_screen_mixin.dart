part of '../login_screen.dart';

mixin _LoginScreenMixin on State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final bool isCheck = true;
  String prefemail = 'pref_email';
  String prefname = 'pref_name';
  String prefpassword = 'pref_password';
  String prefcheck = 'pref_check';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
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

  bool _checkEmail(String email) {
    String pattern = r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  Future<void> login() async {
    if (!_checkEmail(_emailController.text) || _emailController.text.isEmpty) {
    } else if (_passwordController.text.isEmpty) {
    } else {
      loginFun(_emailController.text, _passwordController.text, isCheck);
    }
  }

  void loginFun(String email, String password, bool isCheck) async {
    UserLoginReq req = UserLoginReq(email: email, password: password);
    String requestBody = jsonEncode(req.toJson());
    try {
      http.Response response = await http.post(
        Uri.parse(AppConstants.baseURL),
        body: {'data': base64Encode(utf8.encode(requestBody))},
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('status')) {
          String message = jsonResponse['message'];
          alertBox(message, context);
        } else {
          // 0:"user_id" -> "55"
          // 1:"name" -> "naing"
          // 2:"email" -> "naingthurakyaw6@gmail.com"
          // 3:"msg" -> "Login successfully."
          // 4:"auth_id" -> ""
          // 5:"success" -> "1"
          // 6:"no_ads" -> 0
          // 7:"premium_servers" -> 0
          // 8:"is_premium" -> "0"
          // 9:"perks" -> ""
          // 10:"exp" -> ""
          // 11:"stripe" -> ""
          Map<String, dynamic> data = jsonResponse[AppConstants.tag];
          String msg = data['msg'];
          String success = data['success'];
          if (success == '1') {
            String userid = data['user_id'];
            String name = data['name'];
            String email = data['email'];
            String stripe = data['stripe'];

            if (stripe != '') {
              var striptObject = jsonDecode(stripe);
              String striptJson = striptObject['stripe'];
            }
            Preferences.setName(name: name);
            Preferences.setEmail(email: email);
            if (isCheck) {
              Preferences.setPassword(password: password);
              Preferences.setCheck(isCheck: isCheck);
            }
            Preferences.setProfileId(profileId: userid);
            replaceScreen(context, const MainScreen());
          } else {
            alertBox(msg, context);
          }
        }
      }
    } catch (e) {
      print('Failed try again $e');
      alertBox('Failed try again ', context);
    }
  }
}
