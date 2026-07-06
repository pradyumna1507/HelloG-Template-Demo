import 'package:flutter/material.dart';

import '../model/field_model.dart';
import 'multi_select_widget.dart';

typedef ValueChangedCallback = void Function(String key, dynamic value);

class DynamicField extends StatefulWidget {
  final FieldModel field;

  final dynamic value;

  final ValueChangedCallback onChanged;

  const DynamicField({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
  });

  @override
  State<DynamicField> createState() => _DynamicFieldState();
}

class _DynamicFieldState extends State<DynamicField> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void didUpdateWidget(covariant DynamicField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      controller.text = widget.value?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String getLabel() {
    return widget.field.label['en'] ?? widget.field.key;
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.field.type) {
      case 'text':
        return _textField();
      case 'textarea':
        return _textArea();
      case 'number':
        return _numberField();
      case 'email':
        return _emailField();
      case 'phone':
        return _phoneField();
      case 'boolean':
        return _switchField();
      case 'radio':
        return _radioField();
      case 'select':
        return _dropdownField();
      case 'multiselect':
        return _multiSelectField();
      default:
        return Card(
          color: Colors.red.shade100,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Unsupported Field Type : ${widget.field.type}'),
          ),
        );
    }
  }

  Widget _textField() {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: widget.field.requiredField ? '$getLabel()*' : getLabel(),
      ),
      onChanged: (value) {
        widget.onChanged(widget.field.key, value);
      },
    );
  }

  Widget _textArea() {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: widget.field.requiredField ? '$getLabel()*' : getLabel(),
      ),
      onChanged: (value) {
        widget.onChanged(widget.field.key, value);
      },
    );
  }

  Widget _numberField() {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: widget.field.requiredField ? '$getLabel()*' : getLabel(),
      ),
      onChanged: (value) {
        widget.onChanged(widget.field.key, num.tryParse(value));
      },
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: widget.field.requiredField ? '$getLabel()*' : getLabel(),
      ),
      onChanged: (value) {
        widget.onChanged(widget.field.key, value);
      },
    );
  }

  Widget _phoneField() {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: widget.field.requiredField ? '$getLabel()*' : getLabel(),
      ),
      onChanged: (value) {
        widget.onChanged(widget.field.key, value);
      },
    );
  }

  Widget _switchField() {
    return SwitchListTile(
      title: Text(getLabel()),
      value: widget.value ?? false,
      onChanged: (value) {
        widget.onChanged(widget.field.key, value);
      },
    );
  }

  Widget _radioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.field.requiredField ? '$getLabel()*' : getLabel(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ...widget.field.options.map((option) {
          return RadioListTile<String>(
            value: option.value,
            groupValue: widget.value?.toString(),
            title: Text(option.label['en'] ?? option.value),
            onChanged: (value) {
              widget.onChanged(widget.field.key, value);
            },
          );
        }),
      ],
    );
  }

  Widget _dropdownField() {
    return DropdownButtonFormField<String>(
      initialValue: widget.value?.toString(),
      decoration: InputDecoration(
        labelText: widget.field.requiredField ? '$getLabel()*' : getLabel(),
      ),
      items: widget.field.options.map((option) {
        return DropdownMenuItem(
          value: option.value,
          child: Text(option.label['en'] ?? option.value),
        );
      }).toList(),
      onChanged: (value) {
        widget.onChanged(widget.field.key, value);
      },
    );
  }

  Widget _multiSelectField() {
    return MultiSelectWidget(
      field: widget.field,
      selectedValues: (widget.value as List?)?.cast<String>() ?? [],
      onChanged: (values) {
        widget.onChanged(widget.field.key, values);
      },
    );
  }
}
