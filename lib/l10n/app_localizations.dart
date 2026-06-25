import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'RootFlow'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In pt, this message translates to:
  /// **'Energia • Fluxo • Foco'**
  String get appTagline;

  /// No description provided for @navHome.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get navHome;

  /// No description provided for @navMatch.
  ///
  /// In pt, this message translates to:
  /// **'Match'**
  String get navMatch;

  /// No description provided for @navDashboard.
  ///
  /// In pt, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navHistory.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get navHistory;

  /// No description provided for @start.
  ///
  /// In pt, this message translates to:
  /// **'INICIAR'**
  String get start;

  /// No description provided for @skip.
  ///
  /// In pt, this message translates to:
  /// **'PULAR'**
  String get skip;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @apply.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar'**
  String get apply;

  /// No description provided for @clear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get clear;

  /// No description provided for @recordsCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 registro} other{{count} registros}}'**
  String recordsCount(num count);

  /// No description provided for @consciousActionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ação Consciente'**
  String get consciousActionTitle;

  /// No description provided for @consciousActionSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha com presença'**
  String get consciousActionSubtitle;

  /// No description provided for @areaLabel.
  ///
  /// In pt, this message translates to:
  /// **'🍃 ÁREA DE ATUAÇÃO'**
  String get areaLabel;

  /// No description provided for @availablePracticesLabel.
  ///
  /// In pt, this message translates to:
  /// **'📋 PRÁTICAS DISPONÍVEIS'**
  String get availablePracticesLabel;

  /// No description provided for @practicesCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} práticas'**
  String practicesCount(int count);

  /// No description provided for @selectCategoryFirst.
  ///
  /// In pt, this message translates to:
  /// **'Selecione uma categoria primeiro!'**
  String get selectCategoryFirst;

  /// No description provided for @selectCategoryHint.
  ///
  /// In pt, this message translates to:
  /// **'Selecione uma categoria\npara ver as práticas disponíveis'**
  String get selectCategoryHint;

  /// No description provided for @dashboardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Dashboard Vital'**
  String get dashboardTitle;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Sua jornada de evolução consciente'**
  String get dashboardSubtitle;

  /// No description provided for @dashboardEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma atividade neste período'**
  String get dashboardEmptyTitle;

  /// No description provided for @dashboardEmptySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Altere o período ou inicie uma atividade\nno RootFlow para ver suas métricas'**
  String get dashboardEmptySubtitle;

  /// No description provided for @periodToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get periodToday;

  /// No description provided for @periodWeek.
  ///
  /// In pt, this message translates to:
  /// **'Semana'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In pt, this message translates to:
  /// **'Mês'**
  String get periodMonth;

  /// No description provided for @periodAll.
  ///
  /// In pt, this message translates to:
  /// **'Geral'**
  String get periodAll;

  /// No description provided for @periodCurrent.
  ///
  /// In pt, this message translates to:
  /// **'ATUAL'**
  String get periodCurrent;

  /// No description provided for @periodPrevious.
  ///
  /// In pt, this message translates to:
  /// **'ANTERIOR'**
  String get periodPrevious;

  /// No description provided for @periodDaysAgo.
  ///
  /// In pt, this message translates to:
  /// **'{count} DIAS ATRÁS'**
  String periodDaysAgo(int count);

  /// No description provided for @periodWeeksAgo.
  ///
  /// In pt, this message translates to:
  /// **'{count} SEMANAS ATRÁS'**
  String periodWeeksAgo(int count);

  /// No description provided for @periodMonthsAgo.
  ///
  /// In pt, this message translates to:
  /// **'{count} MESES ATRÁS'**
  String periodMonthsAgo(int count);

  /// No description provided for @backToCurrent.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao atual'**
  String get backToCurrent;

  /// No description provided for @statusVeryActive.
  ///
  /// In pt, this message translates to:
  /// **'🔥 Muito Ativo'**
  String get statusVeryActive;

  /// No description provided for @statusContemplative.
  ///
  /// In pt, this message translates to:
  /// **'🧘 Contemplativo'**
  String get statusContemplative;

  /// No description provided for @statusBalanced.
  ///
  /// In pt, this message translates to:
  /// **'⚖️ Equilibrado'**
  String get statusBalanced;

  /// No description provided for @statusTendingActive.
  ///
  /// In pt, this message translates to:
  /// **'⚡ Tend. Ativa'**
  String get statusTendingActive;

  /// No description provided for @statusTendingPassive.
  ///
  /// In pt, this message translates to:
  /// **'🌿 Tend. Passiva'**
  String get statusTendingPassive;

  /// No description provided for @statusNoData.
  ///
  /// In pt, this message translates to:
  /// **'Sem dados'**
  String get statusNoData;

  /// No description provided for @trendFirstRecords.
  ///
  /// In pt, this message translates to:
  /// **'Primeiros registros! 🎉'**
  String get trendFirstRecords;

  /// No description provided for @trendUp.
  ///
  /// In pt, this message translates to:
  /// **'{percent}% mais que período anterior'**
  String trendUp(int percent);

  /// No description provided for @trendDown.
  ///
  /// In pt, this message translates to:
  /// **'{percent}% menos que período anterior'**
  String trendDown(int percent);

  /// No description provided for @suggestionStart.
  ///
  /// In pt, this message translates to:
  /// **'Inicie sua primeira atividade no RootFlow para ver insights personalizados! 🚀'**
  String get suggestionStart;

  /// No description provided for @suggestionMultipleCategories.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não praticou {count} categorias. Que tal começar com \"{category}\"? 🌱'**
  String suggestionMultipleCategories(int count, String category);

  /// No description provided for @suggestionOneCategory.
  ///
  /// In pt, this message translates to:
  /// **'Falta apenas \"{category}\" para diversificar suas práticas! 🎯'**
  String suggestionOneCategory(String category);

  /// No description provided for @suggestionLowBalance.
  ///
  /// In pt, this message translates to:
  /// **'Seu tempo está concentrado em poucas categorias. Experimente \"{category}\" para equilibrar! ⚖️'**
  String suggestionLowBalance(String category);

  /// No description provided for @suggestionHighBalance.
  ///
  /// In pt, this message translates to:
  /// **'Excelente equilíbrio! {percent}% de distribuição entre categorias! ⭐'**
  String suggestionHighBalance(int percent);

  /// No description provided for @suggestionStreak.
  ///
  /// In pt, this message translates to:
  /// **'{days} dias seguidos! {time} de prática! 🔥'**
  String suggestionStreak(int days, String time);

  /// No description provided for @suggestionVary.
  ///
  /// In pt, this message translates to:
  /// **'Continue variando suas atividades para um desenvolvimento mais completo! 📊'**
  String get suggestionVary;

  /// No description provided for @matchTitle.
  ///
  /// In pt, this message translates to:
  /// **'Match de práticas'**
  String get matchTitle;

  /// No description provided for @matchSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Deslize → para iniciar'**
  String get matchSubtitle;

  /// No description provided for @currentProfileLabel.
  ///
  /// In pt, this message translates to:
  /// **'SEU PERFIL ATUAL'**
  String get currentProfileLabel;

  /// No description provided for @swipeToExplore.
  ///
  /// In pt, this message translates to:
  /// **'Deslize para explorar'**
  String get swipeToExplore;

  /// No description provided for @swipeInstructions.
  ///
  /// In pt, this message translates to:
  /// **'Arraste para os lados'**
  String get swipeInstructions;

  /// No description provided for @progressCount.
  ///
  /// In pt, this message translates to:
  /// **'{current} de {total}'**
  String progressCount(int current, int total);

  /// No description provided for @statusEnergyHigh.
  ///
  /// In pt, this message translates to:
  /// **'Energia Alta'**
  String get statusEnergyHigh;

  /// No description provided for @statusEnergyLow.
  ///
  /// In pt, this message translates to:
  /// **'Energia Baixa'**
  String get statusEnergyLow;

  /// No description provided for @statusEnergyBalanced.
  ///
  /// In pt, this message translates to:
  /// **'Equilibrada'**
  String get statusEnergyBalanced;

  /// No description provided for @statusOrganMindActive.
  ///
  /// In pt, this message translates to:
  /// **'Mente Ativa'**
  String get statusOrganMindActive;

  /// No description provided for @statusOrganBodyActive.
  ///
  /// In pt, this message translates to:
  /// **'Corpo Ativo'**
  String get statusOrganBodyActive;

  /// No description provided for @statusOrganBalanced.
  ///
  /// In pt, this message translates to:
  /// **'Equilibrado'**
  String get statusOrganBalanced;

  /// No description provided for @statusFlowChallenging.
  ///
  /// In pt, this message translates to:
  /// **'Desafiador'**
  String get statusFlowChallenging;

  /// No description provided for @statusFlowComfort.
  ///
  /// In pt, this message translates to:
  /// **'Confortável'**
  String get statusFlowComfort;

  /// No description provided for @statusFlowBalanced.
  ///
  /// In pt, this message translates to:
  /// **'Equilibrado'**
  String get statusFlowBalanced;

  /// No description provided for @insightNoData.
  ///
  /// In pt, this message translates to:
  /// **'Sem registros nos últimos 7 dias. Sugestões baseadas em práticas equilibradas.'**
  String get insightNoData;

  /// No description provided for @insightBalanced.
  ///
  /// In pt, this message translates to:
  /// **'Seu perfil dos últimos 7 dias está equilibrado. Continue assim!'**
  String get insightBalanced;

  /// No description provided for @insightWithIssues.
  ///
  /// In pt, this message translates to:
  /// **'Nos últimos 7 dias: {issues}. As sugestões abaixo visam compensar e reequilibrar.'**
  String insightWithIssues(String issues);

  /// No description provided for @issueHighEnergy.
  ///
  /// In pt, this message translates to:
  /// **'energia alta'**
  String get issueHighEnergy;

  /// No description provided for @issueLowEnergy.
  ///
  /// In pt, this message translates to:
  /// **'energia baixa'**
  String get issueLowEnergy;

  /// No description provided for @issueOverloadedMind.
  ///
  /// In pt, this message translates to:
  /// **'mente sobrecarregada'**
  String get issueOverloadedMind;

  /// No description provided for @issueVeryActiveBody.
  ///
  /// In pt, this message translates to:
  /// **'corpo muito ativo'**
  String get issueVeryActiveBody;

  /// No description provided for @issueTooChallenging.
  ///
  /// In pt, this message translates to:
  /// **'práticas muito desafiadoras'**
  String get issueTooChallenging;

  /// No description provided for @issueComfortZone.
  ///
  /// In pt, this message translates to:
  /// **'zona de conforto'**
  String get issueComfortZone;

  /// No description provided for @reasonBalanceEnergy.
  ///
  /// In pt, this message translates to:
  /// **'Equilibrar energia'**
  String get reasonBalanceEnergy;

  /// No description provided for @reasonAwakVitality.
  ///
  /// In pt, this message translates to:
  /// **'Despertar vitalidade'**
  String get reasonAwakVitality;

  /// No description provided for @reasonActivateBody.
  ///
  /// In pt, this message translates to:
  /// **'Ativar o corpo'**
  String get reasonActivateBody;

  /// No description provided for @reasonExerciseMind.
  ///
  /// In pt, this message translates to:
  /// **'Exercitar a mente'**
  String get reasonExerciseMind;

  /// No description provided for @reasonLighter.
  ///
  /// In pt, this message translates to:
  /// **'Algo mais leve'**
  String get reasonLighter;

  /// No description provided for @reasonChallenge.
  ///
  /// In pt, this message translates to:
  /// **'Sair da zona de conforto'**
  String get reasonChallenge;

  /// No description provided for @reasonDefault.
  ///
  /// In pt, this message translates to:
  /// **'Recomendado para você'**
  String get reasonDefault;

  /// No description provided for @reasonPauseRenew.
  ///
  /// In pt, this message translates to:
  /// **'Um momento de pausa renovadora'**
  String get reasonPauseRenew;

  /// No description provided for @reasonConnectNature.
  ///
  /// In pt, this message translates to:
  /// **'Conecte-se com a natureza'**
  String get reasonConnectNature;

  /// No description provided for @historyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get historyTitle;

  /// No description provided for @historySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Sua jornada registrada'**
  String get historySubtitle;

  /// No description provided for @searchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar atividade...'**
  String get searchHint;

  /// No description provided for @filterPeriodLabel.
  ///
  /// In pt, this message translates to:
  /// **'PERÍODO'**
  String get filterPeriodLabel;

  /// No description provided for @filterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get filterAll;

  /// No description provided for @filterToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get filterToday;

  /// No description provided for @filterWeek.
  ///
  /// In pt, this message translates to:
  /// **'Semana'**
  String get filterWeek;

  /// No description provided for @filterMonth.
  ///
  /// In pt, this message translates to:
  /// **'Mês'**
  String get filterMonth;

  /// No description provided for @filterMonthYear.
  ///
  /// In pt, this message translates to:
  /// **'Mês/Ano'**
  String get filterMonthYear;

  /// No description provided for @selectPeriodTitle.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar Período'**
  String get selectPeriodTitle;

  /// No description provided for @selectPeriodPlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar período'**
  String get selectPeriodPlaceholder;

  /// No description provided for @yearLabel.
  ///
  /// In pt, this message translates to:
  /// **'ANO'**
  String get yearLabel;

  /// No description provided for @monthOptionalLabel.
  ///
  /// In pt, this message translates to:
  /// **'MÊS (OPCIONAL)'**
  String get monthOptionalLabel;

  /// No description provided for @today.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In pt, this message translates to:
  /// **'Ontem'**
  String get yesterday;

  /// No description provided for @activityCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 atividade} other{{count} atividades}}'**
  String activityCount(num count);

  /// No description provided for @historyEmptyNoResults.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum resultado encontrado'**
  String get historyEmptyNoResults;

  /// No description provided for @historyEmptyNoActivity.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma atividade registrada'**
  String get historyEmptyNoActivity;

  /// No description provided for @historyEmptySearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Tente outro termo ou remova os filtros'**
  String get historyEmptySearchHint;

  /// No description provided for @historyEmptyActivityHint.
  ///
  /// In pt, this message translates to:
  /// **'Inicie uma atividade no RootFlow\npara ver seu histórico aqui'**
  String get historyEmptyActivityHint;

  /// No description provided for @exportNoActivity.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma atividade para exportar.'**
  String get exportNoActivity;

  /// No description provided for @energyAtiva.
  ///
  /// In pt, this message translates to:
  /// **'Ativa'**
  String get energyAtiva;

  /// No description provided for @energyPassiva.
  ///
  /// In pt, this message translates to:
  /// **'Passiva'**
  String get energyPassiva;

  /// No description provided for @organMente.
  ///
  /// In pt, this message translates to:
  /// **'Mente'**
  String get organMente;

  /// No description provided for @organCorpo.
  ///
  /// In pt, this message translates to:
  /// **'Corpo'**
  String get organCorpo;

  /// No description provided for @organEspirito.
  ///
  /// In pt, this message translates to:
  /// **'Espírito'**
  String get organEspirito;

  /// No description provided for @organCorpoMente.
  ///
  /// In pt, this message translates to:
  /// **'Corpo/Mente'**
  String get organCorpoMente;

  /// No description provided for @flowFacil.
  ///
  /// In pt, this message translates to:
  /// **'Fácil'**
  String get flowFacil;

  /// No description provided for @flowFacilMedio.
  ///
  /// In pt, this message translates to:
  /// **'Fácil – Médio'**
  String get flowFacilMedio;

  /// No description provided for @flowMedio.
  ///
  /// In pt, this message translates to:
  /// **'Médio'**
  String get flowMedio;

  /// No description provided for @flowMedioDificil.
  ///
  /// In pt, this message translates to:
  /// **'Médio – Difícil'**
  String get flowMedioDificil;

  /// No description provided for @flowDificil.
  ///
  /// In pt, this message translates to:
  /// **'Difícil'**
  String get flowDificil;

  /// No description provided for @categoryEspiritualidade.
  ///
  /// In pt, this message translates to:
  /// **'Espiritualidade'**
  String get categoryEspiritualidade;

  /// No description provided for @categoryAprendizado.
  ///
  /// In pt, this message translates to:
  /// **'Aprendizado'**
  String get categoryAprendizado;

  /// No description provided for @categoryTrabalho.
  ///
  /// In pt, this message translates to:
  /// **'Trabalho'**
  String get categoryTrabalho;

  /// No description provided for @categorySaude.
  ///
  /// In pt, this message translates to:
  /// **'Saúde'**
  String get categorySaude;

  /// No description provided for @categoryLazer.
  ///
  /// In pt, this message translates to:
  /// **'Lazer'**
  String get categoryLazer;

  /// No description provided for @categorySocial.
  ///
  /// In pt, this message translates to:
  /// **'Social'**
  String get categorySocial;

  /// No description provided for @categoryCriacao.
  ///
  /// In pt, this message translates to:
  /// **'Criação'**
  String get categoryCriacao;

  /// No description provided for @categoryNatureza.
  ///
  /// In pt, this message translates to:
  /// **'Natureza'**
  String get categoryNatureza;

  /// No description provided for @categoryAutocuidado.
  ///
  /// In pt, this message translates to:
  /// **'Autocuidado'**
  String get categoryAutocuidado;

  /// No description provided for @descEspiritualidade.
  ///
  /// In pt, this message translates to:
  /// **'Práticas para silenciar a mente e conectar-se com algo maior.'**
  String get descEspiritualidade;

  /// No description provided for @descAprendizado.
  ///
  /// In pt, this message translates to:
  /// **'Atividades que expandem o conhecimento e desenvolvem novas habilidades.'**
  String get descAprendizado;

  /// No description provided for @descTrabalho.
  ///
  /// In pt, this message translates to:
  /// **'Foco e produtividade com presença e intenção.'**
  String get descTrabalho;

  /// No description provided for @descSaude.
  ///
  /// In pt, this message translates to:
  /// **'Movimento, cuidado físico e vitalidade do corpo.'**
  String get descSaude;

  /// No description provided for @descLazer.
  ///
  /// In pt, this message translates to:
  /// **'Momentos de alegria, diversão e descanso ativo.'**
  String get descLazer;

  /// No description provided for @descSocial.
  ///
  /// In pt, this message translates to:
  /// **'Conexões humanas que nutrem e fortalecem os vínculos.'**
  String get descSocial;

  /// No description provided for @descCriacao.
  ///
  /// In pt, this message translates to:
  /// **'Expressão artística e criativa como forma de meditação ativa.'**
  String get descCriacao;

  /// No description provided for @descNatureza.
  ///
  /// In pt, this message translates to:
  /// **'Reencontro com a natureza e o ritmo do mundo natural.'**
  String get descNatureza;

  /// No description provided for @descAutocuidado.
  ///
  /// In pt, this message translates to:
  /// **'Práticas para nutrir o corpo e recuperar a energia vital.'**
  String get descAutocuidado;

  /// No description provided for @descDefault.
  ///
  /// In pt, this message translates to:
  /// **'Práticas conscientes para desenvolver presença e atenção plena no dia a dia.'**
  String get descDefault;

  /// No description provided for @practiceAlongamento.
  ///
  /// In pt, this message translates to:
  /// **'Alongamento'**
  String get practiceAlongamento;

  /// No description provided for @practiceApresentacao.
  ///
  /// In pt, this message translates to:
  /// **'Apresentação'**
  String get practiceApresentacao;

  /// No description provided for @practiceAssistir.
  ///
  /// In pt, this message translates to:
  /// **'Assistir'**
  String get practiceAssistir;

  /// No description provided for @practiceAutoMassagem.
  ///
  /// In pt, this message translates to:
  /// **'Auto-massagem'**
  String get practiceAutoMassagem;

  /// No description provided for @practiceAcampar.
  ///
  /// In pt, this message translates to:
  /// **'Acampar'**
  String get practiceAcampar;

  /// No description provided for @practiceBanhoRelaxante.
  ///
  /// In pt, this message translates to:
  /// **'Banho relaxante'**
  String get practiceBanhoRelaxante;

  /// No description provided for @practiceBar.
  ///
  /// In pt, this message translates to:
  /// **'Bar'**
  String get practiceBar;

  /// No description provided for @practiceCaminhar.
  ///
  /// In pt, this message translates to:
  /// **'Caminhar'**
  String get practiceCaminhar;

  /// No description provided for @practiceChat.
  ///
  /// In pt, this message translates to:
  /// **'Chat'**
  String get practiceChat;

  /// No description provided for @practiceContemplacaoPaisagem.
  ///
  /// In pt, this message translates to:
  /// **'Contemplar paisagem'**
  String get practiceContemplacaoPaisagem;

  /// No description provided for @practiceConversar.
  ///
  /// In pt, this message translates to:
  /// **'Conversar'**
  String get practiceConversar;

  /// No description provided for @practiceCorrida.
  ///
  /// In pt, this message translates to:
  /// **'Correr'**
  String get practiceCorrida;

  /// No description provided for @practiceCozinhar.
  ///
  /// In pt, this message translates to:
  /// **'Cozinhar'**
  String get practiceCozinhar;

  /// No description provided for @practiceCursoOnline.
  ///
  /// In pt, this message translates to:
  /// **'Curso online'**
  String get practiceCursoOnline;

  /// No description provided for @practiceConsultaMedica.
  ///
  /// In pt, this message translates to:
  /// **'Consulta médica'**
  String get practiceConsultaMedica;

  /// No description provided for @practiceDancar.
  ///
  /// In pt, this message translates to:
  /// **'Dançar'**
  String get practiceDancar;

  /// No description provided for @practiceDesenhar.
  ///
  /// In pt, this message translates to:
  /// **'Desenhar'**
  String get practiceDesenhar;

  /// No description provided for @practiceEstudar.
  ///
  /// In pt, this message translates to:
  /// **'Estudar'**
  String get practiceEstudar;

  /// No description provided for @practiceEscrever.
  ///
  /// In pt, this message translates to:
  /// **'Escrever'**
  String get practiceEscrever;

  /// No description provided for @practiceEventoSocial.
  ///
  /// In pt, this message translates to:
  /// **'Evento social'**
  String get practiceEventoSocial;

  /// No description provided for @practiceFotografar.
  ///
  /// In pt, this message translates to:
  /// **'Fotografar'**
  String get practiceFotografar;

  /// No description provided for @practiceHIIT.
  ///
  /// In pt, this message translates to:
  /// **'HIIT'**
  String get practiceHIIT;

  /// No description provided for @practiceJardinagem.
  ///
  /// In pt, this message translates to:
  /// **'Jardinagem'**
  String get practiceJardinagem;

  /// No description provided for @practiceJejum.
  ///
  /// In pt, this message translates to:
  /// **'Jejum'**
  String get practiceJejum;

  /// No description provided for @practiceJogar.
  ///
  /// In pt, this message translates to:
  /// **'Jogar'**
  String get practiceJogar;

  /// No description provided for @practiceLer.
  ///
  /// In pt, this message translates to:
  /// **'Ler'**
  String get practiceLer;

  /// No description provided for @practiceLigarAmigo.
  ///
  /// In pt, this message translates to:
  /// **'Ligar para amigo'**
  String get practiceLigarAmigo;

  /// No description provided for @practiceMacaquear.
  ///
  /// In pt, this message translates to:
  /// **'Macaquear'**
  String get practiceMacaquear;

  /// No description provided for @practiceMalabares.
  ///
  /// In pt, this message translates to:
  /// **'Malabares'**
  String get practiceMalabares;

  /// No description provided for @practiceMassagem.
  ///
  /// In pt, this message translates to:
  /// **'Massagem'**
  String get practiceMassagem;

  /// No description provided for @practiceMeditar.
  ///
  /// In pt, this message translates to:
  /// **'Meditar'**
  String get practiceMeditar;

  /// No description provided for @practiceMusica.
  ///
  /// In pt, this message translates to:
  /// **'Música'**
  String get practiceMusica;

  /// No description provided for @practiceNaoFazerNada.
  ///
  /// In pt, this message translates to:
  /// **'Não fazer nada'**
  String get practiceNaoFazerNada;

  /// No description provided for @practiceOrganizarTarefas.
  ///
  /// In pt, this message translates to:
  /// **'Organizar tarefas'**
  String get practiceOrganizarTarefas;

  /// No description provided for @practiceOrar.
  ///
  /// In pt, this message translates to:
  /// **'Orar'**
  String get practiceOrar;

  /// No description provided for @practiceOuvirAudiolivro.
  ///
  /// In pt, this message translates to:
  /// **'Ouvir audiolivro'**
  String get practiceOuvirAudiolivro;

  /// No description provided for @practicePlanejamento.
  ///
  /// In pt, this message translates to:
  /// **'Planejamento'**
  String get practicePlanejamento;

  /// No description provided for @practicePlanejar.
  ///
  /// In pt, this message translates to:
  /// **'Planejar'**
  String get practicePlanejar;

  /// No description provided for @practicePodcastEducativo.
  ///
  /// In pt, this message translates to:
  /// **'Podcast educativo'**
  String get practicePodcastEducativo;

  /// No description provided for @practiceProjetosPessoais.
  ///
  /// In pt, this message translates to:
  /// **'Projetos pessoais'**
  String get practiceProjetosPessoais;

  /// No description provided for @practiceReuniaoTrabalho.
  ///
  /// In pt, this message translates to:
  /// **'Reunião'**
  String get practiceReuniaoTrabalho;

  /// No description provided for @practiceRespiracaoConsciente.
  ///
  /// In pt, this message translates to:
  /// **'Respiração consciente'**
  String get practiceRespiracaoConsciente;

  /// No description provided for @practiceRetiroEspiritual.
  ///
  /// In pt, this message translates to:
  /// **'Retiro espiritual'**
  String get practiceRetiroEspiritual;

  /// No description provided for @practiceSkinCare.
  ///
  /// In pt, this message translates to:
  /// **'Skin care'**
  String get practiceSkinCare;

  /// No description provided for @practiceSpaDay.
  ///
  /// In pt, this message translates to:
  /// **'Spa day'**
  String get practiceSpaDay;

  /// No description provided for @practiceTrilhas.
  ///
  /// In pt, this message translates to:
  /// **'Trilhas'**
  String get practiceTrilhas;

  /// No description provided for @practiceTrabalhoRemunerado.
  ///
  /// In pt, this message translates to:
  /// **'Trabalho remunerado'**
  String get practiceTrabalhoRemunerado;

  /// No description provided for @practiceYoga.
  ///
  /// In pt, this message translates to:
  /// **'Yoga'**
  String get practiceYoga;

  /// No description provided for @welcomeBack.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo(a) de volta!'**
  String get welcomeBack;

  /// No description provided for @greetingMorning.
  ///
  /// In pt, this message translates to:
  /// **'Bom dia! 🌅'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In pt, this message translates to:
  /// **'Boa tarde! 🌞'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In pt, this message translates to:
  /// **'Boa noite! 🌙'**
  String get greetingEvening;

  /// No description provided for @homeBalanceToday.
  ///
  /// In pt, this message translates to:
  /// **'Equilíbrio hoje'**
  String get homeBalanceToday;

  /// No description provided for @homePracticesToday.
  ///
  /// In pt, this message translates to:
  /// **'práticas hoje'**
  String get homePracticesToday;

  /// No description provided for @homeTotalPractices.
  ///
  /// In pt, this message translates to:
  /// **'total práticas'**
  String get homeTotalPractices;

  /// No description provided for @homeFlowLevels.
  ///
  /// In pt, this message translates to:
  /// **'Níveis de Flow'**
  String get homeFlowLevels;

  /// No description provided for @homeExplorePractices.
  ///
  /// In pt, this message translates to:
  /// **'✨ Explorar Práticas'**
  String get homeExplorePractices;

  /// No description provided for @homeDiscoverActivities.
  ///
  /// In pt, this message translates to:
  /// **'Descubra novas atividades'**
  String get homeDiscoverActivities;

  /// No description provided for @homeActNow.
  ///
  /// In pt, this message translates to:
  /// **'⚡ Agir Agora'**
  String get homeActNow;

  /// No description provided for @homePersonalizedSuggestions.
  ///
  /// In pt, this message translates to:
  /// **'Sugestões personalizadas para você'**
  String get homePersonalizedSuggestions;

  /// No description provided for @homeDominantBody.
  ///
  /// In pt, this message translates to:
  /// **'Corpo {percent}%'**
  String homeDominantBody(int percent);

  /// No description provided for @homeDominantMind.
  ///
  /// In pt, this message translates to:
  /// **'Mental {percent}%'**
  String homeDominantMind(int percent);

  /// No description provided for @homeDominantSpirit.
  ///
  /// In pt, this message translates to:
  /// **'Espírito {percent}%'**
  String homeDominantSpirit(int percent);

  /// No description provided for @homeDominantDefault.
  ///
  /// In pt, this message translates to:
  /// **'Mental 70%'**
  String get homeDominantDefault;

  /// No description provided for @motivationSmallSteps.
  ///
  /// In pt, this message translates to:
  /// **'✨ Pequenos passos todos os dias levam a grandes mudanças'**
  String get motivationSmallSteps;

  /// No description provided for @motivationCloser.
  ///
  /// In pt, this message translates to:
  /// **'🌟 Você está mais perto do que imagina'**
  String get motivationCloser;

  /// No description provided for @motivationBelieve.
  ///
  /// In pt, this message translates to:
  /// **'💪 Acredite no seu potencial'**
  String get motivationBelieve;

  /// No description provided for @motivationFocusProcess.
  ///
  /// In pt, this message translates to:
  /// **'🎯 Foco no processo, não apenas no resultado'**
  String get motivationFocusProcess;

  /// No description provided for @motivationSeed.
  ///
  /// In pt, this message translates to:
  /// **'🌱 Cada prática é uma semente para o futuro'**
  String get motivationSeed;

  /// No description provided for @motivationFutureSelf.
  ///
  /// In pt, this message translates to:
  /// **'🔥 Seu eu do futuro vai agradecer'**
  String get motivationFutureSelf;

  /// No description provided for @motivationAction.
  ///
  /// In pt, this message translates to:
  /// **'⚡ Um minuto de ação vale mais que horas de planejamento'**
  String get motivationAction;

  /// No description provided for @motivationJourney.
  ///
  /// In pt, this message translates to:
  /// **'🌈 A jornada é tão importante quanto o destino'**
  String get motivationJourney;

  /// No description provided for @motivationBreathe.
  ///
  /// In pt, this message translates to:
  /// **'🍃 Respire, concentre-se e siga em frente'**
  String get motivationBreathe;

  /// No description provided for @motivationCapable.
  ///
  /// In pt, this message translates to:
  /// **'⭐ Você é capaz de coisas incríveis'**
  String get motivationCapable;

  /// No description provided for @motivationPresence.
  ///
  /// In pt, this message translates to:
  /// **'🎨 Crie momentos de presença hoje'**
  String get motivationPresence;

  /// No description provided for @motivationCare.
  ///
  /// In pt, this message translates to:
  /// **'💙 Cuide de você como cuidaria de um amigo'**
  String get motivationCare;

  /// No description provided for @statTotalTime.
  ///
  /// In pt, this message translates to:
  /// **'Tempo total'**
  String get statTotalTime;

  /// No description provided for @statActivities.
  ///
  /// In pt, this message translates to:
  /// **'Atividades'**
  String get statActivities;

  /// No description provided for @statStreak.
  ///
  /// In pt, this message translates to:
  /// **'Sequência'**
  String get statStreak;

  /// No description provided for @last7Days.
  ///
  /// In pt, this message translates to:
  /// **'ÚLTIMOS 7 DIAS'**
  String get last7Days;

  /// No description provided for @cardBalanceCategories.
  ///
  /// In pt, this message translates to:
  /// **'Equilíbrio entre Categorias'**
  String get cardBalanceCategories;

  /// No description provided for @notPracticed.
  ///
  /// In pt, this message translates to:
  /// **'Não praticado: {categories}'**
  String notPracticed(String categories);

  /// No description provided for @trySuggestion.
  ///
  /// In pt, this message translates to:
  /// **'✨ Experimente: {category}'**
  String trySuggestion(String category);

  /// No description provided for @totalUPsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Total: {ups} UPs em {count} atividades'**
  String totalUPsLabel(String ups, int count);

  /// No description provided for @relativeBarsNote.
  ///
  /// In pt, this message translates to:
  /// **'* barras relativas ao maior valor'**
  String get relativeBarsNote;

  /// No description provided for @cardEnergyBalance.
  ///
  /// In pt, this message translates to:
  /// **'Balanço Energético'**
  String get cardEnergyBalance;

  /// No description provided for @energyActivePill.
  ///
  /// In pt, this message translates to:
  /// **'⚡ Ativa'**
  String get energyActivePill;

  /// No description provided for @energyPassivePill.
  ///
  /// In pt, this message translates to:
  /// **'🍃 Passiva'**
  String get energyPassivePill;

  /// No description provided for @cardFlowDistribution.
  ///
  /// In pt, this message translates to:
  /// **'Distribuição do Flow'**
  String get cardFlowDistribution;

  /// No description provided for @cardFocusDimension.
  ///
  /// In pt, this message translates to:
  /// **'Foco por Dimensão'**
  String get cardFocusDimension;

  /// No description provided for @cardAvgConsciousness.
  ///
  /// In pt, this message translates to:
  /// **'Consciência Média'**
  String get cardAvgConsciousness;

  /// No description provided for @consciousnessHint.
  ///
  /// In pt, this message translates to:
  /// **'Responda o feedback rápido após cada atividade para desbloquear suas métricas de consciência.'**
  String get consciousnessHint;

  /// No description provided for @stateFlowing.
  ///
  /// In pt, this message translates to:
  /// **'Fluindo'**
  String get stateFlowing;

  /// No description provided for @stateFocused.
  ///
  /// In pt, this message translates to:
  /// **'Focado'**
  String get stateFocused;

  /// No description provided for @statePresent.
  ///
  /// In pt, this message translates to:
  /// **'Presente'**
  String get statePresent;

  /// No description provided for @stateAutomatic.
  ///
  /// In pt, this message translates to:
  /// **'Automático'**
  String get stateAutomatic;

  /// No description provided for @moreAutomatic.
  ///
  /// In pt, this message translates to:
  /// **'← mais automático'**
  String get moreAutomatic;

  /// No description provided for @moreConscious.
  ///
  /// In pt, this message translates to:
  /// **'mais consciente →'**
  String get moreConscious;

  /// No description provided for @activitiesWithFeedback.
  ///
  /// In pt, this message translates to:
  /// **'{count} atividades com feedback'**
  String activitiesWithFeedback(int count);

  /// No description provided for @cardFlowVsChallenge.
  ///
  /// In pt, this message translates to:
  /// **'Flow vs Desafio'**
  String get cardFlowVsChallenge;

  /// No description provided for @flowChallengeHint.
  ///
  /// In pt, this message translates to:
  /// **'Ao finalizar cada atividade, avalie a dificuldade e seu nível de flow para desbloquear este gráfico.'**
  String get flowChallengeHint;

  /// No description provided for @flowPeak.
  ///
  /// In pt, this message translates to:
  /// **'Pico: {zone} {percent}%'**
  String flowPeak(String zone, int percent);

  /// No description provided for @flowZoneEasy.
  ///
  /// In pt, this message translates to:
  /// **'🌊 Fácil'**
  String get flowZoneEasy;

  /// No description provided for @flowZoneMedium.
  ///
  /// In pt, this message translates to:
  /// **'⚡ Médio'**
  String get flowZoneMedium;

  /// No description provided for @flowZoneHard.
  ///
  /// In pt, this message translates to:
  /// **'🔥 Difícil'**
  String get flowZoneHard;

  /// No description provided for @flowActivitiesCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} ativ.'**
  String flowActivitiesCount(int count);

  /// No description provided for @flowRatePercent.
  ///
  /// In pt, this message translates to:
  /// **'{percent}% flow'**
  String flowRatePercent(int percent);

  /// No description provided for @flowInZone.
  ///
  /// In pt, this message translates to:
  /// **'Você entra em flow principalmente em atividades {zone}. Este é seu ponto ideal!'**
  String flowInZone(String zone);

  /// No description provided for @flowDistributedMsg.
  ///
  /// In pt, this message translates to:
  /// **'Flow distribuído. Varie a dificuldade para encontrar seu ponto ideal.'**
  String get flowDistributedMsg;

  /// No description provided for @flowLowMsg.
  ///
  /// In pt, this message translates to:
  /// **'Poucos momentos de flow. Tente ajustar: nem tão fácil que entedie, nem tão difícil que frustre.'**
  String get flowLowMsg;

  /// No description provided for @cardChallengeIndex.
  ///
  /// In pt, this message translates to:
  /// **'Índice de Desafio'**
  String get cardChallengeIndex;

  /// No description provided for @challengeHigh.
  ///
  /// In pt, this message translates to:
  /// **'🔥 Alta intensidade'**
  String get challengeHigh;

  /// No description provided for @challengeModerate.
  ///
  /// In pt, this message translates to:
  /// **'⚡ Moderado'**
  String get challengeModerate;

  /// No description provided for @challengeSmooth.
  ///
  /// In pt, this message translates to:
  /// **'🌊 Fluxo tranquilo'**
  String get challengeSmooth;

  /// No description provided for @challengeScale.
  ///
  /// In pt, this message translates to:
  /// **'0 = Suave · 100 = Intenso'**
  String get challengeScale;

  /// No description provided for @cardTopCategories.
  ///
  /// In pt, this message translates to:
  /// **'Top Categorias'**
  String get cardTopCategories;

  /// No description provided for @cardRecentActivities.
  ///
  /// In pt, this message translates to:
  /// **'Atividades Recentes'**
  String get cardRecentActivities;

  /// No description provided for @customizeScreenTitle.
  ///
  /// In pt, this message translates to:
  /// **'Categorias'**
  String get customizeScreenTitle;

  /// No description provided for @myCategories.
  ///
  /// In pt, this message translates to:
  /// **'✨ MINHAS CATEGORIAS'**
  String get myCategories;

  /// No description provided for @newCategory.
  ///
  /// In pt, this message translates to:
  /// **'Nova Categoria'**
  String get newCategory;

  /// No description provided for @defaultCategories.
  ///
  /// In pt, this message translates to:
  /// **'📦 CATEGORIAS PADRÃO'**
  String get defaultCategories;

  /// No description provided for @emptyCustomCategories.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma categoria personalizada.\nToque em \"Nova Categoria\" para criar!'**
  String get emptyCustomCategories;

  /// No description provided for @practicesCountLabel.
  ///
  /// In pt, this message translates to:
  /// **'{count} prática(s)'**
  String practicesCountLabel(int count);

  /// No description provided for @noPracticesAddTip.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma prática — toque em + para adicionar'**
  String get noPracticesAddTip;

  /// No description provided for @addPracticeToCategory.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar prática'**
  String get addPracticeToCategory;

  /// No description provided for @removeCategoryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Remover?'**
  String get removeCategoryTitle;

  /// No description provided for @removeCategoryMessage.
  ///
  /// In pt, this message translates to:
  /// **'A categoria \"{name}\" será removida.'**
  String removeCategoryMessage(String name);

  /// No description provided for @removeCategoryBtn.
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get removeCategoryBtn;

  /// No description provided for @editCategoryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar Categoria'**
  String get editCategoryTitle;

  /// No description provided for @newCategoryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nova Categoria'**
  String get newCategoryTitle;

  /// No description provided for @practicesAddedLater.
  ///
  /// In pt, this message translates to:
  /// **'As práticas são adicionadas depois'**
  String get practicesAddedLater;

  /// No description provided for @iconLabel.
  ///
  /// In pt, this message translates to:
  /// **'Ícone'**
  String get iconLabel;

  /// No description provided for @categoryNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome da categoria'**
  String get categoryNameLabel;

  /// No description provided for @categoryNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Yoga, Jardinagem...'**
  String get categoryNameHint;

  /// No description provided for @practicesFormLabel.
  ///
  /// In pt, this message translates to:
  /// **'Práticas'**
  String get practicesFormLabel;

  /// No description provided for @noPracticesYet.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma prática ainda'**
  String get noPracticesYet;

  /// No description provided for @saveBtn.
  ///
  /// In pt, this message translates to:
  /// **'SALVAR'**
  String get saveBtn;

  /// No description provided for @createCategoryBtn.
  ///
  /// In pt, this message translates to:
  /// **'CRIAR CATEGORIA'**
  String get createCategoryBtn;

  /// No description provided for @newPracticeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nova Prática'**
  String get newPracticeTitle;

  /// No description provided for @inCategoryPrefix.
  ///
  /// In pt, this message translates to:
  /// **'em '**
  String get inCategoryPrefix;

  /// No description provided for @practiceNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome da prática'**
  String get practiceNameLabel;

  /// No description provided for @practiceNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Meditação guiada, Leitura...'**
  String get practiceNameHint;

  /// No description provided for @energySectionLabel.
  ///
  /// In pt, this message translates to:
  /// **'⚡ Energia'**
  String get energySectionLabel;

  /// No description provided for @energySectionQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Qual tipo de energia essa prática mobiliza?'**
  String get energySectionQuestion;

  /// No description provided for @difficultySectionLabel.
  ///
  /// In pt, this message translates to:
  /// **'🌊 Dificuldade'**
  String get difficultySectionLabel;

  /// No description provided for @difficultySectionQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Qual o nível de esforço necessário?'**
  String get difficultySectionQuestion;

  /// No description provided for @focusSectionLabel.
  ///
  /// In pt, this message translates to:
  /// **'🎯 Foco'**
  String get focusSectionLabel;

  /// No description provided for @focusSectionQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Qual dimensão essa prática desenvolve?'**
  String get focusSectionQuestion;

  /// No description provided for @idealTimeSectionLabel.
  ///
  /// In pt, this message translates to:
  /// **'⏱️ Tempo ideal'**
  String get idealTimeSectionLabel;

  /// No description provided for @idealTimeSectionQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Quantos minutos representam uma prática completa e satisfatória?'**
  String get idealTimeSectionQuestion;

  /// No description provided for @idealTimeHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: 20'**
  String get idealTimeHint;

  /// No description provided for @idealTimeSuffix.
  ///
  /// In pt, this message translates to:
  /// **'min'**
  String get idealTimeSuffix;

  /// No description provided for @reminderSectionLabel.
  ///
  /// In pt, this message translates to:
  /// **'💛 Lembrete'**
  String get reminderSectionLabel;

  /// No description provided for @reminderSectionDescription.
  ///
  /// In pt, this message translates to:
  /// **'Tem algo que precisa lembrar antes de começar a prática? Preparações, aquecimento, meditação, propósito, pessoas que ama...'**
  String get reminderSectionDescription;

  /// No description provided for @reminderHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Respirar fundo antes, ligar para alguém especial...'**
  String get reminderHint;

  /// No description provided for @reminderBeforeStartTitle.
  ///
  /// In pt, this message translates to:
  /// **'Antes de começar...'**
  String get reminderBeforeStartTitle;

  /// No description provided for @reminderBeforeStartSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Você deixou um lembrete para essa prática 💛'**
  String get reminderBeforeStartSubtitle;

  /// No description provided for @reminderBeforeStartButton.
  ///
  /// In pt, this message translates to:
  /// **'ESTOU PRONTO — INICIAR'**
  String get reminderBeforeStartButton;

  /// No description provided for @addPracticeButton.
  ///
  /// In pt, this message translates to:
  /// **'ADICIONAR PRÁTICA'**
  String get addPracticeButton;

  /// No description provided for @settingsScreenTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsScreenTitle;

  /// No description provided for @settingsScreenSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Gerencie seus dados e preferências'**
  String get settingsScreenSubtitle;

  /// No description provided for @settingsSectionPreferences.
  ///
  /// In pt, this message translates to:
  /// **'PREFERÊNCIAS'**
  String get settingsSectionPreferences;

  /// No description provided for @settingsLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageDesc.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o idioma do aplicativo'**
  String get settingsLanguageDesc;

  /// No description provided for @languagePickerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolher idioma'**
  String get languagePickerTitle;

  /// No description provided for @languageSystemDefault.
  ///
  /// In pt, this message translates to:
  /// **'Automático (idioma do sistema)'**
  String get languageSystemDefault;

  /// No description provided for @languagePortuguese.
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// No description provided for @languageEnglish.
  ///
  /// In pt, this message translates to:
  /// **'Inglês'**
  String get languageEnglish;

  /// No description provided for @settingsSectionData.
  ///
  /// In pt, this message translates to:
  /// **'DADOS'**
  String get settingsSectionData;

  /// No description provided for @settingsSectionSupport.
  ///
  /// In pt, this message translates to:
  /// **'SUPORTE'**
  String get settingsSectionSupport;

  /// No description provided for @settingsExportData.
  ///
  /// In pt, this message translates to:
  /// **'Exportar dados'**
  String get settingsExportData;

  /// No description provided for @settingsExportDataDesc.
  ///
  /// In pt, this message translates to:
  /// **'Salve um backup de tudo que você registrou'**
  String get settingsExportDataDesc;

  /// No description provided for @settingsImportData.
  ///
  /// In pt, this message translates to:
  /// **'Importar dados'**
  String get settingsImportData;

  /// No description provided for @settingsImportDataDesc.
  ///
  /// In pt, this message translates to:
  /// **'Restaure um backup exportado anteriormente'**
  String get settingsImportDataDesc;

  /// No description provided for @settingsClearData.
  ///
  /// In pt, this message translates to:
  /// **'Limpar todos os dados'**
  String get settingsClearData;

  /// No description provided for @settingsClearDataDesc.
  ///
  /// In pt, this message translates to:
  /// **'Remove permanentemente seu histórico e personalizações'**
  String get settingsClearDataDesc;

  /// No description provided for @settingsFaq.
  ///
  /// In pt, this message translates to:
  /// **'Perguntas frequentes'**
  String get settingsFaq;

  /// No description provided for @settingsAbout.
  ///
  /// In pt, this message translates to:
  /// **'Sobre o app'**
  String get settingsAbout;

  /// No description provided for @settingsVisitSite.
  ///
  /// In pt, this message translates to:
  /// **'Visitar nosso site'**
  String get settingsVisitSite;

  /// No description provided for @exportSuccessMessage.
  ///
  /// In pt, this message translates to:
  /// **'Dados exportados com sucesso!'**
  String get exportSuccessMessage;

  /// No description provided for @exportEmptyMessage.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum dado para exportar ainda.'**
  String get exportEmptyMessage;

  /// No description provided for @exportShareSubject.
  ///
  /// In pt, this message translates to:
  /// **'Root Flow — Backup de dados'**
  String get exportShareSubject;

  /// No description provided for @importConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Importar dados?'**
  String get importConfirmTitle;

  /// No description provided for @importConfirmMessage.
  ///
  /// In pt, this message translates to:
  /// **'{logs} atividades e {categories} categorias serão adicionadas ou atualizadas. Seus dados atuais não serão apagados.'**
  String importConfirmMessage(int logs, int categories);

  /// No description provided for @importConfirmBtn.
  ///
  /// In pt, this message translates to:
  /// **'Importar'**
  String get importConfirmBtn;

  /// No description provided for @importSuccessMessage.
  ///
  /// In pt, this message translates to:
  /// **'Dados importados! Reinicie o app para ver tudo atualizado em todas as telas.'**
  String get importSuccessMessage;

  /// No description provided for @importErrorMessage.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível importar este arquivo. Verifique se é um backup válido do Root Flow.'**
  String get importErrorMessage;

  /// No description provided for @importEmptyFile.
  ///
  /// In pt, this message translates to:
  /// **'O arquivo selecionado não contém dados para importar.'**
  String get importEmptyFile;

  /// No description provided for @clearDataConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Limpar todos os dados?'**
  String get clearDataConfirmTitle;

  /// No description provided for @clearDataConfirmMessage.
  ///
  /// In pt, this message translates to:
  /// **'Isso vai remover permanentemente todo o seu histórico de atividades e categorias personalizadas. Essa ação não pode ser desfeita.'**
  String get clearDataConfirmMessage;

  /// No description provided for @clearDataConfirmBtn.
  ///
  /// In pt, this message translates to:
  /// **'Limpar tudo'**
  String get clearDataConfirmBtn;

  /// No description provided for @clearDataSuccessMessage.
  ///
  /// In pt, this message translates to:
  /// **'Todos os dados foram removidos.'**
  String get clearDataSuccessMessage;

  /// No description provided for @faqQ1.
  ///
  /// In pt, this message translates to:
  /// **'Como funciona o Root Flow?'**
  String get faqQ1;

  /// No description provided for @faqA1.
  ///
  /// In pt, this message translates to:
  /// **'Você escolhe uma categoria (como Saúde, Trabalho ou Lazer) e uma prática dentro dela, inicia o timer e registra o quanto praticou. Tudo aparece depois no Dashboard e no Histórico para você acompanhar sua evolução.'**
  String get faqA1;

  /// No description provided for @faqQ2.
  ///
  /// In pt, this message translates to:
  /// **'O que é o Match?'**
  String get faqQ2;

  /// No description provided for @faqA2.
  ///
  /// In pt, this message translates to:
  /// **'É a tela de cartões (🌼) que sugere práticas combinando com seu momento atual. Deslize para o lado para ver outras sugestões, ou toque em uma para começar.'**
  String get faqA2;

  /// No description provided for @faqQ3.
  ///
  /// In pt, this message translates to:
  /// **'O que são UPs?'**
  String get faqQ3;

  /// No description provided for @faqA3.
  ///
  /// In pt, this message translates to:
  /// **'UPs (Unidades de Prática) medem o quanto você praticou uma atividade em relação ao tempo ideal definido para ela.'**
  String get faqA3;

  /// No description provided for @faqQ4.
  ///
  /// In pt, this message translates to:
  /// **'Como funcionam os modos de Timer?'**
  String get faqQ4;

  /// No description provided for @faqA4.
  ///
  /// In pt, this message translates to:
  /// **'Ao iniciar uma prática você escolhe entre 4 modos: Cronômetro (conta livremente), Pomodoro (ciclos de foco com pausas), Manual (você digita o tempo já praticado) e HIIT (intervalos de treino intenso).'**
  String get faqA4;

  /// No description provided for @faqQ5.
  ///
  /// In pt, this message translates to:
  /// **'O que é o Índice de Equilíbrio?'**
  String get faqQ5;

  /// No description provided for @faqA5.
  ///
  /// In pt, this message translates to:
  /// **'É a métrica do Dashboard que mostra o quão distribuído está seu tempo entre as categorias praticadas. Quanto mais perto de 100%, mais equilibrada está sua rotina.'**
  String get faqA5;

  /// No description provided for @faqQ6.
  ///
  /// In pt, this message translates to:
  /// **'O que é o feedback de consciência depois de uma atividade?'**
  String get faqQ6;

  /// No description provided for @faqA6.
  ///
  /// In pt, this message translates to:
  /// **'Ao concluir uma prática, você avalia como se sentiu (do automático ao fluindo) e o nível de dificuldade. Isso alimenta o gráfico \"Flow vs Desafio\" do Dashboard, ajudando a identificar em qual nível de desafio você mais entra em flow.'**
  String get faqA6;

  /// No description provided for @faqQ7.
  ///
  /// In pt, this message translates to:
  /// **'Onde meus dados são salvos?'**
  String get faqQ7;

  /// No description provided for @faqA7.
  ///
  /// In pt, this message translates to:
  /// **'Tudo fica salvo localmente no seu dispositivo. O Root Flow não envia nada para servidores ou para a nuvem.'**
  String get faqA7;

  /// No description provided for @faqQ8.
  ///
  /// In pt, this message translates to:
  /// **'Como faço backup dos meus dados?'**
  String get faqQ8;

  /// No description provided for @faqA8.
  ///
  /// In pt, this message translates to:
  /// **'Use \"Exportar dados\" no menu de Configurações para gerar um arquivo de backup que você pode guardar ou compartilhar.'**
  String get faqA8;

  /// No description provided for @faqQ9.
  ///
  /// In pt, this message translates to:
  /// **'Posso usar o app em outro celular?'**
  String get faqQ9;

  /// No description provided for @faqA9.
  ///
  /// In pt, this message translates to:
  /// **'Sim. Exporte os dados no aparelho atual e importe o mesmo arquivo no celular novo.'**
  String get faqA9;

  /// No description provided for @faqQ10.
  ///
  /// In pt, this message translates to:
  /// **'Posso excluir uma categoria ou prática padrão?'**
  String get faqQ10;

  /// No description provided for @faqA10.
  ///
  /// In pt, this message translates to:
  /// **'Sim. Na tela de Customizar você pode excluir qualquer categoria, mesmo as padrão — a exclusão é permanente.'**
  String get faqA10;

  /// No description provided for @faqQ11.
  ///
  /// In pt, this message translates to:
  /// **'Perdi meus dados, é possível recuperar?'**
  String get faqQ11;

  /// No description provided for @faqA11.
  ///
  /// In pt, this message translates to:
  /// **'Só se você tiver exportado um backup antes. Sem um arquivo de backup, não é possível recuperar dados removidos.'**
  String get faqA11;

  /// No description provided for @aboutAppDescription.
  ///
  /// In pt, this message translates to:
  /// **'Root Flow é um app de bem-estar que ajuda você a equilibrar energia, fluxo e foco através do registro consciente das suas atividades diárias.'**
  String get aboutAppDescription;

  /// No description provided for @aboutVersionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Versão'**
  String get aboutVersionLabel;

  /// No description provided for @aboutPrivacyNote.
  ///
  /// In pt, this message translates to:
  /// **'Todos os dados ficam armazenados apenas no seu dispositivo.'**
  String get aboutPrivacyNote;

  /// No description provided for @cantOpenLink.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir o link.'**
  String get cantOpenLink;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
