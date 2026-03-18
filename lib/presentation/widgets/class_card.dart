// lib/presentation/widgets/class_card.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/class_model.dart';

class ClassCard extends StatelessWidget {
  final ClassModel classModel;
  final bool isStudent;
  final VoidCallback? onTap;
  final VoidCallback? onCheckIn;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewReport;

  const ClassCard({
    super.key,
    required this.classModel,
    required this.isStudent,
    this.onTap,
    this.onCheckIn,
    this.onEdit,
    this.onDelete,
    this.onViewReport,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = classModel.isCurrentlyActive;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppTheme.kSecondary.withOpacity(0.4) : AppTheme.kDivider,
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: AppTheme.kSecondary.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Course icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      classModel.courseCode.isNotEmpty
                          ? classModel.courseCode.substring(0, classModel.courseCode.length > 2 ? 2 : classModel.courseCode.length).toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.kPrimary,
                        fontSize: 14,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(classModel.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Nunito',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          if (isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.kSecondary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppTheme.kSecondary, shape: BoxShape.circle)),
                                  const SizedBox(width: 4),
                                  const Text('Live', style: TextStyle(fontSize: 10, color: AppTheme.kSecondary, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(classModel.courseCode,
                          style: const TextStyle(fontSize: 12, color: AppTheme.kTextSecondary, fontFamily: 'Nunito')),
                    ],
                  ),
                ),
                // Admin actions
                if (!isStudent)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppTheme.kTextSecondary),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit',   child: Text('Edit')),
                      const PopupMenuItem(value: 'report', child: Text('View Report')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppTheme.kError))),
                    ],
                    onSelected: (v) {
                      if (v == 'edit' && onEdit != null)         onEdit!();
                      if (v == 'delete' && onDelete != null)     onDelete!();
                      if (v == 'report' && onViewReport != null) onViewReport!();
                    },
                  ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Meta row
            Row(
              children: [
                _Chip(icon: Icons.calendar_today_rounded, label: classModel.dayName),
                const SizedBox(width: 8),
                _Chip(icon: Icons.schedule_rounded, label: classModel.timeRange),
                const SizedBox(width: 8),
                _Chip(icon: Icons.radar_rounded, label: '${classModel.radiusMetres.toStringAsFixed(0)}m'),
              ],
            ),

            // Student check-in button
            if (isStudent && isActive) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.login_rounded, size: 16),
                  label: const Text('Check In'),
                  onPressed: onCheckIn,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(fontSize: 13, fontFamily: 'Nunito', fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.kDivider,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: AppTheme.kTextSecondary),
            const SizedBox(width: 4),
            Flexible(child: Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.kTextSecondary, fontFamily: 'Nunito'), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}
