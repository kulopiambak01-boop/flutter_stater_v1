import 'package:flutter/material.dart';

class SplashBrand extends StatelessWidget {
  const SplashBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// LOGO
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),

          child: const Icon(
            Icons.directions_car_rounded,
            size: 72,
            color: Colors.blue,
          ),
        ),

        const SizedBox(height: 36),

        /// TITLE
        const Text(
          'AutoCare Pintar',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 14),

        /// SUBTITLE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Smart Vehicle Monitoring & Maintenance System',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              height: 1.5,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}
