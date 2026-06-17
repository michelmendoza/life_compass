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

  @override
  String get welcomeBack => 'Bem-vindo(a) de volta!';

  @override
  String get greetingMorning => 'Bom dia! 🌅';

  @override
  String get greetingAfternoon => 'Boa tarde! 🌞';

  @override
  String get greetingEvening => 'Boa noite! 🌙';

  @override
  String get homeBalanceToday => 'Equilíbrio hoje';

  @override
  String get homePracticesToday => 'práticas hoje';

  @override
  String get homeTotalPractices => 'total práticas';

  @override
  String get homeFlowLevels => 'Níveis de Flow';

  @override
  String get homeExplorePractices => '✨ Explorar Práticas';

  @override
  String get homeDiscoverActivities => 'Descubra novas atividades';

  @override
  String get homeActNow => '⚡ Agir Agora';

  @override
  String get homePersonalizedSuggestions =>
      'Sugestões personalizadas para você';

  @override
  String homeDominantBody(int percent) {
    return 'Corpo $percent%';
  }

  @override
  String homeDominantMind(int percent) {
    return 'Mental $percent%';
  }

  @override
  String homeDominantSpirit(int percent) {
    return 'Espírito $percent%';
  }

  @override
  String get homeDominantDefault => 'Mental 70%';

  @override
  String get motivationSmallSteps =>
      '✨ Pequenos passos todos os dias levam a grandes mudanças';

  @override
  String get motivationCloser => '🌟 Você está mais perto do que imagina';

  @override
  String get motivationBelieve => '💪 Acredite no seu potencial';

  @override
  String get motivationFocusProcess =>
      '🎯 Foco no processo, não apenas no resultado';

  @override
  String get motivationSeed => '🌱 Cada prática é uma semente para o futuro';

  @override
  String get motivationFutureSelf => '🔥 Seu eu do futuro vai agradecer';

  @override
  String get motivationAction =>
      '⚡ Um minuto de ação vale mais que horas de planejamento';

  @override
  String get motivationJourney =>
      '🌈 A jornada é tão importante quanto o destino';

  @override
  String get motivationBreathe => '🍃 Respire, concentre-se e siga em frente';

  @override
  String get motivationCapable => '⭐ Você é capaz de coisas incríveis';

  @override
  String get motivationPresence => '🎨 Crie momentos de presença hoje';

  @override
  String get motivationCare => '💙 Cuide de você como cuidaria de um amigo';

  @override
  String get statTotalTime => 'Tempo total';

  @override
  String get statActivities => 'Atividades';

  @override
  String get statStreak => 'Sequência';

  @override
  String get last7Days => 'ÚLTIMOS 7 DIAS';

  @override
  String get cardBalanceCategories => 'Equilíbrio entre Categorias';

  @override
  String notPracticed(String categories) {
    return 'Não praticado: $categories';
  }

  @override
  String trySuggestion(String category) {
    return '✨ Experimente: $category';
  }

  @override
  String totalUPsLabel(String ups, int count) {
    return 'Total: $ups UPs em $count atividades';
  }

  @override
  String get relativeBarsNote => '* barras relativas ao maior valor';

  @override
  String get cardEnergyBalance => 'Balanço Energético';

  @override
  String get energyActivePill => '⚡ Ativa';

  @override
  String get energyPassivePill => '🍃 Passiva';

  @override
  String get cardFlowDistribution => 'Distribuição do Flow';

  @override
  String get cardFocusDimension => 'Foco por Dimensão';

  @override
  String get cardAvgConsciousness => 'Consciência Média';

  @override
  String get consciousnessHint =>
      'Responda o feedback rápido após cada atividade para desbloquear suas métricas de consciência.';

  @override
  String get stateFlowing => 'Fluindo';

  @override
  String get stateFocused => 'Focado';

  @override
  String get statePresent => 'Presente';

  @override
  String get stateAutomatic => 'Automático';

  @override
  String get moreAutomatic => '← mais automático';

  @override
  String get moreConscious => 'mais consciente →';

  @override
  String activitiesWithFeedback(int count) {
    return '$count atividades com feedback';
  }

  @override
  String get cardFlowVsChallenge => 'Flow vs Desafio';

  @override
  String get flowChallengeHint =>
      'Ao finalizar cada atividade, avalie a dificuldade e seu nível de flow para desbloquear este gráfico.';

  @override
  String flowPeak(String zone, int percent) {
    return 'Pico: $zone $percent%';
  }

  @override
  String get flowZoneEasy => '🌊 Fácil';

  @override
  String get flowZoneMedium => '⚡ Médio';

  @override
  String get flowZoneHard => '🔥 Difícil';

  @override
  String flowActivitiesCount(int count) {
    return '$count ativ.';
  }

  @override
  String flowRatePercent(int percent) {
    return '$percent% flow';
  }

  @override
  String flowInZone(String zone) {
    return 'Você entra em flow principalmente em atividades $zone. Este é seu ponto ideal!';
  }

  @override
  String get flowDistributedMsg =>
      'Flow distribuído. Varie a dificuldade para encontrar seu ponto ideal.';

  @override
  String get flowLowMsg =>
      'Poucos momentos de flow. Tente ajustar: nem tão fácil que entedie, nem tão difícil que frustre.';

  @override
  String get cardChallengeIndex => 'Índice de Desafio';

  @override
  String get challengeHigh => '🔥 Alta intensidade';

  @override
  String get challengeModerate => '⚡ Moderado';

  @override
  String get challengeSmooth => '🌊 Fluxo tranquilo';

  @override
  String get challengeScale => '0 = Suave · 100 = Intenso';

  @override
  String get cardTopCategories => 'Top Categorias';

  @override
  String get cardRecentActivities => 'Atividades Recentes';

  @override
  String get customizeScreenTitle => 'Categorias';

  @override
  String get myCategories => '✨ MINHAS CATEGORIAS';

  @override
  String get newCategory => 'Nova Categoria';

  @override
  String get defaultCategories => '📦 CATEGORIAS PADRÃO';

  @override
  String get emptyCustomCategories =>
      'Nenhuma categoria personalizada.\nToque em \"Nova Categoria\" para criar!';

  @override
  String practicesCountLabel(int count) {
    return '$count prática(s)';
  }

  @override
  String get noPracticesAddTip => 'Nenhuma prática — toque em + para adicionar';

  @override
  String get addPracticeToCategory => 'Adicionar prática';

  @override
  String get removeCategoryTitle => 'Remover?';

  @override
  String removeCategoryMessage(String name) {
    return 'A categoria \"$name\" será removida.';
  }

  @override
  String get removeCategoryBtn => 'Remover';

  @override
  String get editCategoryTitle => 'Editar Categoria';

  @override
  String get newCategoryTitle => 'Nova Categoria';

  @override
  String get practicesAddedLater => 'As práticas são adicionadas depois';

  @override
  String get iconLabel => 'Ícone';

  @override
  String get categoryNameLabel => 'Nome da categoria';

  @override
  String get categoryNameHint => 'Ex: Yoga, Jardinagem...';

  @override
  String get practicesFormLabel => 'Práticas';

  @override
  String get noPracticesYet => 'Nenhuma prática ainda';

  @override
  String get saveBtn => 'SALVAR';

  @override
  String get createCategoryBtn => 'CRIAR CATEGORIA';

  @override
  String get newPracticeTitle => 'Nova Prática';

  @override
  String get inCategoryPrefix => 'em ';

  @override
  String get practiceNameLabel => 'Nome da prática';

  @override
  String get practiceNameHint => 'Ex: Meditação guiada, Leitura...';

  @override
  String get energySectionLabel => '⚡ Energia';

  @override
  String get energySectionQuestion =>
      'Qual tipo de energia essa prática mobiliza?';

  @override
  String get difficultySectionLabel => '🌊 Dificuldade';

  @override
  String get difficultySectionQuestion => 'Qual o nível de esforço necessário?';

  @override
  String get focusSectionLabel => '🎯 Foco';

  @override
  String get focusSectionQuestion => 'Qual dimensão essa prática desenvolve?';

  @override
  String get idealTimeSectionLabel => '⏱️ Tempo ideal';

  @override
  String get idealTimeSectionQuestion =>
      'Quantos minutos representam uma prática completa e satisfatória?';

  @override
  String get idealTimeHint => 'Ex: 20';

  @override
  String get idealTimeSuffix => 'min';

  @override
  String get reminderSectionLabel => '💛 Lembrete';

  @override
  String get reminderSectionDescription =>
      'Tem algo que precisa lembrar antes de começar a prática? Preparações, aquecimento, meditação, propósito, pessoas que ama...';

  @override
  String get reminderHint =>
      'Ex: Respirar fundo antes, ligar para alguém especial...';

  @override
  String get reminderBeforeStartTitle => 'Antes de começar...';

  @override
  String get reminderBeforeStartSubtitle =>
      'Você deixou um lembrete para essa prática 💛';

  @override
  String get reminderBeforeStartButton => 'ESTOU PRONTO — INICIAR';

  @override
  String get addPracticeButton => 'ADICIONAR PRÁTICA';

  @override
  String get settingsScreenTitle => 'Configurações';

  @override
  String get settingsScreenSubtitle => 'Gerencie seus dados e preferências';

  @override
  String get settingsSectionData => 'DADOS';

  @override
  String get settingsSectionSupport => 'SUPORTE';

  @override
  String get settingsExportData => 'Exportar dados';

  @override
  String get settingsExportDataDesc =>
      'Salve um backup de tudo que você registrou';

  @override
  String get settingsImportData => 'Importar dados';

  @override
  String get settingsImportDataDesc =>
      'Restaure um backup exportado anteriormente';

  @override
  String get settingsClearData => 'Limpar todos os dados';

  @override
  String get settingsClearDataDesc =>
      'Remove permanentemente seu histórico e personalizações';

  @override
  String get settingsFaq => 'Perguntas frequentes';

  @override
  String get settingsAbout => 'Sobre o app';

  @override
  String get settingsVisitSite => 'Visitar nosso site';

  @override
  String get exportSuccessMessage => 'Dados exportados com sucesso!';

  @override
  String get exportEmptyMessage => 'Nenhum dado para exportar ainda.';

  @override
  String get exportShareSubject => 'Root Flow — Backup de dados';

  @override
  String get importConfirmTitle => 'Importar dados?';

  @override
  String importConfirmMessage(int logs, int categories) {
    return '$logs atividades e $categories categorias serão adicionadas ou atualizadas. Seus dados atuais não serão apagados.';
  }

  @override
  String get importConfirmBtn => 'Importar';

  @override
  String get importSuccessMessage =>
      'Dados importados! Reinicie o app para ver tudo atualizado em todas as telas.';

  @override
  String get importErrorMessage =>
      'Não foi possível importar este arquivo. Verifique se é um backup válido do Root Flow.';

  @override
  String get importEmptyFile =>
      'O arquivo selecionado não contém dados para importar.';

  @override
  String get clearDataConfirmTitle => 'Limpar todos os dados?';

  @override
  String get clearDataConfirmMessage =>
      'Isso vai remover permanentemente todo o seu histórico de atividades e categorias personalizadas. Essa ação não pode ser desfeita.';

  @override
  String get clearDataConfirmBtn => 'Limpar tudo';

  @override
  String get clearDataSuccessMessage => 'Todos os dados foram removidos.';

  @override
  String get faqQ1 => 'Onde meus dados são salvos?';

  @override
  String get faqA1 =>
      'Tudo fica salvo localmente no seu dispositivo. O Root Flow não envia nada para servidores ou para a nuvem.';

  @override
  String get faqQ2 => 'Como faço backup dos meus dados?';

  @override
  String get faqA2 =>
      'Use \"Exportar dados\" no menu de Configurações para gerar um arquivo de backup que você pode guardar ou compartilhar.';

  @override
  String get faqQ3 => 'Posso usar o app em outro celular?';

  @override
  String get faqA3 =>
      'Sim. Exporte os dados no aparelho atual e importe o mesmo arquivo no celular novo.';

  @override
  String get faqQ4 => 'O que são UPs?';

  @override
  String get faqA4 =>
      'UPs (Unidades de Prática) medem o quanto você praticou uma atividade em relação ao tempo ideal definido para ela.';

  @override
  String get faqQ5 => 'Posso excluir uma categoria ou prática padrão?';

  @override
  String get faqA5 =>
      'Sim. Na tela de Customizar você pode excluir qualquer categoria, mesmo as padrão — a exclusão é permanente.';

  @override
  String get faqQ6 => 'Perdi meus dados, é possível recuperar?';

  @override
  String get faqA6 =>
      'Só se você tiver exportado um backup antes. Sem um arquivo de backup, não é possível recuperar dados removidos.';

  @override
  String get aboutAppDescription =>
      'Root Flow é um app de bem-estar que ajuda você a equilibrar energia, fluxo e foco através do registro consciente das suas atividades diárias.';

  @override
  String get aboutVersionLabel => 'Versão';

  @override
  String get aboutPrivacyNote =>
      'Todos os dados ficam armazenados apenas no seu dispositivo.';

  @override
  String get cantOpenLink => 'Não foi possível abrir o link.';
}
