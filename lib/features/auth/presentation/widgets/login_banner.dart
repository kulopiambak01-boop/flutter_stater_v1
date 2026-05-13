import 'package:flutter/material.dart';

class LoginBanner extends StatelessWidget {
  const LoginBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 500;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 24 : 36),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(37, 99, 235, 0.2),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.bluetooth_searching,
            color: Colors.white,
            size: isSmall ? 56 : 80,
          ),
          SizedBox(height: isSmall ? 20 : 30),
          Text(
            'Monitor kendaraan\nlebih pintar',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 28 : 42,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          SizedBox(height: isSmall ? 16 : 20),
          Text(
            'Pantau performa mesin, '
            'health score, fuel, '
            'dan maintenance kendaraan '
            'secara real-time.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: isSmall ? 14 : 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
