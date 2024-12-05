import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:laboratorios/screens/reportes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laboratorios/Servicios/User/interfazUsuario.dart';
import 'package:laboratorios/Servicios/Sales/GestionVentas.dart';
import 'login.dart';
import 'dart:io'; // Import necesario para manejo local.

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

  // Aquí puedes cargar datos locales antes de ejecutar la aplicación.
  await loadLocalData();

  runApp(const MyApp());
}

// Función para cargar datos locales (logo y título).
Future<void> loadLocalData() async {
  try {
    final directory = Directory.systemTemp; // Cambia a tu path deseado.
    final titleFile = File('${directory.path}/title.txt');
    final logoFile = File('${directory.path}/logo.png');

    if (await titleFile.exists()) {
      String title = await titleFile.readAsString();
      print('Título cargado: $title');
    } else {
      print('No se encontró un título guardado.');
    }

    if (await logoFile.exists()) {
      print('Logo cargado correctamente.');
    } else {
      print('No se encontró un logo guardado.');
    }
  } catch (e) {
    print('Error al cargar datos locales: $e');
  }
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
      //print('Conexion a Firebase exitosa');
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
