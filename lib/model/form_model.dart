import 'field_model.dart';
import 'section_model.dart';

class FormModel {
  final String templateId;

  final int templateFormatVersion;

  final String category;

  final String subCategory;

  final int version;

  final String? icon;

  final String? minAppVersion;

  final Map<String, String> displayName;

  final List<SectionModel> sections;

  final List<FieldModel> eventFields;

  final List<FieldModel> memberIntakeFields;

  FormModel({
    required this.templateId,
    required this.templateFormatVersion,
    required this.category,
    required this.subCategory,
    required this.version,
    required this.displayName,
    required this.sections,
    required this.eventFields,
    required this.memberIntakeFields,
    this.icon,
    this.minAppVersion,
  });

  factory FormModel.fromJson(Map<String, dynamic> json) {
    return FormModel(
      templateId: json['template_id'] ?? '',
      templateFormatVersion: json['template_format_version'] ?? 1,
      category: json['category'] ?? '',
      subCategory: json['subcategory'] ?? '',
      version: json['version'] ?? 1,
      icon: json['icon'],
      minAppVersion: json['min_app_version'],
      displayName: Map<String, String>.from(json['display_name'] ?? {}),
      sections: (json['sections'] as List<dynamic>? ?? [])
          .map((e) => SectionModel.fromJson(e))
          .toList(),
      eventFields: (json['event_fields'] as List<dynamic>? ?? [])
          .map((e) => FieldModel.fromJson(e))
          .toList(),
      memberIntakeFields: (json['member_intake_fields'] as List<dynamic>? ?? [])
          .map((e) => FieldModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "template_id": templateId,
      "template_format_version": templateFormatVersion,
      "category": category,
      "subcategory": subCategory,
      "version": version,
      "display_name": displayName,
      "icon": icon,
      "min_app_version": minAppVersion,
      "sections": sections.map((e) => e.toJson()).toList(),
      "event_fields": eventFields.map((e) => e.toJson()).toList(),
      "member_intake_fields": memberIntakeFields
          .map((e) => e.toJson())
          .toList(),
    };
  }
}
