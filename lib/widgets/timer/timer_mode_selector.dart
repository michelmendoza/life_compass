import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/timer_mode.dart';

class TimerModeSelector extends StatelessWidget {
  final TimerMode currentMode;
  final Color energyColor;
  final ValueChanged<TimerMode> onModeChanged;

  const TimerModeSelector({
    super.key,
    required this.currentMode,
    required this.energyColor,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final modes = <(TimerMode, String, IconData, Color)>[
      (TimerMode.chronometer, 'Cronômetro', Icons.timer_rounded, energyColor),
      (TimerMode.pomodoro, 'Pomodoro', Icons.timer_rounded, Colors.red[400]!),
      (TimerMode.manual, 'Manual', Icons.edit_calendar_rounded, Colors.orange),
      (TimerMode.hiit, 'HIIT', Icons.fitness_center_rounded, Colors.purple),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: modes.map((mode) {
          final isSelected = currentMode == mode.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => onModeChanged(mode.$1),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? mode.$4
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? mode.$4 : Colors.white,
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(mode.$3,
                        size: 18,
                        color: isSelected ? Colors.white : mode.$4),
                    const SizedBox(height: 2),
                    Text(
                      mode.$2,
                      style: GoogleFonts.lato(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : mode.$4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
