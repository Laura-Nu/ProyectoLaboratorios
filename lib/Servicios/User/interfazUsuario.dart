import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'UsuarioUpdate.dart';
import 'package:laboratorios/Widgets/menu.dart';

class InterfazUsuario extends StatefulWidget {
  final String userId;

  const InterfazUsuario({Key? key, required this.userId}) : super(key: key);

  @override
  _InterfazUsuarioState createState() => _InterfazUsuarioState();
}

class _InterfazUsuarioState extends State<InterfazUsuario> {
  bool _isPasswordVisible = false;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>;
        });
      } else {
        print('Usuario no encontrado');
      }
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DATOS PERSONALES',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: const Color(0xFF5B7FCE),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      drawer: Menu(userId: widget.userId), // Pasar userId al menú
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 130.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildLabelWithBorder('NOMBRE:', userData!['nombre'] ?? ''),
                            _buildLabelWithBorder('NOMBRE DE USUARIO:', userData!['username'] ?? ''),
                            _buildLabelWithBorder('APELLIDOS:', userData!['apellido'] ?? ''),
                            _buildLabelWithBorder('CARNET DE IDENTIFICACIÓN:', userData!['carnet'] ?? ''),
                            _buildLabelWithBorder('FECHA DE NACIMIENTO:', userData!['fechaNacimiento'] ?? ''),
                            _buildLabelWithBorder('DIRECCIÓN:', userData!['direccion'] ?? ''),
                            _buildLabelWithBorder('CORREO ELECTRÓNICO:', userData!['email'] ?? ''),
                            _buildPasswordField('CONTRASEÑA:', userData!['password'] ?? ''),
                            _buildLabelWithBorder('TELÉFONO:', userData!['telefono'] ?? ''),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 200,
                                    child: const Text(
                                      'GÉNERO:',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      _buildRadioOption('MASCULINO', userData!['genero'] == 'MASCULINO'),
                                      const SizedBox(width: 20),
                                      _buildRadioOption('FEMENINO', userData!['genero'] == 'FEMENINO'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0, right: 40.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B7FCE),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UsuarioUpdate(userId: widget.userId),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Text(
                          'ACTUALIZAR DATOS',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLabelWithBorder(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 200,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            width: 1000,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 200,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            width: 1000,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _isPasswordVisible ? value : '************',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String label, bool selected) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio(
          value: selected,
          groupValue: true,
          activeColor: const Color(0xFF5B7FCE),
          onChanged: (bool? value) {},
        ),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}