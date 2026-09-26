import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/repositories/project_change_repository.dart';
import '../../domain/models/project_change.dart';

class ProjectChangeProvider extends ChangeNotifier {
  final ProjectChangeRepository _repo = ProjectChangeRepository();

  List<ProjectChange> _items = [];
  StreamSubscription<List<ProjectChange>>? _sub;

  bool loading = false;
  String? error;

  List<ProjectChange> get items => List.unmodifiable(_items);

  double get approvedTotal => _items
      .where((item) => item.status == ProjectChangeStatus.approved)
      .fold(0, (sum, item) => sum + item.amount);

  void listen(String projectId) {
    _sub?.cancel();

    loading = true;
    error = null;
    notifyListeners();

    _sub = _repo.stream(projectId).listen(
      (items) {
        _items = items;
        loading = false;
        error = null;
        notifyListeners();
      },
      onError: (Object exception) {
        error = exception.toString();
        loading = false;
        notifyListeners();
      },
    );
  }

  Future<void> stopListening() async {
    await _sub?.cancel();
    _sub = null;
    _items = [];
    loading = false;
    error = null;
    notifyListeners();
  }

  Future<void> save(ProjectChange change) async {
    try {
      error = null;
      await _repo.save(change);
    } catch (exception) {
      error = exception.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> delete(String id) => _repo.delete(id);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
