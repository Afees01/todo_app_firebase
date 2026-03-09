import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/task_providers.dart';

class AddTaskView extends StatelessWidget {

  AddTaskView({super.key});

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<TaskProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Add Task")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Task Title",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              child: const Text("Add Task"),
              onPressed: () async {

                await provider.addTask(controller.text);

                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}