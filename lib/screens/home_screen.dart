import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/activity_log.dart';
import '../screens/onboarding_premium_screen.dart'; // ⭐ Adicione este import

class HomeScreen extends StatefulWidget {
  final List<ActivityLog> activityLogs;
  final VoidCallback onAddPractice;
  final VoidCallback onExplore;
  final VoidCallback onActNow;

  const HomeScreen({
    super.key,
    required this.activityLogs,
    required this.onAddPractice,
    required this.onExplore,
    required this.onActNow,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<String> _motivationalMessages;
  String _currentMessage = '';
  final Random _random = Random();
  Timer? _timer;

  final List<String> _messages = [
    "✨ Pequenos passos todos os dias levam a grandes mudanças",
    "🌟 Você está mais perto do que imagina",
    "💪 Acredite no seu potencial",
    "🎯 Foco no processo, não apenas no resultado",
    "🌱 Cada prática é uma semente para o futuro",
    "🔥 Seu eu do futuro vai agradecer",
    "⚡ Um minuto de ação vale mais que horas de planejamento",
    "🌈 A jornada é tão importante quanto o destino",
    "🍃 Respire, concentre-se e siga em frente",
    "⭐ Você é capaz de coisas incríveis",
    "🎨 Crie momentos de presença hoje",
    "💙 Cuide de você como cuidaria de um amigo",
  ];

  @override
  void initState() {
    super.initState();
    _motivationalMessages = List.from(_messages);
    _updateMessage();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) _updateMessage();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateMessage() {
    setState(() {
      _currentMessage =
          _motivationalMessages[_random.nextInt(_motivationalMessages.length)];
    });
  }

  void _showOnboarding() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnboardingPremiumScreen(
          onComplete: () {
            Navigator.pop(context); // Volta para a HomeScreen
          },
        ),
      ),
    );
  }

  String _getDominantArea() {
    int body = 0, mind = 0, spirit = 0;

    for (var log in widget.activityLogs) {
      if (log.timestamp.day == DateTime.now().day &&
          log.timestamp.month == DateTime.now().month &&
          log.timestamp.year == DateTime.now().year) {
        if (log.organ == 'Corpo/Mente' ||
            log.group == 'Saúde' ||
            log.group == 'Exercício') {
          body++;
        } else if (log.group == 'Trabalho' ||
            log.group == 'Aprendizado' ||
            log.group == 'Estudo') {
          mind++;
        } else if (log.group == 'Espiritualidade' ||
            log.group == 'Autocuidado' ||
            log.group == 'Meditação') {
          spirit++;
        }
      }
    }

    final total = body + mind + spirit;
    if (total == 0) return 'Mental 70%';

    if (body >= mind && body >= spirit) {
      final percent = ((body / total) * 100).round();
      return 'Corpo ${percent}%';
    } else if (mind >= body && mind >= spirit) {
      final percent = ((mind / total) * 100).round();
      return 'Mental ${percent}%';
    } else {
      final percent = ((spirit / total) * 100).round();
      return 'Espírito ${percent}%';
    }
  }

  int _getTodayPracticesCount() {
    return widget.activityLogs
        .where((log) =>
            log.timestamp.day == DateTime.now().day &&
            log.timestamp.month == DateTime.now().month &&
            log.timestamp.year == DateTime.now().year)
        .length;
  }

  Map<String, int> _getDifficultyDistribution() {
    Map<String, int> distribution = {'Fácil': 0, 'Médio': 0, 'Difícil': 0};

    for (var log in widget.activityLogs) {
      if (log.difficultyFeedback != null) {
        distribution[log.difficultyFeedback!] =
            (distribution[log.difficultyFeedback!] ?? 0) + 1;
      }
    }
    return distribution;
  }

  @override
  Widget build(BuildContext context) {
    final todayCount = _getTodayPracticesCount();
    final dominantArea = _getDominantArea();
    final distribution = _getDifficultyDistribution();
    final totalWithFeedback = distribution.values.reduce((a, b) => a + b);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9E9),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo e Welcome com botão de replay na logo
                    Row(
                      children: [
                        // ⭐ BOTÃO DE REPLAY NA LOGO ⭐
                        GestureDetector(
                          onTap: _showOnboarding,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6B8E23), Color(0xFF8FBC8F)],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF6B8E23).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Text(
                              '🧭',
                              style: TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bem-vindo(a) de volta!',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                _getGreeting(),
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Card de equilíbrio
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6B8E23), Color(0xFF8FBC8F)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B8E23).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '⚖️',
                            style: TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Equilíbrio hoje',
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  dominantArea,
                                  style: GoogleFonts.lato(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cards de estatísticas
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            '📊',
                            '$todayCount',
                            'práticas hoje',
                            const Color(0xFF6B8E23),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            '🏆',
                            '${widget.activityLogs.length}',
                            'total práticas',
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Mensagem motivacional
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
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
                    const Text('💭', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentMessage,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Seção de dificuldade
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Níveis de Flow',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          _difficultyItem(
                              '🌊',
                              'Fácil',
                              totalWithFeedback > 0
                                  ? (distribution['Fácil']! /
                                          totalWithFeedback *
                                          100)
                                      .round()
                                  : 0,
                              Colors.green),
                          const SizedBox(width: 8),
                          _difficultyItem(
                              '⚡',
                              'Médio',
                              totalWithFeedback > 0
                                  ? (distribution['Médio']! /
                                          totalWithFeedback *
                                          100)
                                      .round()
                                  : 0,
                              Colors.orange),
                          const SizedBox(width: 8),
                          _difficultyItem(
                              '🔥',
                              'Difícil',
                              totalWithFeedback > 0
                                  ? (distribution['Difícil']! /
                                          totalWithFeedback *
                                          100)
                                      .round()
                                  : 0,
                              Colors.red),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Botões de ação
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _actionButton(
                      '✨ Explorar Práticas',
                      'Descubra novas atividades',
                      Icons.explore,
                      widget.onExplore,
                      const Color(0xFF6B8E23),
                    ),
                    const SizedBox(height: 12),
                    _actionButton(
                      '⚡ Agir Agora',
                      'Sugestões personalizadas para você',
                      Icons.flash_on,
                      widget.onActNow,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia! 🌅';
    if (hour < 18) return 'Boa tarde! 🌞';
    return 'Boa noite! 🌙';
  }

  Widget _statCard(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 11,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _difficultyItem(String emoji, String label, int percent, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            '$percent%',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String title, String subtitle, IconData icon,
      VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient:
                    LinearGradient(colors: [color, color.withOpacity(0.7)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
