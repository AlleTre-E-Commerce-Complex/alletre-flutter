import 'dart:io';

import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

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

    // Get the current user info from the provider
    final userProvider = Provider.of<UserProvider>(context);
    final displayName = userProvider.displayName.isNotEmpty
        ? userProvider.displayName
        : 'Username';
    // final authMethod = userProvider.authMethod;
    final photoUrl = userProvider.photoUrl;

    return Theme(
      data: theme,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Card(
          color: primaryColor,
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
                        // Profile image based on auth method
                        if (photoUrl != null)
                          CircleAvatar(
                            radius: 36,
                            backgroundImage: photoUrl.startsWith('http')
                                ? NetworkImage(photoUrl)
                                : FileImage(File(photoUrl)) as ImageProvider,
                            backgroundColor: buttonBgColor,
                          )
                        else if (user.profileImagePath != null)
                          SvgPicture.asset(
                            user.profileImagePath!,
                          )
                        else
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: buttonBgColor,
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
                              displayName,
                              style: theme.textTheme.titleMedium,
                            ),
                            ElevatedButton(
                              onPressed: onButtonPressed,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: primaryColor,
                                backgroundColor: buttonBgColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 6),
                                minimumSize: const Size(80, 31),
                                elevation: 0,
                              ),
                              child: Text(
                                buttonText,
                                style: theme.textTheme.labelSmall!.copyWith(
                                    color: onSecondaryColor),
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
