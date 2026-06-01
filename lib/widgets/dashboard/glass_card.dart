import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardGlassCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? rightWidget;
  final Widget child;

  const DashboardGlassCard({
    super.key,
    required this.title,
    required this.icon,
    this.rightWidget,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B8E23).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: const Color(0xFF6B8E23)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey[500],
                    letterSpacing: 1.2,
                  ),
                  maxLines: 2,
                  softWrap: true,
                ),
              ),
              if (rightWidget != null) ...[
                const SizedBox(width: 8),
                rightWidget!,
              ],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
