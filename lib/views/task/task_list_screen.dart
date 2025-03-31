import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final authViewModel = context.read<AuthViewModel>();
       /* if (!authViewModel.isAuthenticated || authViewModel.currentUser == null) {
          authViewModel.authenticateUser(context);
        }*/
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final taskViewModel = Provider.of<TaskViewModel>(context);
    final userId = authViewModel.currentUser?.uid;
    final theme = Theme.of(context);


    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Management"),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white,),
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(theme.primaryColor)
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10,),
          Wrap(
            spacing: 10,
            children: ["All", "Pending", "Completed", "Overdue"].map((status) {
              Color chipColor;
              switch (status) {
                case "Completed":
                  chipColor = Colors.green;
                  break;
                case "Overdue":
                  chipColor = Colors.red;
                  break;
                case "Pending":
                  chipColor = Colors.orange;
                  break;
                default:
                  chipColor = Colors.blueGrey;
              }

              return ChoiceChip(
                label: Text(status),
                selected: taskViewModel.filterStatus == status,
                onSelected: (selected) {
                  if (selected) {
                    taskViewModel.setFilterStatus(status);
                  }
                },
                elevation: 5,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
                ),
                selectedColor: chipColor.withAlpha(1000),
                backgroundColor: chipColor.withAlpha(50),
                side: BorderSide(color: taskViewModel.filterStatus == status ? chipColor.withAlpha(50) : chipColor.withAlpha(1000)),
                labelStyle: taskViewModel.filterStatus == status
                    ? Theme.of(context).chipTheme.secondaryLabelStyle
                    : Theme.of(context).chipTheme.labelStyle,
              );
            }).toList(),
          ),
          if(userId != null)
          Expanded(
            child: StreamBuilder<List<TaskModel>>(
              stream: taskViewModel.fetchTasks(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary)));
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}", style: theme.textTheme.bodyMedium));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No tasks found.", style: theme.textTheme.bodyMedium));
                }

                final tasks = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final theme = Theme.of(context);
                    Color statusColor = _getStatusColor(task.status);

                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditTaskScreen(task: task,))),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      task.description,
                                      style: theme.textTheme.bodySmall!.copyWith(color: Colors.grey.shade600),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Deadline
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              DateFormat("dd/MM/yyyy").format(task.deadline),
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                        // Status badge

                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  task.status,
                                  style: theme.textTheme.bodySmall!.copyWith(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(context, task, taskViewModel),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.secondary,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditTaskScreen())),
        child: Icon(Icons.add, color: theme.colorScheme.onSecondary),
      ),
    );
  }

  // Function to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green.shade600;
      case "Pending":
        return Colors.orange.shade600;
      case "Overdue":
        return Colors.red.shade600;
      default:
        return Colors.blueGrey;
    }
  }

// Function for delete confirmation dialog
  void _confirmDelete(BuildContext context, TaskModel task, TaskViewModel taskViewModel) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Delete Task", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete '${task.title}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await taskViewModel.deleteTask(task.id!);
    }
  }
}