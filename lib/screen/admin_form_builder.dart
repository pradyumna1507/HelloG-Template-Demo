import 'package:flutter/material.dart';

import '../model/field_model.dart';
import '../model/form_model.dart';
import '../model/option_model.dart';
import '../model/section_model.dart';
import '../services/form_repository.dart';
import 'user_dynamic_form_screen.dart';

class AdminFormBuilder extends StatefulWidget {
  const AdminFormBuilder({super.key});

  @override
  State<AdminFormBuilder> createState() => _AdminFormBuilderState();
}

class _AdminFormBuilderState extends State<AdminFormBuilder> {
  final FormRepository _repository = FormRepository();
  final List<FieldModel> _fields = [];
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _optionsController = TextEditingController();

  String _selectedType = 'text';
  bool _required = false;

  static const Color primaryYellow = Color(0xFFF4B400);
  static const Color darkBlack = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();

    _fields.addAll([
      FieldModel(
        key: 'name',
        sectionKey: 'basic',
        label: {'en': 'Full Name'},
        type: 'text',
        requiredField: true,
        order: 1,
      ),
      FieldModel(
        key: 'email',
        sectionKey: 'basic',
        label: {'en': 'Email'},
        type: 'email',
        requiredField: true,
        order: 2,
      ),
      FieldModel(
        key: 'gender',
        sectionKey: 'basic',
        label: {'en': 'Gender'},
        type: 'radio',
        requiredField: false,
        order: 3,
        options: [
          OptionModel(value: 'male', label: {'en': 'Male'}),
          OptionModel(value: 'female', label: {'en': 'Female'}),
        ],
      ),
    ]);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _keyController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex--;
      }

      final item = _fields.removeAt(oldIndex);
      _fields.insert(newIndex, item);
      _refreshOrder();
    });
  }

  void _deleteField(int index) {
    setState(() {
      _fields.removeAt(index);
      _refreshOrder();
    });
  }

  void _refreshOrder() {
    for (int i = 0; i < _fields.length; i++) {
      _fields[i] = FieldModel(
        key: _fields[i].key,
        sectionKey: _fields[i].sectionKey,
        label: _fields[i].label,
        type: _fields[i].type,
        requiredField: _fields[i].requiredField,
        order: i + 1,
        defaultValue: _fields[i].defaultValue,
        helpText: _fields[i].helpText,
        placeholder: _fields[i].placeholder,
        options: _fields[i].options,
        validation: _fields[i].validation,
        visibleIf: _fields[i].visibleIf,
      );
    }
  }

  void _showAddFieldDialog() {
    _labelController.clear();
    _keyController.clear();
    _optionsController.clear();
    _selectedType = 'text';
    _required = false;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Field'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _labelController,
                    decoration: const InputDecoration(labelText: 'Field Label'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a label';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _keyController,
                    decoration: const InputDecoration(labelText: 'Field Key'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a key';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(labelText: 'Field Type'),
                    items: const [
                      DropdownMenuItem(value: 'text', child: Text('Text')),
                      DropdownMenuItem(value: 'email', child: Text('Email')),
                      DropdownMenuItem(value: 'phone', child: Text('Phone')),
                      DropdownMenuItem(value: 'number', child: Text('Number')),
                      DropdownMenuItem(value: 'radio', child: Text('Radio')),
                      DropdownMenuItem(
                        value: 'select',
                        child: Text('Dropdown'),
                      ),
                      DropdownMenuItem(
                        value: 'multiselect',
                        child: Text('Multi Select'),
                      ),
                      DropdownMenuItem(value: 'boolean', child: Text('Switch')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value ?? 'text';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Required field'),
                    value: _required,
                    onChanged: (value) {
                      setState(() {
                        _required = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _optionsController,
                    decoration: const InputDecoration(
                      labelText: 'Options (comma separated)',
                      hintText: 'male, female',
                    ),
                    enabled:
                        _selectedType == 'radio' ||
                        _selectedType == 'select' ||
                        _selectedType == 'multiselect',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final label = _labelController.text.trim();
                  final key = _keyController.text.trim();
                  final options = _optionsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  setState(() {
                    _fields.add(
                      FieldModel(
                        key: key,
                        sectionKey: 'basic',
                        label: {'en': label},
                        type: _selectedType,
                        requiredField: _required,
                        order: _fields.length + 1,
                        options: options
                            .map(
                              (option) => OptionModel(
                                value: option.toLowerCase(),
                                label: {'en': option},
                              ),
                            )
                            .toList(),
                      ),
                    );
                  });

                  Navigator.pop(context);
                }
              },
              child: const Text('Add Field'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveForm() async {
    if (_fields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one field before saving.')),
      );
      return;
    }

    final form = FormModel(
      templateId: 'DEMO_FORM',
      templateFormatVersion: 1,
      category: 'Demo',
      subCategory: 'Dynamic',
      version: 1,
      displayName: {'en': 'Demo Form'},
      sections: [
        SectionModel(key: 'basic', label: {'en': 'Basic Details'}, order: 1),
      ],
      eventFields: _fields,
      memberIntakeFields: const [],
    );

    final saved = await _repository.saveForm(form);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: saved ? Colors.green : Colors.red,
        content: Text(
          saved ? 'Form saved successfully' : 'Could not save the form',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Admin Form Builder',
          style: TextStyle(color: darkBlack, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            color: primaryYellow,
            icon: const Icon(Icons.preview),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UserDynamicFormScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // Dashboard Header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: darkBlack,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: primaryYellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.dashboard_customize,
                    color: darkBlack,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Build Dynamic Forms',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Create, reorder and manage fields',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryYellow,
                    foregroundColor: darkBlack,
                  ),
                  onPressed: _showAddFieldDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),

          Expanded(
            child: _fields.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.dynamic_form,
                          size: 70,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No fields added',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap Add button to create fields',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _fields.length,
                    onReorder: _onReorder,
                    buildDefaultDragHandles: false,
                    itemBuilder: (context, index) {
                      final field = _fields[index];

                      return Container(
                        key: ValueKey(field.key),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),

                          leading: ReorderableDragStartListener(
                            index: index,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryYellow.withOpacity(.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.drag_handle,
                                color: darkBlack,
                              ),
                            ),
                          ),

                          title: Text(
                            field.label['en'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryYellow.withOpacity(.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    field.type,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  field.requiredField ? 'Required' : 'Optional',
                                ),
                              ],
                            ),
                          ),

                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _deleteField(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 26),
        decoration: const BoxDecoration(color: Colors.white),
        child: SizedBox(
          height: 55,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryYellow,
              foregroundColor: darkBlack,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
            label: const Text(
              'Save Form',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
