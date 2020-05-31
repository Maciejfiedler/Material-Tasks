// Flutter Packages
import 'package:Tasks/utils/database/database.dart';
import 'package:Tasks/utils/model/task.dart';
import 'package:flutter/material.dart';

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
              setState(() {
                onlyDeleteCompleted = value;
              });
            }),
      ),
      actions: <Widget>[
        // Cancel Action
        FlatButton(
          child: Text(
            "Cancel",
            style: TextStyle(
              color: Theme.of(context).cursorColor,
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

  @override
  void initState() {
    super.initState();
  }
}
