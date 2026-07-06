import 'package:flutter/material.dart';

import '../model/form_model.dart';
import '../services/form_repository.dart';
import '../widgets/dynamic_form.dart';

class UserDynamicFormScreen extends StatefulWidget {
  const UserDynamicFormScreen({super.key});

  @override
  State<UserDynamicFormScreen> createState() => _UserDynamicFormScreenState();
}

class _UserDynamicFormScreenState extends State<UserDynamicFormScreen> {
  final FormRepository repository = FormRepository();

  late Future<FormModel?> futureForm;

  @override
  void initState() {
    super.initState();

    futureForm = repository.getForm();
  }

  Future<void> _submitForm(Map<String, dynamic> answers) async {
    final success = await repository.submitForm(answers);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? Colors.green : Colors.red,
        content: Text(
          success ? "Form Submitted Successfully" : "Failed to Submit",
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      futureForm = repository.getForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dynamic Form"), centerTitle: true),

      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<FormModel?>(
          future: futureForm,
          builder: (context, snapshot) {
            //-----------------------------------------
            // Loading
            //-----------------------------------------

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            //-----------------------------------------
            // Error
            //-----------------------------------------

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            //-----------------------------------------
            // No Data
            //-----------------------------------------

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("No Form Found"));
            }

            final form = snapshot.data!;

            //-----------------------------------------
            // Dynamic Form
            //-----------------------------------------

            return DynamicForm(
              form: form,

              /// true = event fields
              eventMode: true,

              onSubmit: (answers) async {
                debugPrint(answers.toString());

                await _submitForm(answers);
              },
            );
          },
        ),
      ),
    );
  }
}
