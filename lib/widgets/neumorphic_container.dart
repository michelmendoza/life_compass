import 'package:flutter/material.dart';
import '../data/colors.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;

  const NeumorphicContainer({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: HawkinsColors.background,
        boxShadow: [
          BoxShadow(
            color: HawkinsColors.lightShadow,
            offset: const Offset(-8, -8),
            blurRadius: 15,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: HawkinsColors.darkShadow,
            offset: const Offset(8, 8),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}