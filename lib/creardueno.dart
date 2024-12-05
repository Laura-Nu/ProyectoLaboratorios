import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroDueno extends StatefulWidget {
  @override
  _RegistroDuenoState createState() => _RegistroDuenoState();
}

class _RegistroDuenoState extends State<RegistroDueno> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores de texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmarPasswordController = TextEditingController();
  
  // Controlador para meses de membresía
  int _mesesMembresia = 6; // Valor por defecto

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Método para registrar dueño
  Future<void> _registrarDueno() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Calcular fechas de membresía
        DateTime fechaInicio = DateTime.now();
        DateTime fechaFin = fechaInicio.add(Duration(days: _mesesMembresia * 30));

        // Crear usuario en Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(), 
              password: _passwordController.text.trim()
            );

        // Guardar datos en Firestore
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userCredential.user!.uid)
            .set({
          'nombre': _nombreController.text.trim(),
          'apellido': _apellidoController.text.trim(),
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'fechainiciosubscripcion': Timestamp.fromDate(fechaInicio),
          'fechafinsubscripcion': Timestamp.fromDate(fechaFin),
          'mesesMembresia': _mesesMembresia,
          'rol': 'dueño',
          'password': _passwordController.text.trim(),
          'notificar':false,
          'estadosubscripcion': true,
        });

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registro exitoso'), backgroundColor: Colors.green)
        );

        // Navegar o realizar acción posterior al registro
        Navigator.pop(context);

      } on FirebaseAuthException catch (e) {
        // Manejo de errores de autenticación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e.code)), 
            backgroundColor: Colors.red
          )
        );
      } catch (e) {
        // Manejo de otros errores
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'), 
            backgroundColor: Colors.red
          )
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  // Método para obtener mensajes de error
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'La contraseña es demasiado débil';
      case 'email-already-in-use':
        return 'El correo electrónico ya está registrado';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      default:
        return 'Error de registro';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Dueño'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campos de texto
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Ingrese su nombre' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _apellidoController,
                decoration: InputDecoration(
                  labelText: 'Apellido',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Ingrese su apellido' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Ingrese un username' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => 
                  value!.isEmpty || !value.contains('@') 
                    ? 'Ingrese un email válido' 
                    : null,
              ),
              SizedBox(height: 16),
              
              // Selector de meses de membresía
              DropdownButtonFormField<int>(
                value: _mesesMembresia,
                decoration: InputDecoration(
                  labelText: 'Meses de Membresía',
                  border: OutlineInputBorder(),
                ),
                items: [3, 6, 12].map((meses) {
                  return DropdownMenuItem(
                    value: meses,
                    child: Text('$meses meses'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _mesesMembresia = value!;
                  });
                },
              ),
              SizedBox(height: 16),

              // Campos de contraseña
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword 
                      ? Icons.visibility 
                      : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) => 
                  value!.length < 6 
                    ? 'Mínimo 6 caracteres' 
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _confirmarPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: _obscurePassword,
                validator: (value) => 
                  value != _passwordController.text 
                    ? 'Las contraseñas no coinciden' 
                    : null,
              ),
              SizedBox(height: 24),

              // Botón de registro
              _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _registrarDueno,
                    child: Text('Registrar'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}