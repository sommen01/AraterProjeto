import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ifms_form/login_page.dart';
import 'package:scoped_model/scoped_model.dart';

import 'formulario.dart';
import 'listagem_page.dart';
import 'user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScopedModel<UserModel>(
      model: UserModel(),
      child: ScopedModelDescendant<UserModel>(builder: (context, child, model) {
        return MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (context) => LoginPage(),
            '/form': (context) => Formulario(),
            '/list': (context) => Listagem(),
          },
          title: "",
          theme: ThemeData(
            primaryColor: Colors.green,
            accentColor: Colors.green,
          ),
          debugShowCheckedModeBanner: false,
        );
      }),
    );
  }
}
