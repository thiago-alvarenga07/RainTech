String formatDate(DateTime date) {
  const months = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String weekdayLabel(DateTime date) {
  const weekdays = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];
  return weekdays[date.weekday - 1];
}

String formatMcft(double value) => value.toStringAsFixed(0);

String formatMillimeters(double value) => '${value.toStringAsFixed(1)} mm';


String formatPercent(double ratio) => '${(ratio * 100).toStringAsFixed(0)}%';


String formatPointsDelta(double ratioDelta) {
  final points = ratioDelta * 100;
  final sign = points > 0 ? '+' : '';
  return '$sign${points.toStringAsFixed(1)} p.p.';
}

String formatDays(double days) => '${days.toStringAsFixed(0)} dias';


String cityShortName(String city) => switch (city) {
  'São Paulo' => 'SP',
  'Rio de Janeiro' => 'RJ',
  'Fortaleza' => 'FOR',
  'Salvador' => 'SSA',
  _ => city.length <= 3 ? city : city.substring(0, 3).toUpperCase(),
};