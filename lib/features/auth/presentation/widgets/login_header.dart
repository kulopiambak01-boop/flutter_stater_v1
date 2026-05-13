import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmall = Responsive.isSmallHeight(context);

    return Column(
      mainAxisSize: MainAxisSize.min,

      children: [
        Text(
          'AutoCare Pintar',

          style: TextStyle(
            fontSize: isSmall ? 24 : 32,

            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: isSmall ? 8 : 12),

        Text(
          'Smart Vehicle Monitoring System',

          textAlign: TextAlign.center,

          style: TextStyle(color: Colors.grey, fontSize: isSmall ? 13 : 16),
        ),
      ],
    );
  }
}
