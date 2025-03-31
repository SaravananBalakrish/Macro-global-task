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

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TaskModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? 'Untitled',
      description: data['description'] ?? '',
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toMap() {
    print("userId :: $userId");
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'deadline': Timestamp.fromDate(deadline),
      'status': status,
    };
  }
}