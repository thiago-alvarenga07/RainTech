import '../core/theme/app_theme.dart';
import '../models/alert.dart';
import '../models/alert_thresholds.dart';
import '../models/water_snapshot.dart';
import 'indicators.dart';

class AlertEngine {
  const AlertEngine({this.thresholds = const AlertThresholds()});

  final AlertThresholds thresholds;

  static const projectionWindow = 14;

  List<PredictiveAlert> evaluate(
    WaterSnapshot snapshot, {
    DateTime? now,
    bool isDemo = false,
    bool isFromCache = false,
  }) {
    if (snapshot.isEmpty) return const [];
    final context = _Context(
      snapshot: snapshot,
      now: now ?? DateTime.now(),
      isDemo: isDemo,
      isFromCache: isFromCache,
    );

    final alerts = <PredictiveAlert>[
      for (final reservoir in snapshot.reservoirs) ...[
        ?_lowReserve(context, reservoir),
        ?_criticalProjection(context, reservoir),
        ?_lowAutonomy(context, reservoir),
      ],
      ?_drySpell(context),
    ];

    alerts.sort((a, b) {
      final bySeverity = b.severity.index.compareTo(a.severity.index);
      return bySeverity != 0 ? bySeverity : b.confidence.compareTo(a.confidence);
    });
    return alerts;
  }

  PredictiveAlert? _lowReserve(_Context c, Reservoir r) {
    final fill = r.fillRatio;
    if (fill >= thresholds.attentionReserve) return null;
    final critical = fill < thresholds.criticalReserve;
    final change = Indicators.change(c.snapshot.fillHistoryFor(r.name));

    final (confidence, reasons) = c.adjust(0.9, [
      'Baseado em leitura direta do volume armazenado.',
    ]);

    return PredictiveAlert(
      id: c.id(AlertType.lowReserve, r.name),
      type: AlertType.lowReserve,
      severity: critical ? RiskLevel.high : RiskLevel.medium,
      city: r.name,
      title: critical
          ? '${r.name}: reservatório em nível crítico'
          : '${r.name}: reservatório abaixo da faixa de atenção',
      summary:
          'O volume armazenado está em ${_pct(fill)} da capacidade, abaixo do '
          'limite de ${_pct(critical ? thresholds.criticalReserve : thresholds.attentionReserve)} '
          'configurado.',
      evidence: [
        'Nível atual: ${_pct(fill)} (${r.storageMcft.toStringAsFixed(0)} de ${r.capacityMcft.toStringAsFixed(0)} MCFT).',
        'Limite de atenção: ${_pct(thresholds.attentionReserve)} • limite crítico: ${_pct(thresholds.criticalReserve)}.',
        if (change != null)
          'Variação nos últimos 7 registros: ${_points(change)}.',
        'Leitura de ${_date(c.snapshot.observedAt)}.',
      ],
      confidence: confidence,
      confidenceReasons: reasons,
      limitations: [
        'Leitura pontual: pode haver erro de medição ou atraso na publicação dos dados.',
        'Não indica sozinha falta de água: depende também de consumo e de outras fontes.',
        ...c.generalLimitations,
      ],
      suggestedAction: critical
          ? 'Avaliar com a operadora a necessidade de campanha de uso consciente e plano de contingência.'
          : 'Acompanhar diariamente o nível e preparar comunicação preventiva à população.',
      generatedAt: c.now,
    );
  }

  PredictiveAlert? _criticalProjection(_Context c, Reservoir r) {
    final history = c.snapshot.fillHistoryFor(r.name);
    if (history.length < 5) return null;
    final window = history.length > projectionWindow
        ? history.sublist(history.length - projectionWindow)
        : history;
    final fit = Indicators.linearFit(window.map((e) => e.$2).toList());
    final current = r.fillRatio;

    if (fit.slope >= 0 || current <= thresholds.criticalReserve) return null;
    final daysToCritical = (current - thresholds.criticalReserve) / -fit.slope;
    if (daysToCritical > thresholds.projectionHorizonDays) return null;

    final eta = c.now.add(Duration(days: daysToCritical.round()));
    final urgent = daysToCritical <= thresholds.projectionHorizonDays / 3;

    final dataShare = window.length / projectionWindow;
    var base = 0.3 + 0.5 * fit.r2 + 0.2 * dataShare;
    final reasons = <String>[
      'Tendência baseada em ${window.length} registros (ideal: $projectionWindow).',
      'R² do ajuste = ${fit.r2.toStringAsFixed(2)} '
          '(${fit.r2 >= 0.8 ? 'tendência consistente' : 'dados irregulares'}).',
    ];
    if (daysToCritical > 30) {
      base -= 0.1;
      reasons.add('Projeções mais distantes que 30 dias são menos confiáveis.');
    }
    final (confidence, allReasons) = c.adjust(base, reasons);

    return PredictiveAlert(
      id: c.id(AlertType.criticalProjection, r.name),
      type: AlertType.criticalProjection,
      severity: urgent ? RiskLevel.high : RiskLevel.medium,
      city: r.name,
      title:
          '${r.name} pode atingir nível crítico em ~${daysToCritical.round()} dias',
      summary:
          'Se o ritmo de queda dos últimos ${window.length} dias continuar, '
          'o reservatório chega a ${_pct(thresholds.criticalReserve)} por volta de ${_date(eta)}.',
      evidence: [
        'Queda média de ${_points(fit.slope)} por dia (regressão linear).',
        'Nível atual: ${_pct(current)} • limite crítico: ${_pct(thresholds.criticalReserve)}.',
        'Distância até o limite: ${_points(current - thresholds.criticalReserve)}.',
        'Data estimada: ${_date(eta)} (horizonte de alerta: ${thresholds.projectionHorizonDays} dias).',
      ],
      confidence: confidence,
      confidenceReasons: allReasons,
      limitations: [
        'Projeção LINEAR: assume que consumo e chuva continuem iguais aos últimos dias.',
        'Não considera previsão do tempo, transferências entre sistemas ou manobras da operadora.',
        'Uma chuva forte ou mudança de operação invalida a estimativa.',
        'Não é confiável com menos de 7 registros ou R² abaixo de 0,5.',
        ...c.generalLimitations,
      ],
      suggestedAction:
          'Validar a projeção com a equipe técnica e decidir se é necessário antecipar medidas de economia.',
      generatedAt: c.now,
    );
  }


  PredictiveAlert? _lowAutonomy(_Context c, Reservoir r) {
    final days = DemandModel.autonomyDays(r);
    if (days >= thresholds.attentionAutonomyDays) return null;
    final high = days < thresholds.attentionAutonomyDays / 2;

    final (confidence, reasons) = c.adjust(0.55, [
      'Depende de população e consumo per capita estimados (dados sintéticos).',
    ]);

    return PredictiveAlert(
      id: c.id(AlertType.lowAutonomy, r.name),
      type: AlertType.lowAutonomy,
      severity: high ? RiskLevel.high : RiskLevel.medium,
      city: r.name,
      title: 'Autonomia de ${r.name} em ~${days.round()} dias',
      summary:
          'Sem chuva, o volume atual atenderia a população estimada por cerca de '
          '${days.round()} dias.',
      evidence: [
        'Volume armazenado: ${r.storageMcft.toStringAsFixed(0)} MCFT.',
        'Demanda estimada: ${DemandModel.dailyDemandMegaliters(r.name).toStringAsFixed(0)} milhões de litros/dia.',
        'Limite de atenção: ${thresholds.attentionAutonomyDays.toStringAsFixed(0)} dias.',
      ],
      confidence: confidence,
      confidenceReasons: reasons,
      limitations: [
        'População atendida e consumo per capita são valores sintéticos.',
        'Ignora chuva futura, evaporação e outras fontes de abastecimento.',
        ...c.generalLimitations,
      ],
      suggestedAction:
          'Conferir os dados reais de consumo com a operadora antes de qualquer medida.',
      generatedAt: c.now,
    );
  }


  PredictiveAlert? _drySpell(_Context c) {
    final daily = c.snapshot.rainfall.map((o) => o.regionalAverageMm).toList();
    final streak = Indicators.dryStreak(daily);
    if (streak < thresholds.drySpellDays) return null;
    final high = streak >= thresholds.drySpellDays * 2;
    final reserveChange = Indicators.change(c.snapshot.reserveRatioHistory);

    final (confidence, reasons) = c.adjust(0.8, [
      'Baseado em leituras observadas de chuva.',
      'Média de apenas 4 estações para toda a região.',
    ]);

    return PredictiveAlert(
      id: c.id(AlertType.drySpell, 'regiao'),
      type: AlertType.drySpell,
      severity: high ? RiskLevel.high : RiskLevel.medium,
      title: 'Estiagem há $streak dias na região',
      summary:
          'A chuva média ficou abaixo de 1 mm/dia por $streak dias seguidos, '
          'o que reduz a reposição dos reservatórios.',
      evidence: [
        '$streak dias seguidos com chuva < 1 mm (limite configurado: ${thresholds.drySpellDays}).',
        'Média dos últimos 7 dias: ${c.snapshot.recentRainfallAverage.toStringAsFixed(1)} mm/dia.',
        if (reserveChange != null)
          'Reserva total variou ${_points(reserveChange)} em 7 registros.',
      ],
      confidence: confidence,
      confidenceReasons: reasons,
      limitations: [
        'Chuvas localizadas podem não ser captadas pelas 4 estações.',
        'Não é previsão do tempo: não indica quando a estiagem termina.',
        ...c.generalLimitations,
      ],
      suggestedAction:
          'Avaliar comunicação de uso consciente e monitorar os boletins meteorológicos oficiais.',
      generatedAt: c.now,
    );
  }

  static String _pct(double ratio) => '${(ratio * 100).toStringAsFixed(0)}%';

  static String _points(double ratio) {
    final p = ratio * 100;
    return '${p > 0 ? '+' : ''}${p.toStringAsFixed(1)} p.p.';
  }

  static String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _Context {
  _Context({
    required this.snapshot,
    required this.now,
    required this.isDemo,
    required this.isFromCache,
  });

  final WaterSnapshot snapshot;
  final DateTime now;
  final bool isDemo;
  final bool isFromCache;

  int get dataAgeDays => now.difference(snapshot.observedAt).inDays;

  String id(AlertType type, String place) {
    final d = snapshot.observedAt;
    return '${type.name}:$place:${d.year}-${d.month}-${d.day}';
  }

  (double, List<String>) adjust(double base, List<String> reasons) {
    var value = base;
    final all = [...reasons];
    if (dataAgeDays > 7) {
      value -= 0.3;
      all.add('Dados com $dataAgeDays dias de atraso (−30%).');
    } else if (dataAgeDays > 2) {
      value -= 0.15;
      all.add('Dados com $dataAgeDays dias de atraso (−15%).');
    }
    if (isFromCache) {
      value -= 0.1;
      all.add('Exibindo dados salvos no aparelho, sem conexão (−10%).');
    }
    if (isDemo) {
      value -= 0.2;
      all.add('Dados sintéticos de demonstração (−20%).');
    }
    return (value.clamp(0.05, 0.99).toDouble(), all);
  }

  List<String> get generalLimitations => [
    if (isDemo) 'Modo demonstração: os números são ilustrativos.',
    'Este alerta é uma sugestão automática e não substitui avaliação técnica.',
  ];
}