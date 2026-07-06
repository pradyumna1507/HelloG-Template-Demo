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
  late TextEditingController tagController;
  late List<String> tags;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: _stringifyValue(widget.value));
    tagController = TextEditingController();
    tags = (widget.value is List)
        ? (widget.value as List).map((item) => item.toString()).toList()
        : <String>[];
  }

  @override
  void didUpdateWidget(covariant DynamicField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      controller.text = _stringifyValue(widget.value);
      tags = (widget.value is List)
          ? (widget.value as List).map((item) => item.toString()).toList()
          : <String>[];
    }
  }

  @override
  void dispose() {
    controller.dispose();
    tagController.dispose();
    super.dispose();
  }

  String getLabel() {
    return widget.field.label['en'] ?? widget.field.key;
  }

  String _stringifyValue(dynamic value) {
    if (value == null) {
      return '';
    }
    if (value is DateTime) {
      return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    }
    if (value is List) {
      return value.join(', ');
    }
    if (value is Map) {
      return value.toString();
    }
    return value.toString();
  }

  void _addTag() {
    final value = tagController.text.trim();
    if (value.isEmpty) {
      return;
    }
    final updated = [...tags, value];
    setState(() {
      tags = updated;
      tagController.clear();
    });
    widget.onChanged(widget.field.key, updated);
  }

  void _removeTag(String tag) {
    final updated = tags.where((item) => item != tag).toList();
    setState(() {
      tags = updated;
    });
    widget.onChanged(widget.field.key, updated);
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
      case 'currency':
        return _currencyField();
      case 'boolean':
        return _switchField();
      case 'radio':
        return _radioField();
      case 'select':
        return _dropdownField();
      case 'multiselect':
        return _multiSelectField();
      case 'tags':
        return _tagsField();
      case 'date':
        return _dateField();
      case 'date_range':
        return _dateRangeField();
      case 'duration':
        return _durationField();
      case 'document':
      case 'image':
        return _fileField();
      case 'url':
        return _urlField();
      case 'rating_scale':
        return _ratingScaleField();
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

  Widget _currencyField() {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: widget.field.requiredField ? '$getLabel()*' : getLabel(),
        prefixText: '₹ ',
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

  Widget _tagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.field.requiredField ? '$getLabel()*' : getLabel(),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: tagController,
                decoration: const InputDecoration(hintText: 'Add tag'),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(onPressed: _addTag, icon: const Icon(Icons.add)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags
              .map(
                (tag) => InputChip(
                  label: Text(tag),
                  onDeleted: () => _removeTag(tag),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _dateField() {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.field.requiredField ? '$getLabel()*' : getLabel(),
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          widget.onChanged(widget.field.key, picked.toIso8601String());
        }
      },
    );
  }

  Widget _dateRangeField() {
    final currentValue = widget.value is Map
        ? Map<String, dynamic>.from(widget.value as Map)
        : <String, dynamic>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.field.requiredField ? '$getLabel()*' : getLabel(),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _dateSelector(
                label: 'Start',
                value: currentValue['start'],
                onPicked: (picked) {
                  final updated = Map<String, dynamic>.from(currentValue)
                    ..['start'] = picked.toIso8601String();
                  widget.onChanged(widget.field.key, updated);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _dateSelector(
                label: 'End',
                value: currentValue['end'],
                onPicked: (picked) {
                  final updated = Map<String, dynamic>.from(currentValue)
                    ..['end'] = picked.toIso8601String();
                  widget.onChanged(widget.field.key, updated);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dateSelector({
    required String label,
    required dynamic value,
    required ValueChanged<DateTime> onPicked,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value is String
              ? DateTime.tryParse(value) ?? DateTime.now()
              : DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onPicked(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(
          value is String && value.isNotEmpty ? value : 'Select date',
        ),
      ),
    );
  }

  Widget _durationField() {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: widget.field.requiredField ? '$getLabel()*' : getLabel(),
        hintText: 'e.g. 2 hours',
      ),
      onChanged: (value) {
        widget.onChanged(widget.field.key, value);
      },
    );
  }

  Widget _fileField() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.field.requiredField ? '$getLabel()*' : getLabel(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            widget.field.type == 'image' ? 'Image upload' : 'Document upload',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.attach_file),
            label: Text(
              widget.field.type == 'image' ? 'Pick image' : 'Pick document',
            ),
          ),
        ],
      ),
    );
  }

  Widget _urlField() {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.url,
      decoration: InputDecoration(
        labelText: widget.field.requiredField ? '$getLabel()*' : getLabel(),
      ),
      onChanged: (value) {
        widget.onChanged(widget.field.key, value);
      },
    );
  }

  Widget _ratingScaleField() {
    final value = widget.value is num ? (widget.value as num).toInt() : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.field.requiredField ? '$getLabel()*' : getLabel(),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(5, (index) {
            final rating = index + 1;
            return ChoiceChip(
              label: Text('$rating'),
              selected: value == rating,
              onSelected: (_) {
                widget.onChanged(widget.field.key, rating);
              },
            );
          }),
        ),
      ],
    );
  }
}
