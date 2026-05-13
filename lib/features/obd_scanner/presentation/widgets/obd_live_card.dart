import 'package:flutter/material.dart';

class ObdLiveCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const ObdLiveCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  Color _accent() {
    switch (label.toLowerCase()) {
      case 'rpm':
        return Colors.orange;

      case 'speed':
        return Colors.blue;

      case 'coolant':
        return Colors.red;

      case 'battery':
        return Colors.green;

      case 'engine load':
        return Colors.purple;

      case 'fuel':
        return Colors.teal;

      default:
        return Colors.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,

        borderRadius: BorderRadius.circular(28),

        border: Border.all(color: accent.withValues(alpha: 0.12)),

        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),

              borderRadius: BorderRadius.circular(18),
            ),

            child: Icon(icon, color: accent, size: 28),
          ),

          const Spacer(),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,

            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
