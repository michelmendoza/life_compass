# RootFlow — Descrição Funcional

## 1. Resumo Técnico e Arquitetura

**Plataforma:** Flutter (iOS + Android), suporte parcial a Web  
**Linguagem:** Dart  
**Persistência:** Hive (banco local NoSQL key-value), dois boxes principais:
- `activity_logs` — registros de sessões, serializados via `toJson`/`fromJson`
- `settings` — flags de configuração (ex: onboarding concluído)
- `custom_activities` — categorias criadas pelo usuário

**Gerência de estado:** sem biblioteca externa; flui via `setState`, callbacks de construtor e `ValueListenableBuilder` no `MainNavigator` (reage a mudanças no box Hive).

**Navegação:** `IndexedStack` com 6 slots; slots 0–4 cobertos pela bottom nav; slot 5 é `ConsciousActionScreen`, aberto pelo FAB central. Subscrens (Timer, Completion) usam `Navigator.push` e retornam resultado via `Navigator.pop`.

**Internacionalização:** `flutter_localizations` + arquivos ARB (PT + EN). Textos de domínio traduzidos via `DomainTranslations`.

**Tipografia:** Playfair Display (títulos), Lato (corpo).  
**Paleta de cores:** `HawkinsColors` — sistema baseado na escala de consciência de David R. Hawkins.

---

## 2. Conceito do Projeto

RootFlow é um **diário de práticas pessoais conscientes**. O usuário registra o tempo que dedica a atividades nas dimensões de Mente, Corpo e Espírito — trabalho, saúde, espiritualidade, lazer, criação, natureza, autocuidado — e o aplicativo devolve análise de equilíbrio, nível de consciência e sugestões de o quê praticar a seguir.

O conceito-chave é a **tríade Mente / Corpo / Espírito**: toda prática é classificada nesses eixos, além de energia (Ativa / Passiva) e dificuldade (Flow). A métrica principal é o **UP (Unidade de Progresso)** = `minutos praticados / tempo ideal da categoria`, calculada em tempo real no Dashboard, nunca armazenada.

O nome "Hawkins" na paleta de cores remete ao modelo de consciência de David R. Hawkins, que é a base conceitual para o feedback de nível de consciência (😴 Automático → ✨ Fluindo).

---

## 3. Dores que o App Ajuda a Tratar

| Dor | Como o RootFlow endereça |
|---|---|
| "Não sei se estou equilibrando minha rotina" | Dashboard com balanceamento visual por órgão (Mente/Corpo/Espírito) e energia (Ativa/Passiva) |
| "Fico no piloto automático sem perceber o que faço" | Registro consciente com nível de consciência (0–3) antes de cada sessão |
| "Não sei por onde começar" | Smart Compass analisa os últimos 7 dias e sugere o que está faltando em forma de cards deslizáveis |
| "Perco o fio da meada ao longo do dia" | FAB sempre visível para registrar uma prática rapidamente; crono, Pomodoro, HIIT e entrada manual |
| "Minha rotina é mecânica, não intencional" | Cada prática tem energia, flow e órgão — o usuário escolhe com intenção, não no automático |
| "Não consigo manter consistência" | Histórico completo filtrável por período + métricas de evolução no Dashboard |
| "O que é saudável para mim é diferente de outros" | Categorias e práticas customizáveis; usuário pode criar suas próprias |

---

## 4. Benefícios de Uso

- **Visibilidade imediata:** UPs, equilíbrio energético e distribuição de órgãos calculados na hora, sem configuração.
- **Baixo atrito para registrar:** FAB central abre a tela de ação consciente em um toque; timer começa com dois toques.
- **Sugestão inteligente:** Smart Compass lê os últimos 7 dias e oferece o contrapeso certo (ex: muita mente → sugere corpo; muito ativo → sugere passivo).
- **Feedback de consciência:** o usuário avalia como estava presente durante a prática, construindo autoconsciência gradual.
- **Timer adaptável:** Crono livre, Pomodoro configurável, HIIT (Tabata ou Intervalado customizável) e entrada manual — cobre do meditador ao atleta.
- **Personalizável:** categorias e práticas criadas pelo usuário são persistidas e integradas ao fluxo existente.
- **Offline-first:** tudo local, sem conta, sem servidor, sem dependência de rede.
- **Multilíngue:** PT e EN disponíveis.

---

## 5. Fluxos Principais e Alternativos

### 5.1 Fluxo Principal — Registrar uma Prática

```
HomeScreen
  └─► FAB "🌿"  ─►  ConsciousActionScreen
        ├─ Seleciona categoria (slider horizontal)
        ├─ Visualiza descrição da categoria
        ├─ Seleciona prática específica
        └─► [INICIAR]  ─►  TimerScreen
              ├─ Escolhe modo: Crono / Pomodoro / HIIT / Manual
              ├─ Inicia / pausa / finaliza sessão
              └─► CompletionScreen
                    ├─ Feedback de nível de consciência (0–3)
                    ├─ Feedback de dificuldade (Fácil / Médio / Difícil)
                    └─► [SALVAR]  ─►  Navigator.pop(log)
                          └─► MainNavigator: _addLog → Hive → rebuild
```

### 5.2 Fluxo Alternativo — Smart Compass (Match)

```
BottomNav "Floresta"  ─►  SmartCompassScreen
  ├─ Analisa últimos 7 dias (energia, órgão, flow dominantes)
  ├─ Gera deck de SuggestionCards rankeados
  ├─ Swipe esquerda = descartar  |  swipe direita = selecionar
  └─► [Selecionar card]  ─►  TimerScreen (mesmo fluxo acima)
```

### 5.3 Fluxo Alternativo — Dashboard

```
BottomNav "Dashboard"  ─►  DashboardScreen
  ├─ Seletor de período: Hoje / Semana / Mês  (navega ◄ ►)
  ├─ HeroStats: total UPs, tempo total, práticas
  ├─ EnergyBalance: Ativa vs Passiva (%)
  ├─ OrganBalance: Mente / Corpo / Espírito (%)
  ├─ ConsciousnessCard: nível médio de consciência
  ├─ FlowDistribution: distribuição Fácil–Difícil
  ├─ ChallengeIndex: índice de desafio do período
  ├─ SmartSuggestion: sugestão textual baseada nos dados
  ├─ CategoriesCard: UPs por categoria
  └─ RecentActivities: últimas 5 práticas
```

### 5.4 Fluxo Alternativo — Histórico

```
BottomNav "Histórico"  ─►  HistoryScreen
  ├─ Busca por texto
  ├─ Filtros: Hoje / Semana / Mês / Ano / Todos
  ├─ Filtros de ano e mês
  ├─ Lista de ActivityLogCards
  ├─ Swipe ou botão para deletar registro
  └─► Exportar dados (share_plus → JSON)
```

### 5.5 Fluxo Alternativo — Customizar Categorias

```
ConsciousActionScreen → botão "+"  ─►  CustomizeScreen
  ├─ Listar categorias custom
  ├─ [+ Nova Categoria]  ─►  CategoryFormDialog
  │     ├─ Nome, ícone, energia predominante
  │     └─► salva no box custom_activities
  └─► [+ Nova Prática]  ─►  PracticeFormSheet
        ├─ Nome, energia, flow, órgão
        └─► salva na categoria selecionada
```

### 5.6 Fluxo Alternativo — Onboarding

```
Primeira execução  ─►  OnboardingPremiumScreen
  ├─ 5 páginas animadas (fade + pulse)
  ├─ Áudio ambiente (floresta) com toggle mudo
  └─► [Concluir]  ─►  settingsBox.put('onboarding_complete', true)
                        └─► runApp rebuild  ─►  MainNavigator
```

---

## 6. Features e Cenários de Teste

---

### Feature 1 — Registro de Prática (Ação Consciente)

**Descrição:** Seleção de categoria e prática seguida de abertura do timer.

| ID | Cenário | Entrada | Resultado Esperado |
|---|---|---|---|
| F1-01 | Abrir tela sem categoria selecionada e tocar INICIAR em uma prática | Nenhuma categoria selecionada | SnackBar de alerta: "Selecione uma categoria primeiro" |
| F1-02 | Selecionar categoria e prática e iniciar | Categoria "Saúde", prática "Caminhar" | TimerScreen abre com parâmetros: group=Saúde, energy=Ativa, flow=Fácil, organ=Corpo |
| F1-03 | Slider de categorias mostra Passivas antes das Ativas | Lista de categorias | Passivas (Espiritualidade, Autocuidado...) aparecem à esquerda das Ativas |
| F1-04 | Card de categoria exibe descrição correta | Categoria "Espiritualidade" selecionada | Descrição da categoria renderizada pelo `DomainTranslations.categoryDesc` |
| F1-05 | Categorias customizadas aparecem no slider | Categoria criada pelo usuário | Categoria custom listada junto às padrão |

---

### Feature 2 — Timer

**Descrição:** Modos de cronometragem (Crono, Pomodoro, HIIT, Manual).

| ID | Cenário | Entrada | Resultado Esperado |
|---|---|---|---|
| F2-01 | Modo Crono: iniciar, pausar, retomar | Toques em play/pause | Tempo acumula, pausa para no tempo exato, retoma do mesmo ponto |
| F2-02 | Modo Pomodoro: completar ciclo | 25min configurados | Ao zerar, toca som + abre modal de pausa/break |
| F2-03 | Modo HIIT Tabata: rounds configurados | 8 rounds × 40s/20s | Alterna trabalho/descanso, conta rounds, toca som na troca |
| F2-04 | Modo HIIT Intervalado customizado | Trabalho=60s, Descanso=30s, 5 rounds | Sequência correta de intervalos |
| F2-05 | Modo Manual: salvar com tempo informado | 1h 30min inseridos manualmente | Log gravado com `durationInSeconds = 5400` |
| F2-06 | Finalizar sessão navega para CompletionScreen | Botão finalizar | CompletionScreen abre com dados da sessão |
| F2-07 | Fechar timer sem salvar | Botão voltar / X | Log não é salvo; retorna para ConsciousActionScreen |

---

### Feature 3 — Completion (Feedback Pós-Sessão)

**Descrição:** Coleta feedback de consciência e dificuldade antes de salvar o log.

| ID | Cenário | Entrada | Resultado Esperado |
|---|---|---|---|
| F3-01 | Salvar com todos os campos preenchidos | Consciência=2, Dificuldade=Médio | ActivityLog criado com `consciousnessLevel=2`, `difficultyFeedback='Médio'` |
| F3-02 | Salvar sem selecionar consciência | Nenhum nível selecionado | Salva com valor padrão (0 = Automático) ou exibe alerta |
| F3-03 | Log retorna para MainNavigator | Após salvar | `_addLog` é chamado; Hive atualizado; HomeScreen reflete novo total |
| F3-04 | Double-pop fecha CompletionScreen e TimerScreen | Após salvar | Retorna direto para ConsciousActionScreen, não mantém TimerScreen na pilha |

---

### Feature 4 — Smart Compass (Match)

**Descrição:** Geração e interação com cards de sugestão baseados nos últimos 7 dias.

| ID | Cenário | Entrada | Resultado Esperado |
|---|---|---|---|
| F4-01 | Muita energia Ativa registrada | 7 dias de práticas Ativas | Cards com práticas Passivas aparecem no topo do deck |
| F4-02 | Muita Mente registrada | 7 dias com maioria de práticas de Mente | Cards de Corpo ou Espírito são priorizados |
| F4-03 | Swipe right seleciona card | Arrastar card para direita | TimerScreen abre com dados da prática do card |
| F4-04 | Swipe left descarta card | Arrastar card para esquerda | Próximo card do deck fica visível |
| F4-05 | Deck vazio | Todos os cards descartados | Estado vazio com opção de regenerar |
| F4-06 | Deck atualiza ao voltar à aba | Novo log adicionado + voltar ao Match | `didUpdateWidget` detecta mudança em `logs.length` e regenera sugestões |
| F4-07 | Sem histórico | Usuário novo, sem logs | Deck gerado com sugestões genéricas balanceadas |

---

### Feature 5 — Dashboard

**Descrição:** Análise visual do histórico por período.

| ID | Cenário | Entrada | Resultado Esperado |
|---|---|---|---|
| F5-01 | Sem logs no período | Hoje sem registros | Estado vazio renderizado pelo `EmptyState` widget |
| F5-02 | Filtro "Hoje" exibe apenas logs do dia | Período = Hoje | Logs de dias anteriores excluídos dos cálculos |
| F5-03 | Navegar para período anterior | Seta ◄ no seletor de semana | Logs da semana anterior carregados corretamente |
| F5-04 | UP calculado corretamente | 30min de Saúde (tempoIdeal=45) | UP = 0.67 (exibido sem armazenar no banco) |
| F5-05 | Balanceamento energético | 3 logs Ativa + 1 log Passiva | EnergyBalance exibe 75% Ativa / 25% Passiva |
| F5-06 | Nível de consciência médio | Logs com níveis 1, 2, 3 | ConsciousnessCard exibe média = 2.0 |
| F5-07 | Comparação com período anterior | Semana atual vs anterior | HeroStatsCard exibe variação (▲ / ▼) |

---

### Feature 6 — Histórico

**Descrição:** Listagem, busca, filtro e exportação de todos os registros.

| ID | Cenário | Entrada | Resultado Esperado |
|---|---|---|---|
| F6-01 | Busca por texto | "Meditar" no campo de busca | Lista filtrada exibe apenas logs com nome "Meditar" |
| F6-02 | Filtro por período | Filtro = "Esta semana" | Logs fora do intervalo ocultados |
| F6-03 | Filtro por ano e mês | Ano=2025, Mês=Março | Apenas logs de março/2025 |
| F6-04 | Deletar log | Swipe ou toque no ícone de delete | Log removido do Hive; lista atualizada instantaneamente |
| F6-05 | Exportar histórico | Botão de exportar | JSON gerado e compartilhado via share_plus |
| F6-06 | Lista vazia após filtros | Filtro sem resultados | Estado vazio exibido |

---

### Feature 7 — Customização de Categorias e Práticas

**Descrição:** Criação e gerência de categorias e práticas personalizadas.

| ID | Cenário | Entrada | Resultado Esperado |
|---|---|---|---|
| F7-01 | Criar categoria custom | Nome="Dança", icon="💃", Energia=Ativa | Categoria salva no box `custom_activities`; aparece no slider |
| F7-02 | Criar prática em categoria custom | Prática="Forró", flow=Médio, organ=Corpo | Prática listada na categoria correspondente |
| F7-03 | Editar categoria existente | Mudar nome de categoria custom | Alteração persistida; nome atualizado em todas as referências |
| F7-04 | Deletar categoria custom | Categoria custom com práticas | Categoria e suas práticas removidas; logs antigos com esse grupo preservados |
| F7-05 | Categorias padrão não são editáveis | Tentar editar "Saúde" | Opções de editar/deletar não disponíveis para categorias nativas |
| F7-06 | Custom aparece no Smart Compass | Prática custom registrada | Smart Compass considera categoria custom na análise de sugestões |

---

### Feature 8 — Onboarding

**Descrição:** Apresentação do app na primeira execução.

| ID | Cenário | Entrada | Resultado Esperado |
|---|---|---|---|
| F8-01 | Exibido apenas na primeira abertura | App nunca aberto antes | OnboardingPremiumScreen aparece; MainNavigator não aparece |
| F8-02 | Navegar entre as 5 páginas | Swipe ou botão próximo | Indicador de página atualiza; conteúdo de cada página correto |
| F8-03 | Toggle de som | Botão de mudo | Áudio de floresta para/retoma; ícone muda |
| F8-04 | Concluir onboarding | Botão "Concluir" na última página | `onboarding_complete=true` salvo; app rebuild para MainNavigator |
| F8-05 | Onboarding não repete | Fechar e reabrir o app | Vai direto para HomeScreen |
| F8-06 | Replay do onboarding | Tocar no ícone 🧭 na HomeScreen | OnboardingPremiumScreen abre via push (sem resetar o app) |

---

### Feature 9 — Internacionalização

**Descrição:** Suporte a PT e EN com tradução de textos de interface e de domínio.

| ID | Cenário | Entrada | Resultado Esperado |
|---|---|---|---|
| F9-01 | App em PT | Idioma do dispositivo = Português | Todos os textos em português; domínio (energia, flow, órgão) em PT |
| F9-02 | App em EN | Idioma do dispositivo = English | Todos os textos em inglês; domínio traduzido via `DomainTranslations` |
| F9-03 | Chave de tradução ausente | Idioma sem cobertura total | Fallback para PT sem crash |
| F9-04 | Meses no histórico | Filtro por mês no idioma EN | Nomes de meses em inglês via `DateFormat` com locale correto |
