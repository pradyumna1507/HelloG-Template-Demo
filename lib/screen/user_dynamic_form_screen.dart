import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../model/form_model.dart';
import '../widgets/dynamic_form.dart';

class UserDynamicFormScreen extends StatefulWidget {
  const UserDynamicFormScreen({super.key});

  @override
  State<UserDynamicFormScreen> createState() => _UserDynamicFormScreenState();
}

class _UserDynamicFormScreenState extends State<UserDynamicFormScreen> {
  static const Color primaryYellow = Color(0xFFF4B400);
  static const Color darkBlack = Color(0xFF1A1A1A);

  late FormModel currentForm;
  String? statusMessage;

  @override
  void initState() {
    super.initState();
    currentForm = FormModel.fromJson(_defaultWorkshopTemplate());
  }

  Future<void> _loadTemplateFromJsonFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    final rawContent = file.bytes != null
        ? utf8.decode(file.bytes!, allowMalformed: false)
        : await DefaultAssetBundle.of(context).loadString('');

    if (!mounted) {
      return;
    }

    try {
      final decoded = jsonDecode(rawContent);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'The selected file is not a valid JSON object.',
        );
      }

      setState(() {
        currentForm = FormModel.fromJson(decoded);
        statusMessage = 'Template loaded from ${file.name}';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        statusMessage = 'Unable to load template: $error';
      });
    }
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
          'User Form Preview',
          style: TextStyle(color: darkBlack, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Upload JSON template',
            onPressed: _loadTemplateFromJsonFile,
            icon: const Icon(Icons.upload_file, color: primaryYellow),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Container(
            //   margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            //   padding: const EdgeInsets.all(18),
            //   decoration: BoxDecoration(
            //     color: darkBlack,
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   child: Row(
            //     children: [
            //       Container(
            //         padding: const EdgeInsets.all(12),
            //         decoration: const BoxDecoration(
            //           color: primaryYellow,
            //           shape: BoxShape.circle,
            //         ),
            //         child: const Icon(
            //           Icons.person_outline,
            //           color: darkBlack,
            //           size: 24,
            //         ),
            //       ),
            //       const SizedBox(width: 14),
            //       Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             const Text(
            //               'Dynamic Form Experience',
            //               style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 18,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //             const SizedBox(height: 4),
            //             Text(
            //               'Upload a JSON template to render the form instantly',
            //               style: TextStyle(
            //                 color: Colors.white.withOpacity(0.78),
            //                 fontSize: 13,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryYellow,
                    foregroundColor: darkBlack,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _loadTemplateFromJsonFile,
                  icon: const Icon(Icons.file_upload_outlined),
                  label: const Text(
                    'Upload .json Template',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            if (statusMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryYellow.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryYellow.withOpacity(0.35)),
                  ),
                  child: Text(
                    statusMessage!,
                    style: const TextStyle(color: darkBlack, fontSize: 13),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: DynamicForm(
                form: currentForm,
                eventMode: true,
                onSubmit: (answers) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: Text('Submitted ${answers.length} answers'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Map<String, dynamic> _defaultWorkshopTemplate() {
  return {
    'template_id': 'EDUCATION#WORKSHOP',
    'template_format_version': 1,
    'category': 'EDUCATION',
    'subcategory': 'WORKSHOP',
    'version': 1,
    'display_name': {'en': 'Workshop'},
    'min_app_version': '1.4.0',
    'sections': [
      {
        'key': 'workshop_details',
        'label': {'en': 'Workshop details'},
        'order': 1,
      },
    ],
    'event_fields': [
      {
        'key': 'workshop_name',
        'section_key': 'workshop_details',
        'label': {'en': 'Workshop Name'},
        'type': 'text',
        'required': true,
        'order': 1,
      },
      {
        'key': 'description',
        'section_key': 'workshop_details',
        'label': {'en': 'Workshop Description'},
        'type': 'textarea',
        'required': true,
        'order': 2,
      },
      {
        'key': 'duration_hours',
        'section_key': 'workshop_details',
        'label': {'en': 'Duration'},
        'type': 'duration',
        'default': '2 hours',
        'required': true,
        'order': 3,
      },
      {
        'key': 'workshop_date',
        'section_key': 'workshop_details',
        'label': {'en': 'Workshop Date'},
        'type': 'date',
        'required': true,
        'order': 4,
      },
      {
        'key': 'max_participants',
        'section_key': 'workshop_details',
        'label': {'en': 'Max participants'},
        'type': 'number',
        'required': false,
        'validation': {'min': 1, 'max': 500},
        'order': 5,
      },
      {
        'key': 'skill_level',
        'section_key': 'workshop_details',
        'label': {'en': 'Skill Level'},
        'type': 'select',
        'required': false,
        'options': [
          {
            'value': 'beginner',
            'label': {'en': 'Beginner'},
          },
          {
            'value': 'intermediate',
            'label': {'en': 'Intermediate'},
          },
          {
            'value': 'advanced',
            'label': {'en': 'Advanced'},
          },
        ],
        'order': 6,
      },
      {
        'key': 'topics_covered',
        'section_key': 'workshop_details',
        'label': {'en': 'Topics Covered'},
        'type': 'tags',
        'required': false,
        'order': 7,
      },
      {
        'key': 'certificate_provided',
        'section_key': 'workshop_details',
        'label': {'en': 'Certificate Provided'},
        'type': 'boolean',
        'default': false,
        'order': 8,
      },
      {
        'key': 'certificate_issuer',
        'section_key': 'workshop_details',
        'label': {'en': 'Certificate Issuer'},
        'type': 'text',
        'required': false,
        'visible_if': {
          'field': 'certificate_provided',
          'op': 'equals',
          'value': true,
        },
        'order': 9,
      },
      {
        'key': 'instructor_name',
        'section_key': 'workshop_details',
        'label': {'en': 'Instructor Name'},
        'type': 'text',
        'required': true,
        'order': 10,
      },
      {
        'key': 'instructor_email',
        'section_key': 'workshop_details',
        'label': {'en': 'Instructor Email'},
        'type': 'email',
        'required': true,
        'order': 11,
      },
    ],
    'member_intake_fields': [],
  };
}
