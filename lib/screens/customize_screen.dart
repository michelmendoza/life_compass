import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/activities.dart';
import '../data/colors.dart';
import '../data/custom_activities.dart';
import '../data/practice.dart';
import 'dialogs/category_form_dialog.dart';
import 'dialogs/practice_form_sheet.dart';

class CustomizeScreen extends StatefulWidget {
  final VoidCallback onActivitiesChanged;

  const CustomizeScreen({super.key, required this.onActivitiesChanged});

  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> {
  List<Activity> _allActivities = [];
  List<Map<String, dynamic>> _customData = [];
  bool _loading = true;

  // Lista fixa das 9 categorias padrão
  final List<Activity> _defaultActivities = Activity.activities;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final activities = await CustomActivitiesManager.loadActivities();
    final custom = await CustomActivitiesManager.getCustomActivities();
    if (mounted) {
      setState(() {
        _allActivities = activities;
        _customData = custom;
        _loading = false;
      });
    }
  }

  /// Separa customizadas das padrão
  List<Activity> get _customActivities {
    final customNames = _customData.map((c) => c['group'] as String).toSet();
    return _allActivities.where((a) => customNames.contains(a.group)).toList();
  }

  /// Apenas as padrão originais (não modificadas)
  List<Activity> get _defaultOnly {
    final customNames = _customData.map((c) => c['group'] as String).toSet();
    return _defaultActivities
        .where((a) => !customNames.contains(a.group))
        .toList();
  }

  int _getCustomIndex(Activity activity) {
    return _customData.indexWhere((c) => c['group'] == activity.group);
  }

  // ========== AÇÕES ==========

  void _addNewCategory() {
    showDialog(
      context: context,
      builder: (_) => CategoryFormDialog(onSave: (activity) async {
        await CustomActivitiesManager.addCustomActivity(activity);
        await _loadData();
        widget.onActivitiesChanged();
      }),
    );
  }

  void _editCategory(Activity activity) {
    final index = _getCustomIndex(activity);
    if (index < 0) return;
    final data = _customData[index];
    showDialog(
      context: context,
      builder: (_) => CategoryFormDialog(
        initialData: data,
        onSave: (updated) async {
          await CustomActivitiesManager.updateCustomActivity(index, updated);
          await _loadData();
          widget.onActivitiesChanged();
        },
      ),
    );
  }

  void _deleteCategory(Activity activity) {
    final index = _getCustomIndex(activity);
    if (index < 0) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF8F9FA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title:
            Text('Remover?', style: GoogleFonts.playfairDisplay(fontSize: 16)),
        content: Text('A categoria "${activity.group}" será removida.',
            style: GoogleFonts.lato(fontSize: 13, color: Colors.grey[600])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.red[400]!, Colors.red[300]!]),
                borderRadius: BorderRadius.circular(10)),
            child: TextButton(
                onPressed: () async {
                  await CustomActivitiesManager.removeCustomActivity(index);
                  await _loadData();
                  widget.onActivitiesChanged();
                  Navigator.pop(ctx);
                },
                child: const Text('Remover',
                    style: TextStyle(color: Colors.white))),
          ),
        ],
      ),
    );
  }

  void _addPractice(Activity activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PracticeFormSheet(
        categoryName: activity.group,
        categoryIcon: activity.icon,
        onSave: (practice) async {
          final updated = List<Practice>.from(activity.practices)
            ..add(practice);
          final updatedActivity = Activity(
              group: activity.group, icon: activity.icon, practices: updated);

          final existingIndex =
              _customData.indexWhere((c) => c['group'] == activity.group);
          if (existingIndex >= 0) {
            await CustomActivitiesManager.updateCustomActivity(
                existingIndex, updatedActivity);
          } else {
            await CustomActivitiesManager.addCustomActivity(updatedActivity);
          }
          await _loadData();
          widget.onActivitiesChanged();
        },
      ),
    );
  }

  // ========== BUILD ==========

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(0xFFF5F9E9),
            Color(0xFFE8F0D5),
            Color(0xFFF0F7E6),
            Color(0xFFD4E8C2)
          ]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ===== MINHAS CATEGORIAS =====
                    _sectionHeader('✨ MINHAS CATEGORIAS', 'Nova Categoria',
                        _addNewCategory),
                    const SizedBox(height: 8),
                    if (_customActivities.isEmpty)
                      _emptyCard(
                          'Nenhuma categoria personalizada.\nToque em "Nova Categoria" para criar!')
                    else
                      ..._customActivities
                          .map((a) => _buildCard(a, isCustom: true)),

                    const SizedBox(height: 24),

                    // ===== CATEGORIAS PADRÃO =====
                    _sectionHeader('📦 CATEGORIAS PADRÃO', null, null),
                    const SizedBox(height: 8),
                    ..._defaultOnly.map((a) => _buildCard(a, isCustom: false)),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String? buttonText, VoidCallback? onTap) {
    return Row(children: [
      Text(title,
          style: GoogleFonts.lato(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.grey[600],
              letterSpacing: 1.5)),
      const Spacer(),
      if (buttonText != null && onTap != null)
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF6B8E23), Color(0xFF8B6914)]),
                borderRadius: BorderRadius.circular(15)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(buttonText,
                  style: GoogleFonts.lato(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
            ]),
          ),
        ),
    ]);
  }

  Widget _emptyCard(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.3))),
      child: Center(
          child: Text(text,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                  fontSize: 12, color: Colors.grey[400], height: 1.5))),
    );
  }

  Widget _buildCard(Activity activity, {required bool isCustom}) {
    final practice =
        activity.practices.isNotEmpty ? activity.practices.first : null;
    final color = practice != null
        ? (HawkinsColors.energyColors[practice.energy] ?? Colors.grey)
        : Colors.grey;
    final flowColor = practice != null
        ? (HawkinsColors.flowGradient[practice.flow] ?? Colors.grey)
        : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.3)),
      ),
      child: Column(children: [
        // Card principal
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(colors: [color, flowColor]))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Text(activity.icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(activity.group,
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: const Color(0xFF2D3436))),
                  ]),
                  const SizedBox(height: 4),
                  Text('${activity.practices.length} prática(s)',
                      style: GoogleFonts.lato(
                          fontSize: 10, color: Colors.grey[500])),
                ])),
            // 🔥 EDITAR sempre disponível (padrão ou customizada)
            GestureDetector(
              onTap: () {
                if (isCustom) {
                  _editCategory(activity);
                } else {
                  _editDefaultCategory(activity);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: const Color(0xFF6B8E23).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.edit_rounded,
                    size: 16, color: Color(0xFF6B8E23)),
              ),
            ),
            // 🔥 DELETAR só nas customizadas
            if (isCustom) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _deleteCategory(activity),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.delete_outline_rounded,
                      size: 16, color: Colors.red),
                ),
              ),
            ],
          ]),
        ),
        // Empty state quando não há práticas
        if (activity.practices.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.07),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
              border: Border(
                  top: BorderSide(color: Colors.amber.withOpacity(0.3))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 13, color: Colors.amber[700]),
                const SizedBox(width: 6),
                Text('Nenhuma prática — toque em + para adicionar',
                    style: GoogleFonts.lato(
                        fontSize: 11,
                        color: Colors.amber[800],
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        // Botão + Prática
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF6B8E23).withOpacity(0.03),
            borderRadius: activity.practices.isEmpty
                ? BorderRadius.zero
                : const BorderRadius.vertical(bottom: Radius.circular(16)),
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
          ),
          child: GestureDetector(
            onTap: () => _addPractice(activity),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.add_rounded,
                    size: 15, color: Color(0xFF6B8E23)),
                const SizedBox(width: 5),
                Text('Adicionar prática',
                    style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B8E23))),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  void _editDefaultCategory(Activity activity) {
    // Abre o formulário com os dados da categoria padrão
    showDialog(
      context: context,
      builder: (_) => CategoryFormDialog(
        initialData: {
          'group': activity.group,
          'icon': activity.icon,
          'practices': activity.practices
              .map((p) => {
                    'name': p.name,
                    'energy': p.energy,
                    'flow': p.flow,
                    'organ': p.organ,
                  })
              .toList(),
        },
        onSave: (updated) async {
          // Salva como customizada (substitui a padrão)
          final existingIndex =
              _customData.indexWhere((c) => c['group'] == activity.group);
          if (existingIndex >= 0) {
            await CustomActivitiesManager.updateCustomActivity(
                existingIndex, updated);
          } else {
            await CustomActivitiesManager.addCustomActivity(updated);
          }
          await _loadData();
          widget.onActivitiesChanged();
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [
            Color(0xFFE8F0D5),
            Color(0xFFF5F9E9),
            Color(0xFFD4E8C2)
          ]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA8C686).withOpacity(0.5))),
      child: Row(children: [
        GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: const Color(0xFF6B8E23).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Color(0xFF6B8E23), size: 20))),
        const SizedBox(width: 10),
        Text('Categorias',
            style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A5D23))),
        const Spacer(),
        GestureDetector(
          onTap: () async {
            await CustomActivitiesManager.resetToDefault();
            await _loadData();
            widget.onActivitiesChanged();
          },
          child: Text('Reset',
              style: GoogleFonts.lato(
                  fontSize: 11,
                  color: Colors.red[400],
                  fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

