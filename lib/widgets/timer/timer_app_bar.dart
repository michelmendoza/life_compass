import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/timer_mode.dart';

class TimerAppBar extends StatelessWidget {
  final String group;
  final String example;
  final Color energyColor;
  final bool isBreak;
  final TimerMode currentMode;
  final VoidCallback onBack;

  const TimerAppBar({
    super.key,
    required this.group,
    required this.example,
    required this.energyColor,
    required this.isBreak,
    required this.currentMode,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: energyColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.arrow_back_rounded,
                  color: energyColor, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: energyColor,
                  ),
                ),
                Text(
                  example,
                  style:
                      GoogleFonts.lato(fontSize: 10, color: Colors.grey[500]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (currentMode == TimerMode.pomodoro && isBreak)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '☕ Pausa',
                style: GoogleFonts.lato(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
