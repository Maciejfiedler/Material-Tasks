// Flutter Packages

import 'package:Tasks/pages/dialogs/delete_all_dialogs.dart';
import 'package:Tasks/pages/dialogs/update_dialog.dart';
import 'package:Tasks/utils/model/task.dart';
import 'package:Tasks/utils/database/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Dart Packages
import 'dart:math';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// Delted Items
Task deletedItem;
bool itemDeleted = false;

List<Task> deletedTasks;
bool itemsDeleted = false;

class _HomeScreenState extends State<HomeScreen> {
  // Tasks
  final List<Task> tasks = List<Task>();

  // Database
  final TaskDatabase database = TaskDatabase();

  // Scaffold Key
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Text Editing Controllers
  final TextEditingController titleController = TextEditingController();

  // Notfication
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails notificationAppLaunchDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Tasks"),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          // Complete All Items

          IconButton(
              icon: Icon(Icons.done_all),
              onPressed: () {
                for (Task item in tasks) {
                  changeTask(
                      Task(id: item.id, title: item.title, complete: true));
                }
              }),

          IconButton(
              icon: Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => DeleteAll(
                    tasks: tasks,
                    database: database,
                  ),
                ).then((value) {
                  // Show Snackbar
                  if (itemsDeleted) {
                    final snackBar = SnackBar(
                      content: Text('Task Deleted'),
                      action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            for (Task item in deletedTasks) {
                              addTask(item.title);
                            }
                          }),
                    );
                    scaffoldKey.currentState.showSnackBar(snackBar);
                  }
                });
              })
        ],
      ),
      body: ListView.separated(
        itemCount: tasks.length,
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
        // Task
        itemBuilder: (BuildContext context, int index) {
          return item(tasks[index]);
        },
      ),
      // Add Task

      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            showTextField();
            showDailNotification();
          }),
    );
  }

  // Item
  Widget item(Task item) {
    return ListTile(
      title: item.complete
          ? Text(
              "${item.title}",
              style: TextStyle(
                decoration: TextDecoration.lineThrough,
              ),
            )
          : Text("${item.title}"),
      onTap: () {
        showTask(item);
      },
      trailing: Checkbox(
          activeColor: Theme.of(context).textSelectionColor,
          checkColor: Theme.of(context).accentColor,
          value: item.complete,
          onChanged: (value) {
            changeTask(Task(id: item.id, title: item.title, complete: value));
          }),
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
    database.updateTask(
        Task(id: item.id, title: "${item.title}", complete: item.complete));
    getTasks();
  }

  // Show TextField
  void showTextField() {
    showModalBottomSheet(
        context: context,
        builder: (context) => Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: titleController,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (value) {
                    addTask('${titleController.text}');
                    titleController.clear();
                  },
                  autofocus: true,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                          icon: Icon(
                            Icons.send,
                            color: Theme.of(context).textSelectionColor,
                          ),
                          onPressed: () {
                            addTask('${titleController.text}');
                            titleController.clear();
                          })),
                ),
              ),
            )).then((value) => titleController.clear());
  }

  // Show Task
  void showTask(Task item) async {
    // TitleController
    final TextEditingController changeTitleController =
        TextEditingController(text: "${item.title}");
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return UpdateScreen(Key("${item.id}"), item, tasks, database,
            changeTitleController, scaffoldKey);
      },
    ).then((value) {
      changeTask(item);
      // Show Snackbar
      if (itemDeleted) {
        final snackBar = SnackBar(
          content: Text('Task Deleted'),
          action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                addTask(deletedItem.title);
              }),
        );
        scaffoldKey.currentState.showSnackBar(snackBar);
      }
    });
  }

  void initiliazeNotifications() async {
    WidgetsFlutterBinding.ensureInitialized();
    notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> showDailNotification() async {
    var list = StringBuffer();
    tasks.forEach((element) {
      list.writeln(
          '${element.title}                                                                                                                                                                                              ');
    });

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'repeatDailyAtTime channel id',
        'repeatDailyAtTime channel name',
        'repeatDailyAtTime description');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    if (tasks.isNotEmpty) {
      await flutterLocalNotificationsPlugin.showDailyAtTime(
          0, 'Tasks', """$list""", Time(6, 0, 0), platformChannelSpecifics);
      await flutterLocalNotificationsPlugin.showDailyAtTime(
          0, 'Tasks', """$list""", Time(12, 0, 0), platformChannelSpecifics);
      await flutterLocalNotificationsPlugin.showDailyAtTime(
          0, 'Tasks', """$list""", Time(18, 0, 0), platformChannelSpecifics);
    }
  }

  @override
  void initState() {
    getTasks();
    initiliazeNotifications();
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}
