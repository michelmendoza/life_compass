import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/activities.dart';
import '../../data/colors.dart';
import 'glass_card.dart';

class CategoriesCard extends StatelessWidget {
  final Map<String, double> categoryDistribution;

  const CategoriesCard({super.key, required this.categoryDistribution});

  Color _colorForGroup(String group) {
    final activity = Activity.activities.firstWhere(
      (a) => a.group == group,
      orElse: () => Activity.activities.first,
    );
    return HawkinsColors.energyColors[activity.energy] ?? const Color(0xFF6B8E23);
  }

  @override
  Widget build(BuildContext context) {
    final sorted = categoryDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(6).toList();

    final rows = <Widget>[];
    for (var i = 0; i < top.length; i += 2) {
      final left = top[i];
      final right = i + 1 < top.length ? top[i + 1] : null;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Expanded(child: _bar(left)),
              if (right != null) ...[
                const SizedBox(width: 16),
                Expanded(child: _bar(right)),
              ] else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }

    return DashboardGlassCard(
      title: 'Top Categorias',
      icon: Icons.pie_chart_rounded,
      child: Column(children: rows),
    );
  }

  Widget _bar(MapEntry<String, double> entry) {
    final color = _colorForGroup(entry.key);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                entry.key,
                style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Text('${(entry.value * 100).round()}%', style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: entry.value,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(6),
          minHeight: 6,
        ),
      ],
    );
  }
}
