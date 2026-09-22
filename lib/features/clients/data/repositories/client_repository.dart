import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/client.dart';

class ClientRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _clientsCollection {
    return _firestore.collection('clients');
  }

  Future<Client?> getClientByProjectId(String projectId) async {
    final snapshot = await _clientsCollection
        .where('projectId', isEqualTo: projectId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return Client.fromFirestore(snapshot.docs.first);
  }

  Future<Client> createClient(Client client) async {
    final doc = await _clientsCollection.add(client.toFirestore());
    return client.copyWith(id: doc.id);
  }

  Future<void> updateClient(Client client) async {
    await _clientsCollection.doc(client.id).update(
      client.copyWith(updatedAt: DateTime.now()).toFirestore(),
    );
  }

  Future<void> deleteClient(String clientId) async {
    await _clientsCollection.doc(clientId).delete();
  }
}
