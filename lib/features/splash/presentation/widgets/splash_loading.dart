import 'package:flutter/material.dart';

class SplashLoading extends StatelessWidget {
  const SplashLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 2.8,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 20),
        Text(
          'Initializing application...',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 14,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
