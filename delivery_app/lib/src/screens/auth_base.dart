import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthBase extends StatefulWidget {
  AuthBase({
    super.key,
    required this.subTitle,
    required this.background,
    required this.children,
    this.reversed = false,
    this.getStarted = false,
  });

  final String subTitle;
  final String background;
  final List<Widget> children;
  final bool getStarted;
  final bool reversed;

  @override
  State<AuthBase> createState() => _AuthBaseState();
}

class _AuthBaseState extends State<AuthBase> {
  final bool border = false;
  bool isKeyboardVisible = false;

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    if (mediaQueryData.viewInsets.bottom > 0) {
      isKeyboardVisible = true;
    } else {
      isKeyboardVisible = false;
    }
    return Column(
      children: [
        Container(
            margin: EdgeInsets.symmetric(vertical: 300.h, horizontal: 95.w),
            padding: EdgeInsets.symmetric(vertical: 70.h, horizontal: 50.w),
            decoration: border
                ? BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                isKeyboardVisible
                    ? const SizedBox()
                    : Container(
                        padding: EdgeInsets.only(bottom: 55.h),
                        child: Image(
                          image: const AssetImage(
                            'assets/images/logo_light.png',
                          ),
                          width: 250.w,
                          height: 250.h,
                        ),
                      ),
                isKeyboardVisible
                    ? const SizedBox()
                    : Text(
                        'Nala Delivery',
                        style: TextStyle(
                          fontSize: 100.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Inter",
                          color:
                              !widget.getStarted ? Colors.white : Colors.black,
                        ),
                      ),
                isKeyboardVisible
                    ? const SizedBox()
                    : Padding(
                        padding: EdgeInsets.symmetric(vertical: 100.h),
                        child: Text(
                          widget.subTitle,
                          style: TextStyle(
                            fontSize: 50.sp,
                            fontFamily: "Inter",
                            color: !widget.getStarted
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                ...widget.children,
              ],
            ))
      ],
    );
  }
}
