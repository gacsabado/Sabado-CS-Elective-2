import 'package:supabase_flutter/supabase_flutter.dart';

/// Formats an amount as Philippine pesos, e.g. ₱1,299.00
String formatPrice(num? value) {
  final amount = (value ?? 0).toDouble();
  final fixed = amount.abs().toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '${amount < 0 ? '-' : ''}₱$whole.${parts[1]}';
}

String formatDate(DateTime? date) {
  if (date == null) return 'Date unavailable';
  final d = date.toLocal();
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}

/// Turns any thrown object into a short message that is safe to show a user.
String friendlyError(Object error) {
  if (error is PostgrestException) {
    if (isPermissionDenied(error)) {
      return 'You do not have permission to do that.';
    }
    if (error.code == '23505') return 'That value already exists.';
    if (error.code == '23503') {
      return 'This item is still in use and cannot be changed.';
    }
    return error.message;
  }
  if (error is AuthException) return error.message;
  if (error is StorageException) {
    final msg = error.message.toLowerCase();
    if (msg.contains('row-level security') || msg.contains('unauthorized')) {
      return 'You do not have permission to upload images.';
    }
    return 'Image upload failed: ${error.message}';
  }

  final text = error.toString();
  if (text.contains('SocketException') ||
      text.contains('ClientException') ||
      text.contains('Failed host lookup')) {
    return 'No connection. Check your internet and try again.';
  }
  return text.replaceFirst('Exception: ', '');
}

bool isPermissionDenied(Object error) {
  if (error is PostgrestException) {
    final message = error.message.toLowerCase();
    return error.code == '42501' ||
        message.contains('row-level security') ||
        message.contains('permission denied');
  }
  return false;
}