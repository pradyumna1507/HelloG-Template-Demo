import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../model/form_model.dart';
import 'api_constants.dart';

class ApiService {
  static final ApiService instance = ApiService._();

  ApiService._();

  final http.Client _client = http.Client();
  FormModel? _cachedForm;

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  Future<FormModel?> fetchForm() async {
    if (_cachedForm != null) {
      return _cachedForm;
    }

    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.forms}/1'),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final form = FormModel.fromJson(decoded);
          _cachedForm = form;
          return form;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    _cachedForm = FormModel.fromJson(_demoTemplate());
    return _cachedForm;
  }

  Future<bool> saveForm(FormModel form) async {
    try {
      _cachedForm = form;
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> submitResponse(Map<String, dynamic> answers) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.forms}'),
        headers: _headers,
        body: jsonEncode({'answers': answers}),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint(e.toString());
      return true;
    }
  }

  Map<String, dynamic> _demoTemplate() {
    return {
      'template_id': 'EMPLOYEE_FORM',
      'template_format_version': 1,
      'category': 'HR',
      'subcategory': 'EMPLOYEE',
      'version': 1,
      'display_name': {'en': 'Employee Registration'},
      'sections': [
        {
          'key': 'basic',
          'label': {'en': 'Basic Details'},
          'order': 1,
        },
      ],
      'event_fields': [
        {
          'key': 'name',
          'section_key': 'basic',
          'label': {'en': 'Full Name'},
          'type': 'text',
          'required': true,
          'order': 1,
        },
        {
          'key': 'email',
          'section_key': 'basic',
          'label': {'en': 'Email Address'},
          'type': 'email',
          'required': true,
          'order': 2,
        },
        {
          'key': 'phone',
          'section_key': 'basic',
          'label': {'en': 'Phone Number'},
          'type': 'phone',
          'required': true,
          'order': 3,
        },
        {
          'key': 'gender',
          'section_key': 'basic',
          'label': {'en': 'Gender'},
          'type': 'radio',
          'required': true,
          'order': 4,
          'options': [
            {
              'value': 'male',
              'label': {'en': 'Male'},
            },
            {
              'value': 'female',
              'label': {'en': 'Female'},
            },
            {
              'value': 'other',
              'label': {'en': 'Other'},
            },
          ],
        },
        {
          'key': 'department',
          'section_key': 'basic',
          'label': {'en': 'Department'},
          'type': 'select',
          'required': true,
          'order': 5,
          'options': [
            {
              'value': 'engineering',
              'label': {'en': 'Engineering'},
            },
            {
              'value': 'sales',
              'label': {'en': 'Sales'},
            },
            {
              'value': 'marketing',
              'label': {'en': 'Marketing'},
            },
            {
              'value': 'hr',
              'label': {'en': 'HR'},
            },
          ],
        },
        {
          'key': 'start_date',
          'section_key': 'basic',
          'label': {'en': 'Expected Start Date'},
          'type': 'date',
          'required': true,
          'order': 6,
        },
        {
          'key': 'skills',
          'section_key': 'basic',
          'label': {'en': 'Skills'},
          'type': 'multiselect',
          'required': false,
          'order': 7,
          'options': [
            {
              'value': 'flutter',
              'label': {'en': 'Flutter'},
            },
            {
              'value': 'android',
              'label': {'en': 'Android'},
            },
            {
              'value': 'ios',
              'label': {'en': 'iOS'},
            },
            {
              'value': 'python',
              'label': {'en': 'Python'},
            },
            {
              'value': 'nodejs',
              'label': {'en': 'Node.js'},
            },
          ],
        },
        {
          'key': 'is_employee',
          'section_key': 'basic',
          'label': {'en': 'Are you an existing employee?'},
          'type': 'boolean',
          'default': false,
          'order': 8,
        },
      ],
      'member_intake_fields': [],
    };
  }
}
