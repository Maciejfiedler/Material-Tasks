// Flutter Packages
import 'package:flutter/material.dart';

// Page
import 'pages/home_screen.dart';

void main() {
  runApp(Start());
}

class Start extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        accentColor: Colors.white,
        cursorColor: Colors.black,
        textSelectionHandleColor: Colors.black,
        inputDecorationTheme: InputDecorationTheme(
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black))),
      ),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          accentColor: Colors.black,
          cursorColor: Colors.white,
          textSelectionHandleColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)))),
      home: HomeScreen(),
    );
  }
}
