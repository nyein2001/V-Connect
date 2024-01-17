part of '../redeem_screen.dart';

mixin _RedeemMixin on State<RedeemScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  String code = '';

  String? isCodeValid(String? value) {
    if (value?.isEmpty == true) {
      return 'Please enter code';
    } else if ((value?.length ?? 0) < 3) {
      return 'Name must be at least 3 characters long';
    } else {
      return null;
    }
  }

  bool validate() {
    _formKey.currentState?.save();
    if (_formKey.currentState!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  void redeemProcess() async {
    code = _codeController.text;
    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      if (Preferences.isLogin()) {
        redeem();
      }
    } else {
      alertBox("no_internet_msg".tr(), false, context);
    }
  }

  Future<void> redeem() async {
    RedeemReq req =
        RedeemReq(methodName: 'redeem_code', code: _codeController.text);
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
        _codeController.clear();
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
          String success = "${data['success']}";
          String msg = data['msg'];
          if (success == "1") {
            String noAds = "${data['no_ads']}";
            String premiumServers = "${data['premium_servers']}";
            String perks = data['perks'];
            String exp = data['exp'];

            Config.noAds = noAds == "1";
            Config.premiumServersAccess = premiumServers == "1";
            Config.perks = perks;
            Config.expiration = exp;

            _showRedeemDialog(
                title: 'Success!',
                perks: perks,
                exp: exp,
                btn: 'Back To Home',
                isFinish: true);
          } else {
            alertBox(msg, false, context);
          }
          setState(() {});
        }
      } else {
        _codeController.clear();
      }
    } catch (error) {
      _codeController.clear();
      print("Error updateUIWithData  $error");
    }
  }

  void btnRedeemStatus() {
    if (Config.perks == "") {
      alertBox("no_redeem_code_msg".tr(), false, context);
    } else {
      _showRedeemDialog(
          title: 'redeem_status'.tr(),
          perks: Config.perks,
          exp: Config.expiration,
          btn: 'close'.tr(),
          isFinish: false);
    }
  }

  void _showRedeemDialog(
      {required String title,
      required String perks,
      required String exp,
      required String btn,
      required bool isFinish}) async {
    return NAlertDialog(
      blur: 10,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Icon(Icons.card_giftcard),
          Text(
            title,
            style: const TextStyle(
                color: Color(0xff0D1543),
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ).tr()
        ],
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text('perks').tr(),
              const SizedBox(
                width: 10,
              ),
              Text(
                perks,
                style: const TextStyle(
                    color: Color(0xff0D1543),
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text('valid_until').tr(),
              const SizedBox(
                width: 10,
              ),
              Text(
                exp,
                style: const TextStyle(
                    color: Color(0xff0D1543),
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              )
            ],
          )
        ],
      ),
      actions: [
        SizedBox(
          height: 50,
          child: TextButton(
            onPressed: () {
              closeScreen(context);
              if (isFinish) {
                replaceScreen(context, const MainScreen());
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xff0D1543),
              backgroundColor: const Color(0xff0D1543).withOpacity(0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(btn),
          ),
        ),
      ],
    ).show(context);
  }
}
