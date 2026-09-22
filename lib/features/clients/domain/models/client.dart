import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String id;
  final String projectId;
  final String name;
  final String phone;
  final String email;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Client({
    required this.id,
    required this.projectId,
    required this.name,
    this.phone = '',
    this.email = '',
    this.comment = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Client copyWith({
    String? id,
    String? projectId,
    String? name,
    String? phone,
    String? email,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'name': name,
      'phone': phone,
      'email': email,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Client.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return Client(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
      comment: data['comment'] as String? ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
