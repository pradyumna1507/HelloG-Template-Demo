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
    return true;
  }

  void _submit() {
    for (final field in fields) {
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
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.form.displayName['en'] ?? '',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...sortedSections.map((section) {
            final sectionFields =
                fields.where((f) => f.sectionKey == section.key).toList()
                  ..sort((a, b) => a.order.compareTo(b.order));

            if (sectionFields.isEmpty) {
              return const SizedBox();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.label['en'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Divider(),
                ...sectionFields.map((field) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
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
                const SizedBox(height: 20),
              ],
            );
          }),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit'),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
