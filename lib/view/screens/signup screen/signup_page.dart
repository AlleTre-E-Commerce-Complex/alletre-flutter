import 'package:alletre_app/view/widgets/common%20widgets/common_appbar.dart';
import 'package:alletre_app/view/widgets/signup%20widgets/signup_buttons.dart';
import 'package:alletre_app/view/widgets/signup%20widgets/signup_form_fields.dart';
import 'package:alletre_app/view/widgets/signup%20widgets/signup_title.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CommonAppBar(),
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
