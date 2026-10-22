import 'package:intl/intl.dart';

class Formatters {
  static String rupiah(int number) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(number);
  }

  static String shortRupiah(int number) {
    if (number >= 1000000000) {
      return 'Rp ${(number / 1000000000).toStringAsFixed(1)}M';
    } else if (number >= 1000000) {
      return 'Rp ${(number / 1000000).toStringAsFixed(1)}jt';
    } else if (number >= 1000) {
      return 'Rp ${(number / 1000).toStringAsFixed(0)}rb';
    }
    return 'Rp $number';
  }

  static String dateRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateDay).inDays;

    final timeStr = DateFormat('HH:mm').format(date);

    if (diff == 0) {
      return 'Hari ini, $timeStr';
    } else if (diff == 1) {
      return 'Kemarin, $timeStr';
    } else if (diff < 7) {
      return '${diff} hari lalu';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  static String monthYear(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
