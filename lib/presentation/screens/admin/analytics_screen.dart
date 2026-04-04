// lib/presentation/screens/admin/analytics_screen.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/class_controller.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final classCtrl = Get.find<ClassController>();
    final theme     = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final classes = classCtrl.classList;
        if (classes.isEmpty) {
          return const Center(child: Text('No classes to analyse yet.'));
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Summary cards ─────────────────────────────────────────────
            _SummaryRow(total: classes.length, active: classes.where((c) => c.isCurrentlyActive).length)
                .animate().fadeIn(),

            const SizedBox(height: 24),

            Text('Classes Overview', style: theme.textTheme.titleLarge)
                .animate(delay: 100.ms).fadeIn(),
            const SizedBox(height: 4),
            Text('Active classes this semester', style: theme.textTheme.bodySmall)
                .animate(delay: 120.ms).fadeIn(),
            const SizedBox(height: 16),

            // ── Bar chart: classes by day ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.kDivider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Classes by Day of Week',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Nunito')),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 160,
                    child: _DayBarChart(classes: classes),
                  ),
                ],
              ),
            ).animate(delay: 150.ms).slideY(begin: 0.1, end: 0, duration: 400.ms).fadeIn(),

            const SizedBox(height: 16),

            // ── Classes list with metadata ─────────────────────────────────
            ...List.generate(classes.length, (i) {
              final cls = classes[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.kDivider),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.kPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(cls.courseCode.isNotEmpty ? cls.courseCode.substring(0, 2).toUpperCase() : '??',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.kPrimary, fontFamily: 'Nunito')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cls.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Nunito')),
                          Text('${cls.dayName} • ${cls.timeRange}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.kTextSecondary, fontFamily: 'Nunito')),
                        ],
                      ),
                    ),
                    if (cls.isCurrentlyActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.kSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Live', style: TextStyle(color: AppTheme.kSecondary, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
                      ),
                  ],
                ),
              ).animate(delay: Duration(milliseconds: 50 * i)).slideX(begin: 0.1, end: 0, duration: 300.ms).fadeIn();
            }),
          ],
        );
      }),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final int total, active;
  const _SummaryRow({required this.total, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _Card(value: '$total', label: 'Total Classes', color: AppTheme.kPrimary, icon: Icons.class_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _Card(value: '$active', label: 'Active Now', color: AppTheme.kSecondary, icon: Icons.sensors_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _Card(value: '${total - active}', label: 'Inactive', color: AppTheme.kTextSecondary, icon: Icons.pause_circle_outline_rounded)),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final String value, label;
  final Color color;
  final IconData icon;
  const _Card({required this.value, required this.label, required this.color, required this.icon});

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
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color, fontFamily: 'Nunito')),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.kTextSecondary, fontFamily: 'Nunito'), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _DayBarChart extends StatelessWidget {
  final List<dynamic> classes;
  const _DayBarChart({required this.classes});

  @override
  Widget build(BuildContext context) {
    // Count classes per day
    final counts = List.filled(7, 0);
    for (final c in classes) {
      if (c.dayOfWeek >= 0 && c.dayOfWeek < 7) counts[c.dayOfWeek]++;
    }

    final maxY = counts.reduce((a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY > 0 ? maxY + 1 : 5,
        barGroups: List.generate(7, (i) => BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: counts[i].toDouble(),
              color: counts[i] > 0 ? AppTheme.kPrimary : AppTheme.kDivider,
              width: 18,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        )),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                return Text(days[v.toInt()],
                    style: const TextStyle(fontSize: 12, color: AppTheme.kTextSecondary, fontFamily: 'Nunito'));
              },
            ),
          ),
        ),
      ),
    );
  }
}
