import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:laboratorios/Servicios/User/interfazUsuario.dart';

class UsuarioUpdate extends StatefulWidget {
<<<<<<< Updated upstream
=======
  final String userId;
  final String userRole;

  const UsuarioUpdate({Key? key, required this.userId, required this.userRole}) : super(key: key);

>>>>>>> Stashed changes
  @override
  _UsuarioUpdateState createState() => _UsuarioUpdateState();
}

class _UsuarioUpdateState extends State<UsuarioUpdate> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(); 

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String _selectedGender = 'MASCULINO'; 

  DateTime? _selectedDate;

<<<<<<< Updated upstream
  final _formKey = GlobalKey<FormState>(); 
=======
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
      var userData = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _nombreController.text = userData['nombre'] ?? '';
        _nombreUsuarioController.text = userData['nombreUsuario'] ?? '';
        _apellidoController.text = userData['apellido'] ?? '';
        _carnetController.text = userData['carnet'] ?? '';
        _fechaNacimientoController.text = userData['fechaNacimiento'] ?? '';
        _direccionController.text = userData['direccion'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _passwordController.text = userData['password'] ?? '';
        _telefonoController.text = userData['telefono'] ?? '';
        if (userData['genero'] != null && (userData['genero'] == 'MASCULINO' || userData['genero'] == 'FEMENINO')) {
          _selectedGender = userData['genero'];
        }

        if (userData['fechaNacimiento'] != null) {
          _selectedDate = DateFormat('dd/MM/yyyy').parse(userData['fechaNacimiento']);
        }
      });
    }
  } catch (e) {
    print('Error al cargar datos del usuario: $e');
  }
}

  Future<void> updateUserData() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(widget.userId)
            .update({
          'nombre': _nombreController.text,
          'nombreUsuario': _nombreUsuarioController.text,
          'apellido': _apellidoController.text,
          'carnet': _carnetController.text,
          'fechaNacimiento': _fechaNacimientoController.text,
          'direccion': _direccionController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'telefono': _telefonoController.text,
          'genero': _selectedGender,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InterfazUsuario(userId: widget.userId, userRole: widget.userRole),
          ),
        );
      } catch (e) {
        print('Error al actualizar datos del usuario: $e');
      }
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@(gmail|hotmail|outlook|yahoo)\.com$');
    
    // Verifica que el email coincida con el patrón y que no contenga espacios.
    if (!emailRegex.hasMatch(email) || email.contains(' ')) {
      return false;
    }

    return true;
  }



  bool _isValidPassword(String password) {  
    final passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = _selectedDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _fechaNacimientoController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }
>>>>>>> Stashed changes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ACTUALIZAR DATOS',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: Color(0xFF5B7FCE), 
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 130.0),
                  child: Form(
                    key: _formKey, 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildTextField('NOMBRE DE USUARIO:'),
                        _buildTextField('NOMBRE:'),
                        _buildTextField('APELLIDOS:'),
                        _buildTextField('CARNET DE IDENTIFICACIÓN:'),
                        _buildDateField('FECHA DE NACIMIENTO:'), 
                        _buildTextField('DIRECCIÓN:'),
                        _buildTextField('CORREO ELECTRÓNICO:'),
                        _buildPasswordField('CONTRASEÑA:'), 
                        _buildConfirmPasswordField('CONFIRMAR CONTRASEÑA:'),
                        _buildTextField('TELÉFONO:'),
                        _buildGenderSelection(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildFooterButtons(),
        ],
      ),
    );
  }

  Widget _buildDateField(String label) {
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
            child: TextFormField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Seleccione la fecha de nacimiento',
                border: InputBorder.none,
              ),
              onTap: () => _selectDate(context),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor seleccione una fecha';
                } else if (_selectedDate == null || _selectedDate!.isAtSameMomentAs(DateTime.now())) {
                  return 'La fecha no puede ser la actual';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today.subtract(Duration(days: 1)), 
      firstDate: DateTime(1900),
      lastDate: today.subtract(Duration(days: 1)), 
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked); 
      });
    }
  }

  Widget _buildTextField(String label) {
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
            child: TextFormField(
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                border: InputBorder.none,
              ),
            ),
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
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la contraseña';
                      } else if (!_isValidPassword(value)) {
                        return 'Debe tener 1 especial, 1 minúscula, 1 mayúscula, 1 número, mínimo 8 caracteres.';
                      }
                      return null;
                    },
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

  Widget _buildConfirmPasswordField(String label) {
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
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor confirme la contraseña';
                      } else if (value != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
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

  bool _isValidPassword(String password) {
    final passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  Widget _buildGenderSelection() {
    return Padding(
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
              _buildRadioOption('MASCULINO'),
              SizedBox(width: 20),
              _buildRadioOption('FEMENINO'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: label,
          groupValue: _selectedGender,
          activeColor: Color(0xFF5B7FCE),
          onChanged: (String? value) {
            setState(() {
              _selectedGender = value!;
            });
          },
        ),
        Text(label, style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildFooterButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0, right: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF5B7FCE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'CANCELAR',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          SizedBox(width: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF5B7FCE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _showConfirmationDialog(context);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'CONFIRMAR',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                'ACTUALIZAR DATOS',
                style: TextStyle(
                  color: Color(0xFF54595E),
                ),
              ),
            ],
          ),
          content: Text(
            '¿ESTÁS SEGURO DE ACTUALIZAR ESTOS DATOS?',
            style: TextStyle(
              color: Color(0xFF54595E),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5B7FCE),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => interfazUsuario(),
                  ),
                );
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}
