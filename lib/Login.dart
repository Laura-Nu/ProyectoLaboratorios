import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< Updated upstream
import 'home.dart';
import 'package:laboratorios/Widgets/menu.dart';
=======
import 'Home.dart';
import 'package:laboratorios/widgets/menu.dart';
>>>>>>> Stashed changes
import 'recoverPassword.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String userRol = '';
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

<<<<<<< Updated upstream
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
=======
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
      final String rol = userDoc['rol'];

       setState(() {
          this.userRol = rol;  // Guardas el rol en una variable local
         });



  

      Navigator.pushReplacement(
        
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(userId: userId, userRole: rol), // Pasa el userId a HomePage
        ),
      );

      return true; // Autenticación de superadmin exitosa
    } catch (e) {
      print('Error de login: $e');
      _showErrorSnackBar('Usuario o contraseña incorrectos');
      return false;
    } finally {
>>>>>>> Stashed changes
      setState(() {
        _isLoading = true;
      });

<<<<<<< Updated upstream
      try {
        // Consultacion del firestore
        final QuerySnapshot result = await FirebaseFirestore.instance
            .collection('superadmin')
            .where('Nombre', isEqualTo: _usernameController.text)
            .where('Contraseña', isEqualTo: _passwordController.text)
            .get();

        if (result.docs.isEmpty) {
          throw Exception('Usuario o contraseña incorrectos');
        }

        // Verificar las fechas
        final userDoc = result.docs.first;
        Timestamp fechaInicio = userDoc['FechaInicio'];
        Timestamp fechaFin = userDoc['FechaFin'];
        DateTime ahora = DateTime.now();

        // Para depuración
        print('Usuario encontrado: ${userDoc['Nombre']}');
        print('Fecha inicio: ${fechaInicio.toDate()}');
        print('Fecha fin: ${fechaFin.toDate()}');
        print('Fecha actual: $ahora');

        if (ahora.isBefore(fechaInicio.toDate()) || ahora.isAfter(fechaFin.toDate())) {
          _showMembershipExpiredDialog();
          return;
        }

        
        _navigateToHome();
        
      } catch (e) {
        print('Error de login: $e'); 
        _showErrorSnackBar('Error al iniciar sesion. Verifique sus credenciales');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
=======
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    try {
      // Validar en la colección "superadmin"
      final QuerySnapshot superadminResult = await FirebaseFirestore.instance
          .collection('superadmin')
          .where('Nombre', isEqualTo: _usernameController.text)
          .where('Contraseña', isEqualTo: _passwordController.text)
          .get();

      if (superadminResult.docs.isNotEmpty) {
        // Usuario encontrado en superadmin
        final userDoc = superadminResult.docs.first;
        String rol = userDoc['rol'];

        // Para depurar
        print('Usuario encontrado: ${userDoc['Nombre']}');
        _navigateToHome(userDoc.id, rol);
        return;
      }

      // Validar en la colección "usuarios"
      final QuerySnapshot usuariosResult = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('username', isEqualTo: _usernameController.text)
          .where('password', isEqualTo: _passwordController.text)
          .get();

      if (usuariosResult.docs.isNotEmpty) {
        // Usuario encontrado en usuarios
        final userDoc = usuariosResult.docs.first;
        String rol = userDoc['rol']; // Obtener el rol del usuario
        
        Timestamp fechaFinSuscripcion = userDoc['fechafinsubscripcion'];
        bool notificar = userDoc['notificar'];
        bool estadoSuscripcion = userDoc['estadosubscripcion'];
        DateTime ahora = DateTime.now();

        // Validar si la membresía ha expirado
        if (ahora.isAfter(fechaFinSuscripcion.toDate())) {
          throw Exception('Su suscripción ha expirado. Por favor, renueve su membresía.');
        }

        // Validar si la membresía está próxima a expirar (5 días antes)
        DateTime cincoDiasAntes = fechaFinSuscripcion.toDate().subtract(Duration(days: 5));
        if (ahora.isAfter(cincoDiasAntes) && ahora.isBefore(fechaFinSuscripcion.toDate())) {
          // Activar notificación
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(userDoc.id)
              .update({'notificar': true});

          // Mostrar notificación al usuario
          _showWarningSnackBar('Su membresía está próxima a expirar. Por favor, renueve antes de ${fechaFinSuscripcion.toDate()}');
        }

        // Validar estado de suscripción
        if (!estadoSuscripcion) {
          throw Exception('Su suscripción no está activa. Contacte con soporte.');
        }

        print('Usuario encontrado: ${userDoc['nombre']} ${userDoc['apellido']}');
         if (rol == 'dueño') {
          _navigateToHome(userDoc.id, rol); 
          

        }
        
        return;
      }

      // Si no se encuentra en ninguna colección
      throw Exception('Usuario o contraseña incorrectos');
    } catch (e) {
      print('Error de login: $e');
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
>>>>>>> Stashed changes
      }
      
    }
  }

<<<<<<< Updated upstream
  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
=======
   void _showWarningSnackBar(String message, {bool isExpirado = false}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(color: Colors.white, fontSize: 16),
    ),
    backgroundColor: isExpirado ? Colors.red : Colors.amber, // Rojo para expirado, amarillo para aviso
    duration: Duration(seconds: 5), // Tiempo de duración en pantalla
    behavior: SnackBarBehavior.floating, // Flotante para mejor visualización
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), // Bordes redondeados
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
 }

  void _navigateToHome(String userId, String rol) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(userId: userId, userRole:rol)
      ),
>>>>>>> Stashed changes
    );
  }

  void _showMembershipExpiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text('MEMBRESIA CADUCADA'),
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