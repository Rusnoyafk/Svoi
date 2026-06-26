/// Форматування дати і часу українською мовою
class TimeFormatter {
  static const _monthsShort = [
    '', 'січ.', 'лют.', 'бер.', 'квіт.', 'трав.', 'черв.',
    'лип.', 'серп.', 'вер.', 'жовт.', 'лист.', 'груд.',
  ];

  static const _monthsFull = [
    '', 'січня', 'лютого', 'березня', 'квітня', 'травня', 'червня',
    'липня', 'серпня', 'вересня', 'жовтня', 'листопада', 'грудня',
  ];

  /// Відносний час: "Щойно", "2 год тому", "Вчора", "15 черв."
  static String format(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Щойно';
    if (diff.inMinutes < 60) return '${diff.inMinutes} хв тому';
    if (diff.inHours < 24) return '${diff.inHours} год тому';

    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    if (date == DateTime(yesterday.year, yesterday.month, yesterday.day)) {
      return 'Вчора';
    }

    if (diff.inDays < 7) return '${diff.inDays} дн. тому';

    return '${dateTime.day} ${_monthsShort[dateTime.month]}';
  }

  /// Дата події: "Сьогодні, 18:00" / "Завтра, 18:00" / "28 черв., 18:00"
  static String formatEventDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final time = _formatTime(dateTime);

    if (date == today) return 'Сьогодні, $time';
    if (date == today.add(const Duration(days: 1))) return 'Завтра, $time';

    return '${dateTime.day} ${_monthsShort[dateTime.month]}, $time';
  }

  /// Повна дата: "28 червня 2026, 18:00"
  static String formatEventDateFull(DateTime dateTime) {
    final time = _formatTime(dateTime);
    return '${dateTime.day} ${_monthsFull[dateTime.month]} ${dateTime.year}, $time';
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
