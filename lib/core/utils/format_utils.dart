import 'package:intl/intl.dart';

class FormatUtils {
  static final NumberFormat _vndFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  static final DateFormat _dateTimeFormat = DateFormat('HH:mm dd/MM/yyyy');
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  /// Formats value as VND currency (e.g. "150.000 ₫") or "—" if null/invalid.
  static String formatVnd(dynamic value) {
    if (value == null) return '—';
    if (value is String && value.trim().isEmpty) return '—';

    try {
      num number;
      if (value is num) {
        number = value;
      } else if (value is String) {
        final cleaned = value.replaceAll(RegExp(r'[^\d-]'), '');
        if (cleaned.isEmpty) return '—';
        number = num.parse(cleaned);
      } else {
        return '—';
      }
      return _vndFormat.format(number).trim();
    } catch (_) {
      return '—';
    }
  }

  /// Formats ISO datetime string to "HH:mm dd/MM/yyyy"
  static String formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '—';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return _dateTimeFormat.format(dateTime);
    } catch (_) {
      return isoString;
    }
  }

  /// Formats ISO datetime string to "dd/MM/yyyy"
  static String formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '—';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return _dateFormat.format(dateTime);
    } catch (_) {
      return isoString;
    }
  }
}
