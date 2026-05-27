import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  DateTime? _startTime;
  bool _isRunning = false;

  bool _isPomodoroMode = false;
  Duration _pomodoroDuration = const Duration(minutes: 25);
  Duration _pomodoroRemaining = const Duration(minutes: 25);
  bool _isPomodoroRunning = false;
  bool _isBreak = false;

  final _hoursController = TextEditingController();
  final _minutesController = TextEditingController();
  bool _showManualInput = false;

  late AnimationController _pulseController;
  late AnimationController _progressAnimationController;
  double _animatedProgress = 0;

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
  }

  Color get _energyColor =>
      HawkinsColors.energyColors[widget.energy] ?? Colors.grey;
  Color get _flowColor =>
      HawkinsColors.flowGradient[widget.flow] ?? Colors.grey;

  // Progresso para o cronômetro (progressivo)
  double get _chronometerProgress {
    if (!_isRunning || _elapsed.inSeconds == 0) return 0;
    const maxDisplaySeconds = 3600;
    final progress =
        (_elapsed.inSeconds % maxDisplaySeconds) / maxDisplaySeconds;
    return progress.clamp(0.0, 1.0);
  }

  // Progresso para o Pomodoro (regressivo)
  double get _pomodoroProgress {
    if (_pomodoroDuration.inSeconds == 0) return 0;
    return (_pomodoroRemaining.inSeconds / _pomodoroDuration.inSeconds)
        .clamp(0.0, 1.0);
  }

  double get _currentProgress =>
      _isPomodoroMode ? _pomodoroProgress : _chronometerProgress;

  void _animateProgress() {
    _progressAnimationController.animateTo(
      _currentProgress,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  // ========== TIMER ==========
  void _startTimer() {
    setState(() {
      _isRunning = true;
      _startTime = DateTime.now().subtract(_elapsed);
      _showManualInput = false;
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
    _showFeedback(_elapsed);
  }

  // ========== POMODORO ==========
  void _startPomodoro() {
    if (_isPomodoroRunning) {
      _pausePomodoro();
      return;
    }
    setState(() {
      _isPomodoroRunning = true;
      _showManualInput = false;
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
    _showFeedback(_pomodoroDuration);
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

  void _iniciarPausa(int minutes) {
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
    if (completed.inSeconds > 0) _showFeedback(completed);
  }

  // ========== FEEDBACK PÓS-ATIVIDADE ==========
  int? _consciousnessLevel; // null = não selecionado
  int? _difficultyLevel; // null = não selecionado

  void _showFeedback(Duration duration) {
    // Resetar valores para null (sem feedback)
    _consciousnessLevel = null;
    _difficultyLevel = null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        // Estado local do modal - fora do builder do StatefulBuilder
        int? localConsciousness;
        int? localDifficulty;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Como foi?',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_isBreak ? '☕ Pausa' : widget.group} · ${_formatDurationShort(duration)}',
                    style:
                        GoogleFonts.lato(fontSize: 13, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 20),

                  // Pergunta 1: Consciência
                  Text(
                    'Como você se sentiu? (opcional)',
                    style: GoogleFonts.lato(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _feedbackOptionModal(
                        setModalState,
                        '😴',
                        'Automático',
                        0,
                        localConsciousness,
                        (value) {
                          setModalState(() {
                            localConsciousness = value;
                          });
                        },
                      ),
                      _feedbackOptionModal(
                        setModalState,
                        '😐',
                        'Presente',
                        1,
                        localConsciousness,
                        (value) {
                          setModalState(() {
                            localConsciousness = value;
                          });
                        },
                      ),
                      _feedbackOptionModal(
                        setModalState,
                        '🔥',
                        'Focado',
                        2,
                        localConsciousness,
                        (value) {
                          setModalState(() {
                            localConsciousness = value;
                          });
                        },
                      ),
                      _feedbackOptionModal(
                        setModalState,
                        '✨',
                        'Fluindo',
                        3,
                        localConsciousness,
                        (value) {
                          setModalState(() {
                            localConsciousness = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pergunta 2: Dificuldade
                  Text(
                    'Como foi a dificuldade? (opcional)',
                    style: GoogleFonts.lato(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _feedbackOptionModal(
                        setModalState,
                        '🌊',
                        'Fácil',
                        0,
                        localDifficulty,
                        (value) {
                          setModalState(() {
                            localDifficulty = value;
                          });
                        },
                        isDifficulty: true,
                      ),
                      _feedbackOptionModal(
                        setModalState,
                        '⚡',
                        'Médio',
                        1,
                        localDifficulty,
                        (value) {
                          setModalState(() {
                            localDifficulty = value;
                          });
                        },
                        isDifficulty: true,
                      ),
                      _feedbackOptionModal(
                        setModalState,
                        '🔥',
                        'Difícil',
                        2,
                        localDifficulty,
                        (value) {
                          setModalState(() {
                            localDifficulty = value;
                          });
                        },
                        isDifficulty: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Botões
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // PULAR - salvar SEM feedback
                            _consciousnessLevel = null;
                            _difficultyLevel = null;
                            Navigator.pop(ctx);
                            _saveLog(duration);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              'PULAR',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // SALVAR - só salva se selecionou algo
                            _consciousnessLevel = localConsciousness;
                            _difficultyLevel = localDifficulty;
                            Navigator.pop(ctx);
                            _saveLog(duration);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_energyColor, _flowColor],
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              'SALVAR',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Opcional: sua resposta ajuda a personalizar futuras sugestões',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 10,
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _feedbackOptionModal(
    StateSetter setModalState,
    String emoji,
    String label,
    int value,
    int? current,
    Function(int?) onSelected, {
    bool isDifficulty = false,
  }) {
    final isSelected = current == value;
    return GestureDetector(
      onTap: () {
        // Se clicar no mesmo item, desmarca
        if (current == value) {
          onSelected(null);
        } else {
          onSelected(value);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _energyColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _energyColor : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? _energyColor : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveLog(Duration duration) {
    // Converte difficultyLevel para String? (pode ser null)
    String? difficultyStr;
    if (_difficultyLevel != null) {
      switch (_difficultyLevel) {
        case 0:
          difficultyStr = 'Fácil';
          break;
        case 1:
          difficultyStr = 'Médio';
          break;
        case 2:
          difficultyStr = 'Difícil';
          break;
      }
    }

    final log = ActivityLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      group: _isBreak ? 'Pausa Pomodoro' : widget.group,
      example: _isBreak
          ? '☕ ${_pomodoroDuration.inMinutes}min de pausa'
          : widget.example,
      energy: _isBreak ? 'Passiva' : widget.energy,
      flow: _isBreak ? 'Fácil' : (difficultyStr ?? widget.flow),
      organ: _isBreak ? 'Corpo/Mente' : widget.organ,
      duration: duration,
      timestamp: DateTime.now(),
      consciousnessLevel: _consciousnessLevel, // Pode ser null
      difficultyFeedback: difficultyStr, // Pode ser null
    );

    print('=== LOG SALVO ===');
    print(
        'Consciousness Level: ${_consciousnessLevel ?? "null (sem feedback)"}');
    print('Difficulty Feedback: ${difficultyStr ?? "null (sem feedback)"}');
    print('Flow usado: ${log.flow}');
    print('================');

    if (mounted) Navigator.pop(context, log);
  }

  void _saveManualTime() {
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final duration = Duration(hours: hours, minutes: minutes);
    if (duration.inSeconds > 0)
      _showFeedback(duration);
    else
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Insira um tempo válido!'),
          backgroundColor: Colors.orange[700],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
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
    _hoursController.dispose();
    _minutesController.dispose();
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
              _buildModeToggle(),
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
          if (_isPomodoroMode)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _isBreak
                    ? Colors.green.withOpacity(0.15)
                    : Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _isBreak ? '☕ Pausa' : '🍅 Foco',
                style: GoogleFonts.lato(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: _isBreak ? Colors.green : Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ========== RELÓGIO CIRCULAR COM PULSO E PROGRESSO ==========
  Widget _buildCircularTimer() {
    final displayDuration = _isPomodoroMode ? _pomodoroRemaining : _elapsed;
    final primaryColor = _isPomodoroMode
        ? (_isBreak ? Colors.green : Colors.red[400]!)
        : _energyColor;

    return AnimatedBuilder(
      animation:
          Listenable.merge([_pulseController, _progressAnimationController]),
      builder: (context, child) {
        final scale = (_isRunning || _isPomodoroRunning)
            ? 1.0 + _pulseController.value * 0.02
            : 1.0;

        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Círculo de fundo
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

                // Círculo de progresso
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

                // Círculo interno
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
                      Text(
                        _isPomodoroMode ? (_isBreak ? '☕' : '🍅') : '🧘',
                        style: const TextStyle(fontSize: 40),
                      ),
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
                      Text(
                        _isRunning || _isPomodoroRunning
                            ? (_isPomodoroMode
                                ? (_isBreak
                                    ? '⏸️ Pausa em andamento...'
                                    : '🎯 Focando...')
                                : '⏱️ Em andamento...')
                            : '▶️ Pronto para iniciar',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (_isPomodoroMode &&
                          !_isBreak &&
                          _pomodoroRemaining.inMinutes > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Meta: ${_pomodoroDuration.inMinutes} min',
                            style: GoogleFonts.lato(
                              fontSize: 10,
                              color: primaryColor.withOpacity(0.7),
                            ),
                          ),
                        ),
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

  // ========== TOGGLE DE MODO ==========
  Widget _buildModeToggle() {
    if (_isRunning || _isPomodoroRunning) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isPomodoroMode = false;
                  _resetPomodoro();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isPomodoroMode ? _energyColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_rounded,
                        size: 18,
                        color: !_isPomodoroMode ? Colors.white : _energyColor),
                    const SizedBox(width: 6),
                    Text(
                      'Cronômetro',
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            !_isPomodoroMode ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isPomodoroMode = true;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isPomodoroMode ? Colors.red[400] : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_rounded,
                        size: 18,
                        color:
                            _isPomodoroMode ? Colors.white : Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Pomodoro',
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            _isPomodoroMode ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== CONTROLES ==========
  Widget _buildControls() {
    if (_isPomodoroMode) {
      return _buildPomodoroControls();
    } else {
      return _buildTimerControls();
    }
  }

  Widget _buildTimerControls() {
    return Column(
      children: [
        if (!_isRunning && !_showManualInput)
          Row(
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
          ),
        if (_isRunning)
          Row(
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
          ),
        if (!_isRunning && !_showManualInput)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: GestureDetector(
              onTap: () => setState(() => _showManualInput = true),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: _energyColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _energyColor.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_calendar_rounded,
                        size: 16, color: _energyColor),
                    const SizedBox(width: 6),
                    Text(
                      'Inserir tempo manualmente',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _energyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_showManualInput) _buildManualInput(),
      ],
    );
  }

  Widget _buildPomodoroControls() {
    return Column(
      children: [
        if (!_isPomodoroRunning) ...[
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
                      border: Border.all(
                        color: sel
                            ? Colors.red[400]!
                            : Colors.white.withOpacity(0.6),
                      ),
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
              _smallPauseButton('☕ 5min', 5, Colors.green),
              const SizedBox(width: 8),
              _smallPauseButton('😴 10min', 10, Colors.teal),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            if (_isPomodoroRunning || _pomodoroRemaining != _pomodoroDuration)
              Expanded(
                child: _controlButton(
                  icon: Icons.refresh_rounded,
                  label: 'RESET',
                  onTap: _resetPomodoro,
                  color: Colors.grey,
                ),
              ),
            if (_isPomodoroRunning || _pomodoroRemaining != _pomodoroDuration)
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
        ),
        if (_isPomodoroRunning)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _isBreak
                  ? '☕ Hora de descansar a mente'
                  : '🍅 Mantenha o foco total',
              style: GoogleFonts.lato(fontSize: 11, color: Colors.grey[500]),
            ),
          ),
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

  Widget _smallPauseButton(String label, int minutes, Color color) {
    return GestureDetector(
      onTap: () => _iniciarPausa(minutes),
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

  Widget _buildManualInput() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            'Registrar tempo manualmente',
            style: GoogleFonts.lato(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _timeField(_hoursController, 'Horas')),
              const SizedBox(width: 10),
              Expanded(child: _timeField(_minutesController, 'Minutos')),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _saveManualTime,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_energyColor, _flowColor]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'SALVAR REGISTRO',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _showManualInput = false),
            child: Text(
              'Voltar para cronômetro',
              style: GoogleFonts.lato(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeField(TextEditingController ctrl, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _energyColor,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.lato(fontSize: 11, color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}
