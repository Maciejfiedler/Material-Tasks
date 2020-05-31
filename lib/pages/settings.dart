import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text("About"),
            leading: Icon(Icons.info_outline),
            onTap: () {
              showAboutDialog(
                  context: context,
                  applicationName: "Material Tasks",
                  applicationVersion: "1.1.0",
                  applicationIcon: Image.asset(
                    "assets/logo.png",
                    width: 64,
                    height: 64,
                  ),
                  children: <Widget>[
                    Text(
                        "Material Tasks is a Flutter Project build by Maciej Fiedler. It was build for fun, because I really liked Tasks apps like Google Tasks or Ticktick.")
                  ]);
            },
          )
        ],
      ),
    );
  }
}
