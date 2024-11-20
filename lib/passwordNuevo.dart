import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart'; 

class PasswordNuevoPage extends StatefulWidget {
  final String email;
  final String username;

  const PasswordNuevoPage({
    Key? key,
    required this.email,
    required this.username,
  }) : super(key: key);

  @override
  _PasswordNuevoPageState createState() => _PasswordNuevoPageState();
}

class _PasswordNuevoPageState extends State<PasswordNuevoPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  // update el firesstore
  Future<void> _updatePassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showErrorDialog('Ingresa ambas contraseñas');
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorDialog('Las contraseñas no coinciden.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // serchuser
      var userDoc = await FirebaseFirestore.instance
          .collection('superadmin')
          .where('Email', isEqualTo: widget.email)
          .where('Nombre', isEqualTo: widget.username)
          .get();

      if (userDoc.docs.isNotEmpty) {
        //ssi  encuentra aluser update
        await FirebaseFirestore.instance
            .collection('superadmin')
            .doc(userDoc.docs.first.id) // id  del doc  encontrado
            .update({'Contraseña': newPassword});

        
        _showSuccessDialog('Contraseña actualizada correctamente');
      } else {
        _showErrorDialog('Error Usuario NO encontrado.');
      }
    } catch (e) {
      _showErrorDialog('Error al actualizar la contraseña');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ERROR'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('EXITO'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()), 
              );
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Establecer Nueva Contraseña'),
        backgroundColor: const Color(0xFF1a237e),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a237e),
              Color(0xFF3949ab),
            ],
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Establece tu nueva contraseña',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nueva Contraseña',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar Contraseña',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updatePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1a237e),
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Actualizar Contraseña'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}