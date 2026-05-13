import 'dart:ui';

import 'package:flutter/material.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 1),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 1),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),

          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),

            child: Container(
              height: 78,

              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),

                borderRadius: BorderRadius.circular(30),

                border: Border.all(color: Colors.white.withValues(alpha: 0.35)),

                boxShadow: [
                  /// Soft ambient shadow
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),

                    blurRadius: 10,

                    spreadRadius: 1,

                    offset: const Offset(0, 2),
                  ),

                  /// Main depth shadow
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),

                    blurRadius: 30,

                    spreadRadius: 2,

                    offset: const Offset(0, 14),
                  ),

                  /// Deep shadow
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),

                    blurRadius: 60,

                    spreadRadius: -8,

                    offset: const Offset(0, 24),
                  ),

                  /// Top highlight
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.7),

                    blurRadius: 12,

                    spreadRadius: -6,

                    offset: const Offset(0, -4),
                  ),
                ],
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,

                children: [
                  _item(index: 0, icon: Icons.home_rounded, label: 'Home'),

                  _item(
                    index: 1,
                    icon: Icons.monitor_heart_rounded,
                    label: 'Monitor',
                  ),

                  _centerButton(),

                  _item(
                    index: 3,
                    icon: Icons.history_rounded,
                    label: 'History',
                  ),

                  _item(index: 4, icon: Icons.person_rounded, label: 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _item({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final selected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),

      behavior: HitTestBehavior.opaque,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

        decoration: BoxDecoration(
          color: selected
              ? Colors.blue.withValues(alpha: 0.12)
              : Colors.transparent,

          borderRadius: BorderRadius.circular(18),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(icon, size: 24, color: selected ? Colors.blue : Colors.grey),

            const SizedBox(height: 4),

            Text(
              label,

              style: TextStyle(
                fontSize: 11,

                fontWeight: FontWeight.w600,

                color: selected ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _centerButton() {
    final selected = currentIndex == 2;

    return GestureDetector(
      onTap: () => onTap(2),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        width: 62,
        height: 62,

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          gradient: LinearGradient(
            colors: selected
                ? [const Color(0xFF2563EB), const Color(0xFF06B6D4)]
                : [Colors.grey.shade400, Colors.grey.shade500],
          ),

          boxShadow: [
            BoxShadow(
              color: (selected ? Colors.blue : Colors.grey).withValues(
                alpha: 0.35,
              ),

              blurRadius: 20,

              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: const Icon(
          Icons.bluetooth_searching_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
