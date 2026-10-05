import '../constants/app_constants.dart';

/// Validator form agar pesan error konsisten di semua layar.
class Validators {
  const Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[\w.!#$%&*+/=?^`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?'
    r'(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$',
  );

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppConstants.msgNameEmpty;
    if (v.length < 3) return AppConstants.msgNameShort;
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppConstants.msgEmailEmpty;
    if (!_emailRegex.hasMatch(v)) return AppConstants.msgEmailInvalid;
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return AppConstants.msgPasswordEmpty;
    if (v.length < 6) return AppConstants.msgPasswordShort;
    return null;
  }

  /// Bandingkan password dengan konfirmasinya.
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return AppConstants.msgPasswordEmpty;
    if (value != password) return AppConstants.msgPasswordNotMatch;
    return null;
  }
}
