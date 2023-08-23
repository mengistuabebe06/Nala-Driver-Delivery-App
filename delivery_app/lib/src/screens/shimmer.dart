import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidgets extends StatelessWidget {
  final double width;
  final double height;
  final Color baseColor;
  final Color highlightColor;
  final ShapeBorder shapeBorder;

  const ShimmerWidgets.rectangular(
      {super.key,
      required this.height,
      this.width = double.infinity,
      required this.baseColor,
      required this.highlightColor})
      : shapeBorder = const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)));

  const ShimmerWidgets.square(
      {super.key,
      this.height = double.infinity,
      this.width = double.infinity,
      required this.baseColor,
      required this.highlightColor})
      : shapeBorder = const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)));

  const ShimmerWidgets.circular(
      {super.key,
      required this.height,
      this.width = double.infinity,
      required this.baseColor,
      required this.highlightColor})
      : shapeBorder = const CircleBorder();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        enabled: true,
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.all(
              Radius.circular(25),
            ),
          ),
          width: width,
          height: height,
        ),
      );
}

Widget buildSchimmerText(double width,
        {Color baseColor = const Color.fromARGB(117, 158, 158, 158),
        Color highlightColor = const Color.fromARGB(205, 230, 230, 230),
        double height = 12}) =>
    ShimmerWidgets.rectangular(
      height: height,
      width: width,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
Widget buildSchimmerSquare(double width,
        {Color baseColor = const Color.fromARGB(117, 158, 158, 158),
        Color highlightColor = const Color.fromARGB(205, 230, 230, 230)}) =>
    ShimmerWidgets.square(
      width: width,
      height: width,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
Widget buildSchimmerProfilePic(double width, double height,
        {Color baseColor = const Color.fromARGB(117, 158, 158, 158),
        Color highlightColor = const Color.fromARGB(205, 230, 230, 230)}) =>
    ShimmerWidgets.circular(
      height: height,
      width: width,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
