import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/activities.dart';
import '../data/colors.dart';

class CompassWidget extends StatefulWidget {
  final Activity? selectedActivity;
  final bool isRotating;
  final String backgroundTheme; // 'hawkins', 'tree', 'custom'

  const CompassWidget({
    super.key,
    required this.selectedActivity,
    this.isRotating = false,
    this.backgroundTheme = 'hawkins',
  });

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget>
    with TickerProviderStateMixin {
  late AnimationController _energyController;
  late Animation<double> _energyAnimation;
  late AnimationController _flowController;
  late Animation<double> _flowAnimation;

  double _previousEnergyAngle = 0;
  double _previousFlowAngle = 0;

  @override
  void initState() {
    super.initState();
    _energyController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _flowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(CompassWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedActivity != null &&
        (oldWidget.selectedActivity != widget.selectedActivity ||
            widget.isRotating)) {
      _animatePointers();
    }
  }

  void _animatePointers() {
    // Ajuste dos ponteiros aqui
    double targetEnergyRad = _calculateEnergyDegrees();
    double targetFlowRad = _calculateFlowDegrees() * pi / 180;

    _energyAnimation = Tween<double>(
      begin: _previousEnergyAngle,
      end: targetEnergyRad,
    ).animate(CurvedAnimation(
      parent: _energyController,
      curve: Curves.easeOutBack,
    ));

    _flowAnimation = Tween<double>(
      begin: _previousFlowAngle,
      end: targetFlowRad,
    ).animate(CurvedAnimation(
      parent: _flowController,
      curve: Curves.easeOutBack,
    ));

    _energyController.reset();
    _flowController.reset();
    _energyController
        .forward()
        .then((_) => _previousEnergyAngle = targetEnergyRad);
    _flowController.forward().then((_) => _previousFlowAngle = targetFlowRad);
  }

  @override
  void dispose() {
    _energyController.dispose();
    _flowController.dispose();
    super.dispose();
  }

  // Ajuste dos ponteiros aqui
  double _calculateEnergyDegrees() {
    if (widget.selectedActivity == null) return 0;
    return widget.selectedActivity!.energy == 'Ativa' ? pi : pi;
  }

// Ajuste dos ponteiros aqui
  double _calculateFlowDegrees() {
    if (widget.selectedActivity == null) return 0;
    switch (widget.selectedActivity!.flow) {
      case 'Difícil':
        return 270;
      case 'Médio – Difícil':
        return 225;
      case 'Médio':
        return 180;
      case 'Fácil – Médio':
        return 120;
      case 'Fácil':
        return 90;
      default:
        return 90;
    }
  }

  Color _getHawkinsBackground() {
    if (widget.selectedActivity == null) return Colors.white.withOpacity(0.6);
    final energy = widget.selectedActivity!.energy;
    final flow = widget.selectedActivity!.flow;

    if (energy == 'Ativa' && (flow == 'Difícil' || flow == 'Médio – Difícil'))
      return const Color(0xFFFFF3E0);
    if (energy == 'Ativa' && (flow == 'Médio' || flow == 'Fácil – Médio'))
      return const Color(0xFFFFF8E1);
    if (energy == 'Ativa' && flow == 'Fácil') return const Color(0xFFF1F8E9);
    if (energy == 'Passiva' && (flow == 'Difícil' || flow == 'Médio – Difícil'))
      return const Color(0xFFEDE7F6);
    if (energy == 'Passiva' && (flow == 'Médio' || flow == 'Fácil – Médio'))
      return const Color(0xFFE0F2F1);
    if (energy == 'Passiva' && flow == 'Fácil') return const Color(0xFFE8F5E9);
    return Colors.white.withOpacity(0.6);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getHawkinsBackground();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            widget.backgroundTheme == 'hawkins' ? bgColor : Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.4),
            offset: const Offset(-6, -6),
            blurRadius: 15,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: HawkinsColors.darkShadow.withOpacity(0.2),
            offset: const Offset(6, 6),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fundo da árvore (tema orgânico)
          if (widget.backgroundTheme == 'tree')
            ClipOval(
              child: Image.asset(
                'assets/images/tree.png',
                width: 240,
                height: 240,
                fit: BoxFit.cover,
              ),
            ),

          // Face da bússola
          if (widget.selectedActivity != null)
            CustomPaint(
              size: const Size(240, 240),
              painter: CompassFacePainter(
                activity: widget.selectedActivity!,
                bgColor: bgColor,
                theme: widget.backgroundTheme,
              ),
            )
          else
            _buildEmptyState(),

          // Ponteiro de ENERGIA
          if (widget.selectedActivity != null)
            AnimatedBuilder(
              animation: _energyAnimation,
              builder: (context, child) => Transform.rotate(
                angle: _energyAnimation.value,
                child: CustomPaint(
                  size: const Size(240, 240),
                  painter: EnergyNeedlePainter(
                    activity: widget.selectedActivity!,
                    theme: widget.backgroundTheme,
                  ),
                ),
              ),
            ),

          // Ponteiro de FLOW
          if (widget.selectedActivity != null)
            AnimatedBuilder(
              animation: _flowAnimation,
              builder: (context, child) => Transform.rotate(
                angle: _flowAnimation.value,
                child: CustomPaint(
                  size: const Size(240, 240),
                  painter: FlowNeedlePainter(
                    activity: widget.selectedActivity!,
                    theme: widget.backgroundTheme,
                  ),
                ),
              ),
            ),

          // Centro decorativo
          if (widget.selectedActivity != null)
            CustomPaint(
              size: const Size(240, 240),
              painter: CenterDotPainter(
                activity: widget.selectedActivity!,
                bgColor: bgColor,
                theme: widget.backgroundTheme,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.explore_rounded, size: 50, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          'Escolha uma\natividade',
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// 🌳 PINTOR DA ÁRVORE DE FUNDO
class TreeBackgroundPainter extends CustomPainter {
  final Activity? activity;

  TreeBackgroundPainter({this.activity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 15;

    // Fundo circular com gradiente orgânico
    final bgGradient = RadialGradient(
      colors: [
        const Color(0xFFF5F9E9), // Verde-amarelado claro
        const Color(0xFFE8F0D5), // Verde suave
        const Color(0xFFD4E8C2), // Verde médio claro
      ],
      stops: [0.3, 0.7, 1.0],
    );

    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = bgGradient
              .createShader(Rect.fromCircle(center: center, radius: radius)));

    // Tronco da árvore (marrom quente, linhas sinuosas)
    _drawTrunk(canvas, center, radius);

    // Raízes expressivas entrelaçadas
    _drawRoots(canvas, center, radius);

    // Galhos e copa
    _drawBranchesAndLeaves(canvas, center, radius);
  }

  void _drawTrunk(Canvas canvas, Offset center, double radius) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF8B6914).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final trunkPath = Path();
    trunkPath.moveTo(center.dx - 6, center.dy + radius * 0.4);
    trunkPath.quadraticBezierTo(
      center.dx - 4,
      center.dy + radius * 0.1,
      center.dx - 3,
      center.dy - radius * 0.3,
    );
    trunkPath.lineTo(center.dx + 3, center.dy - radius * 0.3);
    trunkPath.quadraticBezierTo(
      center.dx + 4,
      center.dy + radius * 0.1,
      center.dx + 6,
      center.dy + radius * 0.4,
    );
    trunkPath.close();
    canvas.drawPath(trunkPath, trunkPaint);

    // Linhas sinuosas no tronco (movimento)
    final linePaint = Paint()
      ..color = const Color(0xFF6B4E0A).withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 3; i++) {
      final linePath = Path();
      final y = center.dy - radius * 0.1 + i * radius * 0.08;
      linePath.moveTo(center.dx - 3, y);
      linePath.quadraticBezierTo(
        center.dx,
        y + 4,
        center.dx + 3,
        y,
      );
      canvas.drawPath(linePath, linePaint);
    }
  }

  void _drawRoots(Canvas canvas, Offset center, double radius) {
    final rootPaint = Paint()
      ..color = const Color(0xFF6B4E0A).withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Raízes curvas e entrelaçadas
    for (int i = -2; i <= 2; i++) {
      final rootPath = Path();
      final startX = center.dx + i * 5.0;
      final startY = center.dy + radius * 0.35;

      rootPath.moveTo(startX, startY);
      rootPath.quadraticBezierTo(
        startX + i * 8,
        startY + radius * 0.25,
        startX + i * 12,
        startY + radius * 0.35,
      );

      canvas.drawPath(rootPath, rootPaint);
    }
  }

  void _drawBranchesAndLeaves(Canvas canvas, Offset center, double radius) {
    // Galhos principais
    final branchPaint = Paint()
      ..color = const Color(0xFF8B6914).withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * pi / 180;
      final branchPath = Path();
      final startOffset = Offset(
        center.dx + 4 * cos(angle),
        center.dy - radius * 0.3 + 4 * sin(angle),
      );
      final endOffset = Offset(
        center.dx + radius * 0.5 * cos(angle),
        center.dy - radius * 0.5 + radius * 0.4 * sin(angle),
      );

      branchPath.moveTo(startOffset.dx, startOffset.dy);
      branchPath.quadraticBezierTo(
        (startOffset.dx + endOffset.dx) / 2,
        (startOffset.dy + endOffset.dy) / 2 - 10,
        endOffset.dx,
        endOffset.dy,
      );
      canvas.drawPath(branchPath, branchPaint);
    }

    // Folhas (pontos verdes)
    final leafPaint = Paint()..style = PaintingStyle.fill;

    final rng = Random(42);
    for (int i = 0; i < 60; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final dist = radius * 0.25 + rng.nextDouble() * radius * 0.45;
      final leafOffset = Offset(
        center.dx + dist * cos(angle),
        center.dy - radius * 0.2 + dist * sin(angle),
      );

      // Variação de verdes
      final greenShade = Color.lerp(
        const Color(0xFF7CB342),
        const Color(0xFFAED581),
        rng.nextDouble(),
      )!
          .withOpacity(0.35);

      leafPaint.color = greenShade;
      canvas.drawCircle(leafOffset, 2.5 + rng.nextDouble() * 2, leafPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ... (manter os outros pintores: CompassFacePainter, EnergyNeedlePainter, etc.)
// Adicione o parâmetro 'theme' neles também

// Face da bússola
class CompassFacePainter extends CustomPainter {
  final Activity activity;
  final Color bgColor;
  final String theme;

  CompassFacePainter({
    required this.activity,
    required this.bgColor,
    this.theme = 'hawkins',
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Se for tema tree, o fundo já foi pintado pelo TreeBackgroundPainter
    if (theme == 'hawkins') {
      final bgPaint = Paint()..color = bgColor.withOpacity(0.5);
      canvas.drawCircle(center, radius, bgPaint);
    }

    // Arco do FLOW
    _drawFlowArc(canvas, center, radius);
    // Eixo horizontal
    _drawEnergyAxis(canvas, center, radius);
    // Labels
    _drawLabels(canvas, center, radius);
    // Bordas
    _drawBorders(canvas, center, radius);
  }

  void _drawFlowArc(Canvas canvas, Offset center, double radius) {
    final arcRect = Rect.fromCircle(center: center, radius: radius - 5);

    // Gradiente: Verde (90°) → Amarelo (180°) → Vermelho (270°)
    final gradient = SweepGradient(
      colors: [
        const Color(0xFF4CAF50), // Verde - Fácil
        const Color(0xFF8BC34A), // Verde claro
        const Color(0xFFFFEB3B), // Amarelo - Médio
        const Color(0xFFFF9800), // Laranja
        const Color(0xFFF44336), // Vermelho - Difícil
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      startAngle: pi / 2, // Começa em 90° (baixo)
      endAngle: 3 * pi / 2, // Termina em 270° (cima)
    );

    final arcPaint = Paint()
      ..shader = gradient.createShader(arcRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, pi / 2, pi, false, arcPaint);

    // Brilho
    final glowPaint = Paint()
      ..shader = gradient.createShader(arcRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawArc(arcRect, pi / 2, pi, false, glowPaint);
  }

  void _drawEnergyAxis(Canvas canvas, Offset center, double radius) {
    final axisPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Linha horizontal
    canvas.drawLine(
      Offset(center.dx - radius * 0.7, center.dy),
      Offset(center.dx + radius * 0.7, center.dy),
      axisPaint,
    );
  }

  void _drawLabels(Canvas canvas, Offset center, double radius) {
    // Labels do FLOW
    final flowLabels = [
      {'text': 'FÁCIL', 'angle': pi / 2, 'color': const Color(0xFF4CAF50)},
      {'text': 'MÉDIO', 'angle': pi, 'color': const Color(0xFFFFEB3B)},
      {
        'text': 'DIFÍCIL',
        'angle': 3 * pi / 2,
        'color': const Color(0xFFF44336)
      },
    ];

    for (final label in flowLabels) {
      final angle = label['angle'] as double;
      final textOffset = Offset(
        center.dx + (radius + 20) * cos(angle),
        center.dy + (radius + 20) * sin(angle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: label['text'] as String,
          style: GoogleFonts.lato(
            color: label['color'] as Color,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        textOffset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Labels ENERGIA
    final energyLabels = [
      {
        'text': '🍃 PASSIVA',
        'pos': Offset(center.dx + radius * 0.4, center.dy - 20)
      },
      {
        'text': '⚡ ATIVA',
        'pos': Offset(center.dx - radius * 0.6, center.dy - 20)
      },
    ];

    for (final label in energyLabels) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: label['text'] as String,
          style: GoogleFonts.lato(
            color: Colors.grey[600],
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        (label['pos'] as Offset) -
            Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  void _drawBorders(Canvas canvas, Offset center, double radius) {
    final outerPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, outerPaint);

    final innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius - 8, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Ponteiro de ENERGIA (raio horizontal)
class EnergyNeedlePainter extends CustomPainter {
  final Activity activity;

  final String theme;

  EnergyNeedlePainter({
    required this.activity,
    this.theme = 'hawkins',
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 30;

    final isActive = activity.energy == 'Ativa';
    final color = isActive ? const Color(0xFFFF6B35) : const Color(0xFF4ECDC4);
    final direction = isActive ? 1.0 : -1.0;

    // Sombra
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final shadowPath = Path()
      ..moveTo(center.dx, center.dy - 5)
      ..lineTo(center.dx + direction * radius * 0.75, center.dy)
      ..lineTo(center.dx, center.dy + 5)
      ..close();
    canvas.drawPath(shadowPath, shadowPaint);

    // Ponteiro principal
    final needlePaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(0.8), color],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    final needlePath = Path()
      ..moveTo(center.dx, center.dy - 5)
      ..lineTo(center.dx + direction * radius * 0.75, center.dy)
      ..lineTo(center.dx, center.dy + 5)
      ..close();
    canvas.drawPath(needlePath, needlePaint);

    // Contorno
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(needlePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Ponteiro de FLOW (raio dentro do arco direito)
class FlowNeedlePainter extends CustomPainter {
  final Activity activity;
  final String theme;

  FlowNeedlePainter({
    required this.activity,
    this.theme = 'hawkins',
  });

  double _getFlowAngle() {
    switch (activity.flow) {
      case 'Fácil':
        return 0; // 90° - Baixo
      case 'Fácil – Médio':
        return pi * 2; // 135°-
      case 'Médio':
        return pi * 2; // 180° - Meio
      case 'Médio – Difícil':
        return pi * 2; // 225°
      case 'Difícil':
        return pi * 2; // 270° - Cima
      default:
        return pi;
    }
  }

  Color _getFlowColor() {
    switch (activity.flow) {
      case 'Fácil':
        return const Color(0xFF4CAF50);
      case 'Fácil – Médio':
        return const Color(0xFF8BC34A);
      case 'Médio':
        return const Color(0xFFFFEB3B);
      case 'Médio – Difícil':
        return const Color(0xFFFF9800);
      case 'Difícil':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 35;
    final flowAngle = _getFlowAngle();
    final flowColor = _getFlowColor();

    // Ponta do ponteiro (na borda do arco)
    final tipOffset = Offset(
      center.dx + radius * 0.85 * cos(flowAngle),
      center.dy + radius * 0.85 * sin(flowAngle),
    );

    // Base do ponteiro (perto do centro)
    final baseOffset = Offset(
      center.dx + 10 * cos(flowAngle),
      center.dy + 10 * sin(flowAngle),
    );

    // Sombra
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final shadowPath = Path()
      ..moveTo(baseOffset.dx - 4 * sin(flowAngle),
          baseOffset.dy + 4 * cos(flowAngle))
      ..lineTo(
          tipOffset.dx - 2 * sin(flowAngle), tipOffset.dy + 2 * cos(flowAngle))
      ..lineTo(
          tipOffset.dx + 2 * sin(flowAngle), tipOffset.dy - 2 * cos(flowAngle))
      ..lineTo(baseOffset.dx + 4 * sin(flowAngle),
          baseOffset.dy - 4 * cos(flowAngle))
      ..close();
    canvas.drawPath(shadowPath, shadowPaint);

    // Ponteiro
    final needlePaint = Paint()
      ..color = flowColor
      ..style = PaintingStyle.fill;

    final needlePath = Path()
      ..moveTo(baseOffset.dx - 4 * sin(flowAngle),
          baseOffset.dy + 4 * cos(flowAngle))
      ..lineTo(tipOffset.dx, tipOffset.dy)
      ..lineTo(baseOffset.dx + 4 * sin(flowAngle),
          baseOffset.dy - 4 * cos(flowAngle))
      ..close();
    canvas.drawPath(needlePath, needlePaint);

    // Contorno
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(needlePath, strokePaint);

    // Círculo na ponta
    canvas.drawCircle(tipOffset, 5, Paint()..color = flowColor);
    canvas.drawCircle(
        tipOffset,
        5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Centro decorativo
class CenterDotPainter extends CustomPainter {
  final Activity activity;
  final Color bgColor;
  final String theme;

  CenterDotPainter({
    required this.activity,
    required this.bgColor,
    this.theme = 'hawkins',
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, 14, Paint()..color = bgColor);

    canvas.drawCircle(
        center,
        14,
        Paint()
          ..color = Colors.grey[300]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    final energyColor = activity.energy == 'Ativa'
        ? const Color(0xFFFF6B35)
        : const Color(0xFF4ECDC4);

    final gradient = RadialGradient(
      colors: [energyColor.withOpacity(0.3), energyColor.withOpacity(0.1)],
    );

    canvas.drawCircle(
        center,
        10,
        Paint()
          ..shader = gradient
              .createShader(Rect.fromCircle(center: center, radius: 10)));

    canvas.drawCircle(center, 3, Paint()..color = energyColor);
    canvas.drawCircle(
        center,
        3,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
