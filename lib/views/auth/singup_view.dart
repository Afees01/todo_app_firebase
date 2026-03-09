import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import 'login_view.dart';

class SignupView extends StatelessWidget {

  SignupView({super.key});

  final email = TextEditingController();
  final password = TextEditingController();

  final controller = AuthController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Signup")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: password,
              decoration: const InputDecoration(labelText: "Password"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              child: const Text("Signup"),
              onPressed: () async {

                await controller.signup(email.text, password.text);

                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginView()));
              },
            )
          ],
        ),
      ),
    );
  }
}