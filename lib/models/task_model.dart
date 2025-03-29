import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  String? id;
  String userId;
  String title;
  String description;
  DateTime deadline;
  String status; // "Pending", "Completed", "Overdue"

  TaskModel({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.deadline,
    required this.status,
  });

  /// Convert Firestore document to `TaskModel`
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      description: data['description'],
      deadline: (data['deadline'] as Timestamp).toDate(),
      status: data['status'],
    );
  }

  /// Convert `TaskModel` to JSON (Firestore & Local Storage)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'deadline': Timestamp.fromDate(deadline),
      'status': status,
    };
  }
}
