import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/colors.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/domain_translations.dart';
import '../../models/activity_log.dart';
import 'glass_card.dart';

class RecentActivitiesCard extends StatelessWidget {
  final List<ActivityLog> filteredLogs;
  final String selectedPeriod;

  const RecentActivitiesCard({
    super.key,
    required this.filteredLogs,
    required this.selectedPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final limit = selectedPeriod == 'Mês' ? 15 : selectedPeriod == 'Geral' ? 20 : 10;
    final sorted = List<ActivityLog>.from(filteredLogs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final recent = sorted.take(limit).toList();
    final dateFormat = DateFormat('dd/MM - HH:mm');

    return DashboardGlassCard(
      title: AppLocalizations.of(context).cardRecentActivities,
      icon: Icons.history_rounded,
      child: Column(
        children: recent.map((log) {
          final color = HawkinsColors.energyColors[log.energy] ?? Colors.grey;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DomainTranslations.category(context, log.group), style: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF2D3436))),
                      const SizedBox(height: 4),
                      Text(log.example, style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(log.formattedDuration, style: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
                    const SizedBox(height: 4),
                    Text(dateFormat.format(log.timestamp), style: GoogleFonts.lato(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
