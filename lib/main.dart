import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LIA - LAB',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginPage(),
    );
  }
}


class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  static Future<bool> testConnection() async {
    try {
      await _firestore.collection('usuarios').limit(1).get();
      print('Conexion a Firebase exitosa');
      return true;
    } catch (e) {
      print('Error en la conexion a Firebase: $e');
      return false;
    }
  }

  
  static CollectionReference get usuarios {
    return _firestore.collection('usuarios');
  }
}