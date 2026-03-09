import 'package:todo_app/models/task_model.dart';
import 'package:todo_app/services/firebase_task_service.dart';


class TaskController {

  final FirebaseTaskService service = FirebaseTaskService();

  Future<List<Task>> getTasks() async {
    final data = await service.fetchTasks();

    List<Task> tasks = [];

    data.forEach((key, value) {
      tasks.add(Task.fromJson(key, value));
    });

    return tasks;
  }

  Future addTask(String title) => service.addTask(title);

  Future deleteTask(String id) => service.deleteTask(id);

  Future toggleTask(String id, bool value) =>
      service.toggleTask(id, value);
}