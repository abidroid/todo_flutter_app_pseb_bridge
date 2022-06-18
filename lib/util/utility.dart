import 'package:intl/intl.dart';

class Utility
{
  static String getHumanReadableDate( int dt )
  {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dt);

    return DateFormat('dd MMM yyyy').format(dateTime);
  }
}