import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseTaskService {
  final String baseUrl =
      "https://todo-flutter-app-98014-default-rtdb.asia-southeast1.firebasedatabase.app";

  Future<Map<String, dynamic>> fetchTasks() async {
    final res = await http.get(Uri.parse("$baseUrl/tasks.json"));
    return json.decode(res.body) ?? {};
  }

  Future<void> addTask({
    required String title,
    String? note,
    int priority = 1,
    DateTime? dueDate,
  }) async {
    await http.post(
      Uri.parse("$baseUrl/tasks.json"),
      body: json.encode({
        "title": title,
        "note": note,
        "priority": priority,
        "dueDate": dueDate?.toIso8601String(),
        "completed": false,
        "createdAt": DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<void> editTask(
    String id,
    String title, {
    String? note,
    int? priority,
    DateTime? dueDate,
  }) async {
    final Map<String, dynamic> updates = {
      "title": title,
    };

    if (note != null) updates["note"] = note;
    if (priority != null) updates["priority"] = priority;
    if (dueDate != null) updates["dueDate"] = dueDate.toIso8601String();

    await http.patch(
      Uri.parse("$baseUrl/tasks/$id.json"),
      body: json.encode(updates),
    );
  }

  Future<void> deleteTask(String id) async {
    await http.delete(Uri.parse("$baseUrl/tasks/$id.json"));
  }

  Future<void> toggleTask(String id, bool value) async {
    await http.patch(Uri.parse("$baseUrl/tasks/$id.json"),
        body: json.encode({"completed": value}));
  }
}
