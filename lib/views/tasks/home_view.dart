import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/task_providers.dart';
import 'package:todo_app/views/tasks/add_task_view.dart';
import 'package:todo_app/views/widgets/task_tittle.dart';


class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<TaskProvider>(context, listen: false).loadTasks());
  }

  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Tasks")),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddTaskView()));
        },
      ),

      body: ListView.builder(
        itemCount: provider.tasks.length,
        itemBuilder: (_, i) {

          final task = provider.tasks[i];

          return TaskTile(task: task);
        },
      ),
    );
  }
}