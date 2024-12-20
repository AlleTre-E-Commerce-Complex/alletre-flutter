import 'package:alletre_app/view/widgets/signup%20widgets/signup_appbar.dart';
import 'package:alletre_app/view/widgets/signup%20widgets/signup_buttons.dart';
import 'package:alletre_app/view/widgets/signup%20widgets/signup_form_fields.dart';
import 'package:alletre_app/view/widgets/signup%20widgets/signup_title.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SignUpAppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SignUpTitle(),
              SizedBox(height: 24),
              SignupFormFields(),
              SizedBox(height: 16),
              SignupButtons()
            ],
          ),
        ),
      ),
    );
  }
}
