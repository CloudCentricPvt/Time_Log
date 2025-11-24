import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:time_log/controllers/login_controller.dart';
import 'package:time_log/utils/constants/k_asstes.dart';
import 'package:time_log/utils/popups/k_material_dialog.dart';

import '../../utils/constants/k_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController _controller = LoginController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isPasswordObscure = true;
  bool _isLoading = false;
  bool _isFormValid = false;
  bool _isHighlightedMessage = false;
  bool _isHighlightedPassword = false;

  @override
  void initState() {
    super.initState();
    _controller.userNameController.addListener(_validateForm);
    _controller.passwordPassController.addListener(_validateForm);
    _focusNode.addListener(() {
      setState(() {
        _isHighlightedMessage = _focusNode.hasFocus;
      });
    });
    _passwordFocusNode.addListener(() {
      setState(() {
        _isHighlightedPassword = _passwordFocusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.appPrimary,
      resizeToAvoidBottomInset: false, // prevent flutter default resize
      body: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              SizedBox(
                height: 300,
                width: double.infinity,
                child: Image.asset(
                  KAssets.login_image,
                  fit: BoxFit.cover,
                ),
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),

                  // outer scroll to avoid overflow
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,   // important
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Welcome Back",
                            style: TextStyle(
                              color: KColors.appPrimary,
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text("Account Login",
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),

                          userLoginForm(),
                          const SizedBox(height: 20),
                          onClickLoginButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///--- user Input field UI i.e User name and Password
  Widget userLoginForm() {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: TextFormField(
            focusNode: _focusNode,
            controller: _controller.userNameController,
            decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isHighlightedMessage = !_isHighlightedMessage;
                    });
                  },
                  icon: _isHighlightedMessage
                      ? SvgPicture.asset(KAssets.highlightedIconMessage)
                      : SvgPicture.asset(KAssets.emailIcon),
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        BorderSide(width: 1, color: KColors.appSecondaryGrey)),
                contentPadding: const EdgeInsets.only(
                    left: 20, top: 10, bottom: 10, right: 10),
                labelText: 'Enter Email',
                labelStyle: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
                hintText: "Enter Email",
                hintStyle: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    fontWeight: FontWeight.normal)),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          height: 50,
          child: TextFormField(
            focusNode: _passwordFocusNode,
            controller: _controller.passwordPassController,
            obscureText: _isPasswordObscure,
            // Toggle password visibility
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        BorderSide(width: 1, color: KColors.appSecondaryGrey)),
                contentPadding: const EdgeInsets.only(
                    left: 20, top: 10, bottom: 10, right: 10),
                labelText: 'Enter Password',
                labelStyle: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
                hintText: "Enter Password",
                hintStyle: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isHighlightedPassword = !_isHighlightedPassword;
                      _isPasswordObscure = !_isPasswordObscure;
                    });
                  },
                  icon: _isHighlightedPassword
                      ? SvgPicture.asset(KAssets.highlightedIconPassword)
                      : SvgPicture.asset(KAssets.eyeIcon),
                )),

            style: const TextStyle(),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        InkWell(
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Forgot Password?",
                style: TextStyle(
                  color: KColors.appPrimary,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          onTap: () {
            KMaterialDialogs.noInternetFound(
              context,
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "OK",
                  style: TextStyle(color: KColors.appPrimary),
                ),
              ),
              "Alert!",
              "Please contact your reporting manager.",
            );
          },
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  void _validateForm() {
    final isValid = _controller.userNameController.text.isNotEmpty &&
        _controller.passwordPassController.text.isNotEmpty;
    setState(() {
      _isFormValid = isValid;
    });
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
      onPressed: (!_isFormValid || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });

              await _controller.login(
                context,
                _controller.userNameController.text.trim(),
                _controller.passwordPassController.text.trim(),
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
                  fontSize: 16,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w500),
            ),
    );
  }

  @override
  void dispose() {
    _controller.userNameController.removeListener(_validateForm);
    _focusNode.dispose();
    _passwordFocusNode.dispose();
    _controller.passwordPassController.removeListener(_validateForm);
    super.dispose();
  }
}
