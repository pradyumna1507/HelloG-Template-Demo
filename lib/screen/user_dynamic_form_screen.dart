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

  // Template Types Enum-like identification
  static const String typeDriving = 'DRIVING';
  static const String typeDance = 'DANCE';
  static const String typeComputer = 'COMPUTER';

  String _selectedTemplateType = typeDriving;
  late FormModel currentForm;
  String? statusMessage;

  @override
  void initState() {
    super.initState();
    _loadSelectedLocalTemplate();
  }

  void _loadSelectedLocalTemplate() {
    Map<String, dynamic> templateData;
    switch (_selectedTemplateType) {
      case typeDance:
        templateData = _danceLearningTemplate();
        break;
      case typeComputer:
        templateData = _computerLearningTemplate();
        break;
      case typeDriving:
      default:
        templateData = _vehicleDrivingTemplate();
        break;
    }
    currentForm = FormModel.fromJson(templateData);
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

    if (!mounted) return;

    try {
      final decoded = jsonDecode(rawContent);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'The selected file is not a valid JSON object.',
        );
      }

      setState(() {
        currentForm = FormModel.fromJson(decoded);
        statusMessage = 'External template loaded from ${file.name}';
      });
    } catch (error) {
      if (!mounted) return;
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
            // --- NEW: Template Switching Switch Tab Bar ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildTabButton('Driving', typeDriving),
                    _buildTabButton('Dance', typeDance),
                    _buildTabButton('Computer', typeComputer),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
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
                    'Upload Custom .json Template',
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
              key: ValueKey(_selectedTemplateType + (statusMessage ?? '')),
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

  Widget _buildTabButton(String label, String type) {
    final isSelected = _selectedTemplateType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTemplateType = type;
            statusMessage = null; // Clear custom upload notice on switch
            _loadSelectedLocalTemplate();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? darkBlack : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 1. Vehicle Driving Learning Template
// ==========================================
Map<String, dynamic> _vehicleDrivingTemplate() {
  return {
    'template_id': 'LEARNING#DRIVING',
    'template_format_version': 1,
    'category': 'LEARNING',
    'subcategory': 'DRIVING',
    'version': 1,
    'display_name': {'en': 'Vehicle Driving Academy'},
    'min_app_version': '1.4.0',
    'sections': [
      {
        'key': 'driving_details',
        'label': {'en': 'Course Details'},
        'order': 1,
      },
    ],
    'event_fields': [
      {
        'key': 'full_name',
        'section_key': 'driving_details',
        'label': {'en': 'Full Name'},
        'type': 'text',
        'required': true,
        'order': 1,
      },
      {
        'key': 'email',
        'section_key': 'driving_details',
        'label': {'en': 'Email Address'},
        'type': 'email',
        'required': true,
        'order': 2,
      },
      {
        'key': 'phone',
        'section_key': 'driving_details',
        'label': {'en': 'Phone Number'},
        'type': 'phone',
        'required': true,
        'order': 3,
      },
      {
        'key': 'license_type',
        'section_key': 'driving_details',
        'label': {'en': 'Target Vehicle Type'},
        'type': 'select',
        'required': true,
        'options': [
          {
            'value': 'two_wheeler',
            'label': {'en': 'Two Wheeler (Motorcycle)'},
          },
          {
            'value': 'four_wheeler_manual',
            'label': {'en': 'Four Wheeler (Manual LMV)'},
          },
          {
            'value': 'four_wheeler_auto',
            'label': {'en': 'Four Wheeler (Automatic LMV)'},
          },
          {
            'value': 'heavy_commercial',
            'label': {'en': 'Heavy Commercial Vehicle'},
          },
        ],
        'order': 4,
      },
      {
        'key': 'has_learner_permit',
        'section_key': 'driving_details',
        'label': {'en': 'Do you already hold a valid Learner\'s Permit?'},
        'type': 'boolean',
        'default': false,
        'order': 5,
      },
      {
        'key': 'permit_number',
        'section_key': 'driving_details',
        'label': {'en': 'Learner\'s Permit Number'},
        'type': 'text',
        'required': false,
        'visible_if': {
          'field': 'has_learner_permit',
          'op': 'equals',
          'value': true,
        },
        'order': 6,
      },
      {
        'key': 'preferred_slot',
        'section_key': 'driving_details',
        'label': {'en': 'Preferred Training Time'},
        'type': 'select',
        'required': true,
        'options': [
          {
            'value': 'morning',
            'label': {'en': 'Early Morning (6 AM - 9 AM)'},
          },
          {
            'value': 'afternoon',
            'label': {'en': 'Afternoon (12 PM - 3 PM)'},
          },
          {
            'value': 'evening',
            'label': {'en': 'Evening (4 PM - 7 PM)'},
          },
        ],
        'order': 7,
      },
      {
        'key': 'start_date',
        'section_key': 'driving_details',
        'label': {'en': 'Preferred Batch Start Date'},
        'type': 'date',
        'required': true,
        'order': 8,
      },
    ],
    'member_intake_fields': [],
  };
}

// ==========================================
// 2. Dance Learning Template
// ==========================================
Map<String, dynamic> _danceLearningTemplate() {
  return {
    'template_id': 'LEARNING#DANCE',
    'template_format_version': 1,
    'category': 'LEARNING',
    'subcategory': 'DANCE',
    'version': 1,
    'display_name': {'en': 'Dance Academy Enrollment'},
    'min_app_version': '1.4.0',
    'sections': [
      {
        'key': 'dance_details',
        'label': {'en': 'Dance Preferences'},
        'order': 1,
      },
    ],
    'event_fields': [
      {
        'key': 'full_name',
        'section_key': 'dance_details',
        'label': {'en': 'Full Name'},
        'type': 'text',
        'required': true,
        'order': 1,
      },
      {
        'key': 'email',
        'section_key': 'dance_details',
        'label': {'en': 'Email Address'},
        'type': 'email',
        'required': true,
        'order': 2,
      },
      {
        'key': 'phone',
        'section_key': 'dance_details',
        'label': {'en': 'Phone Number'},
        'type': 'phone',
        'required': true,
        'order': 3,
      },
      {
        'key': 'age_group',
        'section_key': 'dance_details',
        'label': {'en': 'Age Group'},
        'type': 'select',
        'required': true,
        'options': [
          {
            'value': '5_12',
            'label': {'en': '5 - 12 Years'},
          },
          {
            'value': '13_18',
            'label': {'en': '13 - 18 Years'},
          },
          {
            'value': '19_35',
            'label': {'en': '19 - 35 Years'},
          },
          {
            'value': '36_above',
            'label': {'en': '36+ Years'},
          },
        ],
        'order': 4,
      },
      {
        'key': 'dance_style',
        'section_key': 'dance_details',
        'label': {'en': 'Dance Style Interest'},
        'type': 'select',
        'required': true,
        'options': [
          {
            'value': 'hiphop',
            'label': {'en': 'Hip Hop / Street Dance'},
          },
          {
            'value': 'salsa',
            'label': {'en': 'Salsa & Latin Ballroom'},
          },
          {
            'value': 'classical',
            'label': {'en': 'Contemporary / Classical Ballet'},
          },
          {
            'value': 'bollywood',
            'label': {'en': 'Bollywood Freestyle'},
          },
        ],
        'order': 5,
      },
      {
        'key': 'experience_level',
        'section_key': 'dance_details',
        'label': {'en': 'Your Current Experience Level'},
        'type': 'select',
        'required': true,
        'options': [
          {
            'value': 'absolute_beginner',
            'label': {'en': 'Absolute Beginner (Two left feet)'},
          },
          {
            'value': 'intermediate',
            'label': {'en': 'Intermediate (Know basic rhythms)'},
          },
          {
            'value': 'advanced',
            'label': {'en': 'Advanced / Aspiring Professional'},
          },
        ],
        'order': 6,
      },
      {
        'key': 'medical_conditions',
        'section_key': 'dance_details',
        'label': {
          'en': 'Any relevant physical/medical injuries or conditions?',
        },
        'type': 'textarea',
        'required': false,
        'order': 7,
      },
      {
        'key': 'opt_in_performance',
        'section_key': 'dance_details',
        'label': {
          'en': 'Interested in participating in annual stage recitals?',
        },
        'type': 'boolean',
        'default': true,
        'order': 8,
      },
    ],
    'member_intake_fields': [],
  };
}

// ==========================================
// 3. Computer Learning Template
// ==========================================
Map<String, dynamic> _computerLearningTemplate() {
  return {
    'template_id': 'LEARNING#COMPUTER',
    'template_format_version': 1,
    'category': 'LEARNING',
    'subcategory': 'COMPUTER',
    'version': 1,
    'display_name': {'en': 'IT & Computer Science Bootcamp'},
    'min_app_version': '1.4.0',
    'sections': [
      {
        'key': 'computer_details',
        'label': {'en': 'Technical Track Details'},
        'order': 1,
      },
    ],
    'event_fields': [
      {
        'key': 'full_name',
        'section_key': 'computer_details',
        'label': {'en': 'Full Name'},
        'type': 'text',
        'required': true,
        'order': 1,
      },
      {
        'key': 'email',
        'section_key': 'computer_details',
        'label': {'en': 'Email Address'},
        'type': 'email',
        'required': true,
        'order': 2,
      },
      {
        'key': 'phone',
        'section_key': 'computer_details',
        'label': {'en': 'Phone Number'},
        'type': 'phone',
        'required': true,
        'order': 3,
      },
      {
        'key': 'course_track',
        'section_key': 'computer_details',
        'label': {'en': 'Choose Your Technical Track'},
        'type': 'select',
        'required': true,
        'options': [
          {
            'value': 'python_ai',
            'label': {'en': 'Python Programming & AI Basics'},
          },
          {
            'value': 'web_dev',
            'label': {'en': 'Full-Stack Web Development (MERN)'},
          },
          {
            'value': 'cybersecurity',
            'label': {'en': 'Ethical Hacking & Cybersecurity'},
          },
          {
            'value': 'office_skills',
            'label': {'en': 'Digital Literacy & MS Office Suite'},
          },
        ],
        'order': 4,
      },
      {
        'key': 'has_own_laptop',
        'section_key': 'computer_details',
        'label': {'en': 'Will you bring your own laptop to classes?'},
        'type': 'boolean',
        'default': true,
        'order': 5,
      },
      {
        'key': 'operating_system',
        'section_key': 'computer_details',
        'label': {'en': 'Preferred Primary Operating System'},
        'type': 'select',
        'required': false,
        'visible_if': {
          'field': 'has_own_laptop',
          'op': 'equals',
          'value': true,
        },
        'options': [
          {
            'value': 'windows',
            'label': {'en': 'Windows 10/11'},
          },
          {
            'value': 'macos',
            'label': {'en': 'macOS'},
          },
          {
            'value': 'linux',
            'label': {'en': 'Linux (Ubuntu/Fedora)'},
          },
        ],
        'order': 6,
      },
      {
        'key': 'programming_background',
        'section_key': 'computer_details',
        'label': {'en': 'Prior coding or scripting experience?'},
        'type': 'tags',
        'required': false,
        'order': 7,
      },
      {
        'key': 'batch_time_preference',
        'section_key': 'computer_details',
        'label': {'en': 'Preferred Batch Timing'},
        'type': 'select',
        'required': true,
        'options': [
          {
            'value': 'morning',
            'label': {'en': 'Morning (9 AM - 1 PM)'},
          },
          {
            'value': 'afternoon',
            'label': {'en': 'Afternoon (2 PM - 6 PM)'},
          },
          {
            'value': 'evening',
            'label': {'en': 'Evening (6 PM - 10 PM)'},
          },
          {
            'value': 'weekend',
            'label': {'en': 'Weekend Intensive'},
          },
        ],
        'order': 8,
      },
    ],
    'member_intake_fields': [],
  };
}
