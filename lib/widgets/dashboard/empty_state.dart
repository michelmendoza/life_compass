import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:root_flow/l10n/app_localizations.dart';

class DashboardEmptyState extends StatelessWidget {
  const DashboardEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.7),
              border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.4)),
            ),
            child: Icon(Icons.dashboard_rounded, size: 50, color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context).dashboardEmptyTitle,
            style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).dashboardEmptySubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(fontSize: 13, color: Colors.grey[500], height: 1.4),
          ),
        ],
      ),
    );
  }
}
