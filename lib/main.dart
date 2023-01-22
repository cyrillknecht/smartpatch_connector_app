/// Run flutter app.
import 'package:flutter/material.dart';
import 'pages/pages_export.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartPatch Connector',
      theme: ThemeData(primarySwatch: Colors.lightBlue),
      debugShowCheckedModeBanner:false,
      home: const HomePage(title: 'SmartPatch Connector'),
    );
  }
}
