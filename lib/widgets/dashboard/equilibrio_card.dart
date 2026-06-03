import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/activities.dart';
import '../../data/colors.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/domain_translations.dart';
import 'glass_card.dart';

class EquilibrioCard extends StatelessWidget {
  final Map<String, double> upsPorCategoria;
  final double indiceEquilibrio;
  final List<String> categoriasNaoPraticadas;
  final String sugestaoEquilibrio;
  final double totalUPs;
  final int totalActivities;

  const EquilibrioCard({
    super.key,
    required this.upsPorCategoria,
    required this.indiceEquilibrio,
    required this.categoriasNaoPraticadas,
    required this.sugestaoEquilibrio,
    required this.totalUPs,
    required this.totalActivities,
  });

  Color get _equilibrioColor {
    if (indiceEquilibrio >= 70) return const Color(0xFF6B8E23);
    if (indiceEquilibrio >= 40) return const Color(0xFFD4A017);
    return const Color(0xFFC0392B);
  }

  String get _equilibrioEmoji {
    if (indiceEquilibrio >= 80) return '🌳✨';
    if (indiceEquilibrio >= 60) return '🌿';
    if (indiceEquilibrio >= 40) return '🍂';
    return '🪵';
  }

  String _formatUPs(double ups) => ups.toStringAsFixed(1);

  Color _colorForGroup(String group) {
    final activity = Activity.activities.firstWhere(
      (a) => a.group == group,
      orElse: () => Activity.activities.first,
    );
    return HawkinsColors.energyColors[activity.energy] ?? const Color(0xFF6B8E23);
  }

  @override
  Widget build(BuildContext context) {
    final maxUP = upsPorCategoria.values.isEmpty
        ? 1.0
        : upsPorCategoria.values.reduce((a, b) => a > b ? a : b);

    final l10n = AppLocalizations.of(context);

    return DashboardGlassCard(
      title: l10n.cardBalanceCategories,
      icon: Icons.balance_rounded,
      rightWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _equilibrioColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${indiceEquilibrio.round()}% $_equilibrioEmoji',
          style: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.bold, color: _equilibrioColor),
        ),
      ),
      child: Column(
        children: [
          ...upsPorCategoria.entries.take(5).map((entry) {
            final proporcao = maxUP > 0 ? entry.value / maxUP : 0.0;
            final cor = _colorForGroup(entry.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DomainTranslations.category(context, entry.key), style: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                      Text('${_formatUPs(entry.value)} UP', style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold, color: cor)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: proporcao.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(cor),
                    borderRadius: BorderRadius.circular(6),
                    minHeight: 8,
                  ),
                ],
              ),
            );
          }),
          if (categoriasNaoPraticadas.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.notPracticed(categoriasNaoPraticadas.take(3)
                          .map((c) => DomainTranslations.category(context, c))
                          .join(', ')),
                      style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (sugestaoEquilibrio.isNotEmpty && indiceEquilibrio < 70)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.trySuggestion(DomainTranslations.category(context, sugestaoEquilibrio)),
                style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600, color: _equilibrioColor),
              ),
            ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.totalUPsLabel(_formatUPs(totalUPs), totalActivities),
                style: GoogleFonts.lato(fontSize: 11, color: Colors.grey[500]),
              ),
              Text(l10n.relativeBarsNote, style: GoogleFonts.lato(fontSize: 9, color: Colors.grey[400])),
            ],
          ),
        ],
      ),
    );
  }
}
