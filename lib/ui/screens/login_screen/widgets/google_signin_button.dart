import 'package:flutter/material.dart';
import 'package:ndvpn/core/utils/navigations.dart';
import 'package:ndvpn/main.dart';
import 'package:ndvpn/ui/screens/main_screen.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  GoogleSignInButtonState createState() => GoogleSignInButtonState();
}

class GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: _isSigningIn
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : OutlinedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Theme.of(context).cardColor),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              onPressed: () async {
                setState(() {
                  _isSigningIn = true;
                });
                googleSignIn();
                setState(() {
                  _isSigningIn = false;
                });
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 10, 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.g_mobiledata),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Login With Gmail',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> googleSignIn() async {
    await authService.signInWithGoogle(context).then((value) async {
      replaceScreen(context, const MainScreen());
    }).catchError((e) {
      print('Error in googleSignIn : $e');
    });
  }
}
