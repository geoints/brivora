import 'package:flutter/foundation.dart';

import '../../data/repositories/client_repository.dart';
import '../../domain/models/client.dart';

class ClientProvider extends ChangeNotifier {
  final ClientRepository _repository = ClientRepository();

  Client? _client;
  bool _isLoading = false;
  String? _error;

  Client? get client => _client;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasClient => _client != null;

  Future<void> loadClient(String projectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _client = await _repository.getClientByProjectId(projectId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createClient({
    required String projectId,
    required String name,
    String phone = '',
    String email = '',
    String comment = '',
  }) async {
    final now = DateTime.now();

    final client = Client(
      id: '',
      projectId: projectId,
      name: name.trim(),
      phone: phone.trim(),
      email: email.trim(),
      comment: comment.trim(),
      createdAt: now,
      updatedAt: now,
    );

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _client = await _repository.createClient(client);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateClient({
    required String name,
    String phone = '',
    String email = '',
    String comment = '',
  }) async {
    if (_client == null) return;

    final updatedClient = _client!.copyWith(
      name: name.trim(),
      phone: phone.trim(),
      email: email.trim(),
      comment: comment.trim(),
      updatedAt: DateTime.now(),
    );

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateClient(updatedClient);
      _client = updatedClient;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteClient() async {
    if (_client == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteClient(_client!.id);
      _client = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
