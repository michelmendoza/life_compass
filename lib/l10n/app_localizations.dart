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
