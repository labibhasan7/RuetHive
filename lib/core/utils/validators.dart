// App-wide form validation functions.

class AppValidators {
  AppValidators._();

  // General


  /// [fieldName] is shown in the error message
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Field must meet a minimum character length
  static String? minLength(
      String? value,
      int min, {
        String fieldName = 'This field',
      }) {
    if (value == null || value.trim().length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  /// Field must not exceed a maximum character length.
  static String? maxLength(
      String? value,
      int max, {
        String fieldName = 'This field',
      }) {
    if (value != null && value.trim().length > max) {
      return '$fieldName must be $max characters or fewer';
    }
    return null;
  }

  /// Combines required + minLength in one call.
  static String? requiredMinLength(
      String? value,
      int min, {
        String fieldName = 'This field',
      }) {
    final req = required(value, fieldName: fieldName);
    if (req != null) return req;
    return minLength(value, min, fieldName: fieldName);
  }

  // Email

  /// Must be a valid email address format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    // Simple RFC-compliant pattern - covers the vast majority of real addresses
    final pattern = RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!pattern.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Email is optional - only validated if non-empty.
  static String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return email(value);
  }

  //  Numeric

  /// Field must contain only digits.
  static String? numeric(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (int.tryParse(value.trim()) == null) {
      return '$fieldName must be a number';
    }
    return null;
  }

  /// Must be a number within [min]..[max]
  static String? numericRange(
      String? value,
      int min,
      int max, {
        String fieldName = 'This field',
      }) {
    final numCheck = numeric(value, fieldName: fieldName);
    if (numCheck != null) return numCheck;
    final n = int.parse(value!.trim());
    if (n < min || n > max) {
      return '$fieldName must be between $min and $max';
    }
    return null;
  }

  // Academic / RUETHive-specific

  /// Student ID: must be exactly 7 digits
  static String? studentId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Student ID is required';
    }
    final pattern = RegExp(r'^\d{7}$');
    if (!pattern.hasMatch(value.trim())) {
      return 'Student ID must be exactly 7 digits';
    }
    return null;
  }

  /// Course code: letters + digits + optional hyphen, 4-12 chars
  /// Matches patterns like "CSE-2101", "CSE2101", "MATH201"
  static String? courseCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Course code is required';
    }
    final pattern = RegExp(r'^[A-Za-z]{2,6}-?\d{3,6}$');
    if (!pattern.hasMatch(value.trim())) {
      return 'Enter a valid course code (e.g. CSE-2101)';
    }
    return null;
  }

  /// Room / hall: alphanumeric with spaces, 2-20 chars
  static String? roomNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Room / hall is required';
    }
    if (value.trim().length < 2 || value.trim().length > 20) {
      return 'Room must be 2–20 characters';
    }
    return null;
  }

  /// Schedule / notice title: required, 5-120 chars
  static String? title(String? value) {
    return requiredMinLength(value, 5, fieldName: 'Title') ??
        maxLength(value, 120, fieldName: 'Title');
  }

  /// Notice / schedule body text: required, 10-1000 chars
  static String? bodyText(String? value) {
    return requiredMinLength(value, 10, fieldName: 'Description') ??
        maxLength(value, 1000, fieldName: 'Description');
  }

  /// Teacher / person name: required, 3-60 chars, letters and spaces only
  static String? personName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < 3) {
      return '$fieldName must be at least 3 characters';
    }
    if (value.trim().length > 60) {
      return '$fieldName must be 60 characters or fewer';
    }
    final pattern = RegExp(r"^[A-Za-z\s.\-']+$");
    if (!pattern.hasMatch(value.trim())) {
      return '$fieldName can only contain letters, spaces, and . - \'';
    }
    return null;
  }

  //  Time


  static String? timeOrder(String? startTime, String? endTime) {
    if (startTime == null || endTime == null) return null;
    try {
      final format = RegExp(r'^(\d{1,2}):(\d{2})\s?(AM|PM)$', caseSensitive: false);
      final s = format.firstMatch(startTime.trim());
      final e = format.firstMatch(endTime.trim());
      if (s == null || e == null) return null;

      int toMinutes(RegExpMatch m) {
        int h = int.parse(m.group(1)!);
        final min = int.parse(m.group(2)!);
        final period = m.group(3)!.toUpperCase();
        if (period == 'PM' && h != 12) h += 12;
        if (period == 'AM' && h == 12) h = 0;
        return h * 60 + min;
      }

      if (toMinutes(e) <= toMinutes(s)) {
        return 'End time must be after start time';
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  // Composition helper

  static String? compose(List<String? Function()> validators) {
    for (final v in validators) {
      final result = v();
      if (result != null) return result;
    }
    return null;
  }
}