// lib/presentation/widgets/stat_card.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w800,
            color: color, fontFamily: 'Nunito',
          )),
          Text(label, style: const TextStyle(
            fontSize: 11, color: AppTheme.kTextSecondary, fontFamily: 'Nunito',
          )),
        ],
      ),
    );
  }
}
