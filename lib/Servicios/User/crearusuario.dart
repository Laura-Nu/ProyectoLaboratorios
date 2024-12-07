import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CrearUsuarioPage extends StatefulWidget {
  const CrearUsuarioPage({Key? key}) : super(key: key);

  @override
  _CrearUsuarioPageState createState() => _CrearUsuarioPageState();
}

class _CrearUsuarioPageState extends State<CrearUsuarioPage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _mesesController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> crearUsuario() async {
    try {
      String nombre = _nombreController.text.trim();
      String apellido = _apellidoController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String username = _usernameController.text.trim();
      int mesesAsignados = int.parse(_mesesController.text.trim());

      if (nombre.isEmpty || apellido.isEmpty || email.isEmpty || password.isEmpty || username.isEmpty) {
        throw Exception("Todos los campos son obligatorios.");
      }

      // Calcular fechas de suscripción
      DateTime fechaInicio = DateTime.now();
      DateTime fechaFin = fechaInicio.add(Duration(days: mesesAsignados * 30 + 1));

      // Registrar usuario en Firestore
      DocumentReference userDoc = await _firestore.collection('usuarios').add({
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'password': password, // Nota: Considera encriptar esta contraseña en producción
        'username': username,
        'rol': 'dueño',
        'fechainiciosubscripcion': fechaInicio,
        'fechafinsubscripcion': fechaFin,
        'notificar': false,
      });

      // Crear documento de suscripción
      await _firestore.collection('suscripciones').add({
        'userId': userDoc.id, // Relacionamos la suscripción con el usuario
        'fechaInicio': fechaInicio,
        'fechaFin': fechaFin,
        'estado': 'activa', // La suscripción está activa al crearla
        'tipoSuscripcion': 'mensual', // O el tipo de suscripción según lo que necesites
        'fechaRenovacion': fechaFin.add(Duration(days: 30)), // Se puede cambiar según el tipo de suscripción
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario y suscripción creados exitosamente.')),
      );
      limpiarCampos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear usuario: $e')),
      );
    }
  }

  void limpiarCampos() {
    _nombreController.clear();
    _apellidoController.clear();
    _emailController.clear();
    _passwordController.clear();
    _usernameController.clear();
    _mesesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Dueño')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
             
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _mesesController,
                decoration: const InputDecoration(labelText: 'Meses asignados'),
                keyboardType: TextInputType.number,
              ),
               TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: crearUsuario,
                child: const Text('Crear Dueño'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
