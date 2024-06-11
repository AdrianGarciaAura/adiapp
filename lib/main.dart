import 'package:adiapp/screen/login.dart';
import 'package:flutter/material.dart';

//arranque de la aplicacion
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const _title = 'A.D.I';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _title,
      home:  const LoginScreen(),
    );
  }
}
