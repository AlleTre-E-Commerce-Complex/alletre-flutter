import 'package:alletre_app/utils/theme/app_theme.dart';
import 'package:alletre_app/view/widgets/signup%20widgets/signup_buttons.dart';
import 'package:alletre_app/view/widgets/signup%20widgets/signup_form_fields.dart';
import 'package:alletre_app/view/widgets/signup%20widgets/signup_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: false, // Keeps it off-screen when scrolling down
            floating: true, // Makes it appear only when scrolling up
            backgroundColor: primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: secondaryColor, size: 22),
              onPressed: () => Navigator.pop(context),
            ),
            title: SizedBox(
              width: 210,
              height: 31,
              child: SvgPicture.asset(
                'assets/images/alletre_header.svg',
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SignUpTitle(),
                  SizedBox(height: 24),
                  SignupFormFields(),
                  SizedBox(height: 12),
                  SignupButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
