import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/task_view_model.dart';
import 'task_add_edit_screen.dart';
import '../auth/profile_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {

  @override
  void initState() {
    super.initState();
    context.read<AuthViewModel>().authenticateUser(context);
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final taskViewModel = Provider.of<TaskViewModel>(context);
    final userId = authViewModel.currentUser?.uid;

    if (authViewModel.isCheckingAuth) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!authViewModel.isAuthenticated || userId == null) {
      return const Scaffold(body: Center(child: Text("Authentication failed. Please log in.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Management"),
        actions: [
          DropdownButton<String>(
            value: taskViewModel.filterStatus,
            items: ["All", "Pending", "Completed", "Overdue"]
                .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                .toList(),
            onChanged: (value) => taskViewModel.setFilterStatus(value!),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: taskViewModel.fetchTasks(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No tasks found."));
          }

          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text("${task.status} - Due: ${task.deadline.toLocal()}".split('.')[0]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    bool? confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete Task"),
                        content: Text("Are you sure you want to delete '${task.title}'?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await taskViewModel.deleteTask(task.id!);
                    }
                  },
                ),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditTaskScreen(task: task))),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditTaskScreen())),
      ),
    );
  }
}