import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPremiumScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingPremiumScreen({super.key, required this.onComplete});

  @override
  State<OnboardingPremiumScreen> createState() =>
      _OnboardingPremiumScreenState();
}

class _OnboardingPremiumScreenState extends State<OnboardingPremiumScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  // Controle de som
  bool _isSoundOn = true;
  late AnimationController _soundController;
  late Animation<double> _soundAnimation;
  IconData _soundIcon = Icons.volume_up_rounded;

  // Áudio multiplataforma
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _audioInitialized = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _pulseController =
        AnimationController(duration: const Duration(seconds: 3), vsync: this)
          ..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _soundController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);

    _soundAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
        CurvedAnimation(parent: _soundController, curve: Curves.easeInOut));

    _fadeController.forward();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setSource(AssetSource('sounds/forest_ambience.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(0.25);
      _audioInitialized = true;
      print('🎵 Player pronto');

      // Tenta tocar direto
      try {
        await _audioPlayer.play(AssetSource('sounds/forest_ambience.mp3'));
        print('🎵 Tocando auto');
      } catch (e) {
        print('🎵 Autoplay bloqueado: $e');
      }
    } catch (e) {
      print('🎵 Erro init: $e');
      _audioInitialized = false;
    }
  }

  void _toggleSound() async {
    setState(() {
      _isSoundOn = !_isSoundOn;
    });

    if (_isSoundOn) {
      _soundIcon = Icons.volume_up_rounded;
      _soundController.reverse();
      try {
        // Para e toca de novo (solução garantida)
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource('sounds/forest_ambience.mp3'));
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.setVolume(0.25);
        print('🎵 Tocando!');
      } catch (e) {
        print('🎵 Erro: $e');
      }
    } else {
      _soundIcon = Icons.volume_off_rounded;
      _soundController.forward();
      try {
        await _audioPlayer.pause();
        print('🎵 Pausado');
      } catch (e) {
        print('🎵 Erro pausa: $e');
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _pageController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _soundController.dispose();
    super.dispose();
  }

  final List<_PremiumSlide> _slides = [
    _PremiumSlide(
      imagePath: 'assets/images/onboarding_1.png',
      overlayColors: [
        const Color(0xFF2D3436).withOpacity(0.7), // Cinza escuro
        const Color(0xFF636E72).withOpacity(0.4),
      ],
      icon: '🌫️',
      title: 'Vivendo no\nautomático',
      subtitle: 'A floresta da vida passa.\nVocê está realmente presente?',
      buttonText: 'DESPERTAR',
      buttonColor: const Color(0xFF636E72),
    ),
    _PremiumSlide(
      imagePath: 'assets/images/onboarding_2.png',
      overlayColors: [
        const Color(0xFF4A5D23).withOpacity(0.6), // Verde escuro do app
        const Color(0xFF6B8E23).withOpacity(0.3),
      ],
      icon: '🧭',
      title: 'Sua bússola\ninterior',
      subtitle: 'Entre o fazer e o ser,\nexiste um caminho de equilíbrio.',
      buttonText: 'EXPLORAR',
      buttonColor: const Color(0xFF6B8E23),
    ),
    _PremiumSlide(
      imagePath: 'assets/images/onboarding_3.png',
      overlayColors: [
        const Color(0xFF8B6914).withOpacity(0.5), // Marrom ocre
        const Color(0xFF6B8E23).withOpacity(0.3),
      ],
      icon: '🌿',
      title: 'Três dimensões\nda consciência',
      subtitle: '⚡ Energia · 🧠 Foco · 🌊 Flow\nCada ação tem seu propósito.',
      buttonText: 'COMPREENDER',
      buttonColor: const Color(0xFF8B6914),
    ),

    // 🔥 NOVO: Slide 4 - Como Usar
    _PremiumSlide(
      imagePath: 'assets/images/onboarding_4.png',
      overlayColors: [
        const Color(0xFF6B8E23).withOpacity(0.4),
        const Color(0xFF4A5D23).withOpacity(0.3)
      ],
      icon: '📱',
      title: 'Como usar',
      subtitle: '',
      buttonText: 'ENTENDI',
      buttonColor: const Color(0xFF6B8E23),
      isTutorial: true, // ← NOVO
    ),

    _PremiumSlide(
      imagePath: 'assets/images/onboarding_4.png',
      overlayColors: [
        const Color(0xFF4A5D23).withOpacity(0.4),
        const Color(0xFF8B6914).withOpacity(0.2),
      ],
      icon: '🌳',
      title: 'Sua jornada\ncomeça agora',
      subtitle: 'Não importa o que você faça,\nmas como você faz.',
      buttonText: 'COMEÇAR JORNADA',
      buttonColor: const Color(0xFF6B8E23),
      isLast: true,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _fadeController.reset();
      _pageController
          .nextPage(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut)
          .then((_) {
        _fadeController.forward();
      });
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              _fadeController.reset();
              _fadeController.forward();
            },
            itemCount: _totalPages,
            itemBuilder: (context, index) => _buildSlide(index),
          ),

          // ===== TOPO: Botões de Som e Pular =====
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botão de Som
                GestureDetector(
                  onTap: _toggleSound,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_soundIcon, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(_isSoundOn ? 'Som' : 'Mudo',
                          style: GoogleFonts.lato(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.8))),
                    ]),
                  ),
                ),
                // Pular
                if (_currentPage < _totalPages - 1)
                  GestureDetector(
                    onTap: () => _pageController.animateToPage(_totalPages - 1,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Pular',
                          style: GoogleFonts.lato(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6))),
                    ),
                  ),
              ],
            ),
          ),

          // ===== BOTTOM: Indicadores (NÃO SOBREPÕEM O BOTÃO) =====
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_totalPages, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF8B6914)
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(int index) {
    final slide = _slides[index];

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(slide.imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: slide.overlayColors,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Ícone pulsante
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.15), width: 1.5),
                      ),
                      child: Center(
                          child: Text(slide.icon,
                              style: const TextStyle(fontSize: 55))),
                    ),
                  ),
                ),

                const Spacer(flex: 1),

                // Título
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(slide.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                          shadows: [
                            Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20)
                          ])),
                ),

                const SizedBox(height: 16),

                // Subtítulo
                if (slide.isTutorial)
                  _buildTutorialSteps()
                else
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(slide.subtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.6,
                            shadows: [
                              Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10)
                            ])),
                  ),

                const Spacer(flex: 2),

                // Botão de ação (COM CORES DO APP)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          slide.buttonColor,
                          slide.buttonColor.withOpacity(0.7)
                        ]),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                              color: slide.buttonColor.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8))
                        ],
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(slide.buttonText,
                                style: GoogleFonts.lato(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2)),
                            if (!slide.isLast) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 20)
                            ],
                          ]),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialSteps() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _tutorialStep('1', 'Escolha uma categoria',
              'Toque na lista de categorias', Icons.touch_app_rounded),
          const SizedBox(height: 8),
          _tutorialStep('2', 'Selecione a prática',
              'Cada categoria tem várias opções', Icons.auto_awesome_rounded),
          const SizedBox(height: 8),
          _tutorialStep('3', 'Adicione um detalhe',
              'Escreva algo para lembrar depois', Icons.edit_note_rounded),
          const SizedBox(height: 8),
          _tutorialStep('4', 'Inicie o tempo',
              'Use cronômetro, pomodoro ou manual', Icons.timer_rounded),
        ],
      ),
    );
  }

  Widget _tutorialStep(
      String number, String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF6B8E23), Color(0xFF8B6914)]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
              child: Text(number,
                  style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white))),
        ),
        const SizedBox(width: 12),
        Icon(icon, size: 18, color: Colors.white.withOpacity(0.8)),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text(subtitle,
              style: GoogleFonts.lato(
                  fontSize: 10, color: Colors.white.withOpacity(0.6))),
        ])),
      ]),
    );
  }
}

class _PremiumSlide {
  final String imagePath;
  final List<Color> overlayColors;
  final String icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final Color buttonColor;
  final bool isLast;
  final bool isTutorial;

  _PremiumSlide({
    required this.imagePath,
    required this.overlayColors,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.buttonColor,
    this.isLast = false,
    this.isTutorial = false,
  });
}
