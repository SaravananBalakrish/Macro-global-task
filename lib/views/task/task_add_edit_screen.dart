import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/task_view_model.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? task;
  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _selectedStatus;
  late DateTime _selectedDeadline;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? "");
    _descController = TextEditingController(text: widget.task?.description ?? "");
    _selectedStatus = widget.task?.status ?? "Pending";
    _selectedDeadline = widget.task?.deadline ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskViewModel = Provider.of<TaskViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final isEditing = widget.task != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Task" : "Add Task"),
        elevation: 0,
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: "Title", prefixIcon: Icon(Icons.title)),
                        validator: (value) => value!.isEmpty ? "Enter a title" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descController,
                        decoration: const InputDecoration(labelText: "Description", prefixIcon: Icon(Icons.description)),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField(
                        value: _selectedStatus,
                        items: ["Pending", "Completed", "Overdue"]
                            .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedStatus = value!);
                        },
                        decoration: const InputDecoration(labelText: "Status", prefixIcon: Icon(Icons.list)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              "Deadline: ${DateFormat('dd/MM/yyyy').format(_selectedDeadline)}",
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDeadline,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() => _selectedDeadline = picked);  // ✅ Update UI
                              }
                            },
                            child: const Text("Pick Deadline"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      taskViewModel.isLoading
                          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary)))
                          : ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (_selectedDeadline.isBefore(DateTime.now())) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deadline cannot be in the past")));
                              return;
                            }

                            TaskModel newTask = TaskModel(
                              id: widget.task?.id,
                              userId: authViewModel.currentUser!.uid,
                              title: _titleController.text,
                              description: _descController.text,
                              deadline: _selectedDeadline,
                              status: _selectedStatus,
                            );

                            try {
                              if (isEditing) {
                                await taskViewModel.updateTask(newTask);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Task updated successfully")));
                              } else {
                                await taskViewModel.addTask(newTask);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Task added successfully")));
                              }
                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all required fields")));
                          }
                        },
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                        child: Text(isEditing ? "Update Task" : "Add Task", style: const TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
