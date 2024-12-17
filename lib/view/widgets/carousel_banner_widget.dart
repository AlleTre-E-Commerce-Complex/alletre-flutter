import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CarouselBannerWidget extends StatelessWidget {
  const CarouselBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> bannerImages = [
      'assets/images/banner1.svg',
      'assets/images/banner2.svg',
      'assets/images/banner3.svg',
      'assets/images/banner4.svg'
    ];

    return CarouselSlider(
      items: bannerImages.map((imagePath) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SvgPicture.asset(
              imagePath,
              fit: BoxFit.contain,
              width: double.infinity,
            ),
          ),
        );
      }).toList(),
      options: CarouselOptions(
        height: 140,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.91,
        aspectRatio: 16 / 9,
      ),
    );
  }
}
