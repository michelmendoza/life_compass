import 'practice.dart';

class Activity {
  final String group;
  final String icon; // emoji da categoria
  final List<Practice> practices;

  const Activity({
    required this.group,
    required this.icon,
    required this.practices,
  });

  // Tempo ideal em minutos para UPs
  static const Map<String, int> tempoIdeal = {
    'Espiritualidade': 20,
    'Aprendizado': 60,
    'Trabalho': 240,
    'Saúde': 45,
    'Lazer': 60,
    'Social': 90,
    'Criação': 120,
    'Natureza': 45,
    'Autocuidado': 30,
  };

  // Energia predominante (para cor da categoria)
  String get energy {
    final ativas = practices.where((p) => p.energy == 'Ativa').length;
    final passivas = practices.where((p) => p.energy == 'Passiva').length;
    return ativas >= passivas ? 'Ativa' : 'Passiva';
  }

  // Flow predominante
  String get flow {
    final pesos = {
      'Fácil': 1,
      'Fácil – Médio': 2,
      'Médio': 3,
      'Médio – Difícil': 4,
      'Difícil': 5
    };
    double soma = 0;
    for (final p in practices) {
      soma += pesos[p.flow] ?? 3;
    }
    final media = soma / practices.length;
    if (media <= 1.5) return 'Fácil';
    if (media <= 2.5) return 'Fácil – Médio';
    if (media <= 3.5) return 'Médio';
    if (media <= 4.5) return 'Médio – Difícil';
    return 'Difícil';
  }

  // Órgão predominante
  String get organ {
    final counts = <String, int>{};
    for (final p in practices) {
      counts[p.organ] = (counts[p.organ] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static const List<Activity> activities = [
    Activity(
      group: 'Espiritualidade',
      icon: '🧘',
      practices: [
        Practice(
            name: 'Meditar', energy: 'Passiva', flow: 'Fácil', organ: 'Mente'),
        Practice(
            name: 'Orar', energy: 'Passiva', flow: 'Fácil', organ: 'Mente'),
        Practice(
            name: 'Não fazer nada',
            energy: 'Passiva',
            flow: 'Fácil',
            organ: 'Mente'),
        Practice(
            name: 'Jejum',
            energy: 'Passiva',
            flow: 'Difícil',
            organ: 'Corpo/Mente'),
        Practice(
            name: 'Retiro espiritual',
            energy: 'Passiva',
            flow: 'Médio – Difícil',
            organ: 'Mente'),
      ],
    ),
    Activity(
      group: 'Aprendizado',
      icon: '📚',
      practices: [
        Practice(
            name: 'Estudar',
            energy: 'Ativa',
            flow: 'Médio – Difícil',
            organ: 'Mente'),
        Practice(
            name: 'Ler',
            energy: 'Ativa',
            flow: 'Fácil – Médio',
            organ: 'Mente'),
        Practice(
            name: 'Planejar', energy: 'Ativa', flow: 'Médio', organ: 'Mente'),
        Practice(
            name: 'Curso online',
            energy: 'Ativa',
            flow: 'Médio',
            organ: 'Mente'),
        Practice(
            name: 'Podcast educativo',
            energy: 'Passiva',
            flow: 'Fácil',
            organ: 'Mente'),
        Practice(
            name: 'Ouvir audiolivro',
            energy: 'Passiva',
            flow: 'Fácil',
            organ: 'Mente'),
      ],
    ),
    Activity(
      group: 'Trabalho',
      icon: '💼',
      practices: [
        Practice(
            name: 'Trabalho remunerado',
            energy: 'Ativa',
            flow: 'Médio – Difícil',
            organ: 'Mente'),
        Practice(
            name: 'Organizar tarefas',
            energy: 'Ativa',
            flow: 'Médio',
            organ: 'Mente'),
        Practice(
            name: 'Reunião', energy: 'Ativa', flow: 'Médio', organ: 'Mente'),
        Practice(
            name: 'Apresentação',
            energy: 'Ativa',
            flow: 'Difícil',
            organ: 'Mente'),
        Practice(
            name: 'Planejamento',
            energy: 'Ativa',
            flow: 'Médio',
            organ: 'Mente'),
      ],
    ),
    Activity(
      group: 'Saúde',
      icon: '💪',
      practices: [
        Practice(
            name: 'HIIT', energy: 'Ativa', flow: 'Difícil', organ: 'Corpo'),
        Practice(
            name: 'Caminhar', energy: 'Ativa', flow: 'Fácil', organ: 'Corpo'),
        Practice(
            name: 'Correr', energy: 'Ativa', flow: 'Médio', organ: 'Corpo'),
        Practice(
            name: 'Macaquear',
            energy: 'Ativa',
            flow: 'Fácil – Médio',
            organ: 'Corpo'),
        Practice(
            name: 'Massagem', energy: 'Passiva', flow: 'Fácil', organ: 'Corpo'),
        Practice(
            name: 'Consulta médica',
            energy: 'Passiva',
            flow: 'Médio',
            organ: 'Corpo/Mente'),
        Practice(
            name: 'Yoga',
            energy: 'Passiva',
            flow: 'Médio',
            organ: 'Corpo/Mente'),
        Practice(
            name: 'Alongamento',
            energy: 'Passiva',
            flow: 'Fácil',
            organ: 'Corpo'),
      ],
    ),
    Activity(
      group: 'Lazer',
      icon: '🎮',
      practices: [
        Practice(
            name: 'Jogar',
            energy: 'Ativa',
            flow: 'Fácil – Médio',
            organ: 'Corpo/Mente'),
        Practice(
            name: 'Assistir', energy: 'Passiva', flow: 'Fácil', organ: 'Mente'),
        Practice(
            name: 'Música',
            energy: 'Ativa',
            flow: 'Fácil – Médio',
            organ: 'Corpo/Mente'),
        Practice(
            name: 'Malabares',
            energy: 'Ativa',
            flow: 'Médio',
            organ: 'Corpo/Mente'),
        Practice(
            name: 'Dançar', energy: 'Ativa', flow: 'Médio', organ: 'Corpo'),
      ],
    ),
    Activity(
      group: 'Social',
      icon: '🗣️',
      practices: [
        Practice(
            name: 'Conversar', energy: 'Ativa', flow: 'Fácil', organ: 'Mente'),
        Practice(name: 'Bar', energy: 'Ativa', flow: 'Fácil', organ: 'Mente'),
        Practice(name: 'Chat', energy: 'Ativa', flow: 'Fácil', organ: 'Mente'),
        Practice(
            name: 'Ligar para amigo',
            energy: 'Ativa',
            flow: 'Fácil',
            organ: 'Mente'),
        Practice(
            name: 'Evento social',
            energy: 'Ativa',
            flow: 'Médio',
            organ: 'Mente'),
      ],
    ),
    Activity(
      group: 'Criação',
      icon: '🎨',
      practices: [
        Practice(
            name: 'Escrever',
            energy: 'Ativa',
            flow: 'Médio – Difícil',
            organ: 'Mente'),
        Practice(
            name: 'Projetos pessoais',
            energy: 'Ativa',
            flow: 'Médio – Difícil',
            organ: 'Mente'),
        Practice(
            name: 'Desenhar',
            energy: 'Ativa',
            flow: 'Fácil – Médio',
            organ: 'Corpo/Mente'),
        Practice(
            name: 'Fotografar',
            energy: 'Ativa',
            flow: 'Fácil – Médio',
            organ: 'Corpo/Mente'),
        Practice(
            name: 'Cozinhar',
            energy: 'Ativa',
            flow: 'Médio',
            organ: 'Corpo/Mente'),
      ],
    ),
    Activity(
      group: 'Natureza',
      icon: '🌿',
      practices: [
        Practice(
            name: 'Contemplar paisagem',
            energy: 'Passiva',
            flow: 'Fácil',
            organ: 'Corpo/Mente'),
        Practice(
            name: 'Trilhas',
            energy: 'Ativa',
            flow: 'Médio',
            organ: 'Corpo/Mente'),
        Practice(
            name: 'Jardinagem',
            energy: 'Ativa',
            flow: 'Fácil – Médio',
            organ: 'Corpo'),
        Practice(
            name: 'Acampar',
            energy: 'Ativa',
            flow: 'Médio',
            organ: 'Corpo/Mente'),
      ],
    ),
    Activity(
      group: 'Autocuidado',
      icon: '🛁',
      practices: [
        Practice(
            name: 'Banho relaxante',
            energy: 'Passiva',
            flow: 'Fácil',
            organ: 'Corpo'),
        Practice(
            name: 'Respiração consciente',
            energy: 'Passiva',
            flow: 'Fácil',
            organ: 'Corpo'),
        Practice(
            name: 'Skin care',
            energy: 'Passiva',
            flow: 'Fácil',
            organ: 'Corpo'),
        Practice(
            name: 'Spa day', energy: 'Passiva', flow: 'Fácil', organ: 'Corpo'),
        Practice(
            name: 'Auto-massagem',
            energy: 'Passiva',
            flow: 'Fácil',
            organ: 'Corpo'),
      ],
    ),
  ];

  Map<String, dynamic> toJson() => {
        'group': group,
        'icon': icon,
        'practices': practices.map((p) => p.toJson()).toList(),
      };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        group: json['group'] as String,
        icon: json['icon'] as String,
        practices: (json['practices'] as List)
            .map((p) => Practice.fromJson(p))
            .toList(),
      );
}
