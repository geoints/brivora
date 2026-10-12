import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentReceipt {
  const PaymentReceipt({
    required this.id,
    required this.projectId,
    required this.ownerId,
    required this.fileName,
    required this.filePath,
    required this.contentType,
    required this.sizeBytes,
    required this.paidAt,
    required this.createdAt,
    required this.amount,
    required this.bank,
    required this.comment,
  });

  final String id;
  final String projectId;
  final String ownerId;
  final String fileName;
  final String filePath;
  final String contentType;
  final int sizeBytes;
  final DateTime paidAt;
  final DateTime createdAt;
  final double? amount;
  final String bank;
  final String comment;

  factory PaymentReceipt.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return PaymentReceipt(
      id: doc.id,
      projectId: data['projectId'] as String,
      ownerId: data['ownerId'] as String,
      fileName: data['fileName'] as String,
      filePath: data['filePath'] as String,
      contentType: data['contentType'] as String,
      sizeBytes: (data['sizeBytes'] as num).toInt(),
      paidAt: (data['paidAt'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      amount: (data['amount'] as num?)?.toDouble(),
      bank: (data['bank'] as String?) ?? '',
      comment: (data['comment'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'projectId': projectId,
    'ownerId': ownerId,
    'fileName': fileName,
    'filePath': filePath,
    'contentType': contentType,
    'sizeBytes': sizeBytes,
    'paidAt': Timestamp.fromDate(paidAt),
    'createdAt': Timestamp.fromDate(createdAt),
    'amount': amount,
    'bank': bank,
    'comment': comment,
  };
}
