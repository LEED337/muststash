import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _percentFormatter = NumberFormat.percentPattern();

  static final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  static final DateFormat _timeFormatter = DateFormat('h:mm a');
  static final DateFormat _dateTimeFormatter = DateFormat('MMM dd, h:mm a');

  static String currency(double amount) {
    return _currencyFormatter.format(amount);
  }

  static String percent(double value) {
    return _percentFormatter.format(value);
  }

  static String date(DateTime date) {
    return _dateFormatter.format(date);
  }

  static String time(DateTime date) {
    return _timeFormatter.format(date);
  }

  static String dateTime(DateTime date) {
    return _dateTimeFormatter.format(date);
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return _dateFormatter.format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}