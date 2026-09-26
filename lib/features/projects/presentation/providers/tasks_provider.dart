import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/repositories/project_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/models/project.dart';
import '../../domain/models/task.dart';

class TasksProvider extends ChangeNotifier {
  final TaskRepository repository = TaskRepository();
  final ProjectRepository projectRepository = ProjectRepository();

  StreamSubscription<List<Task>>? _subscription;

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  String _filter = 'all';

  List<Task> get tasks {
    Iterable<Task> result = _tasks;

    switch (_filter) {
      case 'active':
        result = result.where((task) => task.status == TaskStatus.active);
        break;
      case 'inProgress':
        result = result.where((task) => task.status == TaskStatus.inProgress);
        break;
      case 'completed':
        result = result.where((task) => task.status == TaskStatus.completed);
        break;
    }

    return List.unmodifiable(result);
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filter => _filter;

  void setFilter(String value) {
    _filter = value;
    notifyListeners();
  }

  void listenToProjectTasks(String projectId) {
    _subscription?.cancel();

    _isLoading = true;
    _error = null;
    notifyListeners();

    _subscription = repository
        .getProjectTasks(projectId)
        .listen(
          (tasks) {
            _tasks = _removeDuplicateTasks(tasks);
            _isLoading = false;
            _error = null;
            notifyListeners();
            _syncProjectProgress(projectId);
          },
          onError: (error) {
            _isLoading = false;
            _error = error.toString();
            notifyListeners();
          },
        );
  }

  Future<void> stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
    _tasks = [];
    _isLoading = false;
    _error = null;
    _filter = 'all';
    notifyListeners();
  }

  void updateTasks(List<Task> tasks, String projectId) {
    _tasks = _removeDuplicateTasks(tasks);
    notifyListeners();
    _syncProjectProgress(projectId);
  }

  Future<Task> createTask(Task task) async {
    _error = null;
    try {
      // Firestore stream is the single source of truth.
      // Do not insert the task into _tasks manually.
      final createdTask = await repository.createTask(task);
      await _syncProjectProgress(task.projectId);
      return createdTask;
    } catch (error) {
      _error = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    _error = null;
    try {
      await repository.updateTask(task);
      // The Firestore stream updates _tasks.
      await _syncProjectProgress(task.projectId);
    } catch (error) {
      _error = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId, String projectId) async {
    _error = null;
    try {
      await repository.deleteTask(taskId);
      // The Firestore stream removes the task from _tasks.
      await _syncProjectProgress(projectId);
    } catch (error) {
      _error = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTaskStatus(Task task, TaskStatus status) async {
    _error = null;
    try {
      final completedAt = status == TaskStatus.completed
          ? DateTime.now()
          : null;

      await repository.updateTaskStatus(task.id, status, completedAt);

      // The Firestore stream provides the updated task.
      await _syncProjectProgress(task.projectId);
    } catch (error) {
      _error = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  List<Task> _removeDuplicateTasks(List<Task> tasks) {
    final unique = <String, Task>{};
    for (final task in tasks) {
      unique[task.id] = task;
    }
    return unique.values.toList();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _syncProjectProgress(String projectId) async {
    try {
      if (_tasks.isEmpty) {
        await projectRepository.updateProjectProgress(projectId, 0.0);
        return;
      }

      final completedCount = _tasks
          .where((task) => task.status == TaskStatus.completed)
          .length;
      final progress = completedCount / _tasks.length;

      await projectRepository.updateProjectProgress(projectId, progress);

      if (completedCount == _tasks.length) {
        await projectRepository.updateProjectStatus(
          projectId,
          ProjectStatus.completed,
        );
      }
    } catch (error) {
      debugPrint('Ошибка синхронизации прогресса проекта: $error');
    }
  }
}
