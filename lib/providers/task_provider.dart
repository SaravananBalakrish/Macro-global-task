import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<TaskModel> _tasks = [];

  List<TaskModel> get tasks => _tasks;

  Stream<List<TaskModel>> fetchTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .orderBy('deadline')
        .snapshots()
        .map((snapshot) {
      final taskList = snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
      _tasks = taskList; // Sync local list with stream
      notifyListeners();
      return taskList;
    }).handleError((error) {
      throw Exception("Failed to fetch tasks: $error");
    });
  }

  Future<void> addTask(TaskModel task) async {
    if (task.deadline.isBefore(DateTime.now())) {
      throw Exception("Deadline cannot be in the past.");
    }
    try {
      final docRef = await _firestore.collection('tasks').add(task.toMap());
      task.id = docRef.id;
      _tasks.add(task);
      notifyListeners();
    } catch (e) {
      throw Exception("Failed to add task: $e");
    }
  }

  Future<void> updateTask(TaskModel task) async {
    if (task.deadline.isBefore(DateTime.now())) {
      throw Exception("Deadline cannot be in the past.");
    }
    try {
      await _firestore.collection('tasks').doc(task.id).update(task.toMap());
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        notifyListeners();
      }
    } catch (e) {
      throw Exception("Failed to update task: $e");
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      throw Exception("Failed to delete task: $e");
    }
  }
}