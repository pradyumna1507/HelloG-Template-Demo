import 'package:flutter/material.dart';

import '../model/field_model.dart';

class MultiSelectWidget extends StatefulWidget {
  final FieldModel field;

  /// Selected values
  final List<String> selectedValues;

  /// Returns selected values
  final ValueChanged<List<String>> onChanged;

  const MultiSelectWidget({
    super.key,
    required this.field,
    required this.selectedValues,
    required this.onChanged,
  });

  @override
  State<MultiSelectWidget> createState() => _MultiSelectWidgetState();
}

class _MultiSelectWidgetState extends State<MultiSelectWidget> {
  late List<String> values;

  @override
  void initState() {
    super.initState();

    values = List<String>.from(widget.selectedValues);
  }

  String get label => widget.field.label["en"] ?? widget.field.key;

  void _toggle(String value) {
    setState(() {
      if (values.contains(value)) {
        values.remove(value);
      } else {
        values.add(value);
      }
    });

    widget.onChanged(values);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.field.options.map((option) {
            final selected = values.contains(option.value);

            return FilterChip(
              label: Text(option.label["en"] ?? option.value),
              selected: selected,
              onSelected: (_) {
                _toggle(option.value);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
