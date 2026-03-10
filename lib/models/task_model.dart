class Task {
  String id;
  String title;
  String? note;
  int priority;
  bool completed;
  DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    this.note,
    this.priority = 1,
    required this.completed,
    this.dueDate,
  });

  factory Task.fromJson(String id, Map data) {
    return Task(
      id: id,
      title: data['title'] ?? '',
      note: data['note'],
      priority: data['priority'] ?? 1,
      completed: data['completed'] ?? false,
      dueDate: data['dueDate'] != null
          ? DateTime.parse(data['dueDate'])
          : null,
    );
  }
}