import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<TaskModel>> _tasksByDay = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final snapshot = await FirebaseFirestore.instance.collection('tasks').get();
    final tasks = snapshot.docs.map((doc) =>
        TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

    final Map<DateTime, List<TaskModel>> taskMap = {};
    for (var task in tasks) {
      final day = DateTime(task.createdAt.year, task.createdAt.month, task.createdAt.day);
      taskMap.putIfAbsent(day, () => []).add(task);
    }

    setState(() {
      _tasksByDay = taskMap;
    });
  }

  List<TaskModel> _getTasksForDay(DateTime day) {
    return _tasksByDay[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Calendar')),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2022),
            lastDay: DateTime.utc(2050),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() => _focusedDay = focusedDay);
            },
            eventLoader: _getTasksForDay,
          ),
          const SizedBox(height: 12),
          ..._getTasksForDay(_focusedDay).map((task) => ListTile(
                title: Text(task.title),
                subtitle: Text("Status: ${task.status}"),
              )),
        ],
      ),
    );
  }
}
