import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';
import 'recoverPassword.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

 Future<bool> _loginAsSuperAdmin() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    try {
      // Consulta en la colección 'superadmin' con el nombre de usuario y la contraseña
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('superadmin')
          .where('Nombre', isEqualTo: _usernameController.text)
          .where('Contraseña', isEqualTo: _passwordController.text)
          .get();

      if (result.docs.isEmpty) {
        return false; // No encontró superadmin
      }

      // Obtiene el primer documento de la consulta
      final userDoc = result.docs.first;
      final String userId = userDoc.id; // ID del documento, usado como userId

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(userId: userId), // Pasa el userId a HomePage
        ),
      );

      return true; // Autenticación de superadmin exitosa
    } catch (e) {
      print('Error de login: $e');
      _showErrorSnackBar('Usuario o contraseña incorrectos');
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  return false;
}

Future<void> _login() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    // Verifica si es superadmin, si es así, detiene la función
    if (await _loginAsSuperAdmin()) {
      return;
    }

    try {
      // Si no es superadmin, continúa con la autenticación de "dueño"
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('nombreUsuario', isEqualTo: _usernameController.text)
          .where('password', isEqualTo: _passwordController.text)
          .get();

      if (result.docs.isEmpty) {
        throw Exception('Credenciales inválidas');
      }

      final userDoc = result.docs.first;
      final String userId = userDoc.id;

      // Buscar la suscripción usando el userId
      final QuerySnapshot subscriptionResult = await FirebaseFirestore.instance
          .collection('suscripciones')
          .where('userId', isEqualTo: userId)
          .get();

      if (subscriptionResult.docs.isEmpty) {
        throw Exception('Membresía no encontrada');
      }

        final subscriptionDoc = subscriptionResult.docs.first;
        Timestamp fechaInicio = subscriptionDoc['fechaInicio'];
        Timestamp fechaFin = subscriptionDoc['fechaFin'];
        DateTime ahora = DateTime.now();

      // Verificar si la membresía ha caducado
      if (ahora.isBefore(fechaInicio.toDate()) || ahora.isAfter(fechaFin.toDate())) {
        _showMembershipExpiredDialog();
        return;
      }

      // Verificar que el rol sea "dueño"
      if (userDoc['rol'] == 'dueño') {
        _navigateToHome(userId);
      } else {
        _showErrorSnackBar('Acceso denegado: Solo dueños pueden iniciar sesión');
      }
    } catch (e) {
      _showErrorSnackBar('Usuario o contraseña incorrectos');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}


  void _navigateToHome(String userId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(userId: userId),
      ),
    );
  }

  void _showMembershipExpiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text('MEMBRESÍA CADUCADA'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Image.asset(
                              'assets/images/logoMicro.png',
                              width: 60,
                              height: 60,
                            ),
                          ),
                          const SizedBox(height: 40),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nombre de Usuario:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 300,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextFormField(
                                  controller: _usernameController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    hintText: 'NOMBRE DE USUARIO',
                                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                                    counterText: "",
                                  ),
                                  maxLength: 5,
                                  validator: (value) {
                                    final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
                                    if (value == null || value.isEmpty) {
                                      return 'Ingrese su nombre de usuario';
                                    } else if (!validCharacters.hasMatch(value)) {
                                      return 'Caracteres Especiales NO Permitidos';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Contraseña:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 300,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    hintText: 'CONTRASEÑA',
                                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingrese su contraseña';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          SizedBox(
                            width: 200,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF1a237e),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text(
                                      'INICIAR SESIÓN',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RecoverPasswordPage()),
                              );
                            },
                            child: Text(
                              '¿Olvidaste tu Contraseña?',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/lab_background.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}