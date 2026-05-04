import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:life_compass/data/custom_activities.dart';
import 'package:life_compass/data/practice.dart';
import 'package:life_compass/models/activity_log.dart';
import 'package:life_compass/screens/customize_screen.dart';
import 'package:life_compass/screens/onboarding_premium_screen.dart';
import '../data/activities.dart';
import '../data/colors.dart';
import 'timer_screen.dart';

class ConsciousActionScreen extends StatefulWidget {
  final Function(dynamic) onStartActivity;
  final List<ActivityLog> logs;

  const ConsciousActionScreen({
    super.key,
    required this.onStartActivity,
    required this.logs,
  });

  @override
  State<ConsciousActionScreen> createState() => _ConsciousActionScreenState();
}

class _ConsciousActionScreenState extends State<ConsciousActionScreen> {
  Activity? _selectedActivity;
  Practice? _selectedPractice;
  String _activityDetail = '';
  final _detailController = TextEditingController();

  List<Activity> _allActivities = Activity.activities;

  @override
  void initState() {
    super.initState();
    _loadCustomActivities();
  }

  Future<void> _loadCustomActivities() async {
    final activities = await CustomActivitiesManager.loadActivities();
    if (mounted) setState(() => _allActivities = activities);
  }

  List<Activity> get _organizedActivities {
    final passivas =
        _allActivities.where((a) => a.energy == 'Passiva').toList();
    final ativas = _allActivities.where((a) => a.energy == 'Ativa').toList();
    return [...passivas, ...ativas];
  }

  void _startActivity() {
    if (_selectedActivity == null || _selectedPractice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecione uma categoria e uma prática!'),
          backgroundColor: Colors.orange[700],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => TimerScreen(
          group: _selectedActivity!.group,
          example: _activityDetail.isNotEmpty
              ? '${_selectedPractice!.name}: $_activityDetail'
              : _selectedPractice!.name,
          energy: _selectedPractice!.energy,
          flow: _selectedPractice!.flow,
          organ: _selectedPractice!.organ,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ).then((result) {
      if (result != null && result is ActivityLog) {
        widget.onStartActivity(result);
        setState(() {
          _selectedActivity = null;
          _selectedPractice = null;
          _activityDetail = '';
          _detailController.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  Color _getPracticeColor() {
    if (_selectedPractice == null) return Colors.grey[400]!;
    return HawkinsColors.energyColors[_selectedPractice!.energy] ?? Colors.grey;
  }

  Color _getFlowColor() {
    if (_selectedPractice == null) return Colors.grey[400]!;
    return HawkinsColors.flowGradient[_selectedPractice!.flow] ?? Colors.grey;
  }

  Color _getOrganColor() {
    if (_selectedPractice == null) return Colors.grey[400]!;
    return HawkinsColors.organGradients[_selectedPractice!.organ]![0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F9E9),
              Color(0xFFEDF4E1),
              Color(0xFFE8F0D5),
              Color(0xFFF0F7E6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              const SizedBox(height: 6),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      // 2 Colunas: Categorias | Práticas
                      Expanded(
                        flex: 6,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildCategoriesPanel(),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: _buildPracticesPanel(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Card Inferior: Dimensões + Detalhe + Botão
                      _buildBottomCard(),

                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== APPBAR ==========
  Widget _buildAppBar2() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F0D5), Color(0xFFF5F9E9), Color(0xFFD4E8C2)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6B8E23).withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF6B8E23), Color(0xFF8B6914)]),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF6B8E23).withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: const Text('🌿', style: TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Ação Consciente',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4A5D23))),
            Text('Escolha com presença',
                style: GoogleFonts.lato(
                    fontSize: 10,
                    color: const Color(0xFF6B8E23).withOpacity(0.6),
                    fontStyle: FontStyle.italic)),
          ]),
        ),
        if (_selectedActivity != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0xFF6B8E23).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Text(_selectedActivity!.icon,
                style: const TextStyle(fontSize: 16)),
          ),
      ]),
    );
  }

  Widget _buildAppBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F0D5), Color(0xFFF5F9E9), Color(0xFFD4E8C2)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6B8E23).withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF6B8E23), Color(0xFF8B6914)]),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF6B8E23).withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: const Text('🌿', style: TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Ação Consciente',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4A5D23))),
            Text('Escolha com presença',
                style: GoogleFonts.lato(
                    fontSize: 10,
                    color: const Color(0xFF6B8E23).withOpacity(0.6),
                    fontStyle: FontStyle.italic)),
          ]),
        ),

        // 🔄 Botão de Onboarding
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OnboardingPremiumScreen(
                  onComplete: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B6914).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.replay_rounded,
                color: Color(0xFF8B6914), size: 18),
          ),
        ),

        const SizedBox(width: 6),

        // ⚙️ Botão de Customização
        GestureDetector(
          onTap: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => CustomizeScreen(
                        onActivitiesChanged: () => _loadCustomActivities())));
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xFF6B8E23).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.settings_rounded,
                color: Color(0xFF4A5D23), size: 20),
          ),
        ),

        const SizedBox(width: 6),

        if (_selectedActivity != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0xFF6B8E23).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Text(_selectedActivity!.icon,
                style: const TextStyle(fontSize: 16)),
          ),
      ]),
    );
  }

  // ========== PAINEL DE CATEGORIAS ==========
  Widget _buildCategoriesPanel() {
    final activities = _organizedActivities;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6B8E23).withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(children: [
              Text('🍃 CATEGORIAS',
                  style: GoogleFonts.lato(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey[500],
                      letterSpacing: 1.5)),
              const Spacer(),
              Text('${activities.length}',
                  style: GoogleFonts.lato(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6B8E23))),
            ]),
          ),
          const SizedBox(height: 4),
          Container(height: 0.5, color: Colors.grey[200]),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                final isSelected = _selectedActivity == activity;
                final color = isSelected
                    ? (HawkinsColors.energyColors[activity.energy] ??
                        const Color(0xFF6B8E23))
                    : Colors.grey;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedActivity = activity;
                      _selectedPractice = null;
                      _activityDetail = '';
                      _detailController.clear();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: isSelected
                              ? color.withOpacity(0.4)
                              : Colors.transparent,
                          width: isSelected ? 1.5 : 0),
                    ),
                    child: Row(children: [
                      // Ícone único: estrela/raio para todos
                      Text('✨',
                          style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? color : Colors.grey[400])),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(activity.group,
                            style: GoogleFonts.lato(
                              color: isSelected ? color : Colors.grey[700],
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (isSelected)
                        Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle)),
                    ]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ========== PAINEL DE PRÁTICAS ==========
  Widget _buildPracticesPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6B8E23).withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: _selectedActivity != null
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                child: Row(children: [
                  Text('✨ PRÁTICAS',
                      style: GoogleFonts.lato(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey[500],
                          letterSpacing: 1.5)),
                  const Spacer(),
                  Text(_selectedActivity!.icon,
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(_selectedActivity!.group,
                      style: GoogleFonts.lato(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B8E23))),
                ]),
              ),
              Container(height: 0.5, color: Colors.grey[200]),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _selectedActivity!.practices.length,
                  itemBuilder: (context, index) {
                    final practice = _selectedActivity!.practices[index];
                    final isSelected = _selectedPractice == practice;
                    final practiceColor =
                        HawkinsColors.energyColors[practice.energy] ??
                            Colors.grey;
                    final flowColor =
                        HawkinsColors.flowGradient[practice.flow] ??
                            Colors.grey;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedPractice = practice),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? practiceColor.withOpacity(0.06)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: isSelected
                                  ? practiceColor.withOpacity(0.3)
                                  : Colors.grey[100]!,
                              width: isSelected ? 1.5 : 1),
                        ),
                        child: Row(children: [
                          Container(
                              width: 3,
                              height: 28,
                              decoration: BoxDecoration(
                                  color: practiceColor,
                                  borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(practice.name,
                                    style: GoogleFonts.lato(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      fontSize: 14, // ← era 12
                                      color: const Color(0xFF2D3436),
                                    )),
                                const SizedBox(height: 3),
                                Row(children: [
                                  _miniTag(
                                      practice.energy == 'Ativa'
                                          ? '⚡ Ativa'
                                          : '🍃 Passiva',
                                      practiceColor),
                                  const SizedBox(width: 4),
                                  _miniTag(
                                      _flowLabel(practice.flow), flowColor),
                                ]),
                              ])),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded,
                                size: 18, color: practiceColor),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ])
          : Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🌿',
                        style: TextStyle(
                            fontSize: 40,
                            color: const Color(0xFF6B8E23).withOpacity(0.2))),
                    const SizedBox(height: 10),
                    Text('Escolha uma\ncategoria ao lado',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                            fontSize: 12,
                            color: Colors.grey[400],
                            height: 1.4)),
                  ]),
            ),
    );
  }

  String _flowLabel(String flow) {
    if (flow.contains('Difícil')) return '🔥 Difícil';
    if (flow.contains('Fácil')) return '🌊 Fácil';
    return '⚡ Médio';
  }

  Widget _miniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6)),
      child: Text(text,
          style: GoogleFonts.lato(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600)), // ← era 8
    );
  }

  // ========== CARD INFERIOR ==========
  Widget _buildBottomCard() {
    final hasPractice = _selectedPractice != null;
    final energyColor = _getPracticeColor();
    final flowColor = _getFlowColor();
    final organColor = _getOrganColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasPractice
              ? energyColor.withOpacity(0.3)
              : const Color(0xFFA8C686).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: hasPractice
                ? energyColor.withOpacity(0.06)
                : const Color(0xFF6B8E23).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // LINHA 1: Ícones das dimensões
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (hasPractice) ...[
                _dimensionItem(
                    _selectedPractice!.energy == 'Ativa' ? '⚡' : '🍃',
                    _selectedPractice!.energy,
                    energyColor),
                _dimensionItem('🔄', _selectedPractice!.flow, flowColor),
                _dimensionItem(
                  _selectedPractice!.organ == 'Mente'
                      ? '🧠'
                      : _selectedPractice!.organ == 'Corpo'
                          ? '💪'
                          : '🧘',
                  _selectedPractice!.organ,
                  organColor,
                ),
              ] else ...[
                _dimensionItem('⚡', 'Energia', Colors.grey[300]!),
                _dimensionItem('🔄', 'Flow', Colors.grey[300]!),
                _dimensionItem('🧠', 'Foco', Colors.grey[300]!),
              ],
            ],
          ),

          const SizedBox(height: 10),

          // LINHA 2: Campo de detalhe (largura total)
          Container(
            height: 40,
            decoration: BoxDecoration(
              color:
                  hasPractice ? energyColor.withOpacity(0.04) : Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: hasPractice
                      ? energyColor.withOpacity(0.15)
                      : Colors.grey[200]!),
            ),
            child: TextField(
              controller: _detailController,
              onChanged: (v) => _activityDetail = v,
              style: GoogleFonts.lato(
                  fontSize: 13, color: const Color(0xFF2D3436)),
              decoration: InputDecoration(
                hintText: 'Detalhe: nome do livro, local, intensidade...',
                hintStyle:
                    GoogleFonts.lato(fontSize: 12, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                suffixIcon: _activityDetail.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _detailController.clear();
                          setState(() => _activityDetail = '');
                        },
                        child: Icon(Icons.close_rounded,
                            size: 16, color: Colors.grey[400]),
                      )
                    : null,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // LINHA 3: Botão
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _dimensionItem(String icon, String value, Color color) {
    final isPlaceholder = color == Colors.grey[300];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 6),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isPlaceholder ? Colors.grey[400]! : color,
          ),
        ),
      ],
    );
  }

  Widget _bigDimensionItem({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isPlaceholder = color == Colors.grey[300];

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isPlaceholder ? Colors.grey[100] : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color:
                    isPlaceholder ? Colors.grey[200]! : color.withOpacity(0.25),
                width: 1.5),
          ),
          child: Center(
            child: Text(icon, style: TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.lato(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500]),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isPlaceholder ? Colors.grey[400]! : color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _dimensionChip(String icon, String value, Color color) {
    return Container(
      width: 52,
      height: 42,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(icon,
            style: TextStyle(fontSize: color == Colors.grey[300] ? 12 : 14)),
        Text(value,
            style: GoogleFonts.lato(
                fontSize: 8, fontWeight: FontWeight.w600, color: color),
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _buildActionButton() {
    final isEnabled = _selectedActivity != null && _selectedPractice != null;
    final Color buttonColor;
    final Color flowColor;

    if (isEnabled) {
      buttonColor = HawkinsColors.energyColors[_selectedPractice!.energy] ??
          const Color(0xFF6B8E23);
      flowColor = HawkinsColors.flowGradient[_selectedPractice!.flow] ??
          const Color(0xFF8B6914);
    } else {
      buttonColor = Colors.grey[300]!;
      flowColor = Colors.grey[350]!;
    }

    return GestureDetector(
      onTap: isEnabled ? _startActivity : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [buttonColor, flowColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                      color: buttonColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 5))
                ]
              : [],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.auto_awesome_rounded,
              color: isEnabled ? Colors.white : Colors.grey[400], size: 18),
          const SizedBox(width: 6),
          Text(
            isEnabled ? 'INICIAR PRÁTICA' : 'SELECIONE UMA PRÁTICA',
            style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isEnabled ? Colors.white : Colors.grey[400],
                letterSpacing: 1.5),
          ),
        ]),
      ),
    );
  }
}
