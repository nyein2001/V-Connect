import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ndvpn/assets.dart';
import 'package:ndvpn/core/resources/colors.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:ndvpn/ui/screens/forgot_password_screen/bloc/forget_password_bloc.dart';
import 'package:ndvpn/ui/screens/register_screen/register_screen.dart';
part 'mixin/forgot_password_mixin.dart';

final class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with _ForgotPasswordMixin {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgetPasswordBloc(),
      child: BlocListener<ForgetPasswordBloc, ForgetPasswordState>(
        listener: (context, state) {
          if (state is ForgetPasswordInitial) {
            customLoadingDialog(context);
          }
          if (state is ForgetPasswordFail) {
            alertBox(state.message, context);
          }
          if (state is ForgetPasswordSuccess) {
            alertBox(state.message, context);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text(
              "Forgot  Password",
              style: TextStyle(
                  fontSize: 20, letterSpacing: 1, fontWeight: FontWeight.w600),
            ),
            centerTitle: false,
          ),
          body: Stack(children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              height: MediaQuery.of(context).size.height / 10,
            ),
            SingleChildScrollView(
              child: SafeArea(
                minimum:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        FractionallySizedBox(
                            widthFactor: .35,
                            alignment: Alignment.center,
                            child: PhysicalModel(
                                color: Colors.white,
                                elevation: 5,
                                borderRadius: BorderRadius.circular(12),
                                shadowColor: secondaryShade,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(Assets.logo_png,
                                        filterQuality: FilterQuality.medium)))),
                        const SizedBox(height: 16),
                        const Text('Forgot  Password',
                            style: TextStyle(
                                fontSize: 22,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        const Padding(
                          padding: EdgeInsets.only(top: 15),
                          child: Center(
                            child: Text(
                              "Enter your email address below and we'll send you email with instructions on how to change your password",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          children: [
                            RegisterTextFormFieldWidget(
                              hintText: 'E-mail',
                              prefixIcon: Icons.email,
                              controller: _emailController,
                              autofillHints: const [AutofillHints.email],
                              textCapitalization: TextCapitalization.none,
                              textInputAction: TextInputAction.next,
                              validator: isEmailValid,
                            ),
                          ].map((e) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: e.build(context),
                            );
                          }).toList(),
                        )),
                    Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: ElevatedButton(
                          onPressed: submitButton,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 32),
                            shape: const StadiumBorder(),
                          ),
                          child: Text('SUBMIT',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.w400)),
                        )),
                  ],
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
