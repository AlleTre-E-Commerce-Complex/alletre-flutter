import 'package:alletre_app/utils/images/images.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CarouselBannerWidget extends StatelessWidget {
  const CarouselBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: AppImages.bannerImages.map((imagePath) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Calculate the width and height to match the SVG's aspect ratio
            final width = constraints.maxWidth * 0.91; // 91% of screen width
            final height = width / (830.6667 / 353.33334); // Aspect ratio 2.35

            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SvgPicture.asset(
                  imagePath,
                  fit: BoxFit.fill, // Ensures no padding; exact dimensions used
                ),
              ),
            );
          },
        );
      }).toList(),
      options: CarouselOptions(
        height: MediaQuery.of(context).size.width * 0.91 / (830.6667 / 353.33334), // Dynamic height
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 1,
      ),
    );
  }
}
