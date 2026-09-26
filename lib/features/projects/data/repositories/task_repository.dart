import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/task.dart';

class TaskStats {
  final int total;
  final int completed;
  final int inProgress;

  const TaskStats({
    required this.total,
    required this.completed,
    required this.inProgress,
  });

  static const empty = TaskStats(total: 0, completed: 0, inProgress: 0);
}

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tasksCollection =>
      _firestore.collection('tasks');

  Future<Task> createTask(Task task) async {
    final doc = _tasksCollection.doc();
    final newTask = task.copyWith(id: doc.id, createdAt: DateTime.now());

    await doc.set(newTask.toFirestore());
    return newTask;
  }

  Future<void> updateTask(Task task) async {
    await _tasksCollection.doc(task.id).set(task.toFirestore());
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  Stream<List<Task>> getProjectTasks(String projectId) {
    return _tasksCollection
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs
              .map((doc) => Task.fromFirestore(doc))
              .toList();
          tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return tasks;
        });
  }

  Future<TaskStats> getTaskStatsForProjects(Iterable<String> projectIds) async {
    final ids = projectIds.where((id) => id.isNotEmpty).toSet().toList();
    if (ids.isEmpty) return TaskStats.empty;

    final snapshots = await Future.wait(
      ids.map(
        (projectId) =>
            _tasksCollection.where('projectId', isEqualTo: projectId).get(),
      ),
    );

    int total = 0;
    int completed = 0;

    for (final snapshot in snapshots) {
      for (final doc in snapshot.docs) {
        total++;
        final status = doc.data()['status'];
        if (status == TaskStatus.completed.name) {
          completed++;
        }
      }
    }

    return TaskStats(
      total: total,
      completed: completed,
      inProgress: total - completed,
    );
  }

  Future<List<Task>> getTasksForProjects(Iterable<String> projectIds) async {
    final ids = projectIds.where((id) => id.isNotEmpty).toSet().toList();
    if (ids.isEmpty) return [];

    final snapshots = await Future.wait(
      ids.map(
        (projectId) =>
            _tasksCollection.where('projectId', isEqualTo: projectId).get(),
      ),
    );

    final tasks = <Task>[];

    for (final snapshot in snapshots) {
      tasks.addAll(
        snapshot.docs.map((doc) => Task.fromFirestore(doc)),
      );
    }

    tasks.sort((a, b) {
      final aDeadline = a.deadline;
      final bDeadline = b.deadline;

      if (aDeadline == null && bDeadline == null) {
        return b.createdAt.compareTo(a.createdAt);
      }
      if (aDeadline == null) return 1;
      if (bDeadline == null) return -1;

      return aDeadline.compareTo(bDeadline);
    });

    return tasks;
  }

  Future<void> updateTaskStatus(
    String taskId,
    TaskStatus status,
    DateTime? completedAt,
  ) async {
    await _tasksCollection.doc(taskId).update({
      'status': status.name,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt)
          : null,
      'updatedAt': Timestamp.now(),
    });
  }
}
