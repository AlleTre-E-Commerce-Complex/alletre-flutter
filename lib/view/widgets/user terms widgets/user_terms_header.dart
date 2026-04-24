import 'package:flutter/material.dart';

class HeaderText extends StatelessWidget {
  const HeaderText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'ALLE TRE E-COMMERCE COMPLEX LLC OPC',
      style: Theme.of(context).textTheme.displayMedium?.copyWith(
        fontSize: 14
      )
    );
  }
}
