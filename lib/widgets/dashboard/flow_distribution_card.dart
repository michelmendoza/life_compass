import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/colors.dart';
import 'glass_card.dart';

class FlowDistributionCard extends StatelessWidget {
  final Map<String, double> flowDistribution;

  const FlowDistributionCard({super.key, required this.flowDistribution});

  @override
  Widget build(BuildContext context) {
    return DashboardGlassCard(
      title: 'Distribuição do Flow',
      icon: Icons.swap_vert_rounded,
      child: Column(
        children: flowDistribution.entries.map((entry) {
          final color = HawkinsColors.flowGradient[entry.key] ?? Colors.grey;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
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
            ),
          );
        }).toList(),
      ),
    );
  }
}
