import '../core/theme/app_theme.dart';

/// Tipos de alerta que o motor de regras consegue gerar.
enum AlertType {
  lowReserve('Nível baixo'),
  criticalProjection('Projeção de nível crítico'),
  drySpell('Estiagem'),
  lowAutonomy('Autonomia baixa');

  const AlertType(this.label);
  final String label;
}

/// Alerta preditivo: SEMPRE acompanhado de evidências, confiança e
/// limitações. O app apenas sugere; quem decide é uma pessoa.
class PredictiveAlert {
  const PredictiveAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.summary,
    required this.evidence,
    required this.confidence,
    required this.confidenceReasons,
    required this.limitations,
    required this.suggestedAction,
    required this.generatedAt,
    this.city,
  });

  /// Identificador estável (tipo + local + data dos dados), para que a
  /// revisão humana continue associada ao alerta após recarregar.
  final String id;
  final AlertType type;
  final RiskLevel severity;

  /// Cidade afetada; `null` quando o alerta é regional.
  final String? city;
  final String title;
  final String summary;

  /// Justificativa: fatos e números que levaram ao alerta.
  final List<String> evidence;

  /// Confiança de 0 a 1.
  final double confidence;
  final List<String> confidenceReasons;

  /// Limitações e condições em que o alerta NÃO é confiável.
  final List<String> limitations;

  /// Ação sugerida para avaliação humana (nunca executada pelo app).
  final String suggestedAction;
  final DateTime generatedAt;

  String get confidenceLabel => confidence >= 0.75
      ? 'Alta'
      : confidence >= 0.5
      ? 'Média'
      : 'Baixa';

  String get severityLabel => switch (severity) {
    RiskLevel.high => 'Alto',
    RiskLevel.medium => 'Moderado',
    RiskLevel.low => 'Baixo',
  };
}

enum AlertDecision {
  confirmed('Confirmado'),
  dismissed('Descartado');

  const AlertDecision(this.label);
  final String label;
}

/// Registro da decisão humana sobre um alerta.
class AlertReview {
  const AlertReview({
    required this.decision,
    required this.note,
    required this.reviewedAt,
  });

  final AlertDecision decision;
  final String note;
  final DateTime reviewedAt;

  Map<String, dynamic> toJson() => {
    'decision': decision.name,
    'note': note,
    'reviewedAt': reviewedAt.toIso8601String(),
  };

  factory AlertReview.fromJson(Map<String, dynamic> json) => AlertReview(
    decision: AlertDecision.values.byName(json['decision'] as String),
    note: json['note'] as String,
    reviewedAt: DateTime.parse(json['reviewedAt'] as String),
  );
}