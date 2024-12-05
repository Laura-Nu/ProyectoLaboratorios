import 'package:flutter/material.dart';
import 'package:laboratorios/Servicios/User/UsuarioUpdate.dart';
import 'package:laboratorios/Widgets/menu.dart';

<<<<<<< Updated upstream
void main() {
  runApp(interfazUsuario());
=======
class InterfazUsuario extends StatefulWidget {
  final String userId;
  final String userRole;

  const InterfazUsuario({Key? key, required this.userId, required this.userRole}) : super(key: key);

  @override
  _InterfazUsuarioState createState() => _InterfazUsuarioState();
>>>>>>> Stashed changes
}

class interfazUsuario extends StatefulWidget {
  @override
  _interfazUsuarioState createState() => _interfazUsuarioState();
}

class _interfazUsuarioState extends State<interfazUsuario> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'DATOS PERSONALES',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          backgroundColor: Color(0xFF5B7FCE), 
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
        ),
<<<<<<< Updated upstream
        drawer: const Menu(),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Center( 
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 130.0), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center, 
                      children: [
                        _buildLabelWithBorder('NOMBRE DE USUARIO:'),
                        _buildLabelWithBorder('NOMBRE:'),
                        _buildLabelWithBorder('APELLIDOS:'),
                        _buildLabelWithBorder('CARNET DE IDENTIFICACIÓN:'),
                        _buildLabelWithBorder('FECHA DE NACIMIENTO:'),
                        _buildLabelWithBorder('DIRECCIÓN:'),
                        _buildLabelWithBorder('CORREO ELECTRÓNICO:'),
                        _buildPasswordField('CONTRASEÑA:'), 
                        _buildLabelWithBorder('TELÉFONO:'),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0), 
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 200, 
                                child: Text(
                                  'GÉNERO:',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Row(
=======
        backgroundColor: const Color(0xFF5B7FCE),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      drawer: Menu(userId: widget.userId,userRol: widget.userRole), // Pasar userId al menú
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
                            _buildLabelWithBorder('NOMBRE DE USUARIO:', userData!['nombreUsuario'] ?? ''),
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
>>>>>>> Stashed changes
                                children: [
                                  _buildRadioOption('MASCULINO', true),
                                  SizedBox(width: 20), 
                                  _buildRadioOption('FEMENINO', false),
                                ],
                              ),
<<<<<<< Updated upstream
                            ],
=======
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
                            builder: (context) => UsuarioUpdate(userId: widget.userId, userRole: widget.userRole),
>>>>>>> Stashed changes
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
                    backgroundColor: Color(0xFF5B7FCE), 
                    foregroundColor: Colors.white,     
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), 
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UsuarioUpdate(),
                  ),
                );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
      ),
    );
  }

  Widget _buildLabelWithBorder(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 200, 
            child: Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            width: 1000, 
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2), 
              borderRadius: BorderRadius.circular(15), 
            ),
            child: Text(''), 
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 200, 
            child: Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            width: 1000, 
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2), 
              borderRadius: BorderRadius.circular(15), 
            ),
            child: Row(
              children: [
                // Mostrar u ocultar la contraseña
                Expanded(
                  child: Text(
                    _isPasswordVisible ? 'miContraseñaEjemplo' : '************', 
                    style: TextStyle(fontSize: 16),
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
          activeColor: Color(0xFF5B7FCE), // Color igual al del navbar
          onChanged: (bool? value) {},
        ),
        Text(label, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
