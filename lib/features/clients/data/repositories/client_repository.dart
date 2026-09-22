import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/client.dart';

class ClientRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _clientsCollection {
    return _firestore.collection('clients');
  }

  DocumentReference<Map<String, dynamic>> _clientDocument(String projectId) {
    return _clientsCollection.doc(projectId);
  }

  Future<Client?> getClientByProjectId(String projectId) async {
    // One canonical document per project. This avoids Firestore query/rules
    // mismatches and guarantees that the client belongs to this project.
    final document = await _clientDocument(projectId).get();

    if (!document.exists) {
      return null;
    }

    return Client.fromFirestore(document);
  }

  Future<Client> createClient(Client client) async {
    final storedClient = client.copyWith(id: client.projectId);

    await _clientDocument(client.projectId).set(
      storedClient.toFirestore(),
    );

    return storedClient;
  }

  Future<void> updateClient(Client client) async {
    final updatedClient = client.copyWith(
      id: client.projectId,
      updatedAt: DateTime.now(),
    );

    await _clientDocument(client.projectId).set(
      updatedClient.toFirestore(),
    );
  }

  Future<void> deleteClient(String projectId) async {
    await _clientDocument(projectId).delete();
  }
}
