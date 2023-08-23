import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../routes.dart';
import 'auth_base.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    String subtitle =
        "The best online reservation and ticketing system. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur ornare nunc odio, et rhoncus ante consectetur id";
    return AuthBase(
        background: "assets/Images/Welcome_BG.png",
        subTitle: subtitle,
        getStarted: true,
        children: [
          SizedBox(height: 100.h),
          Image.asset(
            "assets/Images/Welcome.png",
            fit: BoxFit.cover,
          ),
          SizedBox(height: 350.h),
          Center(
            child: ElevatedButton(
                onPressed: () {
                  Get.toNamed(RoutesConstant.signUp);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(168, 0, 0, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 40.r, vertical: 25.r),
                  child: Text(
                    'Get Started',
                    style: TextStyle(fontSize: 80.sp),
                  ),
                )),
          )
        ]);
  }
}
