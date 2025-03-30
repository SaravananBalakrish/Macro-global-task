import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/task_view_model.dart';

class AddEditTaskScreen extends StatelessWidget {
  final TaskModel? task;
  const AddEditTaskScreen({super.key, this.task});

  @override
  Widget build(BuildContext context) {
    final taskViewModel = Provider.of<TaskViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController(text: task?.title ?? "");
    final _descController = TextEditingController(text: task?.description ?? "");
    String _selectedStatus = task?.status ?? "Pending";
    DateTime? _selectedDeadline = task?.deadline ?? DateTime.now();
    final isEditing = task != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Edit Task" : "Add Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                  validator: (value) => value!.isEmpty ? "Enter a title" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField(
                  value: _selectedStatus,
                  items: ["Pending", "Completed", "Overdue"]
                      .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: (value) => _selectedStatus = value!,
                  decoration: const InputDecoration(labelText: "Status"),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedDeadline == null
                        ? "No deadline selected"
                        : "Deadline: ${_selectedDeadline!.toLocal()}".split('.')[0]),
                    ElevatedButton(
                      child: const Text("Pick Deadline"),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDeadline ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) _selectedDeadline = picked;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                taskViewModel.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  child: Text(isEditing ? "Update Task" : "Add Task"),
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && _selectedDeadline != null) {
                      if (_selectedDeadline!.isBefore(DateTime.now())) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deadline cannot be in the past")));
                        return;
                      }
                      TaskModel newTask = TaskModel(
                        id: task?.id,
                        userId: authViewModel.currentUser!.uid,
                        title: _titleController.text,
                        description: _descController.text,
                        deadline: _selectedDeadline!,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}