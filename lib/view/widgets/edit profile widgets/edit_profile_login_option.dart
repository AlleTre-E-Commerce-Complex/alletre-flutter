import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EditProfileLoginOption extends StatelessWidget {
  final String svgPath;
  final String label;
  final bool isConnected;
  final VoidCallback onTap;

  const EditProfileLoginOption({
    required this.svgPath,
    required this.label,
    required this.isConnected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      child: Row(
        children: [
          SvgPicture.asset(svgPath, width: 20, height: 20),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Icon(
            isConnected ? Icons.check_circle : Icons.link_outlined,
            color: isConnected ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }
}
