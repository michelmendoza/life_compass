import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_card.dart';

class ChallengeIndexCard extends StatelessWidget {
  final int challengeIndex;

  const ChallengeIndexCard({super.key, required this.challengeIndex});

  @override
  Widget build(BuildContext context) {
    final color = challengeIndex > 70
        ? const Color(0xFFF44336)
        : challengeIndex > 40
            ? const Color(0xFFFFC107)
            : const Color(0xFF6B8E23);

    return DashboardGlassCard(
      title: 'Índice de Desafio',
      icon: Icons.trending_up_rounded,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: challengeIndex / 100,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                '$challengeIndex',
                style: GoogleFonts.lato(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF2D3436)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            challengeIndex > 70 ? '🔥 Alta intensidade' : challengeIndex > 40 ? '⚡ Moderado' : '🌊 Fluxo tranquilo',
            style: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600]),
          ),
          const SizedBox(height: 6),
          Text('0 = Suave · 100 = Intenso', style: GoogleFonts.lato(fontSize: 10, color: Colors.grey[400])),
        ],
      ),
    );
  }
}
