import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:life_compass/data/custom_activities.dart';
import 'package:life_compass/data/practice.dart';
import 'package:life_compass/models/activity_log.dart';
import 'package:life_compass/screens/customize_screen.dart';
import '../data/activities.dart';
import '../data/colors.dart';
import '../widgets/compass.dart';
import 'timer_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(dynamic) onStartActivity;
  final List<ActivityLog> logs;

  const HomeScreen({
    super.key,
    required this.onStartActivity,
    required this.logs,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Activity? _selectedActivity;
  String? _selectedExample;
  bool _isCompassRotating = false;

  String _backgroundTheme = 'tree'; // 'hawkins', 'tree'

  List<Activity> _allActivities = Activity.activities;

  @override
  void initState() {
    super.initState();
    _loadCustomActivities();
  }

  Future<void> _loadCustomActivities() async {
    final activities = await CustomActivitiesManager.loadActivities();
    if (mounted) {
      setState(() {
        _allActivities = activities;
      });
    }
  }

  // Lista organizada: Passiva primeiro, Ativa depois
  List<Activity> get _organizedActivities {
    final passivas =
        _allActivities.where((a) => a.energy == 'Passiva').toList();
    final ativas = _allActivities.where((a) => a.energy == 'Ativa').toList();
    return [...passivas, ...ativas];
  }

  // Cor do botão baseada na energia
  Color _getCategoryColor(Activity activity) {
    if (_selectedActivity == activity) {
      return HawkinsColors.energyColors[activity.energy] ?? Colors.grey;
    }
    // Cor suave baseada na energia mesmo quando não selecionado
    final baseColor =
        HawkinsColors.energyColors[activity.energy] ?? Colors.grey;
    return baseColor.withOpacity(0.08);
  }

  Color _getCategoryTextColor(Activity activity) {
    if (_selectedActivity == activity) {
      return Colors.white;
    }
    return HawkinsColors.energyColors[activity.energy] ?? Colors.grey[600]!;
  }

  Color _getCategoryBorderColor(Activity activity) {
    if (_selectedActivity == activity) {
      return HawkinsColors.energyColors[activity.energy] ?? Colors.grey;
    }
    final baseColor =
        HawkinsColors.energyColors[activity.energy] ?? Colors.grey;
    return baseColor.withOpacity(0.2);
  }

  void _startActivity() async {
    if (_selectedActivity != null && _selectedExample != null) {
      final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => TimerScreen(
            group: _selectedActivity!.group,
            example: _selectedExample!,
            energy: _selectedActivity!.energy,
            flow: _selectedActivity!.flow,
            organ: _selectedActivity!.organ,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );

      widget.onStartActivity(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedActivity == null
                ? 'Selecione uma categoria!'
                : 'Escolha um exemplo!',
          ),
          backgroundColor: Colors.orange[700],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Color _getEnergyColor() {
    final practice = _selectedPractice;
    if (practice == null) return Colors.grey[400]!;
    return HawkinsColors.energyColors[practice.energy] ?? Colors.grey;
  }

  Color _getFlowColor() {
    final practice = _selectedPractice;
    if (practice == null) return Colors.grey[400]!;
    return HawkinsColors.flowGradient[practice.flow] ?? Colors.grey;
  }

  Color _getOrganColor() {
    final practice = _selectedPractice;
    if (practice == null) return Colors.grey[400]!;
    return HawkinsColors.organGradients[practice.organ]![0];
  }

  Practice? get _selectedPractice {
    if (_selectedActivity == null || _selectedExample == null) return null;
    return _selectedActivity!.practices.firstWhere(
      (p) => p.name == _selectedExample,
    );
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
            Color(0xFFE8F0D5),
            Color(0xFFF0F7E6),
            Color(0xFFD4E8C2),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildCompactAppBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    const SizedBox(height: 6),

                    // Bússola + Categorias (com scroll na lista)
                    Expanded(
                      flex: 5,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bússola
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: CompassWidget(
                                selectedActivity: _selectedActivity,
                                isRotating: _isCompassRotating,
                                backgroundTheme: _backgroundTheme,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Categorias com scroll
                          Expanded(
                            flex: 2,
                            child: _buildCompactCategories(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Como Praticar + Dimensões + Botão
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildCompactExamples(),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            flex: 2,
                            child: _buildCompactDimensions(),
                          ),
                          const SizedBox(height: 6),
                          _buildCompactStartButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildCompactAppBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        // Fundo com gradiente orgânico (tons de verde e marrom suave)
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8F0D5), // Verde-amarelado claro
            Color(0xFFF5F9E9), // Verde muito claro
            Color(0xFFD4E8C2), // Verde médio claro
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFA8C686).withOpacity(0.5), // Verde médio
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF6B8E23).withOpacity(0.1), // Verde oliva suave
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícone da árvore no lugar do explorar
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6B8E23), // Verde oliva
                  Color(0xFF8B6914), // Marrom ocre
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B8E23).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Text('🌳', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bússola Vital',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A5D23), // Verde escuro
                ),
              ),
              Text(
                '🌿 Conexão com a natureza',
                style: GoogleFonts.lato(
                  fontSize: 9,
                  color: const Color(0xFF6B8E23).withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded,
                color: Color(0xFF4A5D23), size: 20),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomizeScreen(
                    onActivitiesChanged: () {
                      // Recarrega a lista de atividades
                      _loadCustomActivities();
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCategories() {
    final activities = _organizedActivities;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho fixo
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Row(
              children: [
                Icon(Icons.category_rounded,
                    size: 11,
                    color: _selectedActivity != null
                        ? const Color(0xFF6B8E23)
                        : Colors.grey[400]),
                const SizedBox(width: 3),
                Text('CATEGORIAS',
                    style: GoogleFonts.lato(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey[500],
                        letterSpacing: 1.5)),
                const Spacer(),
                Text('${activities.length}',
                    style: GoogleFonts.lato(
                        fontSize: 8,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Legenda compacta
          Row(
            children: [
              _buildLegendDot(const Color(0xFF4ECDC4)),
              const SizedBox(width: 2),
              Text('P',
                  style:
                      GoogleFonts.lato(fontSize: 7, color: Colors.grey[400])),
              const SizedBox(width: 6),
              _buildLegendDot(const Color(0xFFFF6B35)),
              const SizedBox(width: 2),
              Text('A',
                  style:
                      GoogleFonts.lato(fontSize: 7, color: Colors.grey[400])),
            ],
          ),

          const SizedBox(height: 2),

          // Divisor
          Container(height: 0.5, color: Colors.grey[300]),

          const SizedBox(height: 2),

          // Lista SCROLLABLE
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                final isSelected = _selectedActivity == activity;
                final bgColor = _getCategoryColor(activity);
                final textColor = _getCategoryTextColor(activity);
                final borderColor = _getCategoryBorderColor(activity);
                final energyIcon = activity.energy == 'Ativa' ? '⚡' : '🍃';

                // Mostra divisor entre passiva e ativa
                final showDivider = index > 0 &&
                    activities[index].energy != activities[index - 1].energy;

                return Column(
                  children: [
                    if (showDivider)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 4),
                        child: Container(height: 0.5, color: Colors.grey[300]),
                      ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedActivity = activity;
                          _selectedExample = null;
                          _isCompassRotating = true;
                        });
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted)
                            setState(() => _isCompassRotating = false);
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 5),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: borderColor,
                              width: isSelected ? 1.5 : 0.8),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: borderColor.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2))
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Text(energyIcon,
                                style: const TextStyle(fontSize: 10)),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                activity.group,
                                style: GoogleFonts.lato(
                                    color: textColor,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    fontSize: 9),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded,
                                  size: 12, color: textColor),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // COMO PRATICAR - sempre visível
  Widget _buildCompactExamples() {
    final hasActivity = _selectedActivity != null;
    final color = _getFlowColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedExample != null
              ? color.withOpacity(0.5)
              : Colors.white.withOpacity(0.5),
        ),
        boxShadow: _selectedExample != null
            ? [
                BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.auto_awesome_rounded,
                size: 12,
                color: _selectedExample != null ? color : Colors.grey[400]),
            const SizedBox(width: 4),
            Text('COMO PRATICAR?',
                style: GoogleFonts.lato(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey[500],
                    letterSpacing: 1.5)),
          ]),
          const SizedBox(height: 6),
          Expanded(
            child: hasActivity
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _selectedActivity!.practices.map((practice) {
                        final isSelected = _selectedExample == practice.name;
                        // Cada prática tem sua própria cor
                        final practiceColor =
                            HawkinsColors.energyColors[practice.energy] ??
                                Colors.grey;

                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedExample = practice.name),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? practiceColor.withOpacity(0.15)
                                  : Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: isSelected
                                      ? practiceColor
                                      : Colors.white.withOpacity(0.6),
                                  width: isSelected ? 1.5 : 0.5),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(practice.name,
                                    style: GoogleFonts.lato(
                                        color: isSelected
                                            ? practiceColor
                                            : Colors.grey[600],
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        fontSize: 12)),
                                const SizedBox(height: 2),
                                Row(mainAxisSize: MainAxisSize.min, children: [
                                  Text(practice.energy == 'Ativa' ? '⚡' : '🍃',
                                      style: const TextStyle(fontSize: 8)),
                                  const SizedBox(width: 2),
                                  _flowDot(practice.flow),
                                ]),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app_rounded,
                              size: 24, color: Colors.grey[300]),
                          const SizedBox(height: 4),
                          Text(
                              'Escolha uma categoria ao lado\npara ver as opções de prática',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                  fontSize: 10,
                                  color: Colors.grey[400],
                                  height: 1.4)),
                        ]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _flowDot(String flow) {
    Color color;
    switch (flow) {
      case 'Fácil':
        color = const Color(0xFF4CAF50);
        break;
      case 'Fácil – Médio':
        color = const Color(0xFF8BC34A);
        break;
      case 'Médio':
        color = const Color(0xFFFFEB3B);
        break;
      case 'Médio – Difícil':
        color = const Color(0xFFFF9800);
        break;
      case 'Difícil':
        color = const Color(0xFFF44336);
        break;
      default:
        color = Colors.grey;
    }
    return Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }

  // DIMENSÕES - sempre visível
  Widget _buildCompactDimensions() {
    final practice = _selectedPractice;
    final hasActivity = _selectedActivity != null;
    final hasExample = _selectedExample != null;

    final energyColor = _getEnergyColor();
    final flowColor = _getFlowColor();
    final organColor = _getOrganColor();

    // Valores da PRÁTICA (não da categoria)
    final energyValue = practice?.energy ?? '???';
    final flowValue = practice?.flow ?? '???';
    final organValue = practice?.organ ?? '???';

    final energyIcon =
        practice != null ? (practice.energy == 'Ativa' ? '⚡' : '🍃') : '⚡';

    final organIcon = practice != null
        ? (practice.organ == 'Mente'
            ? '🧠'
            : practice.organ == 'Corpo'
                ? '💪'
                : '🧘')
        : '🧠';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasExample
              ? energyColor.withOpacity(0.5)
              : Colors.white.withOpacity(0.5),
        ),
        boxShadow: hasExample
            ? [
                BoxShadow(
                    color: energyColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.analytics_rounded,
                size: 12, color: hasExample ? energyColor : Colors.grey[400]),
            const SizedBox(width: 4),
            Text('DIMENSÕES',
                style: GoogleFonts.lato(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey[500],
                    letterSpacing: 1.5)),
          ]),
          const SizedBox(height: 6),
          Expanded(
            child: hasActivity
                ? Row(children: [
                    _buildDimChip(
                        energyIcon, energyValue, energyColor, hasExample),
                    const SizedBox(width: 4),
                    _buildDimChip('🔄', flowValue, flowColor, hasExample),
                    const SizedBox(width: 4),
                    _buildDimChip(
                        organIcon, organValue, organColor, hasExample),
                  ])
                : Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDimChip(
                              '⚡', 'Energia', Colors.grey[300]!, false),
                          const SizedBox(width: 4),
                          _buildDimChip('🔄', 'Flow', Colors.grey[300]!, false),
                          const SizedBox(width: 4),
                          _buildDimChip('🧠', 'Foco', Colors.grey[300]!, false),
                        ]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimChip(String icon, String value, Color color, bool active) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: active
              ? color.withOpacity(0.1)
              : Colors.grey[50]!.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? color.withOpacity(0.3) : Colors.grey[200]!,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: TextStyle(
                fontSize: active ? 20 : 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.lato(
                fontSize: 9,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: active ? color : Colors.grey[400],
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStartButton() {
    final isEnabled = _selectedActivity != null && _selectedExample != null;
    final energyColor = _getEnergyColor();

    return GestureDetector(
      onTap: isEnabled ? _startActivity : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isEnabled
              ? LinearGradient(
                  colors: [energyColor, _getFlowColor()],
                )
              : LinearGradient(
                  colors: [Colors.grey[300]!, Colors.grey[350]!],
                ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: energyColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_arrow_rounded,
              color: isEnabled ? Colors.white : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(width: 6),
            Text(
              'INICIAR',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isEnabled ? Colors.white : Colors.grey[400],
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
