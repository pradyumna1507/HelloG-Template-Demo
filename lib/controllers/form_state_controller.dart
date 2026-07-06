import 'package:flutter/foundation.dart';

import '../model/field_model.dart';
import '../model/form_model.dart';

class FormStateController extends ChangeNotifier {
  final FormModel form;

  /// Stores all field values
  final Map<String, dynamic> _values = {};

  FormStateController({required this.form}) {
    _initialize();
  }

  //------------------------------------------------------------
  // Initialize Default Values
  //------------------------------------------------------------

  void _initialize() {
    final allFields = [...form.eventFields, ...form.memberIntakeFields];

    for (final field in allFields) {
      _values[field.key] = field.defaultValue;
    }
  }

  //------------------------------------------------------------
  // Get Value
  //------------------------------------------------------------

  dynamic getValue(String key) {
    return _values[key];
  }

  //------------------------------------------------------------
  // Set Value
  //------------------------------------------------------------

  void setValue(String key, dynamic value) {
    _values[key] = value;

    notifyListeners();
  }

  //------------------------------------------------------------
  // Get All Values
  //------------------------------------------------------------

  Map<String, dynamic> get values {
    return Map<String, dynamic>.from(_values);
  }

  //------------------------------------------------------------
  // Reset Form
  //------------------------------------------------------------

  void reset() {
    _values.clear();

    _initialize();

    notifyListeners();
  }

  //------------------------------------------------------------
  // Clear One Field
  //------------------------------------------------------------

  void clearField(String key) {
    _values.remove(key);

    notifyListeners();
  }

  //------------------------------------------------------------
  // Check VisibleIf
  //------------------------------------------------------------

  bool isFieldVisible(FieldModel field) {
    final rule = field.visibleIf;

    if (rule == null) {
      return true;
    }

    final currentValue = _values[rule.field];

    switch (rule.op) {
      case "equals":
        return currentValue == rule.value;

      case "not_equals":
        return currentValue != rule.value;

      case "in":
        if (currentValue is List) {
          return currentValue.contains(rule.value);
        }
        return false;

      case "not_in":
        if (currentValue is List) {
          return !currentValue.contains(rule.value);
        }
        return true;

      default:
        return true;
    }
  }

  //------------------------------------------------------------
  // Visible Fields
  //------------------------------------------------------------

  List<FieldModel> getVisibleFields(List<FieldModel> fields) {
    return fields.where(isFieldVisible).toList();
  }

  //------------------------------------------------------------
  // Remove Hidden Values
  //------------------------------------------------------------

  void clearHiddenFields(List<FieldModel> fields) {
    for (final field in fields) {
      if (!isFieldVisible(field)) {
        _values.remove(field.key);
      }
    }
  }

  //------------------------------------------------------------
  // Populate Existing Data
  //------------------------------------------------------------

  void loadAnswers(Map<String, dynamic> answers) {
    _values.clear();

    _values.addAll(answers);

    notifyListeners();
  }

  //------------------------------------------------------------
  // Check if Dirty
  //------------------------------------------------------------

  bool get hasChanges {
    return _values.values.any((e) => e != null);
  }

  //------------------------------------------------------------
  // JSON Payload
  //------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return Map<String, dynamic>.from(_values);
  }
}
