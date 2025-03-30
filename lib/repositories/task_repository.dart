import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TaskModel>> fetchTasks(String userId, {String? status}) {
    Query query = _firestore.collection('tasks').where('userId', isEqualTo: userId).orderBy('deadline');
    if (status != null && status != "All") {
      query = query.where('status', isEqualTo: status);
    }
    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  Future<void> addTask(TaskModel task) async {
    if (task.deadline.isBefore(DateTime.now())) throw Exception("Deadline cannot be in the past.");
    final docRef = await _firestore.collection('tasks').add(task.toMap());
    task.id = docRef.id;
  }

  Future<void> updateTask(TaskModel task) async {
    if (task.deadline.isBefore(DateTime.now())) throw Exception("Deadline cannot be in the past.");
    await _firestore.collection('tasks').doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }
}