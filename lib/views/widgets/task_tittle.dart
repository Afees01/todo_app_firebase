import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/task_providers.dart';
import '../../models/task_model.dart';

class TaskTile extends StatelessWidget {

  final Task task;

  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<TaskProvider>(context, listen: false);

    return ListTile(
      title: Text(task.title),

      leading: Checkbox(
        value: task.completed,
        onChanged: (_) {
          provider.toggleTask(task);
        },
      ),

      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          provider.deleteTask(task.id);
        },
      ),
    );
  }
}