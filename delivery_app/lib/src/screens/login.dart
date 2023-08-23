import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../controller/login_controller.dart';
import '../routes.dart';
import 'auth_base.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final GlobalKey<FormState> logInFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find();
    String subtitle =
        "Nala Delivery app for drivers only. Please login to continue.";

    return ScaffoldMessenger(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color(0xFFdbdde1),
          body: DecoratedBox(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/LoginBG.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: AuthBase(
                  background: "assets/images/LoginBG.png",
                  subTitle: subtitle,
                  children: [
                    SizedBox(height: 80.h),
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 95.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Inter",
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 80.h),
                    Form(
                      key: logInFormKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            focusNode: emailFocusNode,
                            controller: loginController.emailController,
                            validator: ValidationBuilder()
                                .email()
                                .maxLength(50)
                                .build(),
                            onFieldSubmitted: (value) {
                              passwordFocusNode.requestFocus();
                            },
                            decoration: InputDecoration(
                              hintText: 'Johndoe@gmail.com',
                              hintStyle: TextStyle(
                                fontSize: 50.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Inter",
                                color: Colors.grey[600],
                              ),
                              fillColor:
                                  const Color.fromARGB(200, 255, 255, 255),
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 2),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14)),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14)),
                              ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14)),
                              ),
                            ),
                          ),
                          SizedBox(height: 50.h),
                          TextFormField(
                            obscureText: true,
                            focusNode: passwordFocusNode,
                            controller: loginController.passwordController,
                            validator: ValidationBuilder()
                                .minLength(6, 'Password Length < 6 😟')
                                .build(),
                            onFieldSubmitted: (value) {
                              if (logInFormKey.currentState!.validate())
                                loginController.login();
                            },
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                fontSize: 50.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Inter",
                                color: Colors.grey[600],
                              ),
                              fillColor:
                                  const Color.fromARGB(200, 255, 255, 255),
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 2),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14)),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14)),
                              ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14)),
                              ),
                            ),
                          ),
                          SizedBox(height: 50.h),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(height: 100.h),
                        GetBuilder<LoginController>(builder: (loginController) {
                          return RoundedLoadingButton(
                            color: const Color(0xFF3e4c45),
                            controller: loginController.btnController,
                            onPressed: () async {
                              if (logInFormKey.currentState!.validate()) {
                                if (!await loginController.login()) {
                                  const SnackBar(
                                      content: Text("Sign Up Failed"));
                                }
                              } else {
                                Future.delayed(const Duration(seconds: 1), () {
                                  loginController.btnController.reset();
                                });
                              }
                            },
                            child: const Text('Login',
                                style: TextStyle(color: Colors.white)),
                          );
                        }),
                        SizedBox(height: 170.h),
                        Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 50.sp,
                            fontFamily: "Inter",
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 45.h),
                        Text.rich(
                          TextSpan(
                            text: 'Don\'t have an account? ',
                            style: TextStyle(
                              fontSize: 50.sp,
                              fontFamily: "Inter",
                              color: Colors.white,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Get.toNamed(RoutesConstant.signUp);
                                  },
                                text: 'Sign Up',
                                style: TextStyle(
                                  fontSize: 50.sp,
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[300],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
