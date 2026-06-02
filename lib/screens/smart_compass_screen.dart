import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/activity_log.dart';
import '../data/activities.dart';
import '../data/colors.dart';
import '../data/practice.dart';
import 'timer_screen.dart';

class SmartCompassScreen extends StatefulWidget {
  final List<ActivityLog> logs;
  final Function(ActivityLog) onStartActivity;
  final bool isSelected;

  const SmartCompassScreen({
    super.key,
    required this.logs,
    required this.onStartActivity,
    this.isSelected = false,
  });

  @override
  State<SmartCompassScreen> createState() => _SmartCompassScreenState();
}

class _SmartCompassScreenState extends State<SmartCompassScreen>
    with TickerProviderStateMixin {
  List<SuggestionCard> _cards = [];
  int _currentIndex = 0;

  double _dragOffset = 0;
  double _dragRotation = 0;
  bool _isSwiping = false;

  late AnimationController _flyController;

  @override
  void initState() {
    super.initState();
    _flyController = AnimationController(vsync: this);
    _generateSuggestions();
  }

  @override
  void didUpdateWidget(SmartCompassScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final becameVisible = widget.isSelected && !oldWidget.isSelected;
    final logsChanged = widget.logs.length != oldWidget.logs.length;
    if (becameVisible || logsChanged) {
      _generateSuggestions();
    }
  }

  @override
  void dispose() {
    _flyController.dispose();
    super.dispose();
  }

  // =========================================================
  // ANÁLISE
  // =========================================================

  List<ActivityLog> get _recentWeek {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return widget.logs.where((l) => l.timestamp.isAfter(cutoff)).toList();
  }

  String get _dominantEnergy {
    if (_recentWeek.isEmpty) return 'equilibrado';
    int active = 0;
    int passive = 0;
    for (final log in _recentWeek) {
      if (log.energy == 'Ativa') {
        active += log.duration.inMinutes;
      } else {
        passive += log.duration.inMinutes;
      }
    }
    if (active > passive * 1.5) return 'muito_ativa';
    if (passive > active * 1.5) return 'muito_passiva';
    return 'equilibrado';
  }

  String get _dominantOrgan {
    if (_recentWeek.isEmpty) return 'equilibrado';
    int mente = 0;
    int corpo = 0;
    for (final log in _recentWeek) {
      if (log.organ.contains('Mente')) mente += log.duration.inMinutes;
      if (log.organ.contains('Corpo')) corpo += log.duration.inMinutes;
    }
    if (mente > corpo * 1.5) return 'muita_mente';
    if (corpo > mente * 1.5) return 'muito_corpo';
    return 'equilibrado';
  }

  String get _dominantFlow {
    if (_recentWeek.isEmpty) return 'equilibrado';
    int facil = 0, medio = 0, dificil = 0;
    for (final log in _recentWeek) {
      final f = log.flow;
      if (f.contains('Difícil')) {
        dificil += log.duration.inMinutes;
      } else if (f.contains('Fácil')) {
        facil += log.duration.inMinutes;
      } else {
        medio += log.duration.inMinutes;
      }
    }
    if (dificil > (facil + medio) * 1.5) return 'muito_dificil';
    if (facil > (medio + dificil) * 1.5) return 'muito_facil';
    return 'equilibrado';
  }

  Map<String, dynamic> get _statusData {
    return {
      'energia': {
        'icon': _dominantEnergy == 'muito_ativa'
            ? '⚡'
            : (_dominantEnergy == 'muito_passiva' ? '🍃' : '🌿'),
        'label': _dominantEnergy == 'muito_ativa'
            ? 'Energia Alta'
            : (_dominantEnergy == 'muito_passiva'
                ? 'Energia Baixa'
                : 'Equilibrada'),
      },
      'foco': {
        'icon': _dominantOrgan == 'muita_mente'
            ? '🧠'
            : (_dominantOrgan == 'muito_corpo' ? '💪' : '🌸'),
        'label': _dominantOrgan == 'muita_mente'
            ? 'Mente Ativa'
            : (_dominantOrgan == 'muito_corpo' ? 'Corpo Ativo' : 'Equilibrado'),
      },
      'flow': {
        'icon': _dominantFlow == 'muito_dificil'
            ? '🔥'
            : (_dominantFlow == 'muito_facil' ? '💤' : '✨'),
        'label': _dominantFlow == 'muito_dificil'
            ? 'Desafiador'
            : (_dominantFlow == 'muito_facil' ? 'Confortável' : 'Equilibrado'),
      },
    };
  }

  String get _insightMessage {
    if (_recentWeek.isEmpty) {
      return 'Sem registros nos últimos 7 dias. Sugestões baseadas em práticas equilibradas.';
    }
    final parts = <String>[];
    if (_dominantEnergy == 'muito_ativa') {
      parts.add('energia alta');
    } else if (_dominantEnergy == 'muito_passiva') {
      parts.add('energia baixa');
    }
    if (_dominantOrgan == 'muita_mente') {
      parts.add('mente sobrecarregada');
    } else if (_dominantOrgan == 'muito_corpo') {
      parts.add('corpo muito ativo');
    }
    if (_dominantFlow == 'muito_dificil') {
      parts.add('práticas muito desafiadoras');
    } else if (_dominantFlow == 'muito_facil') {
      parts.add('zona de conforto');
    }
    if (parts.isEmpty) {
      return 'Seu perfil dos últimos 7 dias está equilibrado. Continue assim!';
    }
    return 'Nos últimos 7 dias: ${parts.join(', ')}. As sugestões abaixo visam compensar e reequilibrar.';
  }

  // =========================================================
  // SUGESTÕES
  // =========================================================

  void _generateSuggestions() {
    final List<SuggestionCard> newCards = [];
    final energyNeed = _dominantEnergy;
    final organNeed = _dominantOrgan;
    final flowNeed = _dominantFlow;

    for (final activity in Activity.activities) {
      for (final practice in activity.practices) {
        int score = 0;
        List<String> reasons = [];

        if (energyNeed == 'muito_ativa' && practice.energy == 'Passiva') {
          score += 3;
          reasons.add('Equilibrar energia');
        } else if (energyNeed == 'muito_passiva' &&
            practice.energy == 'Ativa') {
          score += 3;
          reasons.add('Despertar vitalidade');
        }

        if (organNeed == 'muita_mente' && practice.organ.contains('Corpo')) {
          score += 2;
          reasons.add('Ativar o corpo');
        } else if (organNeed == 'muito_corpo' &&
            practice.organ.contains('Mente')) {
          score += 2;
          reasons.add('Exercitar a mente');
        }

        if (flowNeed == 'muito_dificil' && practice.flow.contains('Fácil')) {
          score += 2;
          reasons.add('Algo mais leve');
        } else if (flowNeed == 'muito_facil' &&
            !practice.flow.contains('Fácil')) {
          score += 2;
          reasons.add('Sair da zona de conforto');
        }

        if (score >= 2 || reasons.isNotEmpty) {
          newCards.add(SuggestionCard(
            practice: practice,
            category: activity.group,
            categoryIcon: activity.icon,
            reason:
                reasons.isNotEmpty ? reasons.first : 'Recomendado para você',
            score: score,
          ));
        }
      }
    }

    newCards.sort((a, b) => b.score.compareTo(a.score));
    if (newCards.length > 8) newCards.shuffle(Random());

    if (newCards.isEmpty) {
      newCards.addAll([
        SuggestionCard(
          practice: const Practice(
              name: 'Meditar',
              energy: 'Passiva',
              flow: 'Fácil',
              organ: 'Mente'),
          category: 'Espiritualidade',
          categoryIcon: '🧘',
          reason: 'Um momento de pausa renovadora',
          score: 1,
        ),
        SuggestionCard(
          practice: const Practice(
              name: 'Caminhada',
              energy: 'Ativa',
              flow: 'Fácil',
              organ: 'Corpo'),
          category: 'Movimento',
          categoryIcon: '🚶',
          reason: 'Conecte-se com a natureza',
          score: 1,
        ),
      ]);
    }

    setState(() {
      _cards = newCards;
      _currentIndex = 0;
      _dragOffset = 0;
      _dragRotation = 0;
    });
  }

  // =========================================================
  // AÇÕES
  // =========================================================

  void _nextCard() {
    if (_currentIndex < _cards.length - 1) {
      setState(() {
        _currentIndex++;
        _dragOffset = 0;
        _dragRotation = 0;
      });
    } else {
      _generateSuggestions();
    }
  }

  void _startPractice(SuggestionCard card) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TimerScreen(
          group: card.category,
          example: card.practice.name,
          energy: card.practice.energy,
          flow: card.practice.flow,
          organ: card.practice.organ,
        ),
      ),
    );
    if (result != null && result is ActivityLog) {
      widget.onStartActivity(result);
    }
    _nextCard();
  }

  // =========================================================
  // DRAG
  // =========================================================

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_isSwiping) return;
    setState(() {
      _dragOffset += details.delta.dx;
      _dragRotation = _dragOffset / 500;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_isSwiping) return;
    final screenWidth = MediaQuery.of(context).size.width;
    if (_dragOffset > screenWidth * 0.2) {
      _animateFlyOut(screenWidth * 1.5, () => _startPractice(_cards[_currentIndex]));
    } else if (_dragOffset < -(screenWidth * 0.2)) {
      _animateFlyOut(-screenWidth * 1.5, _nextCard);
    } else {
      _animateSnapBack();
    }
  }

  Future<void> _animateFlyOut(double target, VoidCallback onDone) async {
    if (!mounted) return;
    _isSwiping = true;

    final startOffset = _dragOffset;
    final startRot = _dragRotation;
    final endRot = target / 500;

    _flyController.duration = const Duration(milliseconds: 300);
    final anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flyController, curve: Curves.easeIn),
    );
    _flyController.reset();

    void listener() {
      if (mounted) {
        setState(() {
          _dragOffset = startOffset + anim.value * (target - startOffset);
          _dragRotation = startRot + anim.value * (endRot - startRot);
        });
      }
    }

    anim.addListener(listener);
    await _flyController.forward();
    anim.removeListener(listener);

    if (mounted) {
      setState(() {
        _dragOffset = 0;
        _dragRotation = 0;
        _isSwiping = false;
      });
      onDone();
    }
  }

  Future<void> _animateSnapBack() async {
    if (!mounted) return;
    _isSwiping = true;

    final startOffset = _dragOffset;
    final startRot = _dragRotation;

    _flyController.duration = const Duration(milliseconds: 200);
    final anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flyController, curve: Curves.easeOut),
    );
    _flyController.reset();

    void listener() {
      if (mounted) {
        setState(() {
          _dragOffset = startOffset * (1 - anim.value);
          _dragRotation = startRot * (1 - anim.value);
        });
      }
    }

    anim.addListener(listener);
    await _flyController.forward();
    anim.removeListener(listener);

    if (mounted) {
      setState(() {
        _dragOffset = 0;
        _dragRotation = 0;
        _isSwiping = false;
      });
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentCard = _cards[_currentIndex];
    final statusData = _statusData;
    final progress = (_currentIndex + 1) / _cards.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9E9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildStatusSection(statusData),
            const SizedBox(height: 10),
            _buildInsightBanner(),
            const SizedBox(height: 12),
            _buildProgressBar(progress, _currentIndex, _cards.length),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildBackgroundCard(scale: 0.92, top: 20),
                    _buildBackgroundCard(scale: 0.96, top: 10),
                    GestureDetector(
                      onHorizontalDragUpdate: _onHorizontalDragUpdate,
                      onHorizontalDragEnd: _onHorizontalDragEnd,
                      child: Transform(
                        transform: Matrix4.identity()
                          ..translateByDouble(_dragOffset, 0, 0, 1)
                          ..rotateZ(_dragRotation),
                        alignment: Alignment.center,
                        child: Stack(
                          children: [
                            _buildCard(currentCard),
                            _buildSwipeOverlay(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildActionButtons(currentCard),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HEADER (NOSSO ESTILO)
  // =========================================================

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F0D5), Color(0xFFF5F9E9), Color(0xFFD4E8C2)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B8E23), Color(0xFF8B6914)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('🧭', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bússola Smart',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4A5D23),
                  ),
                ),
                Text(
                  'Deslize → para iniciar',
                  style: GoogleFonts.lato(
                    fontSize: 10,
                    color: const Color(0xFF6B8E23).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _generateSuggestions,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6B8E23).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.refresh_rounded,
                  color: Color(0xFF6B8E23), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // STATUS SECTION COM TÍTULO
  // =========================================================

  Widget _buildStatusSection(Map<String, dynamic> statusData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Título "SEU PERFIL ATUAL"
          Row(
            children: [
              Container(
                width: 4,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B8E23),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'SEU PERFIL ATUAL',
                style: GoogleFonts.lato(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[500],
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Pills de status
          Row(
            children: [
              _pill(statusData['energia']['icon'],
                  statusData['energia']['label']),
              const SizedBox(width: 8),
              _pill(statusData['foco']['icon'], statusData['foco']['label']),
              const SizedBox(width: 8),
              _pill(statusData['flow']['icon'], statusData['flow']['label']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF6B8E23).withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFF6B8E23).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Text('💡', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _insightMessage,
                style: GoogleFonts.lato(
                  fontSize: 11,
                  height: 1.4,
                  color: const Color(0xFF4A5D23),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                style:
                    GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // PROGRESS BAR
  // =========================================================

  Widget _buildProgressBar(double progress, int current, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$current de $total',
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              Text(
                'Deslize para explorar',
                style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(Color(0xFF6B8E23)),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BACKGROUND CARDS
  // =========================================================

  Widget _buildBackgroundCard({required double scale, required double top}) {
    return Transform.translate(
      offset: Offset(0, top),
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: MediaQuery.of(context).size.width - 48,
          height: MediaQuery.of(context).size.height * 0.50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // CARD PRINCIPAL
  // =========================================================

  Widget _buildCard(SuggestionCard card) {
    final energyColor = HawkinsColors.energyColors[card.practice.energy] ??
        const Color(0xFF6B8E23);
    final flowColor = HawkinsColors.flowGradient[card.practice.flow] ??
        const Color(0xFF8B6914);
    final organColor =
        HawkinsColors.organGradients[card.practice.organ]?[0] ?? Colors.grey;

    return Container(
      width: MediaQuery.of(context).size.width - 48,
      height: MediaQuery.of(context).size.height * 0.58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF9FBF5)],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 35,
            spreadRadius: 2,
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // Categoria no topo
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: energyColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  card.category,
                  style: GoogleFonts.lato(
                      color: energyColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11),
                ),
              ),
            ),

            const Spacer(),

            // Ícone central
            Hero(
              tag: card.practice.name,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      energyColor.withOpacity(0.2),
                      flowColor.withOpacity(0.1)
                    ],
                  ),
                ),
                child: Center(
                  child: Text(card.categoryIcon,
                      style: const TextStyle(fontSize: 46)),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Nome da prática
            Text(
              card.practice.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                height: 1.2,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3436),
              ),
            ),

            const SizedBox(height: 8),

            // Razão
            Text(
              card.reason,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                  fontSize: 13, height: 1.4, color: Colors.grey[700]),
            ),

            const SizedBox(height: 12),

            // Chips
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                _chip(card.practice.energy, energyColor),
                _chip(card.practice.flow, flowColor),
                _chip(card.practice.organ, organColor),
              ],
            ),

            const Spacer(),

            // Dica de swipe
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swipe_rounded, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 6),
                Text(
                  'Arraste para os lados',
                  style:
                      GoogleFonts.lato(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.lato(
            fontWeight: FontWeight.w600, fontSize: 11, color: color),
      ),
    );
  }

  // =========================================================
  // SWIPE OVERLAY
  // =========================================================

  Widget _buildSwipeOverlay() {
    final isRight = _dragOffset > 0;
    final opacity = (_dragOffset.abs() / 120).clamp(0.0, 1.0);

    if (_dragOffset.abs() < 20) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isRight
              ? Colors.green.withOpacity(opacity * 0.12)
              : Colors.red.withOpacity(opacity * 0.1),
        ),
        child: Align(
          alignment: isRight ? Alignment.topLeft : Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Transform.rotate(
              angle: isRight ? -0.2 : 0.2,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      width: 2, color: isRight ? Colors.green : Colors.red),
                ),
                child: Text(
                  isRight ? 'INICIAR' : 'PULAR',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isRight ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // BOTÕES REDONDOS
  // =========================================================

  Widget _buildActionButtons(SuggestionCard card) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Botão DESCARTAR
          GestureDetector(
            onTap: _nextCard,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child:
                  const Icon(Icons.close_rounded, color: Colors.grey, size: 28),
            ),
          ),
          // Botão INICIAR
          GestureDetector(
            onTap: () => _startPractice(card),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B8E23), Color(0xFF8B6914)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B8E23).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 32),
            ),
          ),
        ],
      ),
    );
  }
}

class SuggestionCard {
  final Practice practice;
  final String category;
  final String categoryIcon;
  final String reason;
  final int score;

  SuggestionCard({
    required this.practice,
    required this.category,
    required this.categoryIcon,
    required this.reason,
    required this.score,
  });
}
