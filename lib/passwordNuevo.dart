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
      var userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('email', isEqualTo: widget.email)
          .where('username', isEqualTo: widget.username)
          .get();

      if (userDoc.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userDoc.docs.first.id)
            .update({'password': newPassword});

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
        title: const Text('ÉXITO'),
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
    
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Establecer Nueva Contraseña'),
        backgroundColor: const Color.fromARGB(255, 245, 245, 247),
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
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenWidth * 0.6, 
                minHeight: screenHeight * 0.6, 
              ),
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(height: 20),
                      Icon(
                        Icons.lock_reset,
                        size: 64,
                        color: Color(0xFF1a237e),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Establece tu nueva contraseña',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1a237e),
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Nueva Contraseña',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirmar Contraseña',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updatePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1a237e),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Actualizar Contraseña',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
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