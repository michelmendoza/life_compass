import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';

class HeroStatsCard extends StatelessWidget {
  final int totalMinutes;
  final int totalActivities;
  final int currentStreak;
  final String streakEmoji;
  final String lifeBalance;
  final String trendText;
  final bool isTrendingUp;
  final int trendPercent;
  final bool showTrend;
  final List<int> last7DaysMinutes;

  const HeroStatsCard({
    super.key,
    required this.totalMinutes,
    required this.totalActivities,
    required this.currentStreak,
    required this.streakEmoji,
    required this.lifeBalance,
    required this.trendText,
    required this.isTrendingUp,
    required this.trendPercent,
    required this.showTrend,
    required this.last7DaysMinutes,
  });

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return hours > 0 ? '${hours}h${mins}m' : '${mins}m';
  }

  String _getDayLabel(int weekday, String locale) {
    // Use a fixed reference Monday (2025-01-06 = weekday 1) to map weekday → localized abbrev
    final base = DateTime(2025, 1, 5 + weekday); // Jan 5 = Sunday, Jan 6 = Monday …
    final label = DateFormat('E', locale).format(base);
    return label.length > 3 ? label.substring(0, 3) : label;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B8E23), Color(0xFF8B6914)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B8E23).withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem(icon: Icons.timer_rounded, value: _formatMinutes(totalMinutes), label: l10n.statTotalTime),
              _statItem(icon: Icons.fitness_center_rounded, value: '$totalActivities', label: l10n.statActivities),
              _statItem(
                icon: Icons.local_fire_department_rounded,
                value: '${currentStreak}d',
                label: l10n.statStreak,
                suffix: streakEmoji,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lifeBalance, style: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(trendText, style: GoogleFonts.lato(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
                if (showTrend)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(isTrendingUp ? Icons.trending_up : Icons.trending_down, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text('$trendPercent%', style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSparkline(l10n, locale),
        ],
      ),
    );
  }

  Widget _statItem({required IconData icon, required String value, required String label, String suffix = ''}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 10),
        Text('$value$suffix', style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.lato(fontSize: 11, color: Colors.white70, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildSparkline(AppLocalizations l10n, String locale) {
    final maxMin = last7DaysMinutes.isEmpty ? 0 : last7DaysMinutes.reduce((a, b) => a > b ? a : b);
    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1, color: Colors.white.withOpacity(0.2)),
        const SizedBox(height: 12),
        Text(
          l10n.last7Days,
          style: GoogleFonts.lato(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white60, letterSpacing: 1.1),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (i) {
            final day = today.subtract(Duration(days: 6 - i));
            final mins = last7DaysMinutes[i];
            final proportion = maxMin > 0 ? mins / maxMin : 0.0;
            final isToday = i == 6;
            final barHeight = proportion > 0 ? (proportion * 36).clamp(4.0, 36.0) : 3.0;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (mins > 0)
                      Text(
                        _formatMinutes(mins),
                        style: GoogleFonts.lato(
                          fontSize: 8,
                          color: isToday ? Colors.white : Colors.white.withOpacity(0.55),
                        ),
                      ),
                    const SizedBox(height: 3),
                    Container(
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: mins > 0
                            ? (isToday ? Colors.white : Colors.white.withOpacity(0.5))
                            : Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDayLabel(day.weekday, locale),
                      style: GoogleFonts.lato(
                        fontSize: 9,
                        color: isToday ? Colors.white : Colors.white.withOpacity(0.55),
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
