import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseTaskService {

  final String baseUrl =
      "https://todo-flutter-app-98014-default-rtdb.asia-southeast1.firebasedatabase.app";

  Future<Map<String, dynamic>> fetchTasks() async {
    final res = await http.get(Uri.parse("$baseUrl/tasks.json"));
    return json.decode(res.body) ?? {};
  }

  Future<void> addTask(String title) async {
    await http.post(Uri.parse("$baseUrl/tasks.json"),
        body: json.encode({
          "title": title,
          "completed": false
        }));
  }

  Future<void> deleteTask(String id) async {
    await http.delete(Uri.parse("$baseUrl/tasks/$id.json"));
  }

  Future<void> toggleTask(String id, bool value) async {
    await http.patch(Uri.parse("$baseUrl/tasks/$id.json"),
        body: json.encode({"completed": value}));
  }
}