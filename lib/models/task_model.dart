class Task {
  String id;
  String title;
  bool completed;

  Task({
    required this.id,
    required this.title,
    required this.completed,
  });

  factory Task.fromJson(String id, Map data) {
    return Task(
      id: id,
      title: data['title'] ?? '',
      completed: data['completed'] ?? false,
    );
  }
}