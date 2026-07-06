import '../model/form_model.dart';
import '../services/api_service.dart';

class FormRepository {
  final ApiService _service = ApiService.instance;

  Future<FormModel?> getForm() {
    return _service.fetchForm();
  }

  Future<bool> saveForm(FormModel form) {
    return _service.saveForm(form);
  }

  Future<bool> submitForm(Map<String, dynamic> answers) {
    return _service.submitResponse(answers);
  }
}
