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
    final document = await _clientDocument(projectId).get();

    if (document.exists) {
      return Client.fromFirestore(document);
    }

    // Backward compatibility for clients created before projectId became
    // the document id. If found, migrate the client to the canonical path.
    final legacySnapshot = await _clientsCollection
        .where('projectId', isEqualTo: projectId)
        .limit(1)
        .get();

    if (legacySnapshot.docs.isEmpty) {
      return null;
    }

    final legacyClient = Client.fromFirestore(legacySnapshot.docs.first);
    final migratedClient = legacyClient.copyWith(id: projectId);

    await _clientDocument(projectId).set(migratedClient.toFirestore());

    return migratedClient;
  }

  Future<Client> createClient(Client client) async {
    final storedClient = client.copyWith(id: client.projectId);

    await _clientDocument(client.projectId).set(storedClient.toFirestore());

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
