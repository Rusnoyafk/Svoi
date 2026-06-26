/// Форматування дати у відносний час українською мовою
class TimeFormatter {
  static const _months = [
    '', 'січ.', 'лют.', 'бер.', 'квіт.', 'трав.', 'черв.',
    'лип.', 'серп.', 'вер.', 'жовт.', 'лист.', 'груд.',
  ];

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

    return '${dateTime.day} ${_months[dateTime.month]}';
  }
}
