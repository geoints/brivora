import 'package:flutter/foundation.dart';

import '../../data/repositories/client_repository.dart';
import '../../domain/models/client.dart';

class ClientProvider extends ChangeNotifier {
  final ClientRepository _repository = ClientRepository();

  final Map<String, Client?> _clientsByProject = <String, Client?>{};
  String? _projectId;
  int _loadRequest = 0;
  bool _isLoading = false;
  String? _error;

  Client? get client => _projectId == null ? null : _clientsByProject[_projectId];
  Client? clientForProject(String projectId) => _clientsByProject[projectId];
  String? get projectId => _projectId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasClient => client != null;

  Future<void> loadClient(String projectId) async {
    // This provider is shared by all project screens, so never keep the
    // previous project's client while the new project is loading.
    final requestId = ++_loadRequest;
    _projectId = projectId;
    _clientsByProject[projectId] = null;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loadedClient = await _repository.getClientByProjectId(projectId);

      // Ignore a late response from a project that is no longer visible.
      if (requestId != _loadRequest || _projectId != projectId) return;

      _clientsByProject[projectId] = loadedClient;
    } catch (e) {
      if (requestId != _loadRequest || _projectId != projectId) return;

      _clientsByProject[projectId] = null;
      _error = e.toString();
    } finally {
      if (requestId == _loadRequest && _projectId == projectId) {
        _isLoading = false;
        notifyListeners();
      }
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
    _projectId = projectId;
    notifyListeners();

    try {
      _clientsByProject[projectId] = await _repository.createClient(client);
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
    final current = _client;
    if (current == null) {
      _error = 'Клиент не загружен';
      notifyListeners();
      return;
    }

    final updatedClient = current.copyWith(
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
      _clientsByProject[updatedClient.projectId] = updatedClient;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteClient() async {
    final current = _client;
    if (current == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteClient(current.id);
      _clientsByProject[current.projectId] = null;
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
