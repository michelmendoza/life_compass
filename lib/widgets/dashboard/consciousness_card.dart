import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/activity_log.dart';
import 'glass_card.dart';

class ConsciousnessCard extends StatelessWidget {
  final List<ActivityLog> filteredLogs;

  const ConsciousnessCard({super.key, required this.filteredLogs});

  @override
  Widget build(BuildContext context) {
    final logsWithData = filteredLogs
        .where((l) => l.consciousnessLevel != null && l.consciousnessLevel! > 0)
        .toList();

    if (logsWithData.isEmpty) {
      return DashboardGlassCard(
        title: 'Consciência Média',
        icon: Icons.self_improvement_rounded,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF6B8E23).withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Text('📝', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Responda o feedback rápido após cada atividade para desbloquear suas métricas de consciência.',
                  style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600], height: 1.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final avgConsciousness = logsWithData.fold(0.0, (sum, l) => sum + (l.consciousnessLevel ?? 0)) / logsWithData.length;
    final counts = <int, int>{0: 0, 1: 0, 2: 0, 3: 0};
    for (final log in logsWithData) {
      final level = log.consciousnessLevel ?? 0;
      counts[level] = (counts[level] ?? 0) + 1;
    }
    final total = logsWithData.length;
    final emoji = avgConsciousness >= 3 ? '✨' : avgConsciousness >= 2 ? '🔥' : avgConsciousness >= 1 ? '😐' : '😴';
    final label = avgConsciousness >= 3 ? 'Fluindo' : avgConsciousness >= 2 ? 'Focado' : avgConsciousness >= 1 ? 'Presente' : 'Automático';

    return DashboardGlassCard(
      title: 'Consciência Média',
      icon: Icons.self_improvement_rounded,
      rightWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF6B8E23).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$emoji $label',
          style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF6B8E23)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _bar('😴', counts[0] ?? 0, total, const Color(0xFFE57373)),
              const SizedBox(width: 8),
              _bar('😐', counts[1] ?? 0, total, const Color(0xFFFFEB3B)),
              const SizedBox(width: 8),
              _bar('🔥', counts[2] ?? 0, total, const Color(0xFFFF9800)),
              const SizedBox(width: 8),
              _bar('✨', counts[3] ?? 0, total, const Color(0xFF6B8E23)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('← mais automático', style: GoogleFonts.lato(fontSize: 9, color: Colors.grey[400])),
              Text('mais consciente →', style: GoogleFonts.lato(fontSize: 9, color: Colors.grey[400])),
            ],
          ),
          const SizedBox(height: 10),
          Text('${logsWithData.length} atividades com feedback', style: GoogleFonts.lato(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _bar(String emoji, int count, int total, Color color) {
    final percent = total > 0 ? count / total : 0.0;
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.bold, color: percent > 0 ? color : Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
