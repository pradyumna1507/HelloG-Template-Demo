import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/dynamic_form.dart';

class UserFormScreen extends StatelessWidget {
  const UserFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiService.instance.fetchForm(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final form = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: Text(form.displayName["en"]!)),
          body: DynamicForm(
            form: form,
            eventMode: true,
            onSubmit: (answers) {
              debugPrint(answers.toString());
            },
          ),
        );
      },
    );
  }
}
