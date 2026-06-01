import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/colors.dart';
import '../models/activity_log.dart';

class ActivityLogCard extends StatelessWidget {
  final ActivityLog log;
  final Function(ActivityLog)? onDelete;

  const ActivityLogCard({super.key, required this.log, this.onDelete});

  Color _energyColor(String energy) => HawkinsColors.energyColors[energy] ?? Colors.grey;
  Color _flowColor(String flow) => HawkinsColors.flowGradient[flow] ?? Colors.grey;
  Color _organColor(String organ) => HawkinsColors.organGradients[organ]?[0] ?? Colors.grey;

  @override
  Widget build(BuildContext context) {
    final energyColor = _energyColor(log.energy);
    final flowColor = _flowColor(log.flow);
    final organColor = _organColor(log.organ);
    final organIcon = switch (log.organ) {
      'Mente' => '🧠',
      'Corpo' => '💪',
      'Espírito' => '🙏',
      _ => '🧘',
    };

    final hasFeedback = (log.consciousnessLevel != null && log.consciousnessLevel! > 0) ||
        (log.difficultyFeedback != null && log.difficultyFeedback!.isNotEmpty);

    String consciousnessText = '';
    String consciousnessEmoji = '';
    if (log.consciousnessLevel != null && log.consciousnessLevel! > 0) {
      if (log.consciousnessLevel! >= 3) {
        consciousnessEmoji = '✨';
        consciousnessText = 'Fluindo';
      } else if (log.consciousnessLevel! >= 2) {
        consciousnessEmoji = '🔥';
        consciousnessText = 'Focado';
      } else if (log.consciousnessLevel! >= 1) {
        consciousnessEmoji = '😐';
        consciousnessText = 'Presente';
      }
    }

    return Dismissible(
      key: Key(log.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.red[400]!, Colors.red[300]!]),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: Text('Excluir atividade?',
                    style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold)),
                content: Text('"${log.example}"\nEsta ação não pode ser desfeita.',
                    style: GoogleFonts.lato(fontSize: 13, color: Colors.grey[600])),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text('Cancelar', style: GoogleFonts.lato(fontSize: 13, color: Colors.grey[500])),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Excluir', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete?.call(log),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: hasFeedback ? const Color(0xFFF5F9E9) : Colors.white.withOpacity(0.45),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasFeedback
                ? const Color(0xFF6B8E23).withOpacity(0.3)
                : const Color(0xFFA8C686).withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [energyColor, flowColor, organColor],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: energyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(child: Text(organIcon, style: const TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.group, style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF2D3436))),
                        const SizedBox(height: 4),
                        Text(log.example, style: GoogleFonts.lato(fontSize: 13, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _chip(log.energy, energyColor, log.energy == 'Ativa' ? '⚡' : '🍃'),
                            _chip(log.flow, flowColor, '🔄'),
                            _chip(log.organ, organColor, organIcon),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: energyColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(log.formattedDuration,
                            style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold, color: energyColor)),
                      ),
                      const SizedBox(height: 4),
                      Text(DateFormat('HH:mm').format(log.timestamp),
                          style: GoogleFonts.lato(fontSize: 11, color: Colors.grey[400])),
                    ],
                  ),
                ],
              ),
            ),
            if (hasFeedback) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                height: 1,
                color: const Color(0xFF6B8E23).withOpacity(0.15),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (consciousnessEmoji.isNotEmpty) ...[
                      Text(consciousnessEmoji, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(consciousnessText,
                          style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF6B8E23))),
                    ],
                    if (consciousnessEmoji.isNotEmpty && log.difficultyFeedback != null)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('•', style: TextStyle(fontSize: 9, color: Colors.grey)),
                      ),
                    if (log.difficultyFeedback != null) ...[
                      Icon(
                        log.difficultyFeedback == 'Fácil'
                            ? Icons.wb_sunny_rounded
                            : log.difficultyFeedback == 'Difícil'
                                ? Icons.whatshot_rounded
                                : Icons.bolt_rounded,
                        size: 11,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(log.difficultyFeedback!,
                          style: GoogleFonts.lato(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey[500])),
                    ],
                    const Spacer(),
                    Text('feedback',
                        style: GoogleFonts.lato(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey[400])),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color color, String icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 3),
          Text(text, style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}
