import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'control_button.dart';

class ManualTimePicker extends StatelessWidget {
  final int hours;
  final int minutes;
  final Color accentColor;
  final VoidCallback onHoursDecrement;
  final VoidCallback onHoursIncrement;
  final VoidCallback onMinutesDecrement;
  final VoidCallback onMinutesIncrement;
  final VoidCallback onSave;

  const ManualTimePicker({
    super.key,
    required this.hours,
    required this.minutes,
    required this.accentColor,
    required this.onHoursDecrement,
    required this.onHoursIncrement,
    required this.onMinutesDecrement,
    required this.onMinutesIncrement,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Registrar Tempo Manualmente',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Adicione uma atividade já realizada',
            style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          _TimeStepRow(
            icon: Icons.schedule,
            label: 'Horas',
            value: hours,
            accentColor: accentColor,
            onDecrement: onHoursDecrement,
            onIncrement: onHoursIncrement,
          ),
          const SizedBox(height: 16),
          _TimeStepRow(
            icon: Icons.timer,
            label: 'Minutos',
            value: minutes,
            accentColor: accentColor,
            onDecrement: onMinutesDecrement,
            onIncrement: onMinutesIncrement,
          ),
          const SizedBox(height: 24),
          ControlButton(
            icon: Icons.save_rounded,
            label: 'SALVAR REGISTRO',
            onTap: onSave,
            accentColor: accentColor,
            isPrimary: true,
          ),
        ],
      ),
    );
  }
}

class _TimeStepRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color accentColor;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _TimeStepRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const Spacer(),
          _StepButton(
            icon: Icons.remove,
            color: accentColor,
            onTap: onDecrement,
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: Text(
              value.toString().padLeft(2, '0'),
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          _StepButton(
            icon: Icons.add,
            color: accentColor,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StepButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
