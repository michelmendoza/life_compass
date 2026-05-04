import '../models/activity_log.dart';

class TestData {
  static List<ActivityLog> gerarDados() {
    final now = DateTime.now();
    final logs = <ActivityLog>[];

    // ========== ÚLTIMOS 14 DIAS ==========

    // Hoje (Terça)
    logs.addAll(_dia(now, [
      _atividade(
          'Trabalho', 'Organizar tarefas', 'Ativa', 'Difícil', 'Mente', 480),
      _atividade('Saúde', 'HIIT', 'Ativa', 'Médio – Difícil', 'Corpo', 45),
      _atividade('Espiritualidade', 'Meditar', 'Passiva', 'Fácil', 'Mente', 20),
      _atividade('Autocuidado', 'Respiração consciente', 'Passiva', 'Fácil',
          'Corpo', 15),
      _atividade(
          'Lazer', 'Música', 'Ativa', 'Fácil – Médio', 'Corpo/Mente', 30),
    ]));

    // Ontem (Segunda)
    logs.addAll(_dia(now.subtract(const Duration(days: 1)), [
      _atividade('Trabalho', 'Reunião de planejamento', 'Ativa', 'Médio',
          'Mente', 240),
      _atividade('Aprendizado', 'Estudar Flutter', 'Ativa', 'Médio – Difícil',
          'Mente', 120),
      _atividade('Saúde', 'Correr', 'Ativa', 'Médio', 'Corpo', 30),
      _atividade('Social', 'Almoço com equipe', 'Ativa', 'Fácil', 'Mente', 60),
      _atividade('Natureza', 'Caminhada no parque', 'Passiva', 'Fácil',
          'Corpo/Mente', 25),
    ]));

    // Domingo
    logs.addAll(_dia(now.subtract(const Duration(days: 2)), [
      _atividade('Espiritualidade', 'Meditar', 'Passiva', 'Fácil', 'Mente', 30),
      _atividade('Lazer', 'Jogar videogame', 'Ativa', 'Fácil – Médio',
          'Corpo/Mente', 120),
      _atividade('Social', 'Bar com amigos', 'Ativa', 'Fácil', 'Mente', 180),
      _atividade(
          'Autocuidado', 'Banho relaxante', 'Passiva', 'Fácil', 'Corpo', 30),
      _atividade('Natureza', 'Contemplar pôr do sol', 'Passiva', 'Fácil',
          'Corpo/Mente', 20),
    ]));

    // Sábado
    logs.addAll(_dia(now.subtract(const Duration(days: 3)), [
      _atividade('Saúde', 'Macaquear', 'Ativa', 'Fácil – Médio', 'Corpo', 20),
      _atividade('Lazer', 'Maratonar série', 'Ativa', 'Fácil', 'Mente', 240),
      _atividade('Criação', 'Projeto pessoal', 'Ativa', 'Médio – Difícil',
          'Mente', 180),
      _atividade(
          'Social', 'Videochamada família', 'Ativa', 'Fácil', 'Mente', 45),
      _atividade(
          'Natureza', 'Trilha na mata', 'Passiva', 'Médio', 'Corpo/Mente', 90),
    ]));

    // Sexta
    logs.addAll(_dia(now.subtract(const Duration(days: 4)), [
      _atividade(
          'Trabalho', 'Finalizar relatório', 'Ativa', 'Difícil', 'Mente', 360),
      _atividade('Saúde', 'HIIT', 'Ativa', 'Médio – Difícil', 'Corpo', 40),
      _atividade(
          'Aprendizado', 'Ler artigo técnico', 'Ativa', 'Médio', 'Mente', 30),
      _atividade(
          'Lazer', 'Tocar violão', 'Ativa', 'Fácil – Médio', 'Corpo/Mente', 45),
    ]));

    // Quinta (semana passada)
    logs.addAll(_dia(now.subtract(const Duration(days: 5)), [
      _atividade('Trabalho', 'Desenvolvimento', 'Ativa', 'Médio – Difícil',
          'Mente', 420),
      _atividade('Aprendizado', 'Curso online', 'Ativa', 'Médio', 'Mente', 90),
      _atividade(
          'Criação', 'Escrever artigo', 'Ativa', 'Difícil', 'Mente', 120),
      _atividade('Saúde', 'Caminhar', 'Ativa', 'Fácil', 'Corpo', 35),
    ]));

    // Quarta (semana passada)
    logs.addAll(_dia(now.subtract(const Duration(days: 6)), [
      _atividade('Trabalho', 'Reunião cliente', 'Ativa', 'Médio', 'Mente', 180),
      _atividade('Saúde', 'Correr', 'Ativa', 'Médio', 'Corpo', 45),
      _atividade('Social', 'Café com colega', 'Ativa', 'Fácil', 'Mente', 30),
      _atividade(
          'Aprendizado', 'Podcast', 'Ativa', 'Fácil – Médio', 'Mente', 60),
      _atividade('Autocuidado', 'Alongamento', 'Passiva', 'Fácil', 'Corpo', 15),
    ]));

    // Terça (semana passada)
    logs.addAll(_dia(now.subtract(const Duration(days: 7)), [
      _atividade(
          'Trabalho', 'Planejamento sprint', 'Ativa', 'Difícil', 'Mente', 300),
      _atividade('Criação', 'Design interface', 'Ativa', 'Médio – Difícil',
          'Mente', 150),
      _atividade('Espiritualidade', 'Orar', 'Passiva', 'Fácil', 'Mente', 15),
      _atividade(
          'Lazer', 'Jogar online', 'Ativa', 'Fácil – Médio', 'Corpo/Mente', 90),
    ]));

    // Segunda (semana passada)
    logs.addAll(_dia(now.subtract(const Duration(days: 8)), [
      _atividade('Trabalho', 'Daily meeting', 'Ativa', 'Médio', 'Mente', 30),
      _atividade('Aprendizado', 'Estudar arquitetura', 'Ativa',
          'Médio – Difícil', 'Mente', 120),
      _atividade('Saúde', 'HIIT', 'Ativa', 'Difícil', 'Corpo', 50),
      _atividade('Natureza', 'Trilhas', 'Passiva', 'Médio', 'Corpo/Mente', 120),
    ]));

    // Domingo (semana passada)
    logs.addAll(_dia(now.subtract(const Duration(days: 9)), [
      _atividade('Espiritualidade', 'Meditar', 'Passiva', 'Fácil', 'Mente', 25),
      _atividade('Lazer', 'Assistir filme', 'Ativa', 'Fácil', 'Mente', 150),
      _atividade(
          'Autocuidado', 'Banho relaxante', 'Passiva', 'Fácil', 'Corpo', 30),
      _atividade('Criação', 'Projeto pessoal', 'Ativa', 'Médio', 'Mente', 90),
      _atividade('Social', 'Jantar família', 'Ativa', 'Fácil', 'Mente', 120),
    ]));

    // Sábado (semana passada)
    logs.addAll(_dia(now.subtract(const Duration(days: 10)), [
      _atividade('Saúde', 'Correr', 'Ativa', 'Médio', 'Corpo', 60),
      _atividade(
          'Lazer', 'Música', 'Ativa', 'Fácil – Médio', 'Corpo/Mente', 60),
      _atividade('Natureza', 'Contemplar paisagem', 'Passiva', 'Fácil',
          'Corpo/Mente', 30),
      _atividade(
          'Aprendizado', 'Ler livro', 'Ativa', 'Fácil – Médio', 'Mente', 90),
    ]));

    // ========== MÊS PASSADO ==========

    // 15 dias atrás
    logs.addAll(_dia(now.subtract(const Duration(days: 15)), [
      _atividade('Trabalho', 'Apresentação', 'Ativa', 'Difícil', 'Mente', 240),
      _atividade('Saúde', 'HIIT', 'Ativa', 'Médio – Difícil', 'Corpo', 45),
      _atividade('Social', 'Happy hour', 'Ativa', 'Fácil', 'Mente', 120),
    ]));

    // 20 dias atrás
    logs.addAll(_dia(now.subtract(const Duration(days: 20)), [
      _atividade('Trabalho', 'Workshop', 'Ativa', 'Médio', 'Mente', 360),
      _atividade(
          'Aprendizado', 'Certificação', 'Ativa', 'Difícil', 'Mente', 180),
      _atividade(
          'Criação', 'Protótipo', 'Ativa', 'Médio – Difícil', 'Mente', 240),
    ]));

    // 25 dias atrás
    logs.addAll(_dia(now.subtract(const Duration(days: 25)), [
      _atividade(
          'Trabalho', 'Relatório mensal', 'Ativa', 'Difícil', 'Mente', 300),
      _atividade('Saúde', 'Caminhar', 'Ativa', 'Fácil', 'Corpo', 45),
      _atividade('Natureza', 'Trilhas', 'Passiva', 'Médio', 'Corpo/Mente', 180),
      _atividade('Espiritualidade', 'Meditar', 'Passiva', 'Fácil', 'Mente', 20),
    ]));

    // 30 dias atrás
    logs.addAll(_dia(now.subtract(const Duration(days: 30)), [
      _atividade('Trabalho', 'Planejamento trimestral', 'Ativa',
          'Médio – Difícil', 'Mente', 420),
      _atividade('Lazer', 'Jogar', 'Ativa', 'Fácil – Médio', 'Corpo/Mente', 90),
      _atividade('Social', 'Bar', 'Ativa', 'Fácil', 'Mente', 150),
      _atividade(
          'Autocuidado', 'Banho relaxante', 'Passiva', 'Fácil', 'Corpo', 25),
    ]));

    // 35 dias atrás (mês passado)
    logs.addAll(_dia(now.subtract(const Duration(days: 35)), [
      _atividade(
          'Trabalho', 'Projeto especial', 'Ativa', 'Difícil', 'Mente', 480),
      _atividade(
          'Criação', 'Escrever', 'Ativa', 'Médio – Difícil', 'Mente', 120),
      _atividade('Saúde', 'HIIT', 'Ativa', 'Médio', 'Corpo', 40),
    ]));

    // ========== POMODOROS ==========
    logs.addAll([
      _atividade('Pausa Pomodoro', '☕ 5min de pausa', 'Passiva', 'Fácil',
          'Corpo/Mente', 5, now),
      _atividade('Pausa Pomodoro', '☕ 5min de pausa', 'Passiva', 'Fácil',
          'Corpo/Mente', 5, now.subtract(const Duration(days: 1))),
      _atividade('Pausa Pomodoro', '☕ 10min de pausa', 'Passiva', 'Fácil',
          'Corpo/Mente', 10, now.subtract(const Duration(days: 4))),
      _atividade('Pausa Pomodoro', '☕ 5min de pausa', 'Passiva', 'Fácil',
          'Corpo/Mente', 5, now.subtract(const Duration(days: 7))),
      _atividade('Pausa Pomodoro', '☕ 5min de pausa', 'Passiva', 'Fácil',
          'Corpo/Mente', 5, now.subtract(const Duration(days: 10))),
      _atividade('Pausa Pomodoro', '☕ 10min de pausa', 'Passiva', 'Fácil',
          'Corpo/Mente', 10, now.subtract(const Duration(days: 20))),
    ]);

// ========== MESES ANTERIORES ==========

// 45 dias atrás
    logs.addAll(_dia(now.subtract(const Duration(days: 45)), [
      _atividade(
          'Trabalho', 'Projeto cliente', 'Ativa', 'Difícil', 'Mente', 420),
      _atividade('Aprendizado', 'Curso avançado', 'Ativa', 'Médio – Difícil',
          'Mente', 150),
      _atividade('Saúde', 'Correr', 'Ativa', 'Médio', 'Corpo', 45),
      _atividade('Social', 'Almoço equipe', 'Ativa', 'Fácil', 'Mente', 60),
    ]));

// 50 dias atrás
    logs.addAll(_dia(now.subtract(const Duration(days: 50)), [
      _atividade('Trabalho', 'Sprint planning', 'Ativa', 'Médio', 'Mente', 180),
      _atividade(
          'Criação', 'Novo projeto', 'Ativa', 'Médio – Difícil', 'Mente', 240),
      _atividade(
          'Natureza', 'Trilha longa', 'Passiva', 'Médio', 'Corpo/Mente', 180),
      _atividade('Espiritualidade', 'Retiro', 'Passiva', 'Fácil', 'Mente', 60),
    ]));

// 55 dias atrás
    logs.addAll(_dia(now.subtract(const Duration(days: 55)), [
      _atividade('Trabalho', 'Apresentação diretoria', 'Ativa', 'Difícil',
          'Mente', 300),
      _atividade('Lazer', 'Show', 'Ativa', 'Fácil – Médio', 'Corpo/Mente', 180),
      _atividade('Autocuidado', 'Spa day', 'Passiva', 'Fácil', 'Corpo', 120),
    ]));

// 60 dias atrás
    logs.addAll(_dia(now.subtract(const Duration(days: 60)), [
      _atividade(
          'Trabalho', 'Relatório trimestral', 'Ativa', 'Difícil', 'Mente', 480),
      _atividade('Saúde', 'HIIT', 'Ativa', 'Médio – Difícil', 'Corpo', 50),
      _atividade('Aprendizado', 'Workshop', 'Ativa', 'Médio', 'Mente', 240),
      _atividade('Social', 'Happy hour', 'Ativa', 'Fácil', 'Mente', 90),
    ]));

// 70 dias atrás
    logs.addAll(_dia(now.subtract(const Duration(days: 70)), [
      _atividade(
          'Trabalho', 'Projeto especial', 'Ativa', 'Difícil', 'Mente', 360),
      _atividade(
          'Criação', 'Lançamento produto', 'Ativa', 'Difícil', 'Mente', 300),
      _atividade(
          'Natureza', 'Viagem campo', 'Passiva', 'Médio', 'Corpo/Mente', 360),
    ]));

// 80 dias atrás
    logs.addAll(_dia(now.subtract(const Duration(days: 80)), [
      _atividade('Trabalho', 'Planejamento anual', 'Ativa', 'Médio – Difícil',
          'Mente', 240),
      _atividade('Saúde', 'Maratona', 'Ativa', 'Difícil', 'Corpo', 180),
      _atividade(
          'Espiritualidade', 'Jejum', 'Passiva', 'Difícil', 'Mente', 120),
      _atividade('Lazer', 'Viagem', 'Ativa', 'Fácil', 'Corpo/Mente', 480),
    ]));

// 90 dias atrás
    logs.addAll(_dia(now.subtract(const Duration(days: 90)), [
      _atividade('Trabalho', 'Conferência', 'Ativa', 'Médio', 'Mente', 480),
      _atividade(
          'Aprendizado', 'Certificação', 'Ativa', 'Difícil', 'Mente', 360),
      _atividade(
          'Social', 'Networking', 'Ativa', 'Fácil – Médio', 'Mente', 180),
      _atividade('Autocuidado', 'Massagem', 'Passiva', 'Fácil', 'Corpo', 60),
    ]));
    // Ordena por data (mais recente primeiro)
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return logs;
  }

  // Helper para criar atividade
  static ActivityLog _atividade(
    String group,
    String example,
    String energy,
    String flow,
    String organ,
    int minutes, [
    DateTime? date,
  ]) {
    final dateTime = date ?? DateTime.now();
    return ActivityLog(
      id: '${dateTime.millisecondsSinceEpoch}_${group}_$minutes',
      group: group,
      example: example,
      energy: energy,
      flow: flow,
      organ: organ,
      duration: Duration(minutes: minutes),
      timestamp: DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        // Horário variado para parecer real
        6 + (minutes ~/ 60) + (dateTime.hashCode % 10),
        minutes % 60,
      ),
    );
  }

  // Helper para criar atividades de um dia
  static List<ActivityLog> _dia(DateTime date, List<ActivityLog> atividades) {
    return atividades.map((a) {
      return ActivityLog(
        id: a.id,
        group: a.group,
        example: a.example,
        energy: a.energy,
        flow: a.flow,
        organ: a.organ,
        duration: a.duration,
        timestamp: DateTime(
          date.year,
          date.month,
          date.day,
          a.timestamp.hour,
          a.timestamp.minute,
        ),
      );
    }).toList();
  }
}
