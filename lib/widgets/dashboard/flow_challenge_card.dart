import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../models/activity_log.dart';
import 'glass_card.dart';

class FlowVsChallengeCard extends StatelessWidget {
  final List<ActivityLog> filteredLogs;

  const FlowVsChallengeCard({super.key, required this.filteredLogs});

  @override
  Widget build(BuildContext context) {
    final logsWithFeedback = filteredLogs
        .where((l) =>
            l.difficultyFeedback != null &&
            l.difficultyFeedback!.isNotEmpty &&
            l.consciousnessLevel != null &&
            l.consciousnessLevel! > 0)
        .toList();

    final l10n = AppLocalizations.of(context);

    if (logsWithFeedback.isEmpty) {
      return DashboardGlassCard(
        title: l10n.cardFlowVsChallenge,
        icon: Icons.show_chart_rounded,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF6B8E23).withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Text('🧪', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.flowChallengeHint,
                  style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600], height: 1.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    int facilFlow = 0, facilNoFlow = 0;
    int medioFlow = 0, medioNoFlow = 0;
    int dificilFlow = 0, dificilNoFlow = 0;

    for (final log in logsWithFeedback) {
      final hasFlow = (log.consciousnessLevel ?? 0) >= 3;
      final difficulty = log.difficultyFeedback ?? '';
      if (difficulty == 'Fácil') {
        hasFlow ? facilFlow++ : facilNoFlow++;
      } else if (difficulty == 'Difícil') {
        hasFlow ? dificilFlow++ : dificilNoFlow++;
      } else {
        hasFlow ? medioFlow++ : medioNoFlow++;
      }
    }

    final facilTotal = facilFlow + facilNoFlow;
    final medioTotal = medioFlow + medioNoFlow;
    final dificilTotal = dificilFlow + dificilNoFlow;
    final facilRate = facilTotal > 0 ? facilFlow / facilTotal : 0.0;
    final medioRate = medioTotal > 0 ? medioFlow / medioTotal : 0.0;
    final dificilRate = dificilTotal > 0 ? dificilFlow / dificilTotal : 0.0;

    String bestZone;
    double bestRate;
    if (medioRate >= facilRate && medioRate >= dificilRate) {
      bestZone = 'Médio';
      bestRate = medioRate;
    } else if (dificilRate >= facilRate) {
      bestZone = 'Difícil';
      bestRate = dificilRate;
    } else {
      bestZone = 'Fácil';
      bestRate = facilRate;
    }

    final translatedBestZone = bestZone == 'Fácil'
        ? l10n.flowFacil
        : bestZone == 'Difícil'
            ? l10n.flowDificil
            : l10n.flowMedio;

    return DashboardGlassCard(
      title: l10n.cardFlowVsChallenge,
      icon: Icons.show_chart_rounded,
      rightWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF6B8E23).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          l10n.flowPeak(translatedBestZone, (bestRate * 100).round()),
          style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF6B8E23)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _zoneBar(l10n.flowZoneEasy, facilFlow, facilTotal, facilRate, const Color(0xFF4CAF50), l10n),
              const SizedBox(width: 8),
              _zoneBar(l10n.flowZoneMedium, medioFlow, medioTotal, medioRate, const Color(0xFFFFC107), l10n),
              const SizedBox(width: 8),
              _zoneBar(l10n.flowZoneHard, dificilFlow, dificilTotal, dificilRate, const Color(0xFFF44336), l10n),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6B8E23).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    bestRate > 0.6
                        ? l10n.flowInZone(translatedBestZone)
                        : bestRate > 0.3
                            ? l10n.flowDistributedMsg
                            : l10n.flowLowMsg,
                    style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[700], height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _zoneBar(String label, int flowCount, int total, double rate, Color color, AppLocalizations l10n) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          const SizedBox(height: 6),
          Container(
            height: 32,
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                if (flowCount > 0)
                  Expanded(
                    flex: flowCount,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.8),
                        borderRadius: BorderRadius.horizontal(
                          left: const Radius.circular(8),
                          right: flowCount == total ? const Radius.circular(8) : Radius.zero,
                        ),
                      ),
                      child: Center(
                        child: Text('✨$flowCount', style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                if (total - flowCount > 0)
                  Expanded(
                    flex: total - flowCount,
                    child: Center(
                      child: Text('${total - flowCount}', style: GoogleFonts.lato(fontSize: 11, color: Colors.grey[500])),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(l10n.flowActivitiesCount(total), style: GoogleFonts.lato(fontSize: 10, color: Colors.grey[500])),
          const SizedBox(height: 4),
          Text(l10n.flowRatePercent((rate * 100).round()), style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
