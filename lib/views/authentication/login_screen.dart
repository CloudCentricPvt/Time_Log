import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
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
                margin: EdgeInsets.zero,
                // REMOVE extra space outside the card
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
              borderRadius: BorderRadius.circular(12.0),
            ),
            contentPadding:
                const EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 10),
            labelText: 'Enter Email',
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        TextFormField(
          focusNode: _passwordFocusNode,
          controller: _controller.passwordPassController,
          obscureText: _isPasswordObscure,
          // Toggle password visibility
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
                  color: Colors.blue,
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
    return
      ElevatedButton(
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
                fontSize: 18,
              ),
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
