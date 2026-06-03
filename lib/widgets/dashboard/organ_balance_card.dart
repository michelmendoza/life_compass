import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/colors.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/domain_translations.dart';
import 'glass_card.dart';

class OrganBalanceCard extends StatelessWidget {
  final Map<String, double> organBalance;

  const OrganBalanceCard({super.key, required this.organBalance});

  @override
  Widget build(BuildContext context) {
    const organs = ['Mente', 'Corpo', 'Espírito'];
    const icons = {'Mente': '🧠', 'Corpo': '💪', 'Espírito': '🧘'};

    final l10n = AppLocalizations.of(context);
    return DashboardGlassCard(
      title: l10n.cardFocusDimension,
      icon: Icons.psychology_rounded,
      child: Column(
        children: organs.map((organ) {
          final percent = ((organBalance[organ] ?? 0) * 100).round();
          final color = HawkinsColors.organGradients[organ]?[0] ?? Colors.grey;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${DomainTranslations.organ(context, organ)} ${icons[organ]}', style: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                    Text('$percent%', style: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: percent / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  borderRadius: BorderRadius.circular(6),
                  minHeight: 8,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
