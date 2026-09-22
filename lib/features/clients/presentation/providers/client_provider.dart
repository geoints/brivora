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

  Client? get client =>
      _projectId == null ? null : _clientsByProject[_projectId];

  Client? clientForProject(String projectId) => _clientsByProject[projectId];

  String? get projectId => _projectId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasClient => client != null;

  Future<void> loadClient(String projectId) async {
    final requestId = ++_loadRequest;
    _projectId = projectId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loadedClient = await _repository.getClientByProjectId(projectId);

      if (requestId != _loadRequest || _projectId != projectId) {
        return;
      }

      _clientsByProject[projectId] = loadedClient;
    } catch (e) {
      if (requestId != _loadRequest || _projectId != projectId) {
        return;
      }

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
    final newClient = Client(
      id: '',
      projectId: projectId,
      name: name.trim(),
      phone: phone.trim(),
      email: email.trim(),
      comment: comment.trim(),
      createdAt: now,
      updatedAt: now,
    );

    _projectId = projectId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final createdClient = await _repository.createClient(newClient);
      _clientsByProject[projectId] = createdClient;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateClient({
    required String projectId,
    required String name,
    String phone = '',
    String email = '',
    String comment = '',
  }) async {
    final current = _clientsByProject[projectId];

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

    _projectId = projectId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateClient(updatedClient);
      _clientsByProject[projectId] = updatedClient;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteClient(String projectId) async {
    final current = _clientsByProject[projectId];
    if (current == null) return;

    _projectId = projectId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteClient(current.id);
      _clientsByProject[projectId] = null;
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
