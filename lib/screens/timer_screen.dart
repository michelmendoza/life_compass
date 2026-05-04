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

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  Color get _energyColor =>
      HawkinsColors.energyColors[widget.energy] ?? Colors.grey;
  Color get _flowColor =>
      HawkinsColors.flowGradient[widget.flow] ?? Colors.grey;

  // ========== TIMER ==========
  void _startTimer() {
    setState(() {
      _isRunning = true;
      _startTime = DateTime.now().subtract(_elapsed);
      _showManualInput = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted)
        setState(() => _elapsed = DateTime.now().difference(_startTime!));
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
    _showFeedback(_pomodoroDuration);
  }

  void _resetPomodoro() {
    _timer?.cancel();
    setState(() {
      _isPomodoroRunning = false;
      _isBreak = false;
      _pomodoroDuration = const Duration(minutes: 25);
      _pomodoroRemaining = const Duration(minutes: 25);
    });
  }

  void _setPomodoroDuration(int minutes) {
    if (_isPomodoroRunning) return;
    setState(() {
      _isBreak = false;
      _pomodoroDuration = Duration(minutes: minutes);
      _pomodoroRemaining = Duration(minutes: minutes);
    });
  }

  void _iniciarPausa(int minutes) {
    _timer?.cancel();
    setState(() {
      _isBreak = true;
      _isPomodoroRunning = false;
      _pomodoroDuration = Duration(minutes: minutes);
      _pomodoroRemaining = Duration(minutes: minutes);
    });
  }

  void _stopPomodoroAndSave() {
    _timer?.cancel();
    final completed = _pomodoroDuration - _pomodoroRemaining;
    if (completed.inSeconds > 0) _showFeedback(completed);
  }

  // ========== FEEDBACK PÓS-ATIVIDADE ==========
  int _consciousnessLevel = 0; // 0=automático, 1=presente, 2=focado, 3=fluindo
  int _difficultyLevel = 1; // 0=fácil, 1=médio, 2=difícil

  void _showFeedback(Duration duration) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),

              Text('Como foi?',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                  '${_isBreak ? '☕ Pausa' : widget.group} · ${_formatDurationShort(duration)}',
                  style:
                      GoogleFonts.lato(fontSize: 13, color: Colors.grey[500])),

              const SizedBox(height: 20),

              // Pergunta 1: Consciência
              Text('Como você se sentiu?',
                  style: GoogleFonts.lato(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _feedbackOption(
                    setModalState, '😴', 'Automático', 0, _consciousnessLevel),
                _feedbackOption(
                    setModalState, '😐', 'Presente', 1, _consciousnessLevel),
                _feedbackOption(
                    setModalState, '🔥', 'Focado', 2, _consciousnessLevel),
                _feedbackOption(
                    setModalState, '✨', 'Fluindo', 3, _consciousnessLevel),
              ]),

              const SizedBox(height: 16),

              // Pergunta 2: Dificuldade
              Text('Como foi a dificuldade?',
                  style: GoogleFonts.lato(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _feedbackOption(
                    setModalState, '🌊', 'Fácil', 0, _difficultyLevel,
                    isDifficulty: true),
                _feedbackOption(
                    setModalState, '⚡', 'Médio', 1, _difficultyLevel,
                    isDifficulty: true),
                _feedbackOption(
                    setModalState, '🔥', 'Difícil', 2, _difficultyLevel,
                    isDifficulty: true),
              ]),

              const SizedBox(height: 20),

              // Botões
              Row(children: [
                // PULAR (esquerda)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _saveLog(duration);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text('PULAR',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                              fontSize: 14, color: Colors.grey[500])),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // SALVAR (direita)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _saveLog(duration);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient:
                            LinearGradient(colors: [_energyColor, _flowColor]),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text('SALVAR',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feedbackOption(StateSetter setModalState, String emoji, String label,
      int value, int current,
      {bool isDifficulty = false}) {
    final isSelected = current == value;
    return GestureDetector(
      onTap: () => setModalState(() {
        if (isDifficulty)
          _difficultyLevel = value;
        else
          _consciousnessLevel = value;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _energyColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? _energyColor : Colors.grey[200]!,
              width: isSelected ? 2 : 1),
        ),
        child: Column(children: [
          Text(emoji, style: TextStyle(fontSize: 24)),
          const SizedBox(height: 3),
          Text(label,
              style: GoogleFonts.lato(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? _energyColor : Colors.grey[600])),
        ]),
      ),
    );
  }

  // ========== SALVAR ==========
  void _saveLog(Duration duration) {
    // Mapeia dificuldade para string
    String difficultyStr;
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
      default:
        difficultyStr = 'Médio';
    }

    final log = ActivityLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      group: _isBreak ? 'Pausa Pomodoro' : widget.group,
      example: _isBreak
          ? '☕ ${_pomodoroDuration.inMinutes}min de pausa'
          : widget.example,
      energy: _isBreak ? 'Passiva' : widget.energy,
      flow: _isBreak
          ? 'Fácil'
          : difficultyStr, // Usa dificuldade real do feedback
      organ: _isBreak ? 'Corpo/Mente' : widget.organ,
      duration: duration,
      timestamp: DateTime.now(),
      consciousnessLevel: _consciousnessLevel,
      difficultyFeedback: difficultyStr,
    );
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
    if (h > 0)
      return '${h}h ${m.toString().padLeft(2, '0')}m ${s.toString().padLeft(2, '0')}s';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatDurationShort(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    if (d.inHours > 0) return '${d.inHours}h${m % 60}m';
    return '${m}m${s}s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
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
              _flowColor.withOpacity(0.08)
            ])),
        child: SafeArea(
          child: Column(children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  _buildTimerCard(),
                  const SizedBox(height: 12),
                  _buildInfoRow(),
                  const SizedBox(height: 12),
                  if (!_showManualInput) ...[
                    _buildModeToggle(),
                    const SizedBox(height: 10),
                    if (_isPomodoroMode)
                      _buildPomodoroControls()
                    else
                      _buildTimerControls(),
                  ],
                  if (_showManualInput) _buildManualInput(),
                  const SizedBox(height: 10),
                  if (!_isRunning && !_isPomodoroRunning) _buildInputToggle(),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.5))),
      child: Row(children: [
        GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: _energyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.arrow_back_rounded,
                    color: _energyColor, size: 20))),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.group,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _energyColor)),
          Text(widget.example,
              style: GoogleFonts.lato(fontSize: 10, color: Colors.grey[500]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis)
        ])),
        if (_isPomodoroMode)
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: _isBreak
                      ? Colors.green.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(_isBreak ? '☕ Pausa' : '🍅 Foco',
                  style: GoogleFonts.lato(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: _isBreak ? Colors.green : Colors.red))),
      ]),
    );
  }

  Widget _buildTimerCard() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = (_isRunning || _isPomodoroRunning)
            ? 1.0 + _pulseController.value * 0.015
            : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 35),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isPomodoroMode
                    ? (_isBreak
                        ? [Colors.green, Colors.green[300]!]
                        : [Colors.red[400]!, Colors.orange[300]!])
                    : [_energyColor, _flowColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (_isPomodoroMode ? Colors.red : _energyColor)
                      .withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ÍCONE
                Text(
                  _isPomodoroMode ? (_isBreak ? '☕' : '🍅') : '⏱️',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 8),

                // TEMPO
                Text(
                  _isPomodoroMode
                      ? _formatDuration(_pomodoroRemaining)
                      : _formatDuration(_elapsed),
                  style: GoogleFonts.lato(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2),
                ),
                const SizedBox(height: 8),

                // STATUS
                Text(
                  _isPomodoroMode
                      ? (_isPomodoroRunning
                          ? '⏳ ${_isBreak ? "Pausando..." : "Focando..."}'
                          : '⏸️ Pronto para iniciar')
                      : (_isRunning ? '✨ Em andamento...' : '⏸️ Aguardando'),
                  style: GoogleFonts.lato(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 8),

                // BARRA DE PROGRESSO (sempre presente, mas invisível no cronômetro)
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: _isPomodoroMode
                        ? (_pomodoroRemaining.inSeconds /
                            _pomodoroDuration.inSeconds)
                        : 1.0,
                    backgroundColor:
                        Colors.white.withOpacity(_isPomodoroMode ? 0.3 : 0.0),
                    valueColor: AlwaysStoppedAnimation(
                        _isPomodoroMode ? Colors.white : Colors.transparent),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.5))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _chip('${widget.energy == "Ativa" ? "⚡" : "🍃"} ${widget.energy}',
            _energyColor),
        _chip('🔄 ${widget.flow}', _flowColor),
        _chip(
            '${widget.organ == "Mente" ? "🧠" : widget.organ == "Corpo" ? "💪" : "🧘"} ${widget.organ}',
            HawkinsColors.organGradients[widget.organ]![0]),
      ]),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.2))),
        child: Text(text,
            style: GoogleFonts.lato(
                fontSize: 11, fontWeight: FontWeight.w600, color: color)));
  }

  Widget _buildModeToggle() {
    if (_isRunning || _isPomodoroRunning) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.5))),
      child: Row(children: [
        Expanded(
            child: GestureDetector(
                onTap: () => setState(() => _isPomodoroMode = false),
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: !_isPomodoroMode
                            ? _energyColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16)),
                    child: Text('⏱️ Cronômetro',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: !_isPomodoroMode
                                ? Colors.white
                                : Colors.grey[600]))))),
        Expanded(
            child: GestureDetector(
                onTap: () => setState(() => _isPomodoroMode = true),
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: _isPomodoroMode
                            ? Colors.red[400]
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16)),
                    child: Text('🍅 Pomodoro',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _isPomodoroMode
                                ? Colors.white
                                : Colors.grey[600]))))),
      ]),
    );
  }

  Widget _buildPomodoroControls() {
    return Column(children: [
      if (!_isPomodoroRunning) ...[
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [15, 25, 30, 45].map((min) {
              final sel = _pomodoroDuration.inMinutes == min && !_isBreak;
              return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                      onTap: () => _setPomodoroDuration(min),
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: sel
                                  ? Colors.red[400]
                                  : Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: sel
                                      ? Colors.red[400]!
                                      : Colors.white.withOpacity(0.6))),
                          child: Text('${min}min',
                              style: GoogleFonts.lato(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: sel
                                      ? Colors.white
                                      : Colors.grey[600])))));
            }).toList()),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _pausaBtn('☕ 5min', 5, Colors.green),
          const SizedBox(width: 6),
          _pausaBtn('😴 10min', 10, Colors.teal),
        ]),
        const SizedBox(height: 8),
      ],
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (_isPomodoroRunning || _pomodoroRemaining != _pomodoroDuration) ...[
          GestureDetector(
              onTap: _resetPomodoro,
              child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.refresh_rounded,
                      color: Colors.grey, size: 20))),
          const SizedBox(width: 12),
        ],
        GestureDetector(
          onTap: _startPomodoro,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isBreak
                    ? [Colors.green, Colors.green[300]!]
                    : [Colors.red[400]!, Colors.orange[300]!],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color:
                      (_isBreak ? Colors.green : Colors.red).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isPomodoroRunning
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 6),
                Text(
                  _isPomodoroRunning ? 'PAUSAR' : 'INICIAR',
                  style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5),
                ),
              ],
            ),
          ),
        ),
        if (_pomodoroRemaining != _pomodoroDuration) ...[
          const SizedBox(width: 12),
          GestureDetector(
              onTap: _stopPomodoroAndSave,
              child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3))),
                  child: const Icon(Icons.stop_rounded,
                      color: Colors.red, size: 20))),
        ],
      ]),
      if (_isPomodoroRunning)
        Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
                _isBreak ? '☕ Pausa para descansar' : '🍅 Mantenha o foco!',
                style:
                    GoogleFonts.lato(fontSize: 11, color: Colors.grey[500]))),
    ]);
  }

  Widget _pausaBtn(String label, int minutes, Color color) {
    return GestureDetector(
      onTap: () => _iniciarPausa(minutes),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label,
            style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color)), // ← era color[700]
      ),
    );
  }

  Widget _buildTimerControls() {
    return Column(children: [
      if (!_isRunning)
        GestureDetector(
          onTap: _startTimer,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_energyColor, _flowColor]),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: _energyColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 26),
                const SizedBox(width: 8),
                Text(
                  'INICIAR CRONÔMETRO',
                  style: GoogleFonts.lato(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5),
                ),
              ],
            ),
          ),
        ),
      if (_isRunning)
        Row(children: [
          Expanded(
              child: _smallBtn(
                  Icons.pause_rounded, 'Pausar', Colors.orange, _pauseTimer)),
          const SizedBox(width: 10),
          Expanded(
              child: _smallBtn(
                  Icons.stop_rounded, 'Finalizar', Colors.red, _stopTimer)),
        ]),
    ]);
  }

  Widget _smallBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withOpacity(0.3))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(label,
                  style: GoogleFonts.lato(
                      fontSize: 13, fontWeight: FontWeight.bold, color: color))
            ])));
  }

  Widget _buildManualInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.5))),
      child: Column(children: [
        Text('Registrar tempo',
            style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700])),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _timeField(_hoursController, 'Horas')),
          const SizedBox(width: 10),
          Expanded(child: _timeField(_minutesController, 'Minutos')),
        ]),
        const SizedBox(height: 12),
        GestureDetector(
            onTap: _saveManualTime,
            child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                    gradient:
                        LinearGradient(colors: [_energyColor, _flowColor]),
                    borderRadius: BorderRadius.circular(18)),
                child: Text('SALVAR REGISTRO',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5)))),
      ]),
    );
  }

  Widget _timeField(TextEditingController ctrl, String label) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.6))),
      child: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
              fontSize: 16, fontWeight: FontWeight.bold, color: _energyColor),
          decoration: InputDecoration(
              labelText: label,
              labelStyle:
                  GoogleFonts.lato(fontSize: 11, color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10))),
    );
  }

  Widget _buildInputToggle() {
    return GestureDetector(
      onTap: () => setState(() => _showManualInput = !_showManualInput),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
            color: _energyColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _energyColor.withOpacity(0.15))),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                  _showManualInput
                      ? Icons.timer_rounded
                      : Icons.edit_calendar_rounded,
                  size: 16,
                  color: _energyColor),
              const SizedBox(width: 6),
              Text(
                  _showManualInput
                      ? 'Usar cronômetro'
                      : 'Inserir tempo manualmente',
                  style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _energyColor)),
            ]),
      ),
    );
  }
}
