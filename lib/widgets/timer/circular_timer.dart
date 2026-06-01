import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/hiit_interval.dart';
import '../../models/timer_mode.dart';

class CircularTimer extends StatelessWidget {
  final TimerMode mode;
  final Duration displayDuration;
  final double animatedProgress;
  final Color primaryColor;
  final bool isActive;
  final bool isBreak;
  final Animation<double> pulseAnimation;
  final HiitInterval? currentHiitInterval;
  final int hiitCurrentIndex;
  final int hiitTotal;
  final int manualHours;
  final int manualMinutes;

  const CircularTimer({
    super.key,
    required this.mode,
    required this.displayDuration,
    required this.animatedProgress,
    required this.primaryColor,
    required this.isActive,
    required this.pulseAnimation,
    this.isBreak = false,
    this.currentHiitInterval,
    this.hiitCurrentIndex = 0,
    this.hiitTotal = 0,
    this.manualHours = 0,
    this.manualMinutes = 0,
  });

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildCenterIcon() {
    switch (mode) {
      case TimerMode.chronometer:
        return const Text('⏱️', style: TextStyle(fontSize: 40));
      case TimerMode.pomodoro:
        return Text(isBreak ? '☕' : '🍅',
            style: const TextStyle(fontSize: 40));
      case TimerMode.manual:
        return const SizedBox.shrink();
      case TimerMode.hiit:
        final interval = currentHiitInterval;
        if (interval != null) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(interval.icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 4),
              Text(
                interval.name,
                style: GoogleFonts.lato(
                    fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          );
        }
        return const Text('🏃‍♂️', style: TextStyle(fontSize: 40));
    }
  }

  Widget _buildSubtitle() {
    switch (mode) {
      case TimerMode.manual:
        return Text(
          '📝 Selecione o tempo abaixo',
          style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[500]),
        );
      case TimerMode.hiit:
        if (hiitTotal > 0) {
          return Text(
            '${hiitCurrentIndex + 1}/$hiitTotal • ${isActive ? "▶️ Em andamento" : "⏸️ Pausado"}',
            style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[500]),
          );
        }
        return const SizedBox.shrink();
      default:
        return Text(
          isActive ? '▶️ Em andamento...' : '⏸️ Pronto para iniciar',
          style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[500]),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (mode == TimerMode.manual) return _buildManualDisplay();
    return _buildAnimatedRing();
  }

  Widget _buildManualDisplay() {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                Colors.white.withOpacity(0.4),
                Colors.grey.withOpacity(0.05),
              ]),
            ),
          ),
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📝', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 16),
                Text(
                  '${manualHours.toString().padLeft(2, '0')}:${manualMinutes.toString().padLeft(2, '0')}:00',
                  style: GoogleFonts.lato(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tempo selecionado',
                  style:
                      GoogleFonts.lato(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedRing() {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, _) {
        final scale = isActive ? 1.0 + pulseAnimation.value * 0.02 : 1.0;
        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      Colors.white.withOpacity(0.4),
                      primaryColor.withOpacity(0.05),
                    ]),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CircularProgressIndicator(
                    value: animatedProgress,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCenterIcon(),
                      const SizedBox(height: 16),
                      Text(
                        _formatDuration(displayDuration),
                        style: GoogleFonts.lato(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildSubtitle(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
