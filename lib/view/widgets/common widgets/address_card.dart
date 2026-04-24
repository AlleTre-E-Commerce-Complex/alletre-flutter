import 'package:flutter/material.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';

class AddressCard extends StatelessWidget {
  final String address;
  final String? addressLabel;
  final String? phone;
  final String? subtitle;
  final bool isDefault;
  final bool selected;
  final VoidCallback? onMakeDefault;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const AddressCard({
    super.key,
    required this.address,
    this.addressLabel,
    this.phone,
    required this.isDefault,
    this.onMakeDefault,
    this.onEdit,
    this.onDelete,
    this.subtitle,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: selected ? primaryColor : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding:
              EdgeInsets.fromLTRB(12, isDefault ? 2 : 14, 12, isDefault ? 14 : 12),
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
              if (addressLabel != null && addressLabel!.trim().isNotEmpty)
                Text(
                  addressLabel!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: onSecondaryColor,
                  ),
                ),
              const SizedBox(height: 2),
              Text(
                address,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: onSecondaryColor,
                ),
              ),
              if (subtitle != null && subtitle!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0, bottom: 4.0),
                  child: Text(
                    subtitle!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: onSecondaryColor,
                    ),
                  ),
                ),
              if (phone != null && phone!.trim().isNotEmpty)
                Text(
                  phone!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: onSecondaryColor,
                  ),
                ),
              // Only show action row if any action is provided
              if (!isDefault && (onMakeDefault != null || onEdit != null || onDelete != null))
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (onMakeDefault != null)
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
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: primaryColor),
                        onPressed: onEdit,
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon:
                            const Icon(Icons.delete, size: 18, color: primaryColor),
                        onPressed: onDelete,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
