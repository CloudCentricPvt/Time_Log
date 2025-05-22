import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:time_log/controllers/login_controller.dart';
import 'package:time_log/utils/constants/k_asstes.dart';

import '../../utils/constants/k_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController _controller = LoginController();
  bool _isPasswordObscure = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: KColors.appPrimary,
        body: Column(
          children: [
            ///image column.....
            SizedBox(
              height: 350,
              child: Image.asset(
                KAssets.login_image,
              ),
            ),
            /// card  .....
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Card(
                  margin: EdgeInsets.zero, // REMOVE extra space outside the card
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  elevation: 0,
                  color: Colors.white,
                  /// design part of inside card.....
                  child: Padding(
                    padding:
                    EdgeInsets.only(top: 51, left: 21, right: 21, bottom: 21),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                              color: Color(0XFF38C4FF),
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Account Login",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          /// Login Box....
                          userLoginForm(),
                          onClickLoginButton()

                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }

  ///--- user Input field UI i.e User name and Password
  Widget userLoginForm() {
    return Column(
      children: [
        TextFormField(
          controller: _controller.userNameController,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isPasswordObscure =
                      !_isPasswordObscure; // Toggle the password visibility
                });
              },
              icon: SvgPicture.asset(
                _isPasswordObscure ? KAssets.emailIcon : '',
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            contentPadding:
                const EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 10),
            labelText: 'Enter Username or Email',
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        TextFormField(
          controller: _controller.passwordPassController,
          obscureText: _isPasswordObscure, // Toggle password visibility
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              contentPadding: const EdgeInsets.only(
                  left: 20, top: 10, bottom: 10, right: 10),
              labelText: 'Enter Password',
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _isPasswordObscure =
                        !_isPasswordObscure; // Toggle the password visibility
                  });
                },
                icon: SvgPicture.asset(
                  _isPasswordObscure ? KAssets.eyeIcon : KAssets.eyeClose,
                ),
              )),

          style: const TextStyle(),
        ),
        const SizedBox(
          height: 20,
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Forgot Password?",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  ///--- Login button UI and click for action perform
  Widget onClickLoginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: KColors.appPrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 0),
      ),
      onPressed: _isLoading
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });

              await _controller.login(
                context,
                _controller.userNameController.text,
                _controller.passwordPassController.text,
              );

              setState(() {
                _isLoading = false;
              });
            },
      child: _isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(KColors.appPrimaryRed),
                strokeWidth: 4,
              ),
            )
          : const Text(
              "LOGIN NOW",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
    );
  }
}
