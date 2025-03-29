import 'package:flutter/material.dart';
import 'package:macro_global_task/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? task;
  const AddEditTaskScreen({super.key, this.task});

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime? _selectedDeadline;
  String _selectedStatus = "Pending";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? "");
    _descController = TextEditingController(text: widget.task?.description ?? "");
    _selectedDeadline = widget.task?.deadline ?? DateTime.now();
    _selectedStatus = widget.task?.status ?? "Pending";
  }

  Future<void> _saveTask(BuildContext context) async {
    if (!_formKey.currentState!.validate() || _selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => _isLoading = true);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      TaskModel task = TaskModel(
        id: widget.task?.id,
        userId: authProvider.currentUser!.uid,
        title: _titleController.text,
        description: _descController.text,
        deadline: _selectedDeadline!,
        status: _selectedStatus,
      );

      if (widget.task != null) {
        await taskProvider.updateTask(task);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Task updated successfully")),
        );
      } else {
        await taskProvider.addTask(task);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Task added successfully")),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

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
                  decoration: InputDecoration(labelText: "Title"),
                  validator: (value) => value!.isEmpty ? "Enter a title" : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _descController,
                  decoration: InputDecoration(labelText: "Description"),
                  maxLines: 3,
                ),
                SizedBox(height: 10),
                DropdownButtonFormField(
                  value: _selectedStatus,
                  items: ["Pending", "Completed", "Overdue"]
                      .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedStatus = value!),
                  decoration: InputDecoration(labelText: "Status"),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedDeadline == null
                        ? "No deadline selected"
                        : "Deadline: ${_selectedDeadline!.toLocal()}".split('.')[0]),
                    ElevatedButton(
                      child: Text("Pick Deadline"),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDeadline ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _selectedDeadline = picked);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  child: Text(isEditing ? "Update Task" : "Add Task"),
                  onPressed: () => _saveTask(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }
}