// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'RootFlow';

  @override
  String get appTagline => 'Energia • Fluxo • Foco';

  @override
  String get navHome => 'Início';

  @override
  String get navMatch => 'Match';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navHistory => 'Histórico';

  @override
  String get start => 'INICIAR';

  @override
  String get skip => 'PULAR';

  @override
  String get cancel => 'Cancelar';

  @override
  String get apply => 'Aplicar';

  @override
  String get clear => 'Limpar';

  @override
  String recordsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros',
      one: '1 registro',
    );
    return '$_temp0';
  }

  @override
  String get consciousActionTitle => 'Ação Consciente';

  @override
  String get consciousActionSubtitle => 'Escolha com presença';

  @override
  String get areaLabel => '🍃 ÁREA DE ATUAÇÃO';

  @override
  String get availablePracticesLabel => '📋 PRÁTICAS DISPONÍVEIS';

  @override
  String practicesCount(int count) {
    return '$count práticas';
  }

  @override
  String get selectCategoryFirst => 'Selecione uma categoria primeiro!';

  @override
  String get selectCategoryHint =>
      'Selecione uma categoria\npara ver as práticas disponíveis';

  @override
  String get dashboardTitle => 'Dashboard Vital';

  @override
  String get dashboardSubtitle => 'Sua jornada de evolução consciente';

  @override
  String get dashboardEmptyTitle => 'Nenhuma atividade neste período';

  @override
  String get dashboardEmptySubtitle =>
      'Altere o período ou inicie uma atividade\nno RootFlow para ver suas métricas';

  @override
  String get periodToday => 'Hoje';

  @override
  String get periodWeek => 'Semana';

  @override
  String get periodMonth => 'Mês';

  @override
  String get periodAll => 'Geral';

  @override
  String get periodCurrent => 'ATUAL';

  @override
  String get periodPrevious => 'ANTERIOR';

  @override
  String periodDaysAgo(int count) {
    return '$count DIAS ATRÁS';
  }

  @override
  String periodWeeksAgo(int count) {
    return '$count SEMANAS ATRÁS';
  }

  @override
  String periodMonthsAgo(int count) {
    return '$count MESES ATRÁS';
  }

  @override
  String get backToCurrent => 'Voltar ao atual';

  @override
  String get statusVeryActive => '🔥 Muito Ativo';

  @override
  String get statusContemplative => '🧘 Contemplativo';

  @override
  String get statusBalanced => '⚖️ Equilibrado';

  @override
  String get statusTendingActive => '⚡ Tend. Ativa';

  @override
  String get statusTendingPassive => '🌿 Tend. Passiva';

  @override
  String get statusNoData => 'Sem dados';

  @override
  String get trendFirstRecords => 'Primeiros registros! 🎉';

  @override
  String trendUp(int percent) {
    return '$percent% mais que período anterior';
  }

  @override
  String trendDown(int percent) {
    return '$percent% menos que período anterior';
  }

  @override
  String get suggestionStart =>
      'Inicie sua primeira atividade no RootFlow para ver insights personalizados! 🚀';

  @override
  String suggestionMultipleCategories(int count, String category) {
    return 'Você ainda não praticou $count categorias. Que tal começar com \"$category\"? 🌱';
  }

  @override
  String suggestionOneCategory(String category) {
    return 'Falta apenas \"$category\" para diversificar suas práticas! 🎯';
  }

  @override
  String suggestionLowBalance(String category) {
    return 'Seu tempo está concentrado em poucas categorias. Experimente \"$category\" para equilibrar! ⚖️';
  }

  @override
  String suggestionHighBalance(int percent) {
    return 'Excelente equilíbrio! $percent% de distribuição entre categorias! ⭐';
  }

  @override
  String suggestionStreak(int days, String time) {
    return '$days dias seguidos! $time de prática! 🔥';
  }

  @override
  String get suggestionVary =>
      'Continue variando suas atividades para um desenvolvimento mais completo! 📊';

  @override
  String get matchTitle => 'Match de práticas';

  @override
  String get matchSubtitle => 'Deslize → para iniciar';

  @override
  String get currentProfileLabel => 'SEU PERFIL ATUAL';

  @override
  String get swipeToExplore => 'Deslize para explorar';

  @override
  String get swipeInstructions => 'Arraste para os lados';

  @override
  String progressCount(int current, int total) {
    return '$current de $total';
  }

  @override
  String get statusEnergyHigh => 'Energia Alta';

  @override
  String get statusEnergyLow => 'Energia Baixa';

  @override
  String get statusEnergyBalanced => 'Equilibrada';

  @override
  String get statusOrganMindActive => 'Mente Ativa';

  @override
  String get statusOrganBodyActive => 'Corpo Ativo';

  @override
  String get statusOrganBalanced => 'Equilibrado';

  @override
  String get statusFlowChallenging => 'Desafiador';

  @override
  String get statusFlowComfort => 'Confortável';

  @override
  String get statusFlowBalanced => 'Equilibrado';

  @override
  String get insightNoData =>
      'Sem registros nos últimos 7 dias. Sugestões baseadas em práticas equilibradas.';

  @override
  String get insightBalanced =>
      'Seu perfil dos últimos 7 dias está equilibrado. Continue assim!';

  @override
  String insightWithIssues(String issues) {
    return 'Nos últimos 7 dias: $issues. As sugestões abaixo visam compensar e reequilibrar.';
  }

  @override
  String get issueHighEnergy => 'energia alta';

  @override
  String get issueLowEnergy => 'energia baixa';

  @override
  String get issueOverloadedMind => 'mente sobrecarregada';

  @override
  String get issueVeryActiveBody => 'corpo muito ativo';

  @override
  String get issueTooChallenging => 'práticas muito desafiadoras';

  @override
  String get issueComfortZone => 'zona de conforto';

  @override
  String get reasonBalanceEnergy => 'Equilibrar energia';

  @override
  String get reasonAwakVitality => 'Despertar vitalidade';

  @override
  String get reasonActivateBody => 'Ativar o corpo';

  @override
  String get reasonExerciseMind => 'Exercitar a mente';

  @override
  String get reasonLighter => 'Algo mais leve';

  @override
  String get reasonChallenge => 'Sair da zona de conforto';

  @override
  String get reasonDefault => 'Recomendado para você';

  @override
  String get reasonPauseRenew => 'Um momento de pausa renovadora';

  @override
  String get reasonConnectNature => 'Conecte-se com a natureza';

  @override
  String get historyTitle => 'Histórico';

  @override
  String get historySubtitle => 'Sua jornada registrada';

  @override
  String get searchHint => 'Buscar atividade...';

  @override
  String get filterPeriodLabel => 'PERÍODO';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterToday => 'Hoje';

  @override
  String get filterWeek => 'Semana';

  @override
  String get filterMonth => 'Mês';

  @override
  String get filterMonthYear => 'Mês/Ano';

  @override
  String get selectPeriodTitle => 'Selecionar Período';

  @override
  String get selectPeriodPlaceholder => 'Selecionar período';

  @override
  String get yearLabel => 'ANO';

  @override
  String get monthOptionalLabel => 'MÊS (OPCIONAL)';

  @override
  String get today => 'Hoje';

  @override
  String get yesterday => 'Ontem';

  @override
  String activityCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count atividades',
      one: '1 atividade',
    );
    return '$_temp0';
  }

  @override
  String get historyEmptyNoResults => 'Nenhum resultado encontrado';

  @override
  String get historyEmptyNoActivity => 'Nenhuma atividade registrada';

  @override
  String get historyEmptySearchHint => 'Tente outro termo ou remova os filtros';

  @override
  String get historyEmptyActivityHint =>
      'Inicie uma atividade no RootFlow\npara ver seu histórico aqui';

  @override
  String get exportNoActivity => 'Nenhuma atividade para exportar.';

  @override
  String get energyAtiva => 'Ativa';

  @override
  String get energyPassiva => 'Passiva';

  @override
  String get organMente => 'Mente';

  @override
  String get organCorpo => 'Corpo';

  @override
  String get organEspirito => 'Espírito';

  @override
  String get organCorpoMente => 'Corpo/Mente';

  @override
  String get flowFacil => 'Fácil';

  @override
  String get flowFacilMedio => 'Fácil – Médio';

  @override
  String get flowMedio => 'Médio';

  @override
  String get flowMedioDificil => 'Médio – Difícil';

  @override
  String get flowDificil => 'Difícil';

  @override
  String get categoryEspiritualidade => 'Espiritualidade';

  @override
  String get categoryAprendizado => 'Aprendizado';

  @override
  String get categoryTrabalho => 'Trabalho';

  @override
  String get categorySaude => 'Saúde';

  @override
  String get categoryLazer => 'Lazer';

  @override
  String get categorySocial => 'Social';

  @override
  String get categoryCriacao => 'Criação';

  @override
  String get categoryNatureza => 'Natureza';

  @override
  String get categoryAutocuidado => 'Autocuidado';

  @override
  String get descEspiritualidade =>
      'Práticas para silenciar a mente e conectar-se com algo maior.';

  @override
  String get descAprendizado =>
      'Atividades que expandem o conhecimento e desenvolvem novas habilidades.';

  @override
  String get descTrabalho => 'Foco e produtividade com presença e intenção.';

  @override
  String get descSaude => 'Movimento, cuidado físico e vitalidade do corpo.';

  @override
  String get descLazer => 'Momentos de alegria, diversão e descanso ativo.';

  @override
  String get descSocial =>
      'Conexões humanas que nutrem e fortalecem os vínculos.';

  @override
  String get descCriacao =>
      'Expressão artística e criativa como forma de meditação ativa.';

  @override
  String get descNatureza =>
      'Reencontro com a natureza e o ritmo do mundo natural.';

  @override
  String get descAutocuidado =>
      'Práticas para nutrir o corpo e recuperar a energia vital.';

  @override
  String get descDefault =>
      'Práticas conscientes para desenvolver presença e atenção plena no dia a dia.';

  @override
  String get practiceAlongamento => 'Alongamento';

  @override
  String get practiceApresentacao => 'Apresentação';

  @override
  String get practiceAssistir => 'Assistir';

  @override
  String get practiceAutoMassagem => 'Auto-massagem';

  @override
  String get practiceAcampar => 'Acampar';

  @override
  String get practiceBanhoRelaxante => 'Banho relaxante';

  @override
  String get practiceBar => 'Bar';

  @override
  String get practiceCaminhar => 'Caminhar';

  @override
  String get practiceChat => 'Chat';

  @override
  String get practiceContemplacaoPaisagem => 'Contemplar paisagem';

  @override
  String get practiceConversar => 'Conversar';

  @override
  String get practiceCorrida => 'Correr';

  @override
  String get practiceCozinhar => 'Cozinhar';

  @override
  String get practiceCursoOnline => 'Curso online';

  @override
  String get practiceConsultaMedica => 'Consulta médica';

  @override
  String get practiceDancar => 'Dançar';

  @override
  String get practiceDesenhar => 'Desenhar';

  @override
  String get practiceEstudar => 'Estudar';

  @override
  String get practiceEscrever => 'Escrever';

  @override
  String get practiceEventoSocial => 'Evento social';

  @override
  String get practiceFotografar => 'Fotografar';

  @override
  String get practiceHIIT => 'HIIT';

  @override
  String get practiceJardinagem => 'Jardinagem';

  @override
  String get practiceJejum => 'Jejum';

  @override
  String get practiceJogar => 'Jogar';

  @override
  String get practiceLer => 'Ler';

  @override
  String get practiceLigarAmigo => 'Ligar para amigo';

  @override
  String get practiceMacaquear => 'Macaquear';

  @override
  String get practiceMalabares => 'Malabares';

  @override
  String get practiceMassagem => 'Massagem';

  @override
  String get practiceMeditar => 'Meditar';

  @override
  String get practiceMusica => 'Música';

  @override
  String get practiceNaoFazerNada => 'Não fazer nada';

  @override
  String get practiceOrganizarTarefas => 'Organizar tarefas';

  @override
  String get practiceOrar => 'Orar';

  @override
  String get practiceOuvirAudiolivro => 'Ouvir audiolivro';

  @override
  String get practicePlanejamento => 'Planejamento';

  @override
  String get practicePlanejar => 'Planejar';

  @override
  String get practicePodcastEducativo => 'Podcast educativo';

  @override
  String get practiceProjetosPessoais => 'Projetos pessoais';

  @override
  String get practiceReuniaoTrabalho => 'Reunião';

  @override
  String get practiceRespiracaoConsciente => 'Respiração consciente';

  @override
  String get practiceRetiroEspiritual => 'Retiro espiritual';

  @override
  String get practiceSkinCare => 'Skin care';

  @override
  String get practiceSpaDay => 'Spa day';

  @override
  String get practiceTrilhas => 'Trilhas';

  @override
  String get practiceTrabalhoRemunerado => 'Trabalho remunerado';

  @override
  String get practiceYoga => 'Yoga';
}
