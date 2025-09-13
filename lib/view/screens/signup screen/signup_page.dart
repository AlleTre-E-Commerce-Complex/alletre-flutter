import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/common%20widgets/common_appbar.dart';
import 'package:alletre_app/view/widgets/signup%20widgets/signup_buttons.dart';
import 'package:alletre_app/view/widgets/signup%20widgets/signup_form_fields.dart';
import 'package:alletre_app/view/widgets/signup%20widgets/signup_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SignUpPage extends StatelessWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: false, // Keeps it off-screen when scrolling down
            floating: true, // Makes it appear only when scrolling up
            backgroundColor: primaryColor,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
              child: SizedBox(
                width: 8,
                height: 8,
                child: SvgPicture.asset(
                  'assets/icons/app-icon.svg',
                ),
              ),
            ),
            centerTitle: true,
            title: const Text(
              'Sign Up',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SignUpTitle(),
                  const SizedBox(height: 24),
                  SignupFormFields(formKey: formKey),
                  const SizedBox(height: 10),
                  SignupButtons(formKey: formKey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
