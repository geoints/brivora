import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/models/payment_receipt.dart';

class PaymentReceiptRepository {
  PaymentReceiptRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _auth = auth ?? FirebaseAuth.instance;

  static const maxFileBytes = 15 * 1024 * 1024;
  static const allowedContentTypes = <String, String>{
    'pdf': 'application/pdf',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
  };

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('payment_receipts');

  Stream<List<PaymentReceipt>> watchProjectReceipts(String projectId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _collection
        .where('projectId', isEqualTo: projectId)
        .where('ownerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(PaymentReceipt.fromFirestore)
              .toList(growable: false),
        );
  }

  Future<PaymentReceipt> uploadReceipt({
    required String projectId,
    required String fileName,
    required Uint8List bytes,
    required String extension,
    required DateTime paidAt,
    required double? amount,
    required String bank,
    required String comment,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Необходимо войти в аккаунт.');

    final normalizedExtension = extension.toLowerCase();
    final contentType = allowedContentTypes[normalizedExtension];
    if (contentType == null) {
      throw const FormatException('Поддерживаются только PDF, JPG и PNG.');
    }
    if (bytes.isEmpty || bytes.length > maxFileBytes) {
      throw const FormatException('Размер файла должен быть не более 15 МБ.');
    }

    final document = _collection.doc();
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._ -]'), '_');
    final storageName = '${document.id}.$normalizedExtension';
    final storagePath = 'projects/$projectId/receipts/$storageName';
    final storageRef = _storage.ref().child(storagePath);

    await storageRef.putData(
      bytes,
      SettableMetadata(
        contentType: contentType,
        customMetadata: {'originalName': safeName},
      ),
    );

    try {
      final receipt = PaymentReceipt(
        id: document.id,
        projectId: projectId,
        ownerId: user.uid,
        fileName: safeName,
        filePath: storagePath,
        contentType: contentType,
        sizeBytes: bytes.length,
        paidAt: paidAt,
        createdAt: DateTime.now(),
        amount: amount,
        bank: bank.trim(),
        comment: comment.trim(),
      );
      await document.set(receipt.toFirestore());
      return receipt;
    } catch (_) {
      await storageRef.delete();
      rethrow;
    }
  }

  Future<String> getDownloadUrl(PaymentReceipt receipt) =>
      _storage.ref().child(receipt.filePath).getDownloadURL();

  Future<void> deleteReceipt(PaymentReceipt receipt) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != receipt.ownerId) {
      throw StateError('Недостаточно прав для удаления чека.');
    }

    await _collection.doc(receipt.id).delete();
    try {
      await _storage.ref().child(receipt.filePath).delete();
    } on FirebaseException catch (error) {
      // A missing object must not leave a stale Firestore entry.
      if (error.code != 'object-not-found') rethrow;
    }
  }
}
