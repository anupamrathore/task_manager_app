import 'package:flutter/material.dart';
import 'package:task_manager_app/parse_stub.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';

class TaskListScreen extends StatefulWidget {
  final ParseUser currentUser;
  const TaskListScreen({super.key, required this.currentUser});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  bool _loading = false;
  List<ParseObject> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _loading = true);
    final ownerId = widget.currentUser.objectId ?? '';
    try {
      final tasks = await TaskService.fetchTasks(ownerId);
      setState(() => _tasks = tasks);
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    Navigator.pushReplacementNamed(context, '/');
  }

  Future<void> _deleteTask(String objectId) async {
    await TaskService.deleteTask(objectId);
    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final userId = widget.currentUser.objectId ?? 'unknown';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Tasks'),
        actions: [IconButton(onPressed: _logout, icon: const Icon(Icons.logout))],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTasks,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _tasks.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text('No tasks yet. Tap + to add one.')),
                    ],
                  )
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, i) {
                      final t = _tasks[i];
                      final title = t.get('title') ?? '';
                      final desc = t.get('description') ?? '';
                      final completed = t.get('completed') ?? false;
                      return ListTile(
                        title: Text(title),
                        subtitle: Text(desc.toString()),
                        leading: Checkbox(
                          value: completed,
                          onChanged: (v) async {
                            await TaskService.updateTask(
                              objectId: t.objectId!,
                              title: title,
                              description: desc,
                              completed: v ?? false,
                            );
                            await _loadTasks();
                          },
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async => await _deleteTask(t.objectId!),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await showDialog<bool>(
            context: context,
            builder: (context) => _CreateTaskDialog(ownerId: userId),
          );
          if (res == true) await _loadTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CreateTaskDialog extends StatefulWidget {
  final String ownerId;
  const _CreateTaskDialog({required this.ownerId});

  @override
  State<_CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<_CreateTaskDialog> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await TaskService.createTask(
        title: _title.text.trim(),
        description: _desc.text.trim(),
        ownerId: widget.ownerId,
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      // show error
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
          TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        ElevatedButton(onPressed: _loading ? null : _create, child: const Text('Create')),
      ],
    );
  }
}
