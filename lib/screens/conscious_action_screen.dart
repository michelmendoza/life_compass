import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:root_flow/data/custom_activities.dart';
import 'package:root_flow/data/practice.dart';
import 'package:root_flow/models/activity_log.dart';
import 'package:root_flow/screens/customize_screen.dart';
import '../data/activities.dart';
import '../data/colors.dart';
import '../l10n/app_localizations.dart';
import '../l10n/domain_translations.dart';
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

  void _startActivity(Practice practice) {
    if (_selectedActivity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).selectCategoryFirst),
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
              ? '${practice.name}: $_activityDetail'
              : practice.name,
          energy: practice.energy,
          flow: practice.flow,
          organ: practice.organ,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ).then((result) {
      if (result != null && result is ActivityLog) {
        widget.onStartActivity(result);
        setState(() {
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

  String _getCategoryDescription(Activity activity) =>
      DomainTranslations.categoryDesc(context, activity.group);

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
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Slider de Categorias
                      _buildCategoriesSlider(),

                      const SizedBox(height: 20),

                      // Card de Descrição da Categoria Selecionada
                      if (_selectedActivity != null)
                        _buildCategoryDescriptionCard(),

                      const SizedBox(height: 20),

                      // Título das Práticas
                      if (_selectedActivity != null) ...[
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context).availablePracticesLabel,
                              style: GoogleFonts.lato(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Colors.grey[500],
                                letterSpacing: 1.5,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6B8E23).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                AppLocalizations.of(context).practicesCount(_selectedActivity!.practices.length),
                                style: GoogleFonts.lato(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6B8E23),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Lista de Práticas em Cards
                      if (_selectedActivity != null) ..._buildPracticesList(),

                      if (_selectedActivity == null)
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    const Color(0xFFA8C686).withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '🌿',
                                style: TextStyle(
                                    fontSize: 60,
                                    color: const Color(0xFF6B8E23)
                                        .withOpacity(0.3)),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppLocalizations.of(context).selectCategoryHint,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6B8E23), Color(0xFF8B6914)],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B8E23).withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text('🌿', style: TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).consciousActionTitle,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A5D23),
                ),
              ),
              Text(
                AppLocalizations.of(context).consciousActionSubtitle,
                style: GoogleFonts.lato(
                  fontSize: 10,
                  color: const Color(0xFF6B8E23).withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CustomizeScreen(
                  onActivitiesChanged: () => _loadCustomActivities(),
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6B8E23).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.add_rounded,
                color: Color(0xFF4A5D23), size: 22),
          ),
        ),
      ]),
    );
  }

  // ========== SLIDER DE CATEGORIAS ==========
  Widget _buildCategoriesSlider() {
    final activities = _organizedActivities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            AppLocalizations.of(context).areaLabel,
            style: GoogleFonts.lato(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.grey[600],
              letterSpacing: 1.5,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              final isSelected = _selectedActivity == activity;
              final color = HawkinsColors.energyColors[activity.energy] ??
                  const Color(0xFF6B8E23);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedActivity = activity;
                    _selectedPractice = null;
                    _activityDetail = '';
                    _detailController.clear();
                  });
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withOpacity(0.15),
                              color.withOpacity(0.08),
                            ],
                          )
                        : null,
                    color: isSelected ? null : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? color.withOpacity(0.5)
                          : Colors.grey[200]!,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        activity.icon,
                        style: TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DomainTranslations.category(context, activity.group),
                        style: GoogleFonts.lato(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? color : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ========== CARD DE DESCRIÇÃO DA CATEGORIA ==========
  Widget _buildCategoryDescriptionCard() {
    final color = HawkinsColors.energyColors[_selectedActivity!.energy] ??
        const Color(0xFF6B8E23);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                _selectedActivity!.icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DomainTranslations.category(context, _selectedActivity!.group),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getCategoryDescription(_selectedActivity!),
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== LISTA DE PRÁTICAS ==========
  List<Widget> _buildPracticesList() {
    return _selectedActivity!.practices.asMap().entries.map((entry) {
      final practice = entry.value;
      final energyColor =
          HawkinsColors.energyColors[practice.energy] ?? Colors.grey;
      final flowColor =
          HawkinsColors.flowGradient[practice.flow] ?? Colors.grey;
      final organColor =
          HawkinsColors.organGradients[practice.organ]?[0] ?? Colors.grey;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildPracticeCard(practice, energyColor, flowColor, organColor),
      );
    }).toList();
  }

  // ========== CARD DE PRÁTICA ==========
  Widget _buildPracticeCard(
      Practice practice, Color energyColor, Color flowColor, Color organColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: energyColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do card com nome da prática
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  energyColor.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    practice.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3436),
                    ),
                  ),
                ),
                // Botão de iniciar prática no card
                ElevatedButton.icon(
                  onPressed: () => _startActivity(practice),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(
                    AppLocalizations.of(context).start,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: energyColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Informações da prática
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                _infoChip(
                  practice.energy == 'Ativa' ? '⚡' : '🍃',
                  DomainTranslations.energy(context, practice.energy),
                  energyColor,
                ),
                const SizedBox(width: 8),
                _infoChip(
                  practice.flow.contains('Difícil')
                      ? '🔥'
                      : (practice.flow.contains('Fácil') ? '🌊' : '⚡'),
                  DomainTranslations.flow(context, practice.flow),
                  flowColor,
                ),
                const SizedBox(width: 8),
                _infoChip(
                  switch (practice.organ) {
                    'Mente' => '🧠',
                    'Corpo' => '💪',
                    'Espírito' => '🙏',
                    _ => '🧘',
                  },
                  DomainTranslations.organ(context, practice.organ),
                  organColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
