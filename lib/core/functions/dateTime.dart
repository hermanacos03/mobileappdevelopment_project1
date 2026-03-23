Map<String, String> getFormattedDateTime() {
  final now = DateTime.now();

  final time =
      '${(now.hour % 12 == 0 ? 12 : now.hour % 12)}:${now.minute.toString().padLeft(2, '0')} '
      '${now.hour >= 12 ? 'PM' : 'AM'}';

  final date = '${now.month}/${now.day}/${now.year}';

  return {
    'date': date,
    'time': time,
  };
}