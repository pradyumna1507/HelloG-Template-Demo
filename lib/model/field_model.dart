import 'option_model.dart';
import 'visible_if_model.dart';

class FieldModel {
  final String key;
  final String sectionKey;

  final Map<String, String> label;
  final Map<String, String>? helpText;
  final Map<String, String>? placeholder;

  final String type;

  final bool requiredField;

  final dynamic defaultValue;

  final int order;

  final List<OptionModel> options;

  final Map<String, dynamic>? validation;

  final VisibleIfModel? visibleIf;

  FieldModel({
    required this.key,
    required this.sectionKey,
    required this.label,
    required this.type,
    required this.requiredField,
    required this.order,
    this.defaultValue,
    this.helpText,
    this.placeholder,
    this.options = const [],
    this.validation,
    this.visibleIf,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      key: json['key'] ?? '',
      sectionKey: json['section_key'] ?? '',
      label: Map<String, String>.from(json['label'] ?? {}),
      helpText: json['help_text'] != null
          ? Map<String, String>.from(json['help_text'])
          : null,
      placeholder: json['placeholder'] != null
          ? Map<String, String>.from(json['placeholder'])
          : null,
      type: json['type'] ?? 'text',
      requiredField: json['required'] ?? false,
      defaultValue: json['default'],
      order: json['order'] ?? 0,
      validation: json['validation'],
      visibleIf: json['visible_if'] != null
          ? VisibleIfModel.fromJson(json['visible_if'])
          : null,
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => OptionModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "key": key,
      "section_key": sectionKey,
      "label": label,
      "help_text": helpText,
      "placeholder": placeholder,
      "type": type,
      "required": requiredField,
      "default": defaultValue,
      "order": order,
      "validation": validation,
      "visible_if": visibleIf?.toJson(),
      "options": options.map((e) => e.toJson()).toList(),
    };
  }
}
