import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat('yMMMEd').format(date);
}

String formatTime(DateTime date) {
  return DateFormat.jm().format(date);
}

String formatDuration(Duration duration) {
  final List<String> hoursMinsSeconds = duration
      .toString()
      .split('.')
      .first
      .split(":");
  return '${hoursMinsSeconds[0]}h:${hoursMinsSeconds[1]}m:${hoursMinsSeconds[2]}s';
}
