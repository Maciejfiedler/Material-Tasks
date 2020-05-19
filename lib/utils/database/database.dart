import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:Tasks/utils/model/task.dart';

class TaskDatabase {
  static final TaskDatabase _instance = TaskDatabase._();
  static Database _database;

  TaskDatabase._();

  factory TaskDatabase() {
    return _instance;
  }

  Future<Database> get db async {
    if (_database != null) {
      return _database;
    }

    _database = await initialize();

    return _database;
  }

  Future<Database> initialize() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String dbPath = join(directory.path, 'tasks.db');
    var database = openDatabase(dbPath,
        version: 1, onCreate: onCreate, onUpgrade: onUpgrade);

    return database;
  }

  void onCreate(Database db, int version) {
    db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        complete INTEGER)
    ''');
  }

  void onUpgrade(Database db, int oldVersion, int newVersion) {}

  Future<int> addTask(Task task) async {
    var client = await db;
    return client.insert('tasks', task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Task> getTask(int id) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps =
        client.query('tasks', where: 'id = ?', whereArgs: [id]);
    var maps = await futureMaps;

    if (maps.length != 0) {
      return Task.fromMap(maps.first);
    }

    return null;
  }

  Future<List<Task>> getAll() async {
    var client = await db;
    var res = await client.query('tasks');

    if (res.isNotEmpty) {
      List<Task> task = res.map((taskMap) => Task.fromMap(taskMap)).toList();
      return task;
    }
    return [];
  }

  Future<int> updateTask(Task newTask) async {
    var client = await db;
    return client.update('tasks', newTask.toMap(),
        where: 'id = ?',
        whereArgs: [newTask.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeTask(int id) async {
    var client = await db;
    return client.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> removeAll() async {
    var client = await db;
    return client.delete('tasks');
  }

  Future dispose() async {
    var client = await db;
    client.close();
  }
}
