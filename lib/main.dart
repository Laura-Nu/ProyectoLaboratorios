import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:laboratorios/screens/reportes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDv8ob1atV7_hYOBglo2zTT_2xNcXSOJNA",
      authDomain: "bddlabo.firebaseapp.com",
      projectId: "bddlabo",
      storageBucket: "bddlabo.appspot.com",
      messagingSenderId: "209852280768",
      appId: "1:209852280768:web:3ed4ff50de18c2abe52225",
      measurementId: "G-RPLFXBQ278",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laboratorio Firebase Web',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReportPage(), // Cambia MyHomePage por PruebaInsert
    );
  }
}
