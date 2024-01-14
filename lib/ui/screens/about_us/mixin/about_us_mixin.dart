part of '../about_us_screen.dart';

mixin _AboutUsMixin on State<AboutUsScreen> {
  GlobalKey key = GlobalKey();
  String appFaq = 'appFaq';
  String text = '',
      appName = '',
      appLogo = '',
      appVersion = '',
      appAuthor = '',
      appContact = '',
      appEmail = '',
      appWebsite = '',
      appDes = '';

  @override
  void initState() {
    super.initState();
    callData();
  }

  void callData() async {
    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      getRefCode();
    } else {
      alertBox("Internet connection not available", false, context);
    }
  }

  Future<void> getRefCode() async {
    ReqWithUserId req = ReqWithUserId(methodName: 'app_about');
    String methodBody = jsonEncode(req.toJson());
    CustomProgressDialog customProgressDialog =
        CustomProgressDialog(context, dismissable: false, onDismiss: () {});
    customProgressDialog.show();
    try {
      http.Response response = await http.post(
        Uri.parse(AppConstants.baseURL),
        body: {'data': base64Encode(utf8.encode(methodBody))},
      ).then((value) {
        customProgressDialog.dismiss();
        return value;
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);

        if (jsonData.containsKey("status")) {
          String status = jsonData["status"];
          String message = jsonData["message"];

          if (status == "-2") {
            replaceScreen(context, const LoginScreen());
            alertBox(message, false, context);
          } else {
            alertBox(message, false, context);
          }
        } else {
          Map<String, dynamic> data = jsonData[AppConstants.tag];
          String success = '${data['success']}';
          if (success == "1") {
            appFaq = data["app_description"];
            appName = data["app_name"];
            appLogo = data["app_logo"];
            appVersion = data["app_version"];
            appAuthor = data["app_author"];
            appContact = data["app_contact"];
            appEmail = data["app_email"];
            appWebsite = data["app_website"];
            text = '''
            <html>
              <head>
                <style type="text/css">
                  @font-face {
                    font-family: MyFont;
                    src: url("file:///android_asset/fonts/opensans_semi_bold.TTF");
                  }
                  p {
                    color: white;
                    text-indent: 30px;
                  }
                  body {
                    font-family: MyFont;
                    color: #fffffff;
                    line-height: 1.6;
                  }
                  a {
                    color: #fffffff;
                    text-decoration: none;
                  }
                </style>
              </head>
              <body>
               $appFaq
              </body>
            </html>
          ''';

            setState(() {});
          }
        }
      }
    } catch (error) {
      print("Error updateUIWithData  $error");
    }
  }
}
