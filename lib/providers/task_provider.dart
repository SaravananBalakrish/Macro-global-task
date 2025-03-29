import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<TaskModel> _tasks = [];

  List<TaskModel> get tasks => _tasks;

  /// **Fetch User's Tasks (Real-time Updates)**
  Stream<List<TaskModel>> fetchTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .orderBy('deadline')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  /// **Add a New Task**
  Future<void> addTask(TaskModel task) async {
    if (task.deadline.isBefore(DateTime.now())) {
      throw Exception("Deadline cannot be in the past.");
    }

    final docRef = await _firestore.collection('tasks').add(task.toMap());
    task.id = docRef.id;
    _tasks.add(task);
    notifyListeners();
  }

  /// **Update an Existing Task**
  Future<void> updateTask(TaskModel task) async {
    if (task.deadline.isBefore(DateTime.now())) {
      throw Exception("Deadline cannot be in the past.");
    }

    await _firestore.collection('tasks').doc(task.id).update(task.toMap());
    _tasks[_tasks.indexWhere((t) => t.id == task.id)] = task;
    notifyListeners();
  }

  /// **Delete a Task**
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }
}
