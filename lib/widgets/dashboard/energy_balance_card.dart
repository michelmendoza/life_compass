import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import 'glass_card.dart';

class EnergyBalanceCard extends StatelessWidget {
  final Map<String, double> energyBalance;

  const EnergyBalanceCard({super.key, required this.energyBalance});

  @override
  Widget build(BuildContext context) {
    final activePercent = ((energyBalance['Ativa'] ?? 0) * 100).round();
    final passivePercent = ((energyBalance['Passiva'] ?? 0) * 100).round();

    final l10n = AppLocalizations.of(context);
    return DashboardGlassCard(
      title: l10n.cardEnergyBalance,
      icon: Icons.bolt_rounded,
      child: Row(
        children: [
          Expanded(child: _pill(l10n.energyActivePill, activePercent, const Color(0xFFFF6B35))),
          const SizedBox(width: 16),
          Expanded(child: _pill(l10n.energyPassivePill, passivePercent, const Color(0xFF4ECDC4))),
        ],
      ),
    );
  }

  Widget _pill(String label, int percent, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 8),
          Text('$percent%', style: GoogleFonts.lato(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
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
  }
}
