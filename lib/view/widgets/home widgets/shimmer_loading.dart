import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final String title;
  final double width;
  final double height;

  const ShimmerLoading({super.key, required this.title, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: borderColor,
                      highlightColor: shimmerColor,
      child: Container(
        width: (MediaQuery.of(context).size.width - 32 - 10) / 2,
                        height: height,
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
