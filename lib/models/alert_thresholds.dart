class AlertThresholds {
  const AlertThresholds({
    this.criticalReserve = 0.25,
    this.attentionReserve = 0.45,
    this.projectionHorizonDays = 60,
    this.drySpellDays = 5,
    this.attentionAutonomyDays = 60,
  });

  final double criticalReserve;

  final double attentionReserve;

  final int projectionHorizonDays;

  final int drySpellDays;

  final double attentionAutonomyDays;
}