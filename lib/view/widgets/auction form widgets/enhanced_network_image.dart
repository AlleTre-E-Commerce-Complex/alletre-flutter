import 'package:flutter/material.dart';

class EnhancedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color backgroundColor;

  const EnhancedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.backgroundColor = Colors.grey,
  });

  bool _isValidImageUrl(String url) {
    // Check for common image extensions
    final validExtensions = [
      '.jpg', '.jpeg', '.png', '.gif', '.webp', 
      '.bmp', '.tiff', '.heic', '.heif', '.svg'
    ];
    final lowerUrl = url.toLowerCase();
    return validExtensions.any((ext) => lowerUrl.endsWith(ext)) ||
           url.startsWith('data:image/'); // Support base64 encoded images
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValidImageUrl(imageUrl)) {
      return _buildErrorWidget();
    }

    return Container(
      width: width,
      height: height,
      color: backgroundColor,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: child,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingWidget(loadingProgress);
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      ),
    );
  }

  Widget _buildLoadingWidget(ImageChunkEvent loadingProgress) {
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded / 
              loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 40),
          SizedBox(height: 8),
          Text(
            'Image not available',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}