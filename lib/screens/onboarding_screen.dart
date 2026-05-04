import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  // Chave para animação do tutorial
  final GlobalKey _tutorialKey = GlobalKey();

  final List<OnboardingSlide> _slides = [
    // Slide 1: O Automático
    OnboardingSlide(
      imagePath:
          'assets/images/onboarding_1.png', // Pessoa no automático, tons cinza
      gradient: const [Color(0xFFBDBDBD), Color(0xFFE0E0E0), Color(0xFFF5F5F5)],
      title: 'A maior parte do tempo,\nagimos no automático',
      subtitle: 'Sem perceber para onde vamos.\nSem escolher o que fazemos.',
      icon: '🌫️',
      textColor: const Color(0xFF424242),
    ),

    // Slide 2: O Despertar
    OnboardingSlide(
      imagePath:
          'assets/images/onboarding_2.png', // Bússola aparecendo, cores surgindo
      gradient: [
        const Color(0xFF90CAF9).withOpacity(0.3),
        const Color(0xFFBBDEFB).withOpacity(0.2),
        const Color(0xFFE3F2FD)
      ],
      title: 'Mas existe um momento\nde clareza',
      subtitle: 'Uma pausa para perguntar:\n"O que estou fazendo agora?"',
      icon: '👁️',
      textColor: const Color(0xFF1565C0),
    ),

    // Slide 3: As Dimensões
    OnboardingSlide(
      imagePath: 'assets/images/onboarding_3.png', // Ícones das dimensões
      gradient: [
        const Color(0xFFE8F0D5),
        const Color(0xFFF5F9E9),
        const Color(0xFFD4E8C2)
      ],
      title: 'Sua vida tem\ndimensões',
      subtitle: 'Energia ⚡\nFoco 🧠\nFlow 🌊',
      icon: '🌿',
      textColor: const Color(0xFF4A5D23),
    ),

    // Slide 4: Como Usar (Tutorial Rápido)
    OnboardingSlide(
      imagePath: 'assets/images/onboarding_4.png', // Mãos interagindo com o app
      gradient: [
        const Color(0xFFF5F9E9),
        const Color(0xFFE8F0D5),
        const Color(0xFFD4E8C2)
      ],
      title: 'É simples começar',
      subtitle: '',
      icon: '📱',
      textColor: const Color(0xFF4A5D23),
      isTutorial: true,
    ),

    // Slide 5: O Convite
    OnboardingSlide(
      imagePath: 'assets/images/onboarding_5.png', // Árvore completa
      gradient: [
        const Color(0xFFE8F0D5),
        const Color(0xFF6B8E23).withOpacity(0.1),
        const Color(0xFFF5F9E9)
      ],
      title: 'Life Compass\nBússola Vital',
      subtitle: 'Um convite para agir\ncom consciência.',
      icon: '🌳',
      textColor: const Color(0xFF4A5D23),
      isLast: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      _totalPages - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView com Parallax
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _totalPages,
            itemBuilder: (context, index) {
              return _buildParallaxSlide(index);
            },
          ),

          // Indicadores no topo
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_totalPages, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        isActive ? const Color(0xFF6B8E23) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

          // Botão Pular (some no último slide)
          if (_currentPage < _totalPages - 1)
            Positioned(
              top: 52,
              right: 20,
              child: GestureDetector(
                onTap: _skipToEnd,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Pular',
                      style: GoogleFonts.lato(
                          fontSize: 12,
                          color: _slides[_currentPage]
                              .textColor
                              .withOpacity(0.6))),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildParallaxSlide(int index) {
    final slide = _slides[index];
    final pageOffset = _currentPage - index;

    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        // Efeito parallax: imagem se move mais devagar
        final parallaxOffset = pageOffset * 0.3;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: slide.gradient,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Área da Imagem (com parallax)
                Transform.translate(
                  offset: Offset(0, parallaxOffset * 20),
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.3),
                      boxShadow: [
                        BoxShadow(
                          color: slide.textColor.withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: slide.imagePath.isNotEmpty
                          ? Image.asset(
                              slide.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(slide.icon,
                                    style: const TextStyle(fontSize: 80)),
                              ),
                            )
                          : Center(
                              child: Text(slide.icon,
                                  style: const TextStyle(fontSize: 80))),
                    ),
                  ),
                ),

                const Spacer(flex: 1),

                // Título
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    slide.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: slide.textColor,
                      height: 1.3,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Subtítulo (ou tutorial)
                if (slide.isTutorial)
                  _buildTutorial()
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      slide.subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        color: slide.textColor.withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),
                  ),

                const Spacer(flex: 2),

                // Botão de ação
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: GestureDetector(
                    onTap: _nextPage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: slide.isLast
                            ? const LinearGradient(
                                colors: [Color(0xFF6B8E23), Color(0xFF8B6914)])
                            : LinearGradient(colors: [
                                slide.textColor,
                                slide.textColor.withOpacity(0.8)
                              ]),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: slide.textColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slide.isLast ? 'COMEÇAR JORNADA' : 'PRÓXIMO',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          if (!slide.isLast) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 20),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTutorial() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _tutorialStep('1', 'Escolha uma categoria',
              'Toque na lista de categorias', Icons.touch_app_rounded),
          const SizedBox(height: 6),
          _tutorialStep('2', 'Selecione a prática',
              'Cada categoria tem várias opções', Icons.auto_awesome_rounded),
          const SizedBox(height: 6),
          _tutorialStep('3', 'Adicione um detalhe',
              'Escreva algo para lembrar depois', Icons.edit_note_rounded),
          const SizedBox(height: 6),
          _tutorialStep(
              '4',
              'Inicie o tempo',
              'Use cronômetro, pomodoro ou registro manual',
              Icons.timer_rounded),
        ],
      ),
    );
  }

  Widget _tutorialStep(
      String number, String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF6B8E23), Color(0xFF8B6914)]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
              child: Text(number,
                  style: GoogleFonts.lato(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white))),
        ),
        const SizedBox(width: 12),
        Icon(icon, size: 18, color: const Color(0xFF6B8E23)),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3436))),
          Text(subtitle,
              style: GoogleFonts.lato(fontSize: 10, color: Colors.grey[500])),
        ])),
      ]),
    );
  }
}

// ========== MODELO DE SLIDE ==========
class OnboardingSlide {
  final String imagePath;
  final List<Color> gradient;
  final String title;
  final String subtitle;
  final String icon;
  final Color textColor;
  final bool isLast;
  final bool isTutorial;

  OnboardingSlide({
    required this.imagePath,
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.textColor,
    this.isLast = false,
    this.isTutorial = false,
  });
}
