import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MySQL Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List pacientes = [];

  @override
  void initState() {
    super.initState();
    fetchPacientes();
  }

  Future<void> fetchPacientes() async {
    final response = await http.get(Uri.parse('http://localhost:3000/pacientes'));
    if (response.statusCode == 200) {
      setState(() {
        pacientes = json.decode(response.body);
      });
    } else {
      throw Exception('Error al cargar pacientes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
      ),
      body: ListView.builder(
        itemCount: pacientes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(pacientes[index]['nombre']),
            subtitle: Text(pacientes[index]['apellido']),
          );
        },
      ),
    );
  }
}
