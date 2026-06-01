import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SmartSuggestion extends StatelessWidget {
  final String suggestion;

  const SmartSuggestion({super.key, required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5F9E9), Color(0xFFE8F0D5)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              suggestion,
              style: GoogleFonts.lato(fontSize: 13, color: const Color(0xFF4A5D23), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
