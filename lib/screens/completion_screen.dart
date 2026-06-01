import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/timer/feedback_button.dart';

class CompletionScreen extends StatefulWidget {
  final String group;
  final String example;
  final String energy;
  final String flow;
  final String organ;
  final Duration duration;
  final Color energyColor;
  final Color flowColor;
  final Function(int?, String?) onSave;

  const CompletionScreen({
    super.key,
    required this.group,
    required this.example,
    required this.energy,
    required this.flow,
    required this.organ,
    required this.duration,
    required this.energyColor,
    required this.flowColor,
    required this.onSave,
  });

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen> {
  int? _consciousnessLevel;
  int? _difficultyLevel;

  String get _formattedDuration {
    final d = widget.duration;
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}min';
    if (m > 0) return '${m}min ${s}s';
    return '${s}s';
  }

  String? get _difficultyString {
    switch (_difficultyLevel) {
      case 0: return 'Fácil';
      case 1: return 'Médio';
      case 2: return 'Difícil';
      default: return null;
    }
  }

  String? get _consciousnessString {
    switch (_consciousnessLevel) {
      case 0: return 'Automático';
      case 1: return 'Presente';
      case 2: return 'Focado';
      case 3: return 'Fluindo';
      default: return null;
    }
  }

  Future<void> _shareResult() async {
    final text = '''
🏆 Completei minha atividade! 🏆

📋 ${widget.group}
⏱️ Duração: $_formattedDuration
${_consciousnessString != null ? '🧠 Estado: $_consciousnessString' : ''}
${_difficultyString != null ? '⚡ Dificuldade: $_difficultyString' : ''}

✨ "${widget.example}"

#HawkinsTracker #Produtividade #Mindfulness
    ''';
    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDragHandle(),
              _buildHeader(),
              _buildSummaryCard(),
              _buildPracticeChip(),
              const SizedBox(height: 16),
              _buildDivider(),
              const SizedBox(height: 16),
              _buildConsciousnessSection(),
              const SizedBox(height: 16),
              _buildDifficultySection(),
              const SizedBox(height: 20),
              _buildDivider(),
              const SizedBox(height: 12),
              _buildActionButtons(),
              TextButton(
                onPressed: () => widget.onSave(null, null),
                child: Text(
                  'Pular feedback',
                  style: GoogleFonts.lato(
                      fontSize: 10, color: Colors.grey[400]),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 16),
          child: const Text('🎉', style: TextStyle(fontSize: 48)),
        ),
        Text(
          'Atividade Concluída!',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: widget.energyColor,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Text('📋', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 2),
                Text('Categoria',
                    style: GoogleFonts.lato(
                        fontSize: 10, color: Colors.grey[500])),
                Text(
                  widget.group,
                  style: GoogleFonts.lato(
                      fontSize: 12, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          Expanded(
            child: Column(
              children: [
                const Text('⏱️', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 2),
                Text('Duração',
                    style: GoogleFonts.lato(
                        fontSize: 10, color: Colors.grey[500])),
                Text(
                  _formattedDuration,
                  style: GoogleFonts.lato(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeChip() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.energyColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('✨', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              widget.example,
              style: GoogleFonts.lato(
                  fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsciousnessSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Text(
            'Você estava consciente durante a prática?',
            style: GoogleFonts.lato(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FeedbackButton(
                emoji: '😴', label: 'Automático', value: 0,
                currentValue: _consciousnessLevel, color: widget.energyColor,
                onTap: () => setState(() => _consciousnessLevel =
                    _consciousnessLevel == 0 ? null : 0),
              ),
              FeedbackButton(
                emoji: '😐', label: 'Presente', value: 1,
                currentValue: _consciousnessLevel, color: widget.energyColor,
                onTap: () => setState(() => _consciousnessLevel =
                    _consciousnessLevel == 1 ? null : 1),
              ),
              FeedbackButton(
                emoji: '🔥', label: 'Focado', value: 2,
                currentValue: _consciousnessLevel, color: widget.energyColor,
                onTap: () => setState(() => _consciousnessLevel =
                    _consciousnessLevel == 2 ? null : 2),
              ),
              FeedbackButton(
                emoji: '✨', label: 'Fluindo', value: 3,
                currentValue: _consciousnessLevel, color: widget.energyColor,
                onTap: () => setState(() => _consciousnessLevel =
                    _consciousnessLevel == 3 ? null : 3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Text(
            'Nível de dificuldade?',
            style: GoogleFonts.lato(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FeedbackButton(
                emoji: '🌊', label: 'Fácil', value: 0,
                currentValue: _difficultyLevel, color: Colors.green,
                onTap: () => setState(() =>
                    _difficultyLevel = _difficultyLevel == 0 ? null : 0),
              ),
              FeedbackButton(
                emoji: '⚡', label: 'Médio', value: 1,
                currentValue: _difficultyLevel, color: Colors.orange,
                onTap: () => setState(() =>
                    _difficultyLevel = _difficultyLevel == 1 ? null : 1),
              ),
              FeedbackButton(
                emoji: '🔥', label: 'Difícil', value: 2,
                currentValue: _difficultyLevel, color: Colors.red,
                onTap: () => setState(() =>
                    _difficultyLevel = _difficultyLevel == 2 ? null : 2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _shareResult,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.share_rounded,
                        size: 16, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text(
                      'Compartilhar',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  widget.onSave(_consciousnessLevel, _difficultyString),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [widget.energyColor, widget.flowColor]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      'Finalizar',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
