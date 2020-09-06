// Flutter Packages
import 'package:Tasks/utils/database/database.dart';
import 'package:Tasks/utils/model/task.dart';
import 'package:flutter/material.dart';

// Page
import 'package:Tasks/pages/home_screen.dart';

// Dart Packages
import 'dart:math';

class UpdateScreen extends StatefulWidget {
  // Task
  final Task item;

  // Tasks
  final List<Task> tasks;

  // Database
  final TaskDatabase database;

  // TitleController
  final TextEditingController changeTitleController;

  // Scaffold Key
  final GlobalKey<ScaffoldState> scaffoldKey;

  const UpdateScreen(Key key, this.item, this.tasks, this.database,
      this.changeTitleController, this.scaffoldKey)
      : super(key: key);
  @override
  _UpdateScreenState createState() => _UpdateScreenState(
      item, tasks, database, changeTitleController, scaffoldKey);
}



class _UpdateScreenState extends State<UpdateScreen> {
  // Task
  final Task item;

  // Tasks
  final List<Task> tasks;

  // Database
  final TaskDatabase database;

  // TitleController
  final TextEditingController changeTitleController;

  // Scaffold Key
  final GlobalKey<ScaffoldState> scaffoldKey;

  Color save_cancel_color(){
    if(MediaQuery.of(context).platformBrightness == Brightness.light){
      return Colors.black;
    } else{
      return Colors.white;
    }
  }

  _UpdateScreenState(this.item, this.tasks, this.database,
      this.changeTitleController, this.scaffoldKey);
  @override
  Widget build(BuildContext context) {
    // Dialog
    return AlertDialog(
      title: Row(
        children: <Widget>[
          // Change Item title
          Flexible(
            flex: 5,
            child: item.complete
                ? TextField(
                    controller: changeTitleController,
                    enabled: false,
                    style: TextStyle(decoration: TextDecoration.lineThrough),
                  )
                : TextField(
                    controller: changeTitleController,
                    textCapitalization: TextCapitalization.sentences,
                  ),
          ),
          Spacer(),
          // Change Item completed
          Checkbox(
              activeColor:
                  MediaQuery.of(context).platformBrightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
              checkColor:
                  MediaQuery.of(context).platformBrightness == Brightness.light
                      ? Colors.white
                      : Colors.black,
              value: item.complete,
              onChanged: (value) {
                setState(() {
                  item.complete = value;
                });
              }),
        ],
      ),
      actions: <Widget>[
        // Delete Action
        FlatButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.redAccent),
          ),
          splashColor: Colors.grey.withOpacity(0.5),
          onPressed: () {
            // To show Snackbar
            setState(() {
              deletedItem = item;
              itemDeleted = true;
            });
            changeTitleController.clear();
            removeTask(item);
            Navigator.pop(context);
          },
        ),
        SizedBox(
          width: 48,
        ),
        // Cancel Action
        FlatButton(
          child: Text(
            "Cancel",
            style: TextStyle(
              color: save_cancel_color()
            ),
          ),
          splashColor: Colors.grey.withOpacity(0.5),
          onPressed: () {
            changeTitleController.clear();
            Navigator.pop(context);
          },
        ),
        // Save Action
        FlatButton(
          child: Text(
            "Save",
            style: TextStyle(
              color:save_cancel_color(),
            ),
          ),
          splashColor: Colors.grey.withOpacity(0.5),
          onPressed: () {
            setState(() {
              item.title = "${changeTitleController.text}";
            });
            changeTask(
                Task(id: item.id, title: item.title, complete: item.complete));

            changeTitleController.clear();
            Navigator.pop(context);
          },
        )
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

  // Add Task
  void addTask(String title) {
    database.addTask(Task(
        id: Random.secure().nextInt(9999999),
        title: "$title",
        complete: false));
    getTasks();
  }

  // Remove Task
  void removeTask(Task item) {
    database.removeTask(item.id);
    getTasks();
  }

  // Change Task
  void changeTask(Task item) {
    tasks.remove(item);

    database.updateTask(
        Task(id: item.id, title: "${item.title}", complete: item.complete));
    getTasks();
  }

  @override
  void initState() {
    changeTitleController.text = "${item.title}";
    super.initState();
  }

  @override
  void dispose() {
    changeTitleController.dispose();
    super.dispose();
  }
}
