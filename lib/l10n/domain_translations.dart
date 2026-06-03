import 'package:flutter/material.dart';
import 'package:root_flow/l10n/app_localizations.dart';

// Translates internal domain keys (stored in Portuguese in Hive) to the
// current locale. All internal keys stay in Portuguese to avoid breaking
// existing stored logs.
class DomainTranslations {
  static String energy(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    return switch (key) {
      'Ativa' => l10n.energyAtiva,
      'Passiva' => l10n.energyPassiva,
      _ => key,
    };
  }

  static String organ(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    return switch (key) {
      'Mente' => l10n.organMente,
      'Corpo' => l10n.organCorpo,
      'Espírito' => l10n.organEspirito,
      'Corpo/Mente' => l10n.organCorpoMente,
      _ => key,
    };
  }

  static String flow(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    return switch (key) {
      'Fácil' => l10n.flowFacil,
      'Fácil – Médio' => l10n.flowFacilMedio,
      'Médio' => l10n.flowMedio,
      'Médio – Difícil' => l10n.flowMedioDificil,
      'Difícil' => l10n.flowDificil,
      _ => key,
    };
  }

  static String category(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    return switch (key) {
      'Espiritualidade' => l10n.categoryEspiritualidade,
      'Aprendizado' => l10n.categoryAprendizado,
      'Trabalho' => l10n.categoryTrabalho,
      'Saúde' => l10n.categorySaude,
      'Lazer' => l10n.categoryLazer,
      'Social' => l10n.categorySocial,
      'Criação' => l10n.categoryCriacao,
      'Natureza' => l10n.categoryNatureza,
      'Autocuidado' => l10n.categoryAutocuidado,
      _ => key,
    };
  }

  static String categoryDesc(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    return switch (key) {
      'Espiritualidade' => l10n.descEspiritualidade,
      'Aprendizado' => l10n.descAprendizado,
      'Trabalho' => l10n.descTrabalho,
      'Saúde' => l10n.descSaude,
      'Lazer' => l10n.descLazer,
      'Social' => l10n.descSocial,
      'Criação' => l10n.descCriacao,
      'Natureza' => l10n.descNatureza,
      'Autocuidado' => l10n.descAutocuidado,
      _ => l10n.descDefault,
    };
  }

  static String practice(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    return switch (key) {
      'Alongamento' => l10n.practiceAlongamento,
      'Apresentação' => l10n.practiceApresentacao,
      'Assistir' => l10n.practiceAssistir,
      'Auto-massagem' => l10n.practiceAutoMassagem,
      'Acampar' => l10n.practiceAcampar,
      'Banho relaxante' => l10n.practiceBanhoRelaxante,
      'Bar' => l10n.practiceBar,
      'Caminhar' => l10n.practiceCaminhar,
      'Chat' => l10n.practiceChat,
      'Contemplar paisagem' => l10n.practiceContemplacaoPaisagem,
      'Conversar' => l10n.practiceConversar,
      'Correr' => l10n.practiceCorrida,
      'Cozinhar' => l10n.practiceCozinhar,
      'Curso online' => l10n.practiceCursoOnline,
      'Consulta médica' => l10n.practiceConsultaMedica,
      'Dançar' => l10n.practiceDancar,
      'Desenhar' => l10n.practiceDesenhar,
      'Estudar' => l10n.practiceEstudar,
      'Escrever' => l10n.practiceEscrever,
      'Evento social' => l10n.practiceEventoSocial,
      'Fotografar' => l10n.practiceFotografar,
      'HIIT' => l10n.practiceHIIT,
      'Jardinagem' => l10n.practiceJardinagem,
      'Jejum' => l10n.practiceJejum,
      'Jogar' => l10n.practiceJogar,
      'Ler' => l10n.practiceLer,
      'Ligar para amigo' => l10n.practiceLigarAmigo,
      'Macaquear' => l10n.practiceMacaquear,
      'Malabares' => l10n.practiceMalabares,
      'Massagem' => l10n.practiceMassagem,
      'Meditar' => l10n.practiceMeditar,
      'Música' => l10n.practiceMusica,
      'Não fazer nada' => l10n.practiceNaoFazerNada,
      'Organizar tarefas' => l10n.practiceOrganizarTarefas,
      'Orar' => l10n.practiceOrar,
      'Ouvir audiolivro' => l10n.practiceOuvirAudiolivro,
      'Planejamento' => l10n.practicePlanejamento,
      'Planejar' => l10n.practicePlanejar,
      'Podcast educativo' => l10n.practicePodcastEducativo,
      'Projetos pessoais' => l10n.practiceProjetosPessoais,
      'Reunião' => l10n.practiceReuniaoTrabalho,
      'Respiração consciente' => l10n.practiceRespiracaoConsciente,
      'Retiro espiritual' => l10n.practiceRetiroEspiritual,
      'Skin care' => l10n.practiceSkinCare,
      'Spa day' => l10n.practiceSpaDay,
      'Trilhas' => l10n.practiceTrilhas,
      'Trabalho remunerado' => l10n.practiceTrabalhoRemunerado,
      'Yoga' => l10n.practiceYoga,
      _ => key,
    };
  }

  static String reason(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    return switch (key) {
      'reasonBalanceEnergy' => l10n.reasonBalanceEnergy,
      'reasonAwakVitality' => l10n.reasonAwakVitality,
      'reasonActivateBody' => l10n.reasonActivateBody,
      'reasonExerciseMind' => l10n.reasonExerciseMind,
      'reasonLighter' => l10n.reasonLighter,
      'reasonChallenge' => l10n.reasonChallenge,
      'reasonPauseRenew' => l10n.reasonPauseRenew,
      'reasonConnectNature' => l10n.reasonConnectNature,
      _ => l10n.reasonDefault,
    };
  }
}
