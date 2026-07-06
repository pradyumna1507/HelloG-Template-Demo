import '../model/field_model.dart';

class DynamicValidator {
  DynamicValidator._();

  static String? validate(FieldModel field, dynamic value) {
    //---------------------------------------------------
    // Required Validation
    //---------------------------------------------------

    if (field.requiredField) {
      if (value == null) {
        return "${_label(field)} is required";
      }

      if (value is String && value.trim().isEmpty) {
        return "${_label(field)} is required";
      }

      if (value is List && value.isEmpty) {
        return "Please select ${_label(field)}";
      }
    }

    if (value == null) return null;

    //---------------------------------------------------
    // Type Validation
    //---------------------------------------------------

    switch (field.type) {
      case "email":
        return _validateEmail(value.toString());

      case "phone":
        return _validatePhone(value.toString());

      case "number":
      case "currency":
        return _validateNumber(field, value);

      case "url":
        return _validateUrl(value.toString());

      case "text":
      case "textarea":
        return _validateText(field, value.toString());

      case "select":
        return _validateDropdown(field, value);

      case "multiselect":
        return _validateMultiSelect(field, value);

      default:
        return null;
    }
  }

  //--------------------------------------------------------
  // TEXT
  //--------------------------------------------------------

  static String? _validateText(FieldModel field, String value) {
    final validation = field.validation ?? {};

    final minLength = validation["min_length"];
    final maxLength = validation["max_length"];
    final pattern = validation["pattern"];

    if (minLength != null && value.length < minLength) {
      return "Minimum $minLength characters required";
    }

    if (maxLength != null && value.length > maxLength) {
      return "Maximum $maxLength characters allowed";
    }

    if (pattern != null) {
      final regex = RegExp(pattern);

      if (!regex.hasMatch(value)) {
        return "Invalid format";
      }
    }

    return null;
  }

  //--------------------------------------------------------
  // NUMBER
  //--------------------------------------------------------

  static String? _validateNumber(FieldModel field, dynamic value) {
    final validation = field.validation ?? {};

    final min = validation["min"];
    final max = validation["max"];

    final number = num.tryParse(value.toString());

    if (number == null) {
      return "Invalid number";
    }

    if (min != null && number < min) {
      return "Minimum value is $min";
    }

    if (max != null && number > max) {
      return "Maximum value is $max";
    }

    return null;
  }

  //--------------------------------------------------------
  // EMAIL
  //--------------------------------------------------------

  static String? _validateEmail(String value) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');

    if (!regex.hasMatch(value)) {
      return "Invalid Email";
    }

    return null;
  }

  //--------------------------------------------------------
  // PHONE
  //--------------------------------------------------------

  static String? _validatePhone(String value) {
    final regex = RegExp(r'^[6-9]\d{9}$');

    if (!regex.hasMatch(value)) {
      return "Invalid Mobile Number";
    }

    return null;
  }

  //--------------------------------------------------------
  // URL
  //--------------------------------------------------------

  static String? _validateUrl(String value) {
    final regex = RegExp(r'^(https?:\/\/)?([\w\-])+\.{1}[a-zA-Z]{2,}(\/.*)?$');

    if (!regex.hasMatch(value)) {
      return "Invalid URL";
    }

    return null;
  }

  //--------------------------------------------------------
  // DROPDOWN
  //--------------------------------------------------------

  static String? _validateDropdown(FieldModel field, dynamic value) {
    final values = field.options.map((e) => e.value).toList();

    if (!values.contains(value)) {
      return "Invalid Selection";
    }

    return null;
  }

  //--------------------------------------------------------
  // MULTISELECT
  //--------------------------------------------------------

  static String? _validateMultiSelect(FieldModel field, dynamic value) {
    if (value is! List) {
      return "Invalid Selection";
    }

    final allowed = field.options.map((e) => e.value).toSet();

    for (var item in value) {
      if (!allowed.contains(item)) {
        return "Invalid Selection";
      }
    }

    return null;
  }

  //--------------------------------------------------------
  // LABEL
  //--------------------------------------------------------

  static String _label(FieldModel field) {
    return field.label["en"] ?? field.key;
  }
}
