import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter();

  static String getVerboseDateTimeRepresentation({required DateTime dateTime, String whatFor = 'history'}) {
    String roughTimeString = "";
    if (dateTime.hour != 0 || dateTime.minute != 0 || dateTime.second != 0) {
      roughTimeString = DateFormat('jm').format(dateTime);
    }

    DateTime now = DateTime.now();
    DateTime justNow = now.subtract(const Duration(minutes: 1));
    DateTime localDateTime = dateTime.toLocal();

    if (roughTimeString != "" && (!localDateTime.difference(justNow).isNegative) && whatFor == 'history') {
      return 'Just now';
    }

    if (localDateTime.day == now.day && localDateTime.month == now.month && localDateTime.year == now.year) {
      return roughTimeString != "" ? ('Today $roughTimeString') : 'Today';
    }

    DateTime yesterday = now.subtract(const Duration(days: 1));

    if (localDateTime.day == yesterday.day && localDateTime.month == now.month && localDateTime.year == now.year) {
      return roughTimeString != "" ? ('Yesterday, $roughTimeString') : 'Yesterday';
    }

    if (now.difference(localDateTime).inDays < 4) {
      String weekday = DateFormat('EEEE').format(localDateTime);

      return roughTimeString != "" ? ('$weekday, $roughTimeString') : weekday;
    }

    if (localDateTime.year == now.year) {
      String monthDay = DateFormat('MMMd').format(localDateTime);
      return roughTimeString != "" ? ('$monthDay, $roughTimeString') : monthDay;
    }

    return roughTimeString != "" ? ('${DateFormat('yMd').format(dateTime)}, $roughTimeString') : DateFormat('yMd').format(dateTime);
  }

  static String getMMMdRepresentation({required DateTime dateTime}) {
    String roughTimeString = "";
    if (dateTime.hour != 0 || dateTime.minute != 0 || dateTime.second != 0) {
      roughTimeString = DateFormat('jm').format(dateTime);
    }

    DateTime localDateTime = dateTime.toLocal();

    String monthDay = DateFormat('MMM d, y').format(localDateTime);
    if (roughTimeString == "") {
      return monthDay;
    } else {
      monthDay = DateFormat('MMM d').format(localDateTime);
      return '$monthDay, $roughTimeString';
    }
  }

  static DateTime parseFromMMMddyyyy(String date) {
    DateFormat dateFormat = DateFormat("MMM dd, yyyy");
    return dateFormat.parse(date);
  }

  static String getDDMMYYYYRepresentation({required DateTime dateTime}) {
    DateFormat dateFormat = DateFormat("dd MMMM yyyy");
    return dateFormat.format(dateTime);
  }
}
