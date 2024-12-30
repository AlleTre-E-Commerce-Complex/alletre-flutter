import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserProfileCard extends StatelessWidget {
  final UserModel user;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const UserProfileCard({
    super.key,
    required this.user,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = customTheme();

    return Theme(
      data: theme,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Card(
          color: buttonBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 3,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 19.0, horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Displays either the user-selected SVG or a default placeholder
                        user.profileImagePath != null
                            ? SvgPicture.asset(
                                user.profileImagePath!,
                              )
                            : CircleAvatar(
                                radius: 36,
                                backgroundColor: secondaryColor,
                                child: Icon(
                                  Icons.person,
                                  color: avatarColor,
                                  size: 36,
                                ),
                              ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name.isNotEmpty ? user.name : 'User Name',
                              style: theme.textTheme.titleLarge,
                            ),
                            ElevatedButton(
                              onPressed: onButtonPressed,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: primaryColor,
                                backgroundColor: buttonBgColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: dividerColor),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 6),
                                minimumSize: const Size(80, 31),
                                elevation: 0,
                              ),
                              child: Text(
                                buttonText,
                                style: theme.textTheme.labelSmall!
                                    .copyWith(color: onSecondaryColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
