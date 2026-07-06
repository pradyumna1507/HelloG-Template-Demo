import 'package:flutter/material.dart';

import '../model/field_model.dart';
import '../model/form_model.dart';
import 'dynamic_field.dart';

class DynamicForm extends StatefulWidget {
  final FormModel form;

  /// true = event_fields
  /// false = member_intake_fields
  final bool eventMode;

  final Function(Map<String, dynamic>) onSubmit;

  const DynamicForm({
    super.key,
    required this.form,
    this.eventMode = true,
    required this.onSubmit,
  });

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final Map<String, dynamic> formValues = {};

  List<FieldModel> get fields {
    return widget.eventMode
        ? widget.form.eventFields
        : widget.form.memberIntakeFields;
  }

  @override
  void initState() {
    super.initState();
    _resetFormValues();
  }

  @override
  void didUpdateWidget(covariant DynamicForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.form.templateId != widget.form.templateId ||
        oldWidget.eventMode != widget.eventMode) {
      _resetFormValues();
    }
  }

  void _resetFormValues() {
    formValues.clear();
    for (final field in fields) {
      formValues[field.key] = field.defaultValue;
    }
  }

  bool _hasValue(dynamic value) {
    if (value == null) {
      return false;
    }
    if (value is String) {
      return value.trim().isNotEmpty;
    }
    if (value is List) {
      return value.isNotEmpty;
    }
    if (value is Map) {
      return value.isNotEmpty;
    }
    return true;
  }

  bool _shouldShowField(FieldModel field) {
    if (field.visibleIf == null) {
      return true;
    }

    final sourceValue = formValues[field.visibleIf!.field];
    switch (field.visibleIf!.op) {
      case 'equals':
        return sourceValue == field.visibleIf!.value;
      case 'not_equals':
        return sourceValue != field.visibleIf!.value;
      case 'in':
        if (field.visibleIf!.value is List) {
          return (field.visibleIf!.value as List).contains(sourceValue);
        }
        return false;
      case 'not_in':
        if (field.visibleIf!.value is List) {
          return !(field.visibleIf!.value as List).contains(sourceValue);
        }
        return true;
      default:
        return true;
    }
  }

  void _submit() {
    for (final field in fields) {
      if (!_shouldShowField(field)) {
        continue;
      }
      if (field.requiredField && !_hasValue(formValues[field.key])) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${field.label['en'] ?? field.key} is required.'),
          ),
        );
        return;
      }
    }

    widget.onSubmit(Map<String, dynamic>.from(formValues));
  }

  @override
  Widget build(BuildContext context) {
    final sortedSections = [...widget.form.sections]
      ..sort((a, b) => a.order.compareTo(b.order));

    return Form(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4B400).withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF4B400).withOpacity(0.35),
              ),
            ),
            child: Text(
              widget.form.displayName['en'] ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...sortedSections.map((section) {
            final sectionFields =
                fields.where((f) => f.sectionKey == section.key).toList()
                  ..sort((a, b) => a.order.compareTo(b.order));

            if (sectionFields.isEmpty) {
              return const SizedBox();
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.label['en'] ?? '',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...sectionFields.where(_shouldShowField).map((field) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: DynamicField(
                        field: field,
                        value: formValues[field.key],
                        onChanged: (key, value) {
                          setState(() {
                            formValues[key] = value;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4B400),
                foregroundColor: const Color(0xFF1A1A1A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _submit,
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
