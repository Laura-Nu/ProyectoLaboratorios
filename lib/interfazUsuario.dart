import 'package:flutter/material.dart';
import 'package:laboratorios/UsuarioUpdate.dart';

void main() {
  runApp(interfazUsuario());
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
        drawer: Drawer(
          child: Container(
            color: Color(0xFF5B7FCE), 
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'NAVEGADOR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        leading: Icon(Icons.home, color: Colors.black, size: 30),
                        title: Text(
                          'HOME',
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: Icon(Icons.person, color: Colors.black, size: 30),
                        title: Text(
                          'PERFIL',
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: Icon(Icons.check_box, color: Colors.black, size: 30),
                        title: Text(
                          'SERVICIOS',
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: Icon(Icons.shopping_cart, color: Colors.black, size: 30),
                        title: Text(
                          'COMPRAS',
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: Icon(Icons.report, color: Colors.black, size: 30),
                        title: Text(
                          'REPORTES',
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: Icon(Icons.login, color: Colors.black, size: 30),
                        title: Text(
                          'Log Up',
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
                                children: [
                                  _buildRadioOption('MASCULINO', true),
                                  SizedBox(width: 20), 
                                  _buildRadioOption('FEMENINO', false),
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
