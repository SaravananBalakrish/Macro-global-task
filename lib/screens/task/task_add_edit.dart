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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? "");
    _descController = TextEditingController(text: widget.task?.description ?? "");
    _selectedDeadline = widget.task?.deadline;
    _selectedStatus = widget.task?.status ?? "Pending";
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Edit Task" : "Add Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Title"),
                validator: (value) => value!.isEmpty ? "Enter a title" : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              DropdownButtonFormField(
                value: _selectedStatus,
                items: ["Pending", "Completed", "Overdue"]
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedStatus = value!),
              ),
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
              ElevatedButton(
                child: Text(isEditing ? "Update Task" : "Add Task"),
                onPressed: () async {
                  // print(context.read<AuthProvider>().currentUser.toJson());
                  /*if (_formKey.currentState!.validate()) {
                    TaskModel task = TaskModel(
                      id: widget.task?.id,
                      userId: context.read<AuthProvider>().currentUser!.uid,
                      title: _titleController.text,
                      description: _descController.text,
                      deadline: _selectedDeadline!,
                      status: _selectedStatus,
                    );
                    isEditing ? await taskProvider.updateTask(task) : await taskProvider.addTask(task);
                    Navigator.pop(context);
                  }*/
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
