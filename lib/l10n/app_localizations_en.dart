// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'RootFlow';

  @override
  String get appTagline => 'Energy • Flow • Focus';

  @override
  String get navHome => 'Home';

  @override
  String get navMatch => 'Match';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navHistory => 'History';

  @override
  String get start => 'START';

  @override
  String get skip => 'SKIP';

  @override
  String get cancel => 'Cancel';

  @override
  String get apply => 'Apply';

  @override
  String get clear => 'Clear';

  @override
  String recordsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records',
      one: '1 record',
    );
    return '$_temp0';
  }

  @override
  String get consciousActionTitle => 'Conscious Action';

  @override
  String get consciousActionSubtitle => 'Choose with presence';

  @override
  String get areaLabel => '🍃 AREA OF PRACTICE';

  @override
  String get availablePracticesLabel => '📋 AVAILABLE PRACTICES';

  @override
  String practicesCount(int count) {
    return '$count practices';
  }

  @override
  String get selectCategoryFirst => 'Select a category first!';

  @override
  String get selectCategoryHint =>
      'Select a category\nto see available practices';

  @override
  String get dashboardTitle => 'Vital Dashboard';

  @override
  String get dashboardSubtitle => 'Your conscious evolution journey';

  @override
  String get dashboardEmptyTitle => 'No activity in this period';

  @override
  String get dashboardEmptySubtitle =>
      'Change the period or start an activity\nin RootFlow to see your metrics';

  @override
  String get periodToday => 'Today';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get periodAll => 'All';

  @override
  String get periodCurrent => 'CURRENT';

  @override
  String get periodPrevious => 'PREVIOUS';

  @override
  String periodDaysAgo(int count) {
    return '$count DAYS AGO';
  }

  @override
  String periodWeeksAgo(int count) {
    return '$count WEEKS AGO';
  }

  @override
  String periodMonthsAgo(int count) {
    return '$count MONTHS AGO';
  }

  @override
  String get backToCurrent => 'Back to current';

  @override
  String get statusVeryActive => '🔥 Very Active';

  @override
  String get statusContemplative => '🧘 Contemplative';

  @override
  String get statusBalanced => '⚖️ Balanced';

  @override
  String get statusTendingActive => '⚡ Tend. Active';

  @override
  String get statusTendingPassive => '🌿 Tend. Passive';

  @override
  String get statusNoData => 'No data';

  @override
  String get trendFirstRecords => 'First records! 🎉';

  @override
  String trendUp(int percent) {
    return '$percent% more than last period';
  }

  @override
  String trendDown(int percent) {
    return '$percent% less than last period';
  }

  @override
  String get suggestionStart =>
      'Start your first activity in RootFlow to see personalized insights! 🚀';

  @override
  String suggestionMultipleCategories(int count, String category) {
    return 'You haven\'t practiced $count categories yet. How about starting with \"$category\"? 🌱';
  }

  @override
  String suggestionOneCategory(String category) {
    return 'Just \"$category\" missing to diversify your practices! 🎯';
  }

  @override
  String suggestionLowBalance(String category) {
    return 'Your time is concentrated in few categories. Try \"$category\" to balance! ⚖️';
  }

  @override
  String suggestionHighBalance(int percent) {
    return 'Excellent balance! $percent% distribution among categories! ⭐';
  }

  @override
  String suggestionStreak(int days, String time) {
    return '$days days in a row! $time of practice! 🔥';
  }

  @override
  String get suggestionVary =>
      'Keep varying your activities for more complete development! 📊';

  @override
  String get matchTitle => 'Practice Match';

  @override
  String get matchSubtitle => 'Swipe → to start';

  @override
  String get currentProfileLabel => 'YOUR CURRENT PROFILE';

  @override
  String get swipeToExplore => 'Swipe to explore';

  @override
  String get swipeInstructions => 'Swipe sideways';

  @override
  String progressCount(int current, int total) {
    return '$current of $total';
  }

  @override
  String get statusEnergyHigh => 'High Energy';

  @override
  String get statusEnergyLow => 'Low Energy';

  @override
  String get statusEnergyBalanced => 'Balanced';

  @override
  String get statusOrganMindActive => 'Active Mind';

  @override
  String get statusOrganBodyActive => 'Active Body';

  @override
  String get statusOrganBalanced => 'Balanced';

  @override
  String get statusFlowChallenging => 'Challenging';

  @override
  String get statusFlowComfort => 'Comfortable';

  @override
  String get statusFlowBalanced => 'Balanced';

  @override
  String get insightNoData =>
      'No records in the last 7 days. Suggestions based on balanced practices.';

  @override
  String get insightBalanced =>
      'Your profile for the last 7 days is balanced. Keep it up!';

  @override
  String insightWithIssues(String issues) {
    return 'In the last 7 days: $issues. The suggestions below aim to compensate and rebalance.';
  }

  @override
  String get issueHighEnergy => 'high energy';

  @override
  String get issueLowEnergy => 'low energy';

  @override
  String get issueOverloadedMind => 'overloaded mind';

  @override
  String get issueVeryActiveBody => 'very active body';

  @override
  String get issueTooChallenging => 'too challenging practices';

  @override
  String get issueComfortZone => 'comfort zone';

  @override
  String get reasonBalanceEnergy => 'Balance energy';

  @override
  String get reasonAwakVitality => 'Awaken vitality';

  @override
  String get reasonActivateBody => 'Activate the body';

  @override
  String get reasonExerciseMind => 'Exercise the mind';

  @override
  String get reasonLighter => 'Something lighter';

  @override
  String get reasonChallenge => 'Leave the comfort zone';

  @override
  String get reasonDefault => 'Recommended for you';

  @override
  String get reasonPauseRenew => 'A moment of renewing pause';

  @override
  String get reasonConnectNature => 'Connect with nature';

  @override
  String get historyTitle => 'History';

  @override
  String get historySubtitle => 'Your recorded journey';

  @override
  String get searchHint => 'Search activity...';

  @override
  String get filterPeriodLabel => 'PERIOD';

  @override
  String get filterAll => 'All';

  @override
  String get filterToday => 'Today';

  @override
  String get filterWeek => 'Week';

  @override
  String get filterMonth => 'Month';

  @override
  String get filterMonthYear => 'Month/Year';

  @override
  String get selectPeriodTitle => 'Select Period';

  @override
  String get selectPeriodPlaceholder => 'Select period';

  @override
  String get yearLabel => 'YEAR';

  @override
  String get monthOptionalLabel => 'MONTH (OPTIONAL)';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String activityCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activities',
      one: '1 activity',
    );
    return '$_temp0';
  }

  @override
  String get historyEmptyNoResults => 'No results found';

  @override
  String get historyEmptyNoActivity => 'No activity recorded';

  @override
  String get historyEmptySearchHint => 'Try another term or remove the filters';

  @override
  String get historyEmptyActivityHint =>
      'Start an activity in RootFlow\nto see your history here';

  @override
  String get exportNoActivity => 'No activity to export.';

  @override
  String get energyAtiva => 'Active';

  @override
  String get energyPassiva => 'Passive';

  @override
  String get organMente => 'Mind';

  @override
  String get organCorpo => 'Body';

  @override
  String get organEspirito => 'Spirit';

  @override
  String get organCorpoMente => 'Body/Mind';

  @override
  String get flowFacil => 'Easy';

  @override
  String get flowFacilMedio => 'Easy – Medium';

  @override
  String get flowMedio => 'Medium';

  @override
  String get flowMedioDificil => 'Medium – Difficult';

  @override
  String get flowDificil => 'Difficult';

  @override
  String get categoryEspiritualidade => 'Spirituality';

  @override
  String get categoryAprendizado => 'Learning';

  @override
  String get categoryTrabalho => 'Work';

  @override
  String get categorySaude => 'Health';

  @override
  String get categoryLazer => 'Leisure';

  @override
  String get categorySocial => 'Social';

  @override
  String get categoryCriacao => 'Creation';

  @override
  String get categoryNatureza => 'Nature';

  @override
  String get categoryAutocuidado => 'Self-care';

  @override
  String get descEspiritualidade =>
      'Practices to quiet the mind and connect with something greater.';

  @override
  String get descAprendizado =>
      'Activities that expand knowledge and develop new skills.';

  @override
  String get descTrabalho =>
      'Focus and productivity with presence and intention.';

  @override
  String get descSaude => 'Movement, physical care and body vitality.';

  @override
  String get descLazer => 'Moments of joy, fun and active rest.';

  @override
  String get descSocial =>
      'Human connections that nourish and strengthen bonds.';

  @override
  String get descCriacao =>
      'Artistic and creative expression as a form of active meditation.';

  @override
  String get descNatureza =>
      'Reconnecting with nature and the rhythm of the natural world.';

  @override
  String get descAutocuidado =>
      'Practices to nourish the body and restore vital energy.';

  @override
  String get descDefault =>
      'Conscious practices to develop presence and mindfulness in daily life.';

  @override
  String get practiceAlongamento => 'Stretching';

  @override
  String get practiceApresentacao => 'Presentation';

  @override
  String get practiceAssistir => 'Watch';

  @override
  String get practiceAutoMassagem => 'Self-massage';

  @override
  String get practiceAcampar => 'Camping';

  @override
  String get practiceBanhoRelaxante => 'Relaxing bath';

  @override
  String get practiceBar => 'Bar';

  @override
  String get practiceCaminhar => 'Walk';

  @override
  String get practiceChat => 'Chat';

  @override
  String get practiceContemplacaoPaisagem => 'Contemplate landscape';

  @override
  String get practiceConversar => 'Talk';

  @override
  String get practiceCorrida => 'Run';

  @override
  String get practiceCozinhar => 'Cook';

  @override
  String get practiceCursoOnline => 'Online course';

  @override
  String get practiceConsultaMedica => 'Medical consultation';

  @override
  String get practiceDancar => 'Dance';

  @override
  String get practiceDesenhar => 'Draw';

  @override
  String get practiceEstudar => 'Study';

  @override
  String get practiceEscrever => 'Write';

  @override
  String get practiceEventoSocial => 'Social event';

  @override
  String get practiceFotografar => 'Photography';

  @override
  String get practiceHIIT => 'HIIT';

  @override
  String get practiceJardinagem => 'Gardening';

  @override
  String get practiceJejum => 'Fasting';

  @override
  String get practiceJogar => 'Play';

  @override
  String get practiceLer => 'Read';

  @override
  String get practiceLigarAmigo => 'Call a friend';

  @override
  String get practiceMacaquear => 'Physical play';

  @override
  String get practiceMalabares => 'Juggling';

  @override
  String get practiceMassagem => 'Massage';

  @override
  String get practiceMeditar => 'Meditate';

  @override
  String get practiceMusica => 'Music';

  @override
  String get practiceNaoFazerNada => 'Do nothing';

  @override
  String get practiceOrganizarTarefas => 'Organize tasks';

  @override
  String get practiceOrar => 'Pray';

  @override
  String get practiceOuvirAudiolivro => 'Listen to audiobook';

  @override
  String get practicePlanejamento => 'Planning';

  @override
  String get practicePlanejar => 'Plan';

  @override
  String get practicePodcastEducativo => 'Educational podcast';

  @override
  String get practiceProjetosPessoais => 'Personal projects';

  @override
  String get practiceReuniaoTrabalho => 'Meeting';

  @override
  String get practiceRespiracaoConsciente => 'Conscious breathing';

  @override
  String get practiceRetiroEspiritual => 'Spiritual retreat';

  @override
  String get practiceSkinCare => 'Skin care';

  @override
  String get practiceSpaDay => 'Spa day';

  @override
  String get practiceTrilhas => 'Hiking';

  @override
  String get practiceTrabalhoRemunerado => 'Paid work';

  @override
  String get practiceYoga => 'Yoga';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get greetingMorning => 'Good morning! 🌅';

  @override
  String get greetingAfternoon => 'Good afternoon! 🌞';

  @override
  String get greetingEvening => 'Good evening! 🌙';

  @override
  String get homeBalanceToday => 'Today\'s balance';

  @override
  String get homePracticesToday => 'practices today';

  @override
  String get homeTotalPractices => 'total practices';

  @override
  String get homeFlowLevels => 'Flow Levels';

  @override
  String get homeExplorePractices => '✨ Explore Practices';

  @override
  String get homeDiscoverActivities => 'Discover new activities';

  @override
  String get homeActNow => '⚡ Act Now';

  @override
  String get homePersonalizedSuggestions => 'Personalized suggestions for you';

  @override
  String homeDominantBody(int percent) {
    return 'Body $percent%';
  }

  @override
  String homeDominantMind(int percent) {
    return 'Mind $percent%';
  }

  @override
  String homeDominantSpirit(int percent) {
    return 'Spirit $percent%';
  }

  @override
  String get homeDominantDefault => 'Mind 70%';

  @override
  String get motivationSmallSteps =>
      '✨ Small steps every day lead to big changes';

  @override
  String get motivationCloser => '🌟 You are closer than you think';

  @override
  String get motivationBelieve => '💪 Believe in your potential';

  @override
  String get motivationFocusProcess =>
      '🎯 Focus on the process, not just the result';

  @override
  String get motivationSeed => '🌱 Each practice is a seed for the future';

  @override
  String get motivationFutureSelf => '🔥 Your future self will thank you';

  @override
  String get motivationAction =>
      '⚡ One minute of action is worth more than hours of planning';

  @override
  String get motivationJourney =>
      '🌈 The journey is as important as the destination';

  @override
  String get motivationBreathe => '🍃 Breathe, focus, and move forward';

  @override
  String get motivationCapable => '⭐ You are capable of incredible things';

  @override
  String get motivationPresence => '🎨 Create moments of presence today';

  @override
  String get motivationCare => '💙 Take care of yourself as you would a friend';

  @override
  String get statTotalTime => 'Total time';

  @override
  String get statActivities => 'Activities';

  @override
  String get statStreak => 'Streak';

  @override
  String get last7Days => 'LAST 7 DAYS';

  @override
  String get cardBalanceCategories => 'Balance Between Categories';

  @override
  String notPracticed(String categories) {
    return 'Not practiced: $categories';
  }

  @override
  String trySuggestion(String category) {
    return '✨ Try: $category';
  }

  @override
  String totalUPsLabel(String ups, int count) {
    return 'Total: $ups UPs in $count activities';
  }

  @override
  String get relativeBarsNote => '* bars relative to highest value';

  @override
  String get cardEnergyBalance => 'Energy Balance';

  @override
  String get energyActivePill => '⚡ Active';

  @override
  String get energyPassivePill => '🍃 Passive';

  @override
  String get cardFlowDistribution => 'Flow Distribution';

  @override
  String get cardFocusDimension => 'Focus by Dimension';

  @override
  String get cardAvgConsciousness => 'Average Consciousness';

  @override
  String get consciousnessHint =>
      'Answer the quick feedback after each activity to unlock your consciousness metrics.';

  @override
  String get stateFlowing => 'Flowing';

  @override
  String get stateFocused => 'Focused';

  @override
  String get statePresent => 'Present';

  @override
  String get stateAutomatic => 'Automatic';

  @override
  String get moreAutomatic => '← more automatic';

  @override
  String get moreConscious => 'more conscious →';

  @override
  String activitiesWithFeedback(int count) {
    return '$count activities with feedback';
  }

  @override
  String get cardFlowVsChallenge => 'Flow vs Challenge';

  @override
  String get flowChallengeHint =>
      'After completing each activity, rate the difficulty and your flow level to unlock this chart.';

  @override
  String flowPeak(String zone, int percent) {
    return 'Peak: $zone $percent%';
  }

  @override
  String get flowZoneEasy => '🌊 Easy';

  @override
  String get flowZoneMedium => '⚡ Medium';

  @override
  String get flowZoneHard => '🔥 Difficult';

  @override
  String flowActivitiesCount(int count) {
    return '$count act.';
  }

  @override
  String flowRatePercent(int percent) {
    return '$percent% flow';
  }

  @override
  String flowInZone(String zone) {
    return 'You enter flow mainly in $zone activities. This is your ideal zone!';
  }

  @override
  String get flowDistributedMsg =>
      'Distributed flow. Vary the difficulty to find your ideal zone.';

  @override
  String get flowLowMsg =>
      'Few flow moments. Try adjusting: not so easy it bores, not so hard it frustrates.';

  @override
  String get cardChallengeIndex => 'Challenge Index';

  @override
  String get challengeHigh => '🔥 High intensity';

  @override
  String get challengeModerate => '⚡ Moderate';

  @override
  String get challengeSmooth => '🌊 Smooth flow';

  @override
  String get challengeScale => '0 = Gentle · 100 = Intense';

  @override
  String get cardTopCategories => 'Top Categories';

  @override
  String get cardRecentActivities => 'Recent Activities';

  @override
  String get customizeScreenTitle => 'Categories';

  @override
  String get myCategories => '✨ MY CATEGORIES';

  @override
  String get newCategory => 'New Category';

  @override
  String get defaultCategories => '📦 DEFAULT CATEGORIES';

  @override
  String get emptyCustomCategories =>
      'No custom categories.\nTap \"New Category\" to create one!';

  @override
  String practicesCountLabel(int count) {
    return '$count practice(s)';
  }

  @override
  String get noPracticesAddTip => 'No practices — tap + to add';

  @override
  String get addPracticeToCategory => 'Add practice';

  @override
  String get removeCategoryTitle => 'Remove?';

  @override
  String removeCategoryMessage(String name) {
    return 'Category \"$name\" will be removed.';
  }

  @override
  String get removeCategoryBtn => 'Remove';

  @override
  String get editCategoryTitle => 'Edit Category';

  @override
  String get newCategoryTitle => 'New Category';

  @override
  String get practicesAddedLater => 'Practices are added later';

  @override
  String get iconLabel => 'Icon';

  @override
  String get categoryNameLabel => 'Category name';

  @override
  String get categoryNameHint => 'E.g.: Yoga, Gardening...';

  @override
  String get practicesFormLabel => 'Practices';

  @override
  String get noPracticesYet => 'No practices yet';

  @override
  String get saveBtn => 'SAVE';

  @override
  String get createCategoryBtn => 'CREATE CATEGORY';

  @override
  String get newPracticeTitle => 'New Practice';

  @override
  String get inCategoryPrefix => 'in ';

  @override
  String get practiceNameLabel => 'Practice name';

  @override
  String get practiceNameHint => 'E.g.: Guided meditation, Reading...';

  @override
  String get energySectionLabel => '⚡ Energy';

  @override
  String get energySectionQuestion =>
      'What type of energy does this practice mobilize?';

  @override
  String get difficultySectionLabel => '🌊 Difficulty';

  @override
  String get difficultySectionQuestion => 'What is the required effort level?';

  @override
  String get focusSectionLabel => '🎯 Focus';

  @override
  String get focusSectionQuestion =>
      'Which dimension does this practice develop?';

  @override
  String get addPracticeButton => 'ADD PRACTICE';
}
