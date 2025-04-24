import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:time_log/controllers/login_controller.dart';
import 'package:time_log/utils/constants/k_asstes.dart';
import 'package:time_log/utils/constants/k_loader.dart';

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
    //changeStatusBarColor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.appPrimary,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: KColors.appSecondary,
        ),
        body: Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.55, // Adjust height dynamically (55% of screen)
            widthFactor: 1.0, // Full width
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                border: Border.all(
                  // **Stroke (Border) instead of Shadow**
                  color: Colors.grey.shade300, // Light grey border
                  width: 1.5, // Adjust stroke thickness
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome Back",
                            style: TextStyle(color: Colors.blue, fontSize: 14),
                          ),
                        ],
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Account Login",
                            style:
                                TextStyle(color: Colors.black, fontSize: 22.5),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
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
                          contentPadding: const EdgeInsets.only(
                              left: 20, top: 10, bottom: 10, right: 10),
                          labelText: 'Enter Username or Email',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _controller.passwordPassController,
                        obscureText: true, // Toggle password visibility
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
                                _isPasswordObscure
                                    ? KAssets.eyeIcon
                                    : KAssets.eyeClose,
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
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            // Wrap content height
                            minimumSize: const Size(
                                double.infinity, 0), // Match parent width
                          ),
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  await _controller.login(context, _controller.userNameController.text, _controller.passwordPassController.text);

                                  setState(() {
                                    _isLoading = false;
                                  });
                                },
                          child: _isLoading ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(KColors.appPrimaryRed),
                            strokeWidth: 4,
                      ),

                          )
                          :const Text(
                            "LOGIN NOW",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
