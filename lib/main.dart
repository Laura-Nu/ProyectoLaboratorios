import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laboratorios/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Firebase 
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyDv8ob1atV7_hYOBglo2zTT_2xNcXSOJNA",
        authDomain: "bddlabo.firebaseapp.com",
        projectId: "bddlabo",
        storageBucket: "bddlabo.appspot.com",
        messagingSenderId: "209852280768",
        appId: "1:209852280768:web:3ed4ff50de18c2abe52225",
        measurementId: "G-RPLFXBQ278"),
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
      home: LoginPage(), //mainPage
    );
  }
}

class MyHomePage extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> agregarUsuario() async {
    try {
      await firestore.collection('usuarios').add({
        'nombre': 'Juan',
        'rol': 'vendedor',
        'fechaRegistro': Timestamp.now(), // Agrega la fecha de registro
      });
      print('Usuario agregado con éxito');
    } catch (e) {
      print('Error al agregar usuario: $e');
    }
  }

  Future<void> leerUsuarios() async {
    try {
      QuerySnapshot snapshot = await firestore.collection('usuarios').get();
      snapshot.docs.forEach((doc) {
        print('Usuario: ${doc['nombre']} - Rol: ${doc['rol']}');
      });
    } catch (e) {
      print('Error al leer usuarios: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase en Flutter Web'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: agregarUsuario,
              child: Text('Agregar Usuario'),
            ),
            ElevatedButton(
              onPressed: leerUsuarios,
              child: Text('Leer Usuarios'),
            ),
          ],
        ),
      ),
    );
  }
}
