import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../models/activity_log.dart';
import '../data/colors.dart';

class TimerScreen extends StatefulWidget {
  final String group;
  final String example;
  final String energy;
  final String flow;
  final String organ;

  const TimerScreen({
    super.key,
    required this.group,
    required this.example,
    required this.energy,
    required this.flow,
    required this.organ,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

enum TimerMode { chronometer, pomodoro, manual, hiit }

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  DateTime? _startTime;
  bool _isRunning = false;

  // Modo atual
  TimerMode _currentMode = TimerMode.chronometer;

  // Pomodoro
  Duration _pomodoroDuration = const Duration(minutes: 25);
  Duration _pomodoroRemaining = const Duration(minutes: 25);
  bool _isPomodoroRunning = false;
  bool _isBreak = false;

  // Manual
  int _manualHours = 0;
  int _manualMinutes = 0;

  // HIIT
  List<HiitInterval> _hiitIntervals = [];
  int _currentIntervalIndex = 0;
  bool _isHiitRunning = false;
  Duration _hiitRemaining = Duration.zero;

  late AnimationController _pulseController;
  late AnimationController _progressAnimationController;
  double _animatedProgress = 0;

  // Dados para tela de conclusão
  Duration? _completionDuration;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimationController.addListener(() {
      setState(() {
        _animatedProgress = _progressAnimationController.value;
      });
    });

    _initDefaultHiit();
  }

  void _initDefaultHiit() {
    _hiitIntervals = [
      HiitInterval(
          name: 'Aquecimento',
          duration: const Duration(seconds: 30),
          color: Colors.green,
          icon: '🔥'),
      HiitInterval(
          name: 'Exercício',
          duration: const Duration(seconds: 20),
          color: Colors.red,
          icon: '💪'),
      HiitInterval(
          name: 'Descanso',
          duration: const Duration(seconds: 10),
          color: Colors.blue,
          icon: '😮‍💨'),
      HiitInterval(
          name: 'Exercício',
          duration: const Duration(seconds: 20),
          color: Colors.red,
          icon: '💪'),
      HiitInterval(
          name: 'Descanso',
          duration: const Duration(seconds: 10),
          color: Colors.blue,
          icon: '😮‍💨'),
      HiitInterval(
          name: 'Exercício',
          duration: const Duration(seconds: 20),
          color: Colors.red,
          icon: '💪'),
      HiitInterval(
          name: 'Descanso',
          duration: const Duration(seconds: 10),
          color: Colors.blue,
          icon: '😮‍💨'),
      HiitInterval(
          name: 'Exercício',
          duration: const Duration(seconds: 20),
          color: Colors.red,
          icon: '💪'),
      HiitInterval(
          name: 'Resfriamento',
          duration: const Duration(seconds: 30),
          color: Colors.green,
          icon: '🧘'),
    ];
    _hiitRemaining = _hiitIntervals[0].duration;
  }

  Color get _energyColor =>
      HawkinsColors.energyColors[widget.energy] ?? Colors.grey;
  Color get _flowColor =>
      HawkinsColors.flowGradient[widget.flow] ?? Colors.grey;

  double get _chronometerProgress {
    if (!_isRunning || _elapsed.inSeconds == 0) return 0;
    const maxDisplaySeconds = 3600;
    final progress =
        (_elapsed.inSeconds % maxDisplaySeconds) / maxDisplaySeconds;
    return progress.clamp(0.0, 1.0);
  }

  double get _pomodoroProgress {
    if (_pomodoroDuration.inSeconds == 0) return 0;
    return (_pomodoroRemaining.inSeconds / _pomodoroDuration.inSeconds)
        .clamp(0.0, 1.0);
  }

  double get _hiitProgress {
    if (_hiitIntervals.isEmpty) return 0;
    final totalDuration = _hiitIntervals.fold(
        Duration.zero, (sum, interval) => sum + interval.duration);
    final elapsed = totalDuration - _hiitRemaining;
    return (elapsed.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);
  }

  double get _currentProgress {
    switch (_currentMode) {
      case TimerMode.chronometer:
        return _chronometerProgress;
      case TimerMode.pomodoro:
        return _pomodoroProgress;
      case TimerMode.hiit:
        return _hiitProgress;
      default:
        return 0;
    }
  }

  Duration get _currentDuration {
    switch (_currentMode) {
      case TimerMode.chronometer:
        return _elapsed;
      case TimerMode.pomodoro:
        return _pomodoroRemaining;
      case TimerMode.hiit:
        return _hiitRemaining;
      default:
        return Duration.zero;
    }
  }

  void _animateProgress() {
    _progressAnimationController.animateTo(
      _currentProgress,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  // ========== CRONÔMETRO ==========
  void _startTimer() {
    setState(() {
      _isRunning = true;
      _startTime = DateTime.now().subtract(_elapsed);
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(_startTime!);
          _animateProgress();
        });
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _stopTimer() {
    _timer?.cancel();
    _completionDuration = _elapsed;
    _showCompletionScreen();
  }

  // ========== POMODORO ==========
  void _startPomodoro() {
    if (_isPomodoroRunning) {
      _pausePomodoro();
      return;
    }
    setState(() {
      _isPomodoroRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          if (_pomodoroRemaining.inSeconds > 0) {
            _pomodoroRemaining -= const Duration(seconds: 1);
            _animateProgress();
          } else {
            _pomodoroComplete();
          }
        });
      }
    });
  }

  void _pausePomodoro() {
    _timer?.cancel();
    setState(() => _isPomodoroRunning = false);
  }

  void _pomodoroComplete() {
    _timer?.cancel();
    setState(() {
      _isPomodoroRunning = false;
    });
    _completionDuration = _pomodoroDuration;
    _showCompletionScreen();
  }

  void _resetPomodoro() {
    _timer?.cancel();
    setState(() {
      _isPomodoroRunning = false;
      _isBreak = false;
      _pomodoroDuration = const Duration(minutes: 25);
      _pomodoroRemaining = const Duration(minutes: 25);
      _animateProgress();
    });
  }

  void _setPomodoroDuration(int minutes) {
    if (_isPomodoroRunning) return;
    setState(() {
      _isBreak = false;
      _pomodoroDuration = Duration(minutes: minutes);
      _pomodoroRemaining = Duration(minutes: minutes);
      _animateProgress();
    });
  }

  void _startBreak(int minutes) {
    _timer?.cancel();
    setState(() {
      _isBreak = true;
      _isPomodoroRunning = false;
      _pomodoroDuration = Duration(minutes: minutes);
      _pomodoroRemaining = Duration(minutes: minutes);
      _animateProgress();
    });
  }

  void _stopPomodoroAndSave() {
    _timer?.cancel();
    final completed = _pomodoroDuration - _pomodoroRemaining;
    if (completed.inSeconds > 0) {
      _completionDuration = completed;
      _showCompletionScreen();
    }
  }

  // ========== MANUAL ==========
  void _saveManualTime() {
    final duration = Duration(hours: _manualHours, minutes: _manualMinutes);
    if (duration.inSeconds > 0) {
      _completionDuration = duration;
      _showCompletionScreen();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecione um tempo válido!'),
          backgroundColor: Colors.orange[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ========== HIIT ==========
  void _startHiit() {
    if (_isHiitRunning) {
      _pauseHiit();
      return;
    }

    if (_hiitRemaining == Duration.zero) {
      _resetHiit();
    }

    setState(() {
      _isHiitRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          if (_hiitRemaining.inSeconds > 0) {
            _hiitRemaining -= const Duration(seconds: 1);
            _animateProgress();
          } else {
            _nextHiitInterval();
          }
        });
      }
    });
  }

  void _nextHiitInterval() {
    if (_currentIntervalIndex + 1 < _hiitIntervals.length) {
      setState(() {
        _currentIntervalIndex++;
        _hiitRemaining = _hiitIntervals[_currentIntervalIndex].duration;
      });
    } else {
      _completeHiit();
    }
  }

  void _completeHiit() {
    _timer?.cancel();
    setState(() {
      _isHiitRunning = false;
    });
    final totalDuration = _hiitIntervals.fold(
        Duration.zero, (sum, interval) => sum + interval.duration);
    _completionDuration = totalDuration;
    _showCompletionScreen();
  }

  void _pauseHiit() {
    _timer?.cancel();
    setState(() => _isHiitRunning = false);
  }

  void _resetHiit() {
    _timer?.cancel();
    setState(() {
      _isHiitRunning = false;
      _currentIntervalIndex = 0;
      _hiitRemaining = _hiitIntervals[0].duration;
      _animateProgress();
    });
  }

  // ========== TELA DE CONCLUSÃO SEPARADA ==========
  void _showCompletionScreen() {
    // Usar pushReplacement para não acumular telas
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompletionScreen(
          group: _isBreak ? 'Pausa Pomodoro' : widget.group,
          example: _getExampleText(),
          energy: _isBreak ? 'Passiva' : widget.energy,
          flow: widget.flow,
          organ: _isBreak ? 'Corpo/Mente' : widget.organ,
          duration: _completionDuration!,
          energyColor: _energyColor,
          flowColor: _flowColor,
          onSave: (consciousnessLevel, difficultyStr) {
            // Salva o log e volta para a tela principal
            _saveLogAndClose(
                _completionDuration!, consciousnessLevel, difficultyStr);
          },
        ),
      ),
    );
  }

  void _saveLogAndClose(
      Duration duration, int? consciousnessLevel, String? difficultyStr) {
    final log = ActivityLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      group: _isBreak ? 'Pausa Pomodoro' : widget.group,
      example: _getExampleText(), // Agora vai pegar o exemplo correto
      energy: _isBreak ? 'Passiva' : widget.energy,
      flow: difficultyStr ?? widget.flow,
      organ: _isBreak ? 'Corpo/Mente' : widget.organ,
      duration: duration,
      timestamp: DateTime.now(),
      consciousnessLevel: consciousnessLevel,
      difficultyFeedback: difficultyStr,
    );

    print('=== LOG SALVO ===');
    print('Group: ${log.group}');
    print('Example: ${log.example}');
    print('Duration: ${log.duration.inMinutes} min');
    print('Consciousness: ${consciousnessLevel ?? "null"}');
    print('Difficulty: ${difficultyStr ?? "null"}');
    print('ID: ${log.id}');
    print('Timestamp: ${log.timestamp}');
    print('================');

    // Volta para a tela anterior (TimerScreen) com o log
    Navigator.pop(context, log);

    // Também fecha a TimerScreen e volta para o Dashboard com o log
    Future.delayed(Duration(milliseconds: 50), () {
      if (mounted) {
        Navigator.pop(context, log);
      }
    });

    // Volta diretamente para o Dashboard com o log (apenas um pop)
    // Navigator.popUntil(context, (route) => route.isFirst);
    // Navigator.pop(context, log);
  }

  String _getExampleText() {
    switch (_currentMode) {
      case TimerMode.chronometer:
        return widget.example; // Mantém o exemplo original
      case TimerMode.pomodoro:
        return _isBreak
            ? '☕ Pausa de ${_pomodoroDuration.inMinutes}min'
            : widget.example; // Mantém o exemplo original no foco
      case TimerMode.manual:
        // Para modo manual, mostra a prática original + " (registro manual)"
        return '${widget.example} (registro manual)';
      case TimerMode.hiit:
        return '🏃‍♂️ ${widget.example} - HIIT'; // Mostra a prática + HIIT
    }
  }

  void _resetAfterCompletion() {
    switch (_currentMode) {
      case TimerMode.chronometer:
        setState(() {
          _elapsed = Duration.zero;
          _isRunning = false;
        });
        break;
      case TimerMode.pomodoro:
        _resetPomodoro();
        break;
      case TimerMode.hiit:
        _resetHiit();
        break;
      default:
        break;
    }
  }

  void _saveLog(
      Duration duration, int? consciousnessLevel, String? difficultyStr) {
    final log = ActivityLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      group: _isBreak ? 'Pausa Pomodoro' : widget.group,
      example: _getExampleText(),
      energy: _isBreak ? 'Passiva' : widget.energy,
      flow: difficultyStr ?? widget.flow,
      organ: _isBreak ? 'Corpo/Mente' : widget.organ,
      duration: duration,
      timestamp: DateTime.now(),
      consciousnessLevel: consciousnessLevel,
      difficultyFeedback: difficultyStr,
    );

    print('=== LOG SALVO ===');
    print('Group: ${log.group}');
    print('Example: ${log.example}');
    print('Duration: ${log.duration.inMinutes} min');
    print('Consciousness: ${consciousnessLevel ?? "null"}');
    print('Difficulty: ${difficultyStr ?? "null"}');
    print('ID: ${log.id}');
    print('Timestamp: ${log.timestamp}');
    print('================');

    // Volta para a tela anterior e passa o log
    Navigator.pop(context, log);
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatDurationShort(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    if (d.inHours > 0) return '${d.inHours}h${m % 60}m';
    if (m > 0) return '${m}m${s}s';
    return '${s}s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _energyColor.withOpacity(0.08),
              _flowColor.withOpacity(0.08),
              Colors.white.withOpacity(0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              const SizedBox(height: 8),
              _buildModeSelector(),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: _buildCircularTimer(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: _buildControls(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
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
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _energyColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  Icon(Icons.arrow_back_rounded, color: _energyColor, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.group,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _energyColor,
                  ),
                ),
                Text(
                  widget.example,
                  style:
                      GoogleFonts.lato(fontSize: 10, color: Colors.grey[500]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (_currentMode == TimerMode.pomodoro && _isBreak)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

  Widget _buildModeSelector() {
    if (_isRunning || _isPomodoroRunning || _isHiitRunning) {
      return const SizedBox();
    }

    final modes = [
      (TimerMode.chronometer, 'Cronômetro', Icons.timer_rounded, _energyColor),
      (TimerMode.pomodoro, 'Pomodoro', Icons.timer_rounded, Colors.red[400]!),
      (TimerMode.manual, 'Manual', Icons.edit_calendar_rounded, Colors.orange),
      (TimerMode.hiit, 'HIIT', Icons.fitness_center_rounded, Colors.purple),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: modes.map((mode) {
          final isSelected = _currentMode == mode.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentMode = mode.$1;
                  if (_currentMode == TimerMode.pomodoro) {
                    _resetPomodoro();
                  } else if (_currentMode == TimerMode.hiit) {
                    _resetHiit();
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? mode.$4 : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? mode.$4 : Colors.white,
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(mode.$3,
                        size: 18, color: isSelected ? Colors.white : mode.$4),
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

  Widget _buildCircularTimer() {
    // Se for modo manual, mostra o relógio simplificado que criamos
    if (_currentMode == TimerMode.manual) {
      final selectedDuration =
          Duration(hours: _manualHours, minutes: _manualMinutes);
      final hours = selectedDuration.inHours;
      final minutes = selectedDuration.inMinutes.remainder(60);

      return Container(
        width: 280,
        height: 280,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Círculo de fundo suave
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.4),
                    Colors.grey.withOpacity(0.05),
                  ],
                ),
              ),
            ),
            // Círculo interno branco
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
                    '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:00',
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
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Código original para os outros modos
    final displayDuration = _currentDuration;
    Color primaryColor;

    switch (_currentMode) {
      case TimerMode.pomodoro:
        primaryColor = _isBreak ? Colors.green : Colors.red[400]!;
        break;
      case TimerMode.hiit:
        if (_hiitIntervals.isNotEmpty &&
            _currentIntervalIndex < _hiitIntervals.length) {
          primaryColor = _hiitIntervals[_currentIntervalIndex].color;
        } else {
          primaryColor = Colors.purple;
        }
        break;
      default:
        primaryColor = _energyColor;
    }

    final isActive = _isRunning || _isPomodoroRunning || _isHiitRunning;

    return AnimatedBuilder(
      animation:
          Listenable.merge([_pulseController, _progressAnimationController]),
      builder: (context, child) {
        final scale = isActive ? 1.0 + _pulseController.value * 0.02 : 1.0;

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
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.4),
                        primaryColor.withOpacity(0.05),
                      ],
                    ),
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
                    value: _animatedProgress,
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
                      _buildTimerIcon(),
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
                      _buildTimerSubtitle(),
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

  Widget _buildTimerIcon() {
    switch (_currentMode) {
      case TimerMode.chronometer:
        return const Text('⏱️', style: TextStyle(fontSize: 40));
      case TimerMode.pomodoro:
        return Text(_isBreak ? '☕' : '🍅',
            style: const TextStyle(fontSize: 40));
      case TimerMode.manual:
        // Não mostra ícone nenhum ou mostra um ícone minimalista
        return const SizedBox.shrink(); // Remove o ícone completamente
      case TimerMode.hiit:
        if (_hiitIntervals.isNotEmpty &&
            _currentIntervalIndex < _hiitIntervals.length) {
          return Column(
            children: [
              Text(_hiitIntervals[_currentIntervalIndex].icon,
                  style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 4),
              Text(
                _hiitIntervals[_currentIntervalIndex].name,
                style:
                    GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          );
        }
        return const Text('🏃‍♂️', style: TextStyle(fontSize: 40));
    }
  }

  Widget _buildTimerSubtitle() {
    final isActive = _isRunning || _isPomodoroRunning || _isHiitRunning;

    if (_currentMode == TimerMode.manual) {
      return Text(
        '📝 Selecione o tempo abaixo',
        style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[500]),
      );
    }

    if (_currentMode == TimerMode.hiit && _hiitIntervals.isNotEmpty) {
      return Text(
        '${_currentIntervalIndex + 1}/${_hiitIntervals.length} • ${isActive ? "▶️ Em andamento" : "⏸️ Pausado"}',
        style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[500]),
      );
    }

    return Text(
      isActive ? '▶️ Em andamento...' : '⏸️ Pronto para iniciar',
      style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[500]),
    );
  }

  Widget _buildControls() {
    switch (_currentMode) {
      case TimerMode.chronometer:
        return _buildChronometerControls();
      case TimerMode.pomodoro:
        return _buildPomodoroControls();
      case TimerMode.manual:
        return _buildManualControls();
      case TimerMode.hiit:
        return _buildHiitControls();
    }
  }

  Widget _buildChronometerControls() {
    if (_isRunning) {
      return Row(
        children: [
          Expanded(
            child: _controlButton(
              icon: Icons.pause_rounded,
              label: 'PAUSAR',
              onTap: _pauseTimer,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _controlButton(
              icon: Icons.stop_rounded,
              label: 'FINALIZAR',
              onTap: _stopTimer,
              color: Colors.red,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _controlButton(
            icon: Icons.play_arrow_rounded,
            label: 'INICIAR',
            onTap: _startTimer,
            isPrimary: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPomodoroControls() {
    if (!_isPomodoroRunning && _pomodoroRemaining == _pomodoroDuration) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [15, 25, 30, 45].map((min) {
              final sel = _pomodoroDuration.inMinutes == min && !_isBreak;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => _setPomodoroDuration(min),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          sel ? Colors.red[400] : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${min}min',
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: sel ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _smallButton('☕ 5min', () => _startBreak(5), Colors.green),
              const SizedBox(width: 8),
              _smallButton('😴 10min', () => _startBreak(10), Colors.teal),
            ],
          ),
          const SizedBox(height: 12),
          _controlButton(
            icon: Icons.play_arrow_rounded,
            label: 'INICIAR',
            onTap: _startPomodoro,
            isPrimary: true,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _controlButton(
            icon: Icons.refresh_rounded,
            label: 'RESET',
            onTap: _resetPomodoro,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _controlButton(
            icon: _isPomodoroRunning
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            label: _isPomodoroRunning ? 'PAUSAR' : 'INICIAR',
            onTap: _startPomodoro,
            isPrimary: true,
            color: _isBreak ? Colors.green : Colors.red[400],
          ),
        ),
        if (_pomodoroRemaining != _pomodoroDuration) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _controlButton(
              icon: Icons.stop_rounded,
              label: 'PARAR',
              onTap: _stopPomodoroAndSave,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildManualControls() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Título
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
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Horas (linha separada)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, size: 20, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      'Horas',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        if (_manualHours > 0) {
                          setState(() => _manualHours--);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _energyColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            Icon(Icons.remove, color: _energyColor, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: _energyColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        _manualHours.toString().padLeft(2, '0'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _energyColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        if (_manualHours < 24) {
                          setState(() => _manualHours++);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _energyColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.add, color: _energyColor, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Minutos (linha separada)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, size: 20, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      'Minutos',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        if (_manualMinutes > 0) {
                          setState(() => _manualMinutes--);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _energyColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            Icon(Icons.remove, color: _energyColor, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: _energyColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        _manualMinutes.toString().padLeft(2, '0'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _energyColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        if (_manualMinutes < 59) {
                          setState(() => _manualMinutes++);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _energyColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.add, color: _energyColor, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Botão salvar
              _controlButton(
                icon: Icons.save_rounded,
                label: 'SALVAR REGISTRO',
                onTap: _saveManualTime,
                isPrimary: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHiitControls() {
    if (_hiitIntervals.isEmpty) return const SizedBox();

    if (!_isHiitRunning && _hiitRemaining == _hiitIntervals[0].duration) {
      return Column(
        children: [
          _controlButton(
            icon: Icons.play_arrow_rounded,
            label: 'INICIAR HIIT',
            onTap: _startHiit,
            isPrimary: true,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _controlButton(
            icon: Icons.refresh_rounded,
            label: 'RESET',
            onTap: _resetHiit,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _controlButton(
            icon:
                _isHiitRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
            label: _isHiitRunning ? 'PAUSAR' : 'INICIAR',
            onTap: _startHiit,
            isPrimary: true,
            color: Colors.purple,
          ),
        ),
        if (_hiitRemaining != _hiitIntervals[0].duration) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _controlButton(
              icon: Icons.stop_rounded,
              label: 'PARAR',
              onTap: _completeHiit,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    bool isPrimary = false,
  }) {
    final buttonColor = color ?? _energyColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  colors: [buttonColor, buttonColor.withOpacity(0.7)])
              : null,
          color: isPrimary ? null : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isPrimary ? Colors.transparent : buttonColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: buttonColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? Colors.white : buttonColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isPrimary ? Colors.white : buttonColor,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallButton(String label, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}

class HiitInterval {
  final String name;
  final Duration duration;
  final Color color;
  final String icon;

  HiitInterval({
    required this.name,
    required this.duration,
    required this.color,
    this.icon = '💪',
  });
}

// TELA DE CONCLUSÃO - VERSÃO COM BOTÕES DO MESMO TAMANHO
class CompletionScreen extends StatefulWidget {
  final String group;
  final String example;
  final String energy;
  final String flow;
  final String organ;
  final Duration duration;
  final Color energyColor;
  final Color flowColor;
  final Function(int?, String?) onSave;

  const CompletionScreen({
    super.key,
    required this.group,
    required this.example,
    required this.energy,
    required this.flow,
    required this.organ,
    required this.duration,
    required this.energyColor,
    required this.flowColor,
    required this.onSave,
  });

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen> {
  int? _consciousnessLevel;
  int? _difficultyLevel;

  String get _formattedDuration {
    final d = widget.duration;
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}min';
    if (m > 0) return '${m}min ${s}s';
    return '${s}s';
  }

  String? get _difficultyString {
    switch (_difficultyLevel) {
      case 0:
        return 'Fácil';
      case 1:
        return 'Médio';
      case 2:
        return 'Difícil';
      default:
        return null;
    }
  }

  String? get _consciousnessString {
    switch (_consciousnessLevel) {
      case 0:
        return 'Automático';
      case 1:
        return 'Presente';
      case 2:
        return 'Focado';
      case 3:
        return 'Fluindo';
      default:
        return null;
    }
  }

  Future<void> _shareResult() async {
    final shareText = '''
🏆 Completei minha atividade! 🏆

📋 ${widget.group}
⏱️ Duração: $_formattedDuration
${_consciousnessString != null ? '🧠 Estado: $_consciousnessString' : ''}
${_difficultyString != null ? '⚡ Dificuldade: $_difficultyString' : ''}

✨ "${widget.example}"

#HawkinsTracker #Produtividade #Mindfulness
    ''';
    await Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador de arrasto
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Ícone de celebração
              Container(
                margin: const EdgeInsets.only(top: 16),
                child: const Text('🎉', style: TextStyle(fontSize: 48)),
              ),

              // Título
              Text(
                'Atividade Concluída!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.energyColor,
                ),
              ),

              const SizedBox(height: 8),

              // Cards de informação (compactos)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text('📋', style: TextStyle(fontSize: 20)),
                          const SizedBox(height: 2),
                          Text('Categoria',
                              style: GoogleFonts.lato(
                                  fontSize: 10, color: Colors.grey[500])),
                          Text(widget.group,
                              style: GoogleFonts.lato(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.grey[200]),
                    Expanded(
                      child: Column(
                        children: [
                          Text('⏱️', style: TextStyle(fontSize: 20)),
                          const SizedBox(height: 2),
                          Text('Duração',
                              style: GoogleFonts.lato(
                                  fontSize: 10, color: Colors.grey[500])),
                          Text(_formattedDuration,
                              style: GoogleFonts.lato(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Prática
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.energyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('✨', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.example,
                        style: GoogleFonts.lato(
                            fontSize: 12, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Divider
              Container(
                  height: 1,
                  color: Colors.grey[200],
                  margin: const EdgeInsets.symmetric(horizontal: 16)),

              const SizedBox(height: 16),

              // Feedback - Nível de Consciência (com texto alterado)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Text('Você estava consciente durante a prática?',
                        style: GoogleFonts.lato(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700]),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _feedbackButton(
                            '😴', 'Automático', 0, _consciousnessLevel, () {
                          setState(() => _consciousnessLevel =
                              _consciousnessLevel == 0 ? null : 0);
                        }, widget.energyColor),
                        _feedbackButton(
                            '😐', 'Presente', 1, _consciousnessLevel, () {
                          setState(() => _consciousnessLevel =
                              _consciousnessLevel == 1 ? null : 1);
                        }, widget.energyColor),
                        _feedbackButton('🔥', 'Focado', 2, _consciousnessLevel,
                            () {
                          setState(() => _consciousnessLevel =
                              _consciousnessLevel == 2 ? null : 2);
                        }, widget.energyColor),
                        _feedbackButton('✨', 'Fluindo', 3, _consciousnessLevel,
                            () {
                          setState(() => _consciousnessLevel =
                              _consciousnessLevel == 3 ? null : 3);
                        }, widget.energyColor),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Feedback - Dificuldade
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Text('Nível de dificuldade?',
                        style: GoogleFonts.lato(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700])),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _feedbackButton('🌊', 'Fácil', 0, _difficultyLevel, () {
                          setState(() => _difficultyLevel =
                              _difficultyLevel == 0 ? null : 0);
                        }, Colors.green),
                        _feedbackButton('⚡', 'Médio', 1, _difficultyLevel, () {
                          setState(() => _difficultyLevel =
                              _difficultyLevel == 1 ? null : 1);
                        }, Colors.orange),
                        _feedbackButton('🔥', 'Difícil', 2, _difficultyLevel,
                            () {
                          setState(() => _difficultyLevel =
                              _difficultyLevel == 2 ? null : 2);
                        }, Colors.red),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Divider
              Container(
                  height: 1,
                  color: Colors.grey[200],
                  margin: const EdgeInsets.symmetric(horizontal: 16)),

              const SizedBox(height: 12),

              // Botões de ação
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _shareResult,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.share_rounded,
                                  size: 16, color: Colors.blue),
                              const SizedBox(width: 6),
                              Text('Compartilhar',
                                  style: GoogleFonts.lato(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onSave(
                            _consciousnessLevel, _difficultyString),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [widget.energyColor, widget.flowColor]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              Text('Finalizar',
                                  style: GoogleFonts.lato(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Botão pular
              TextButton(
                onPressed: () => widget.onSave(null, null),
                child: Text('Pular feedback',
                    style: GoogleFonts.lato(
                        fontSize: 10, color: Colors.grey[400])),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feedbackButton(String emoji, String label, int value, int? current,
      VoidCallback onTap, Color color) {
    final isSelected = current == value;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 65, // Largura fixa para todos os botões
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
            Text(label,
                style: GoogleFonts.lato(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
