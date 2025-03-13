import 'package:flutter/material.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';

class AddressCard extends StatelessWidget {
  final String address;
  final bool isDefault;
  final VoidCallback? onMakeDefault;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AddressCard({
    super.key,
    required this.address,
    required this.isDefault,
    this.onMakeDefault,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14, isDefault ? 2 : 14, 14, isDefault ? 14 : 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isDefault)
                  Container(
                    width: 50,
                    height: 15,
                    margin: const EdgeInsets.only(bottom: 0),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor),
                      borderRadius: BorderRadius.circular(4),
                      color: primaryColor,
                    ),
                    child: const Text(
                      'Default',
                      style: TextStyle(
                        fontSize: 9,
                        color: secondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (isDefault)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: primaryColor),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            if (isDefault) const SizedBox(height: 0),
            Text(
              address,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: onSecondaryColor,
              ),
            ),
            if (!isDefault)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: onMakeDefault,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Make Default',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 128),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: primaryColor),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18, color: primaryColor),
                    onPressed: onDelete,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
