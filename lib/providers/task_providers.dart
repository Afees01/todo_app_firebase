import 'package:flutter/material.dart';
import 'package:todo_app/controllers/task_controller.dart';
import 'package:todo_app/models/task_model.dart';


class TaskProvider extends ChangeNotifier {

  final TaskController controller = TaskController();

  List<Task> tasks = [];

  Future loadTasks() async {
    tasks = await controller.getTasks();
    notifyListeners();
  }

  Future addTask(String title) async {
    await controller.addTask(title);
    await loadTasks();
  }

  Future deleteTask(String id) async {
    await controller.deleteTask(id);
    await loadTasks();
  }

  Future toggleTask(Task task) async {
    await controller.toggleTask(task.id, !task.completed);
    await loadTasks();
  }
}