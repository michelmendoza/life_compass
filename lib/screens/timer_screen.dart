import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/colors.dart';
import '../models/activity_log.dart';
import '../models/hiit_interval.dart';
import '../models/timer_mode.dart';
import '../widgets/timer/circular_timer.dart';
import '../widgets/timer/control_button.dart';
import '../widgets/timer/manual_time_picker.dart';
import '../widgets/timer/timer_app_bar.dart';
import '../widgets/timer/timer_mode_selector.dart';
import 'completion_screen.dart';

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

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  // ── Timer state ──────────────────────────────────────────────────────────
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  DateTime? _startTime;
  bool _isRunning = false;

  TimerMode _currentMode = TimerMode.chronometer;

  // ── Pomodoro ─────────────────────────────────────────────────────────────
  Duration _pomodoroDuration = const Duration(minutes: 25);
  Duration _pomodoroRemaining = const Duration(minutes: 25);
  bool _isPomodoroRunning = false;
  bool _isBreak = false;

  // ── Manual ───────────────────────────────────────────────────────────────
  int _manualHours = 0;
  int _manualMinutes = 0;

  // ── HIIT ─────────────────────────────────────────────────────────────────
  List<HiitInterval> _hiitIntervals = [];
  int _currentIntervalIndex = 0;
  bool _isHiitRunning = false;
  Duration _hiitRemaining = Duration.zero;

  // ── Animations ───────────────────────────────────────────────────────────
  late AnimationController _pulseController;
  late AnimationController _progressController;
  double _animatedProgress = 0;

  Duration? _completionDuration;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..addListener(() {
        setState(() => _animatedProgress = _progressController.value);
      });
    _initDefaultHiit();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  // ── Computed properties ───────────────────────────────────────────────────
  Color get _energyColor =>
      HawkinsColors.energyColors[widget.energy] ?? Colors.grey;
  Color get _flowColor =>
      HawkinsColors.flowGradient[widget.flow] ?? Colors.grey;

  bool get _isAnyTimerRunning =>
      _isRunning || _isPomodoroRunning || _isHiitRunning;

  Color get _primaryColor {
    switch (_currentMode) {
      case TimerMode.pomodoro:
        return _isBreak ? Colors.green : Colors.red[400]!;
      case TimerMode.hiit:
        if (_hiitIntervals.isNotEmpty &&
            _currentIntervalIndex < _hiitIntervals.length) {
          return _hiitIntervals[_currentIntervalIndex].color;
        }
        return Colors.purple;
      default:
        return _energyColor;
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

  double get _currentProgress {
    switch (_currentMode) {
      case TimerMode.chronometer:
        if (!_isRunning || _elapsed.inSeconds == 0) return 0;
        const maxSeconds = 3600;
        return (_elapsed.inSeconds % maxSeconds) / maxSeconds;
      case TimerMode.pomodoro:
        if (_pomodoroDuration.inSeconds == 0) return 0;
        return (_pomodoroRemaining.inSeconds / _pomodoroDuration.inSeconds)
            .clamp(0.0, 1.0);
      case TimerMode.hiit:
        if (_hiitIntervals.isEmpty) return 0;
        final total = _hiitIntervals.fold(
            Duration.zero, (sum, i) => sum + i.duration);
        final elapsed = total - _hiitRemaining;
        return (elapsed.inSeconds / total.inSeconds).clamp(0.0, 1.0);
      default:
        return 0;
    }
  }

  HiitInterval? get _currentHiitInterval =>
      _hiitIntervals.isNotEmpty && _currentIntervalIndex < _hiitIntervals.length
          ? _hiitIntervals[_currentIntervalIndex]
          : null;

  // ── Animation helper ──────────────────────────────────────────────────────
  void _animateProgress() {
    _progressController.animateTo(
      _currentProgress,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  // ── HIIT setup ────────────────────────────────────────────────────────────
  void _initDefaultHiit() {
    _hiitIntervals = [
      HiitInterval(name: 'Aquecimento', duration: const Duration(seconds: 30), color: Colors.green, icon: '🔥'),
      HiitInterval(name: 'Exercício', duration: const Duration(seconds: 20), color: Colors.red, icon: '💪'),
      HiitInterval(name: 'Descanso', duration: const Duration(seconds: 10), color: Colors.blue, icon: '😮‍💨'),
      HiitInterval(name: 'Exercício', duration: const Duration(seconds: 20), color: Colors.red, icon: '💪'),
      HiitInterval(name: 'Descanso', duration: const Duration(seconds: 10), color: Colors.blue, icon: '😮‍💨'),
      HiitInterval(name: 'Exercício', duration: const Duration(seconds: 20), color: Colors.red, icon: '💪'),
      HiitInterval(name: 'Descanso', duration: const Duration(seconds: 10), color: Colors.blue, icon: '😮‍💨'),
      HiitInterval(name: 'Exercício', duration: const Duration(seconds: 20), color: Colors.red, icon: '💪'),
      HiitInterval(name: 'Resfriamento', duration: const Duration(seconds: 30), color: Colors.green, icon: '🧘'),
    ];
    _hiitRemaining = _hiitIntervals[0].duration;
  }

  // ── Chronometer ───────────────────────────────────────────────────────────
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

  // ── Pomodoro ──────────────────────────────────────────────────────────────
  void _startPomodoro() {
    if (_isPomodoroRunning) {
      _pausePomodoro();
      return;
    }
    setState(() => _isPomodoroRunning = true);
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
    setState(() => _isPomodoroRunning = false);
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

  // ── HIIT ──────────────────────────────────────────────────────────────────
  void _startHiit() {
    if (_isHiitRunning) {
      _pauseHiit();
      return;
    }
    if (_hiitRemaining == Duration.zero) _resetHiit();
    setState(() => _isHiitRunning = true);
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
    setState(() => _isHiitRunning = false);
    final total = _hiitIntervals.fold(
        Duration.zero, (sum, i) => sum + i.duration);
    _completionDuration = total;
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

  // ── Manual ────────────────────────────────────────────────────────────────
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

  // ── Completion ────────────────────────────────────────────────────────────
  void _showCompletionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompletionScreen(
          group: _isBreak ? 'Pausa Pomodoro' : widget.group,
          example: _getExampleText(),
          energy: _isBreak ? 'Passiva' : widget.energy,
          flow: widget.flow,
          organ: _isBreak ? 'Corpo/Mente' : widget.organ,
          duration: _completionDuration!,
          energyColor: _energyColor,
          flowColor: _flowColor,
          onSave: _saveLogAndClose,
        ),
      ),
    );
  }

  void _saveLogAndClose(int? consciousnessLevel, String? difficultyStr) {
    final log = ActivityLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      group: _isBreak ? 'Pausa Pomodoro' : widget.group,
      example: _getExampleText(),
      energy: _isBreak ? 'Passiva' : widget.energy,
      flow: difficultyStr ?? widget.flow,
      organ: _isBreak ? 'Corpo/Mente' : widget.organ,
      duration: _completionDuration!,
      timestamp: DateTime.now(),
      consciousnessLevel: consciousnessLevel,
      difficultyFeedback: difficultyStr,
    );

    Navigator.pop(context, log);
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) Navigator.pop(context, log);
    });
  }

  String _getExampleText() {
    switch (_currentMode) {
      case TimerMode.pomodoro:
        return _isBreak
            ? '☕ Pausa de ${_pomodoroDuration.inMinutes}min'
            : widget.example;
      case TimerMode.manual:
        return '${widget.example} (registro manual)';
      case TimerMode.hiit:
        return '🏃‍♂️ ${widget.example} - HIIT';
      default:
        return widget.example;
    }
  }

  void _onModeChanged(TimerMode mode) {
    setState(() {
      _currentMode = mode;
      if (mode == TimerMode.pomodoro) _resetPomodoro();
      if (mode == TimerMode.hiit) _resetHiit();
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────
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
              TimerAppBar(
                group: widget.group,
                example: widget.example,
                energyColor: _energyColor,
                isBreak: _isBreak,
                currentMode: _currentMode,
                onBack: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
              if (!_isAnyTimerRunning)
                TimerModeSelector(
                  currentMode: _currentMode,
                  energyColor: _energyColor,
                  onModeChanged: _onModeChanged,
                ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: CircularTimer(
                    mode: _currentMode,
                    displayDuration: _currentDuration,
                    animatedProgress: _animatedProgress,
                    primaryColor: _primaryColor,
                    isActive: _isAnyTimerRunning,
                    isBreak: _isBreak,
                    pulseAnimation: _pulseController,
                    currentHiitInterval: _currentHiitInterval,
                    hiitCurrentIndex: _currentIntervalIndex,
                    hiitTotal: _hiitIntervals.length,
                    manualHours: _manualHours,
                    manualMinutes: _manualMinutes,
                  ),
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

  // ── Controls ──────────────────────────────────────────────────────────────
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
      return Row(children: [
        Expanded(
          child: ControlButton(
            icon: Icons.pause_rounded,
            label: 'PAUSAR',
            onTap: _pauseTimer,
            accentColor: _energyColor,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ControlButton(
            icon: Icons.stop_rounded,
            label: 'FINALIZAR',
            onTap: _stopTimer,
            accentColor: _energyColor,
            color: Colors.red,
          ),
        ),
      ]);
    }
    return ControlButton(
      icon: Icons.play_arrow_rounded,
      label: 'INICIAR',
      onTap: _startTimer,
      accentColor: _energyColor,
      isPrimary: true,
    );
  }

  Widget _buildPomodoroControls() {
    final isIdle =
        !_isPomodoroRunning && _pomodoroRemaining == _pomodoroDuration;

    if (isIdle) {
      return Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [15, 25, 30, 45].map((min) {
            final isSelected =
                _pomodoroDuration.inMinutes == min && !_isBreak;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => _setPomodoroDuration(min),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.red[400]
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${min}min',
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey[600],
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
            SmallBreakButton(
                label: '☕ 5min',
                onTap: () => _startBreak(5),
                color: Colors.green),
            const SizedBox(width: 8),
            SmallBreakButton(
                label: '😴 10min',
                onTap: () => _startBreak(10),
                color: Colors.teal),
          ],
        ),
        const SizedBox(height: 12),
        ControlButton(
          icon: Icons.play_arrow_rounded,
          label: 'INICIAR',
          onTap: _startPomodoro,
          accentColor: _energyColor,
          isPrimary: true,
        ),
      ]);
    }

    return Row(children: [
      Expanded(
        child: ControlButton(
          icon: Icons.refresh_rounded,
          label: 'RESET',
          onTap: _resetPomodoro,
          accentColor: _energyColor,
          color: Colors.grey,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        flex: 2,
        child: ControlButton(
          icon: _isPomodoroRunning
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          label: _isPomodoroRunning ? 'PAUSAR' : 'INICIAR',
          onTap: _startPomodoro,
          accentColor: _energyColor,
          color: _isBreak ? Colors.green : Colors.red[400],
          isPrimary: true,
        ),
      ),
      if (_pomodoroRemaining != _pomodoroDuration) ...[
        const SizedBox(width: 12),
        Expanded(
          child: ControlButton(
            icon: Icons.stop_rounded,
            label: 'PARAR',
            onTap: _stopPomodoroAndSave,
            accentColor: _energyColor,
            color: Colors.red,
          ),
        ),
      ],
    ]);
  }

  Widget _buildManualControls() {
    return ManualTimePicker(
      hours: _manualHours,
      minutes: _manualMinutes,
      accentColor: _energyColor,
      onHoursDecrement: () {
        if (_manualHours > 0) setState(() => _manualHours--);
      },
      onHoursIncrement: () {
        if (_manualHours < 24) setState(() => _manualHours++);
      },
      onMinutesDecrement: () {
        if (_manualMinutes > 0) setState(() => _manualMinutes--);
      },
      onMinutesIncrement: () {
        if (_manualMinutes < 59) setState(() => _manualMinutes++);
      },
      onSave: _saveManualTime,
    );
  }

  Widget _buildHiitControls() {
    if (_hiitIntervals.isEmpty) return const SizedBox.shrink();

    final isIdle = !_isHiitRunning &&
        _hiitRemaining == _hiitIntervals[0].duration;

    if (isIdle) {
      return ControlButton(
        icon: Icons.play_arrow_rounded,
        label: 'INICIAR HIIT',
        onTap: _startHiit,
        accentColor: _energyColor,
        color: Colors.purple,
        isPrimary: true,
      );
    }

    return Row(children: [
      Expanded(
        child: ControlButton(
          icon: Icons.refresh_rounded,
          label: 'RESET',
          onTap: _resetHiit,
          accentColor: _energyColor,
          color: Colors.grey,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        flex: 2,
        child: ControlButton(
          icon:
              _isHiitRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          label: _isHiitRunning ? 'PAUSAR' : 'INICIAR',
          onTap: _startHiit,
          accentColor: _energyColor,
          color: Colors.purple,
          isPrimary: true,
        ),
      ),
      if (_hiitRemaining != _hiitIntervals[0].duration) ...[
        const SizedBox(width: 12),
        Expanded(
          child: ControlButton(
            icon: Icons.stop_rounded,
            label: 'PARAR',
            onTap: _completeHiit,
            accentColor: _energyColor,
            color: Colors.red,
          ),
        ),
      ],
    ]);
  }
}
