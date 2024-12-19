import 'package:alletre_app/utils/navigation/named_routes.dart';
import 'package:alletre_app/utils/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SearchFieldWidget extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final IconData leadingIcon;
  final VoidCallback? onLeadingIconPressed;
  final bool isNavigable;

  const SearchFieldWidget({
    super.key,
    this.onChanged,
    this.autofocus = false,
    this.leadingIcon = Icons.search, // Default to search icon
    this.onLeadingIconPressed,
    this.isNavigable = false, // flag for navigation behavior
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isNavigable
          ? () {
              // Navigates to SearchScreen when tapped
              Navigator.pushNamed(context, AppRoutes.search);
            }
          : null,
      child: AbsorbPointer(
        absorbing: isNavigable, // Prevents user from typing directly
        child: Padding(
          padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
          child: TextField(
            autofocus: autofocus,
            onChanged: onChanged,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: 'Search on Alletre',
              hintStyle: Theme.of(context).textTheme.displayMedium,
              prefixIcon: IconButton(
                icon: Icon(leadingIcon),
                onPressed: onLeadingIconPressed, // Handles back button press
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: onSecondaryColor),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: primaryColor),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
