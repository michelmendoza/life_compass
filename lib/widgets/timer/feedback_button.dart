import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackButton extends StatelessWidget {
  final String emoji;
  final String label;
  final int value;
  final int? currentValue;
  final VoidCallback onTap;
  final Color color;

  const FeedbackButton({
    super.key,
    required this.emoji,
    required this.label,
    required this.value,
    required this.currentValue,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentValue == value;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 65,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[200]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
