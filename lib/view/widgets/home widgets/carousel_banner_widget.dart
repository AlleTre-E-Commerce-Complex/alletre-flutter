import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:alletre_app/utils/images/images.dart';

class CarouselBannerWidget extends StatelessWidget {
  const CarouselBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: AppImages.bannerImages.map((imagePath) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width * 0.91,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              padding: const EdgeInsets.all(4.0), // Add padding around the border
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), // Slightly larger radius for the outer container
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6), // Slightly smaller radius for the inner container
                child: FutureBuilder<void>(
                  future: precacheImage(AssetImage(imagePath), context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Container(
                          color: Colors.grey[200],
                          width: double.infinity,
                          height: MediaQuery.of(context).size.width * 0.91 * 0.35, // Reduced height
                          child: const Icon(Icons.error_outline, color: Colors.grey),
                        );
                      }
                      return Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: MediaQuery.of(context).size.width * 0.91 * 0.35, // Reduced height
                      );
                    }
                    return Container(
                      color: Colors.grey[200],
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width * 0.91 * 0.35, // Reduced height
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      }).toList(),
      options: CarouselOptions(
        height: MediaQuery.of(context).size.width * 0.4, // Reduced height
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.95,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
      ),
    );
  }
}
