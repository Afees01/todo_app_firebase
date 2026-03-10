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

Future addTask({
  required String title,
  String? note,
  int priority = 1,
  DateTime? dueDate,
}) {
  return service.addTask(
    title: title,
    note: note,
    priority: priority,
    dueDate: dueDate,
  );
}

Future editTask(
  String id,
  String title, {
  String? note,
  int? priority,
  DateTime? dueDate,
}) {
  return service.editTask(
    id,
    title,
    note: note,
    priority: priority,
    dueDate: dueDate,
  );
}
  Future deleteTask(String id) => service.deleteTask(id);

  Future toggleTask(String id, bool value) =>
      service.toggleTask(id, value);
}