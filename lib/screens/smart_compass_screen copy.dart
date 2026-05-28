// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../models/activity_log.dart';
// import '../data/activities.dart';
// import '../data/colors.dart';
// import '../data/practice.dart';
// import 'timer_screen.dart';

// class SmartCompassScreen extends StatefulWidget {
//   final List<ActivityLog> logs;
//   final Function(ActivityLog) onStartActivity;

//   const SmartCompassScreen({
//     super.key,
//     required this.logs,
//     required this.onStartActivity,
//   });

//   @override
//   State<SmartCompassScreen> createState() => _SmartCompassScreenState();
// }

// class _SmartCompassScreenState extends State<SmartCompassScreen> {
//   int _currentSuggestionIndex = 0;
//   List<Map<String, dynamic>> _suggestions = [];

//   @override
//   void initState() {
//     super.initState();
//     _generateSmartSuggestions();
//   }

//   // ========== ANÁLISE SIMPLES ==========

//   List<ActivityLog> get _recentWeek {
//     final cutoff = DateTime.now().subtract(const Duration(days: 7));
//     return widget.logs.where((l) => l.timestamp.isAfter(cutoff)).toList();
//   }

//   String get _dominantEnergy {
//     if (_recentWeek.isEmpty) return 'equilibrado';
//     int active = 0, passive = 0;
//     for (final log in _recentWeek) {
//       if (log.energy == 'Ativa')
//         active += log.duration.inMinutes;
//       else
//         passive += log.duration.inMinutes;
//     }
//     if (active > passive * 1.5) return 'muito_ativa';
//     if (passive > active * 1.5) return 'muito_passiva';
//     return 'equilibrado';
//   }

//   String get _dominantOrgan {
//     if (_recentWeek.isEmpty) return 'equilibrado';
//     int mente = 0, corpo = 0;
//     for (final log in _recentWeek) {
//       if (log.organ.contains('Mente')) mente += log.duration.inMinutes;
//       if (log.organ.contains('Corpo')) corpo += log.duration.inMinutes;
//     }
//     if (mente > corpo * 1.5) return 'muita_mente';
//     if (corpo > mente * 1.5) return 'muito_corpo';
//     return 'equilibrado';
//   }

//   String get _dominantFlow {
//     if (_recentWeek.isEmpty) return 'equilibrado';
//     int facil = 0, medio = 0, dificil = 0;
//     for (final log in _recentWeek) {
//       final f = log.flow;
//       if (f.contains('Difícil'))
//         dificil += log.duration.inMinutes;
//       else if (f.contains('Fácil'))
//         facil += log.duration.inMinutes;
//       else
//         medio += log.duration.inMinutes;
//     }
//     if (dificil > (facil + medio) * 1.5) return 'muito_dificil';
//     if (facil > (medio + dificil) * 1.5) return 'muito_facil';
//     return 'equilibrado';
//   }

//   // ========== GERA SUGESTÕES ==========

//   void _generateSmartSuggestions() {
//     _suggestions = [];
//     final energyNeed = _dominantEnergy;
//     final organNeed = _dominantOrgan;
//     final flowNeed = _dominantFlow;

//     // Busca em todas as categorias
//     for (final activity in Activity.activities) {
//       for (final practice in activity.practices) {
//         int score = 0;
//         String reason = '';

//         // Match de energia
//         if (energyNeed == 'muito_ativa' && practice.energy == 'Passiva') {
//           score += 3;
//           reason =
//               'Você está muito ATIVO. Esta prática PASSIVA vai te equilibrar.';
//         } else if (energyNeed == 'muito_passiva' &&
//             practice.energy == 'Ativa') {
//           score += 3;
//           reason =
//               'Você está muito PASSIVO. Esta prática ATIVA vai te energizar.';
//         }

//         // Match de órgão
//         if (organNeed == 'muita_mente' && practice.organ.contains('Corpo')) {
//           score += 2;
//           reason += '\nSua mente trabalhou muito. Hora de mover o corpo!';
//         } else if (organNeed == 'muito_corpo' &&
//             practice.organ.contains('Mente')) {
//           score += 2;
//           reason += '\nSeu corpo se mexeu bastante. Estimule a mente!';
//         }

//         // Match de flow
//         if (flowNeed == 'muito_dificil' && practice.flow.contains('Fácil')) {
//           score += 2;
//           reason += '\nMuitos desafios. Algo mais leve vai fazer bem.';
//         } else if (flowNeed == 'muito_facil' &&
//             !practice.flow.contains('Fácil')) {
//           score += 2;
//           reason += '\nZona de conforto. Um desafio moderado te faz crescer.';
//         }

//         if (score >= 3) {
//           _suggestions.add({
//             'practice': practice,
//             'category': activity.group,
//             'icon': activity.icon,
//             'reason': reason.trim(),
//             'score': score,
//           });
//         }
//       }
//     }

//     // Se não encontrou, sugere algo equilibrado
//     if (_suggestions.isEmpty) {
//       _suggestions.add({
//         'practice': const Practice(
//             name: 'Meditar', energy: 'Passiva', flow: 'Fácil', organ: 'Mente'),
//         'category': 'Espiritualidade',
//         'icon': '🧘',
//         'reason': 'Um momento de pausa sempre faz bem.',
//         'score': 1,
//       });
//     }

//     _suggestions
//         .sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
//   }

//   // ========== BUILD ==========

//   @override
//   Widget build(BuildContext context) {
//     if (_suggestions.isEmpty)
//       return const Center(child: CircularProgressIndicator());

//     final suggestion =
//         _suggestions[_currentSuggestionIndex % _suggestions.length];
//     final practice = suggestion['practice'] as Practice;

//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFFF5F9E9),
//               Color(0xFFE8F0D5),
//               Color(0xFFF0F7E6),
//               Color(0xFFD4E8C2)
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               _buildAppBar(),
//               Expanded(
//                 child: SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   padding: const EdgeInsets.all(16),
//                   child: Column(children: [
//                     // Mini bússola indicativa
//                     _buildMiniCompass(practice),

//                     const SizedBox(height: 16),

//                     // Cards de diagnóstico
//                     _buildDiagnosisCards(),

//                     const SizedBox(height: 16),

//                     // Sugestão
//                     _buildSuggestionCard(suggestion),

//                     const SizedBox(height: 12),

//                     // Navegação
//                     if (_suggestions.length > 1) _buildNav(),

//                     const SizedBox(height: 16),

//                     // Botão
//                     _buildStartButton(suggestion),
//                   ]),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAppBar() {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//             colors: [Color(0xFFE8F0D5), Color(0xFFF5F9E9), Color(0xFFD4E8C2)]),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.5)),
//       ),
//       child: Row(children: [
//         const Text('🧭', style: TextStyle(fontSize: 22)),
//         const SizedBox(width: 10),
//         Text('Bússola Smart',
//             style: GoogleFonts.playfairDisplay(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: const Color(0xFF4A5D23))),
//         const Spacer(),

//         // 🔄 Botão de atualizar/girar
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               _generateSmartSuggestions();
//               _currentSuggestionIndex = 0;
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('🔄 ${_suggestions.length} novas sugestões!'),
//                 backgroundColor: const Color(0xFF6B8E23),
//                 behavior: SnackBarBehavior.floating,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10)),
//                 duration: const Duration(seconds: 2),
//               ),
//             );
//           },
//           child: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: const Color(0xFF6B8E23).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(Icons.refresh_rounded,
//                 color: Color(0xFF6B8E23), size: 20),
//           ),
//         ),

//         const SizedBox(width: 8),

//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//           decoration: BoxDecoration(
//               color: const Color(0xFF6B8E23).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10)),
//           child: Text('${_suggestions.length} sugestões',
//               style: GoogleFonts.lato(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w600,
//                   color: const Color(0xFF6B8E23))),
//         ),
//       ]),
//     );
//   }

//   Widget _buildMiniCompass(Practice practice) {
//     final energyColor =
//         HawkinsColors.energyColors[practice.energy] ?? Colors.grey;
//     final angle = practice.energy == 'Ativa' ? 0.0 : pi;

//     return Container(
//       width: 160,
//       height: 160,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.white.withOpacity(0.5),
//         border: Border.all(color: energyColor.withOpacity(0.4), width: 3),
//         boxShadow: [
//           BoxShadow(color: energyColor.withOpacity(0.15), blurRadius: 15)
//         ],
//       ),
//       child: Stack(alignment: Alignment.center, children: [
//         // Labels
//         _miniLabel('ATIVA', Alignment.centerRight, const Color(0xFFFF6B35)),
//         _miniLabel('PASSIVA', Alignment.centerLeft, const Color(0xFF4ECDC4)),
//         _miniLabel('DIFÍCIL', Alignment.topCenter, const Color(0xFFF44336)),
//         _miniLabel('FÁCIL', Alignment.bottomCenter, const Color(0xFF4CAF50)),

//         // Agulha simples
//         Transform.rotate(
//           angle: angle,
//           child: CustomPaint(
//             size: const Size(160, 160),
//             painter: _SimpleNeedlePainter(energyColor: energyColor),
//           ),
//         ),

//         // 🔄 Centro com botão de girar
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               _generateSmartSuggestions();
//               _currentSuggestionIndex = 0;
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('🔄 ${_suggestions.length} novas sugestões!'),
//                 backgroundColor: const Color(0xFF6B8E23),
//                 behavior: SnackBarBehavior.floating,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10)),
//                 duration: const Duration(seconds: 2),
//               ),
//             );
//           },
//           child: Container(
//             width: 44,
//             height: 44,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(color: energyColor.withOpacity(0.3), blurRadius: 8),
//               ],
//             ),
//             child: const Icon(Icons.refresh_rounded,
//                 color: Color(0xFF6B8E23), size: 22),
//           ),
//         ),
//       ]),
//     );
//   }

//   Widget _miniLabel(String text, Alignment align, Color color) {
//     return Align(
//       alignment: align,
//       child: Padding(
//         padding: const EdgeInsets.all(8),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
//           decoration: BoxDecoration(
//               color: color.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(4)),
//           child: Text(text,
//               style: GoogleFonts.lato(
//                   fontSize: 7, fontWeight: FontWeight.w800, color: color)),
//         ),
//       ),
//     );
//   }

//   Widget _buildDiagnosisCards() {
//     return Row(children: [
//       Expanded(
//           child: _diagnosisCard(
//               '⚡ Energia',
//               _dominantEnergy == 'muito_ativa'
//                   ? 'Muito Ativa'
//                   : _dominantEnergy == 'muito_passiva'
//                       ? 'Muito Passiva'
//                       : 'Equilibrada',
//               _dominantEnergy == 'equilibrado'
//                   ? const Color(0xFF4CAF50)
//                   : Colors.orange)),
//       const SizedBox(width: 8),
//       Expanded(
//           child: _diagnosisCard(
//               '🧠 Foco',
//               _dominantOrgan == 'muita_mente'
//                   ? 'Muita Mente'
//                   : _dominantOrgan == 'muito_corpo'
//                       ? 'Muito Corpo'
//                       : 'Equilibrado',
//               _dominantOrgan == 'equilibrado'
//                   ? const Color(0xFF4CAF50)
//                   : Colors.orange)),
//       const SizedBox(width: 8),
//       Expanded(
//           child: _diagnosisCard(
//               '🌊 Flow',
//               _dominantFlow == 'muito_dificil'
//                   ? 'Muito Difícil'
//                   : _dominantFlow == 'muito_facil'
//                       ? 'Muito Fácil'
//                       : 'Equilibrado',
//               _dominantFlow == 'equilibrado'
//                   ? const Color(0xFF4CAF50)
//                   : Colors.orange)),
//     ]);
//   }

//   Widget _diagnosisCard(String title, String value, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.35),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withOpacity(0.3))),
//       child: Column(children: [
//         Text(title,
//             style: GoogleFonts.lato(
//                 fontSize: 9,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.grey[500])),
//         const SizedBox(height: 4),
//         Text(value,
//             style: GoogleFonts.lato(
//                 fontSize: 10, fontWeight: FontWeight.bold, color: color),
//             textAlign: TextAlign.center),
//       ]),
//     );
//   }

//   Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
//     final practice = suggestion['practice'] as Practice;
//     final category = suggestion['category'] as String;
//     final icon = suggestion['icon'] as String;
//     final reason = suggestion['reason'] as String;
//     final energyColor =
//         HawkinsColors.energyColors[practice.energy] ?? Colors.grey;
//     final flowColor = HawkinsColors.flowGradient[practice.flow] ?? Colors.grey;

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(colors: [
//           energyColor.withOpacity(0.08),
//           flowColor.withOpacity(0.08)
//         ], begin: Alignment.topLeft, end: Alignment.bottomRight),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: energyColor.withOpacity(0.3)),
//       ),
//       child: Column(children: [
//         Row(children: [
//           Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: LinearGradient(colors: [energyColor, flowColor])),
//             child: Text(icon, style: const TextStyle(fontSize: 28)),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                 Text(category,
//                     style: GoogleFonts.lato(
//                         fontSize: 11, color: Colors.grey[500])),
//                 const SizedBox(height: 2),
//                 Text(practice.name,
//                     style: GoogleFonts.playfairDisplay(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: const Color(0xFF2D3436))),
//                 const SizedBox(height: 6),
//                 Wrap(spacing: 6, children: [
//                   _chip(practice.energy, energyColor),
//                   _chip(practice.flow, flowColor),
//                   _chip(
//                       practice.organ,
//                       HawkinsColors.organGradients[practice.organ]?[0] ??
//                           Colors.grey),
//                 ]),
//               ])),
//         ]),
//         const SizedBox(height: 14),
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.5),
//               borderRadius: BorderRadius.circular(12)),
//           child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             const Text('💡', style: TextStyle(fontSize: 16)),
//             const SizedBox(width: 8),
//             Expanded(
//                 child: Text(reason,
//                     style: GoogleFonts.lato(
//                         fontSize: 12, color: Colors.grey[700], height: 1.4))),
//           ]),
//         ),
//       ]),
//     );
//   }

//   Widget _chip(String text, Color color) {
//     return Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//         decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: color.withOpacity(0.2))),
//         child: Text(text,
//             style: GoogleFonts.lato(
//                 fontSize: 10, fontWeight: FontWeight.w600, color: color)));
//   }

//   Widget _buildNav() {
//     return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//       GestureDetector(
//         onTap: () => setState(() => _currentSuggestionIndex =
//             (_currentSuggestionIndex - 1).clamp(0, _suggestions.length - 1)),
//         child: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.4),
//                 borderRadius: BorderRadius.circular(20)),
//             child: const Icon(Icons.chevron_left_rounded,
//                 size: 20, color: Color(0xFF6B8E23))),
//       ),
//       Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Text('${_currentSuggestionIndex + 1}/${_suggestions.length}',
//             style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[500])),
//       ),
//       GestureDetector(
//         onTap: () => setState(() => _currentSuggestionIndex =
//             (_currentSuggestionIndex + 1) % _suggestions.length),
//         child: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.4),
//                 borderRadius: BorderRadius.circular(20)),
//             child: const Icon(Icons.chevron_right_rounded,
//                 size: 20, color: Color(0xFF6B8E23))),
//       ),
//     ]);
//   }

//   Widget _buildStartButton(Map<String, dynamic> suggestion) {
//     final practice = suggestion['practice'] as Practice;
//     return GestureDetector(
//       onTap: () async {
//         final result = await Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (_) => TimerScreen(
//                       group: suggestion['category'] as String,
//                       example: practice.name,
//                       energy: practice.energy,
//                       flow: practice.flow,
//                       organ: practice.organ,
//                     )));
//         if (result != null && result is ActivityLog)
//           widget.onStartActivity(result);
//       },
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         decoration: BoxDecoration(
//             gradient: const LinearGradient(
//                 colors: [Color(0xFF6B8E23), Color(0xFF8B6914)]),
//             borderRadius: BorderRadius.circular(25),
//             boxShadow: [
//               BoxShadow(
//                   color: const Color(0xFF6B8E23).withOpacity(0.3),
//                   blurRadius: 15,
//                   offset: const Offset(0, 6))
//             ]),
//         child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//           const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
//           const SizedBox(width: 8),
//           Text('INICIAR ESTA PRÁTICA',
//               style: GoogleFonts.lato(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   letterSpacing: 2)),
//         ]),
//       ),
//     );
//   }
// }

// // Pintor simples da agulha
// class _SimpleNeedlePainter extends CustomPainter {
//   final Color energyColor;
//   _SimpleNeedlePainter({required this.energyColor});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final paint = Paint()
//       ..color = energyColor
//       ..style = PaintingStyle.fill;
//     final path = Path()
//       ..moveTo(center.dx, center.dy - 45)
//       ..lineTo(center.dx - 4, center.dy + 10)
//       ..lineTo(center.dx + 4, center.dy + 10)
//       ..close();
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
