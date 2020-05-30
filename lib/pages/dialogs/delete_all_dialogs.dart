// Flutter Packages
import 'package:Tasks/utils/database/database.dart';
import 'package:Tasks/utils/model/task.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Page
import 'package:Tasks/pages/home_screen.dart';

class DeleteAll extends StatefulWidget {
  // Tasks
  final List<Task> tasks;

  // Database
  final TaskDatabase database;

  const DeleteAll({Key key, this.tasks, this.database}) : super(key: key);
  @override
  _DeleteAllState createState() => _DeleteAllState(tasks, database);
}

class _DeleteAllState extends State<DeleteAll> {
  // Tasks
  final List<Task> tasks;

  // Database
  final TaskDatabase database;

  bool onlyDeleteCompleted = true;

  _DeleteAllState(this.tasks, this.database);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Delete All Tasks?"),
      content: ListTile(
        title: Text("Delete Only Completed"),
        // Delete only Completed
        trailing: Checkbox(
            value: onlyDeleteCompleted,
            activeColor:
                MediaQuery.of(context).platformBrightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
            checkColor:
                MediaQuery.of(context).platformBrightness == Brightness.light
                    ? Colors.white
                    : Colors.black,
            onChanged: (value) async {
              // Save in Local Storage
              SharedPreferences prefs = await SharedPreferences.getInstance();

              setState(() {
                prefs.setBool('deleteOnlyCompleted', value);
                onlyDeleteCompleted = prefs.getBool('deleteOnlyCompleted');
              });
            }),
      ),
      actions: <Widget>[
        // Cancel Action
        FlatButton(
          child: Text(
            "Cancel",
            style: TextStyle(
              color: Theme.of(context).textSelectionColor,
            ),
          ),
          splashColor: Colors.grey.withOpacity(0.5),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // Delete Action
        FlatButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.redAccent),
          ),
          splashColor: Colors.grey.withOpacity(0.5),
          onPressed: () {
            if (onlyDeleteCompleted) {
              for (Task item in tasks) {
                if (item.complete) {
                  removeTask(item);
                  // To show Snackbar

                }
                setState(() {
                  deletedTasks = tasks;
                  itemsDeleted = false;
                });
              }
            } else {
              for (Task item in tasks) {
                removeTask(item);
                // To show Snackbar
                setState(() {
                  deletedTasks = tasks;
                  itemsDeleted = true;
                });
              }
            }
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  // Get Tasks
  void getTasks() async {
    List<Task> databaseTasks = await database.getAll();
    setState(() {
      tasks.clear();
      tasks.addAll(databaseTasks);
    });
  }

  // Remove Task
  void removeTask(Task item) {
    database.removeTask(item.id);
    getTasks();
  }

  // initialize Shareds Preferences
  void initializeSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    onlyDeleteCompleted = await prefs.setBool('deleteOnlyCompleted',
        onlyDeleteCompleted == null ? true : onlyDeleteCompleted);
  }

  @override
  void initState() {
    initializeSharedPreferences();
    super.initState();
  }
}
