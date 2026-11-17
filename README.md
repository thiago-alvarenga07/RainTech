# RainTech

Aplicativo Flutter para acompanhar níveis de reservatórios, chuva e indicadores
de abastecimento, com painéis por cidade, alertas explicáveis e revisão humana.

## Estrutura do código

O código separa a interface, o estado da aplicação, o acesso a dados e os
cálculos. Telas e widgets apresentam dados e encaminham ações ao estado; não
acessam diretamente o Supabase nem a persistência local.

```text
lib/
├── main.dart                 # Inicialização e configuração das dependências
├── app.dart                  # Árvore principal, providers, tema e rotas
├── analytics/                # Indicadores e regras para geração de alertas
├── core/
│   ├── routes/               # Rotas nomeadas e navegação
│   └── theme/                # Cores, espaçamento e temas
├── data/
│   ├── water_repository.dart # Leitura e conversão de dados do Supabase
│   └── app_storage.dart      # Cache e preferências locais
├── models/                   # Modelos de domínio e serialização
├── screens/                  # Páginas e composição das telas
│   ├── alerts/               # Lista e detalhe de alertas
│   └── dashboards/           # Painéis de reservatórios, chuva e demanda
├── state/                    # Estado compartilhado e coordenação dos fluxos
└── widgets/                  # Componentes reutilizáveis e gráficos
    └── charts/
test/
└── widget_test.dart          # Testes de interface e fluxos principais
```

### Papel de cada pasta

- **Inicialização e composição** — `main.dart` lê a configuração do Supabase,
  inicializa o armazenamento e monta o repositório. `app.dart` registra os
  estados compartilhados, temas e rotas do aplicativo.
- **Acesso a dados (`data/`)** — `WaterRepository` consulta as tabelas
  `reservoir_levels` e `rainfall`, converte os registros em modelos e fornece
  dados de demonstração quando não há cliente Supabase configurado.
  `AppStorage` persiste o snapshot para uso offline, preferências e, somente
  após consentimento, avaliações de alertas.
- **Estado (`state/`)** — `WaterDataState` coordena carregamento, cache,
  atualização e erros dos dados. `AlertsState` recalcula alertas a partir do
  estado hídrico e gerencia as decisões humanas. `SettingsState` mantém as
  preferências visuais e de acessibilidade.
- **Modelos (`models/`)** — representam snapshots de água, reservatórios,
  observações de chuva, alertas, decisões e limites. Também concentram
  serialização e propriedades derivadas dos dados.
- **Análises (`analytics/`)** — `Indicators` e `DemandModel` calculam métricas;
  `AlertEngine` aplica regras e limiares para produzir alertas com evidências,
  confiança, limitações e ações sugeridas. O motor não executa as ações: a
  decisão final permanece humana.
- **Apresentação (`screens/`, `widgets/`)** — telas organizam navegação e
  conteúdo; widgets reutilizáveis exibem indicadores, gráficos, alertas e
  estados de carregamento, erro ou operação offline.
- **Infraestrutura de interface (`core/`)** — concentra rotas, cores,
  espaçamentos e temas, evitando que essas definições fiquem espalhadas pelas
  telas.
- **Testes (`test/`)** — verificam navegação, apresentação dos painéis,
  preferências e consentimento para persistir avaliações.

## Fluxo dos dados

1. `main.dart` lê `SUPABASE_URL` e `SUPABASE_ANON_KEY`. As duas configurações
   devem ser fornecidas juntas; se ambas forem omitidas, o app usa dados de
   demonstração.
2. `WaterDataState` solicita um snapshot ao `WaterRepository`.
3. O repositório consulta até 30 registros recentes de reservatórios e chuva e
   os converte em `WaterSnapshot`.
4. Snapshots válidos são guardados localmente. Se a consulta falhar, o estado
   tenta carregar o último snapshot salvo e informa à interface quando está
   exibindo dados de cache.
5. `AlertsState` recalcula os alertas quando recebe um snapshot atualizado.
   As telas observam os estados e exibem os resultados.

No Supabase, o repositório espera as tabelas `reservoir_levels` e `rainfall`,
com a coluna `Date` e as colunas de leitura `POONDI`, `CHOLAVARAM`, `REDHILLS`
e `CHEMBARAMBAKKAM`.

O indicador de população atendida e as estimativas de demanda em
`DemandModel.servedPopulation` são sintéticos para demonstração; não são
consultados dessas tabelas nem devem ser interpretados como impacto medido.

## Decisões técnicas

| Escolha | Justificativa |
| --- | --- |
| Provider com `ChangeNotifier` | Compartilha estados pequenos e reativos sem introduzir uma camada de gerenciamento mais complexa que a necessária. |
| Repositório separado da interface | Isola consultas e conversão de dados; telas dependem do estado da aplicação, não do cliente Supabase. |
| `SharedPreferences` | Atende ao cache pequeno do snapshot e às preferências locais. Não é usado como banco para grandes volumes. |
| Regras determinísticas para alertas | Tornam limiares, evidências e limitações inspecionáveis; preservam a avaliação humana em vez de automatizar decisões. |
| `fl_chart` | Fornece gráficos para séries e comparações apresentados nos painéis. |

## Contribuidores e responsabilidades

### Thiago Sobral — [@thiago-alvarenga07](https://github.com/thiago-alvarenga07)

- Estrutura inicial do app e telas de início, preferências e precipitação
- Acessibilidade (alto contraste e tamanho do texto), privacidade e indicador
  social na tela inicial
- Permissão de internet necessária para a build Android de release acessar o
  backend

### Dimeendes — [@Eunaoseiler](https://github.com/Eunaoseiler)

- Tema centralizado e widgets reutilizáveis
- Estado compartilhado com Provider, rotas nomeadas e cache offline
- Painéis de reservatórios, chuva e demanda, gráficos, histórico e indicadores
  relacionados
- Alertas preditivos com evidências, confiança, limitações e revisão humana

## Aplicativo para instalação

Uma build Android do aplicativo está disponível na seção releases deste repositório.