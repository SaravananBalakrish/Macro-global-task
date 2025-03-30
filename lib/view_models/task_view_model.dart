import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class TaskViewModel with ChangeNotifier {
  final TaskRepository _taskRepository = TaskRepository();
  String _filterStatus = "All";
  bool _isLoading = false;

  String get filterStatus => _filterStatus;
  bool get isLoading => _isLoading;

  Stream<List<TaskModel>> fetchTasks(String userId) {
    return _taskRepository.fetchTasks(userId, status: _filterStatus);
  }

  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  Future<void> addTask(TaskModel task) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _taskRepository.addTask(task);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask(TaskModel task) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _taskRepository.updateTask(task);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _taskRepository.deleteTask(taskId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}