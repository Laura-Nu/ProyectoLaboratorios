
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:laboratorios/Servicios/User/interfazUsuario.dart';
import 'package:flutter/services.dart';

class UsuarioUpdate extends StatefulWidget {
  final String userId;

  const UsuarioUpdate({Key? key, required this.userId}) : super(key: key);

  @override
  _UsuarioUpdateState createState() => _UsuarioUpdateState();
}

class _UsuarioUpdateState extends State<UsuarioUpdate> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _nombreUsuarioController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _carnetController = TextEditingController();
  final TextEditingController _fechaNacimientoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _selectedGender;
  DateTime? _selectedDate;

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
            builder: (context) => InterfazUsuario(userId: widget.userId),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ACTUALIZAR DATOS',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: const Color(0xFF5B7FCE),
        iconTheme: const IconThemeData(color: Colors.white),
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
                        _buildTextField('NOMBRE:', _nombreController),
                        _buildTextField('NOMBRE DE USUARIO:', _nombreUsuarioController),
                        _buildTextField('APELLIDOS:', _apellidoController),
                        _buildIdCardField('CARNET DE IDENTIFICACIÓN:', _carnetController),
                        _buildDateField('FECHA DE NACIMIENTO:'),
                        _buildTextField('DIRECCIÓN:', _direccionController),
                        _buildEmailField('CORREO ELECTRÓNICO:', _emailController),
                        _buildPasswordField('CONTRASEÑA:', _passwordController),
                        _buildConfirmPasswordField('CONFIRMAR CONTRASEÑA:', _confirmPasswordController),
                        _buildPhoneField('TELÉFONO:', _telefonoController),
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

Widget _buildPhoneField(String label, TextEditingController controller) {
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
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              border: InputBorder.none,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el teléfono';
              }
              return null;
            },
          ),
        ),
      ],
    ),
  );
}


Widget _buildIdCardField(String label, TextEditingController controller) {
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
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              border: InputBorder.none,
            ),
            // Eliminada la validación del carnet de identificación
          ),
        ),
      ],
    ),
  );
}


  Widget _buildTextField(String label, TextEditingController controller) {
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
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                border: InputBorder.none,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor completa este campo';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

Widget _buildEmailField(String label, TextEditingController controller) {
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
          child: TextFormField(
            controller: controller,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              border: InputBorder.none,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor completa este campo';
              } else if (!_isValidEmail(value)) {
                return 'Ingrese un correo electrónico válido (ej. @gmail.com, @hotmail.com)';
              }
              return null;
            },
          ),
        ),
      ],
    ),
  );
}


  Widget _buildPasswordField(String label, TextEditingController controller) {
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
                  child: TextFormField(
                    controller: controller,
                    obscureText: !_isPasswordVisible,
                    decoration: const InputDecoration(
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

  Widget _buildConfirmPasswordField(String label, TextEditingController controller) {
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
                  child: TextFormField(
                    controller: controller,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
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
            child: TextFormField(
              controller: _fechaNacimientoController,
              readOnly: true,
              decoration: const InputDecoration(
                hintText: 'Seleccione la fecha de nacimiento',
                border: InputBorder.none,
              ),
              onTap: () => _selectDate(context),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildGenderSelection() {
  return Padding(
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
            _buildRadioOption('MASCULINO'),
            const SizedBox(width: 20),
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
        activeColor: const Color(0xFF5B7FCE),
        onChanged: (String? value) {
          setState(() {
            _selectedGender = value!;
          });
        },
      ),
      Text(label, style: const TextStyle(fontSize: 16)),
    ],
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
                updateUserData();
                Navigator.of(context).pop();
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
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
            backgroundColor: const Color(0xFF5B7FCE),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'CANCELAR',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5B7FCE),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _showConfirmationDialog(context);
            }
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
}
