// lib/services/task_service.dart
// NOTE: while developing we import the local stub. When you switch back to Back4App,
// change this import to: import 'package:task_manager_app/parse_stub.dart';
import 'package:task_manager_app/parse_stub.dart';


class TaskService {
  static const String className = 'Task';

  /// Create a task. description may be empty.
  static Future<ParseObject> createTask({
    required String title,
    String? description,
    required String ownerId,
  }) async {
    final task = ParseObject(className)
      ..set('title', title)
      ..set('description', description ?? '')
      ..set('owner', ownerId)
      ..set('completed', false)
      ..set('createdAt', DateTime.now().toIso8601String());

    final ParseResponse response = await task.save();
    if (response.success && response.result != null) {
      return response.result as ParseObject;
    } else {
      throw Exception(response.error?.message ?? 'Create task failed');
    }
  }

  /// Fetch tasks for a given owner (returns empty list on failure).
  static Future<List<ParseObject>> fetchTasks(String ownerId) async {
    final query = QueryBuilder<ParseObject>(ParseObject(className))
      .whereEqualTo('owner', ownerId)
      .orderByDescending('createdAt');

    final ParseResponse response = await query.query();
    if (response.success && response.results != null) {
      return List<ParseObject>.from(response.results!);
    } else {
      return <ParseObject>[];
    }
  }

  /// Update a task by objectId. Only fields provided are updated.
  static Future<ParseObject> updateTask({
    required String objectId,
    String? title,
    String? description,
    bool? completed,
  }) async {
    final task = ParseObject(className)..objectId = objectId;
    if (title != null) task.set('title', title);
    if (description != null) task.set('description', description);
    if (completed != null) task.set('completed', completed);
    task.set('updatedAt', DateTime.now().toIso8601String());

    final ParseResponse response = await task.save();
    if (response.success && response.result != null) {
      return response.result as ParseObject;
    } else {
      throw Exception(response.error?.message ?? 'Update failed');
    }
  }

  /// Delete a task by its objectId.
  static Future<void> deleteTask(String objectId) async {
    final task = ParseObject(className)..objectId = objectId;
    final ParseResponse response = await task.delete();
    if (!response.success) {
      throw Exception(response.error?.message ?? 'Delete failed');
    }
  }

  /// Convert ParseObject to plain map for UI use
  static Map<String, dynamic> toMap(ParseObject obj) {
    return {
      'objectId': obj.objectId,
      'title': obj.get('title') ?? '',
      'description': obj.get('description') ?? '',
      'completed': obj.get('completed') ?? false,
      'owner': obj.get('owner') ?? '',
      'createdAt': obj.get('createdAt') ?? '',
      'updatedAt': obj.get('updatedAt') ?? '',
    };
  }
}
