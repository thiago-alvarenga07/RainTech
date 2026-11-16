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
