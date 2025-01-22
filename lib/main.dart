import 'package:flutter/material.dart';
import 'package:webcrawler/ui/home_page.dart';
import 'package:webcrawler/apis/msg_database.dart' as db;

void main() async {
  // Initialize Database
  await db.initDb();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.green[700], // Set default AppBar color
        ),
      ),
      home: HomePage(),
    );
  }
}