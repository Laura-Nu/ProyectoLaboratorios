import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laboratorios/Widgets/menu.dart';

class UpdatePatient extends StatefulWidget {
  final String patientId; // ID del paciente a actualizar

  UpdatePatient({
    required this.patientId,
    required Map<String, dynamic> patientData,
    Key? key,
  }) : super(key: key) {
    _nombreController.text = patientData['nombre'] ?? '';
    _apellidoPaternoController.text = patientData['apellido_paterno'] ?? '';
    _numeroController.text = patientData['numero'] ?? '';
    _correoController.text = patientData['email'] ?? '';
    _direccionController.text = patientData['direccion'] ?? '';
    _fechaNacimiento =
        patientData['fecha_nacimiento']?.toDate() ?? DateTime.now();
  }

  static final TextEditingController _nombreController =
      TextEditingController();
  static final TextEditingController _apellidoPaternoController =
      TextEditingController();
  static final TextEditingController _direccionController =
      TextEditingController();
  static final TextEditingController _numeroController =
      TextEditingController();
  static final TextEditingController _correoController =
      TextEditingController();

  static DateTime _fechaNacimiento = DateTime.now();

  @override
  _UpdatePatientState createState() => _UpdatePatientState();
}

class _UpdatePatientState extends State<UpdatePatient> {
  @override
  void dispose() {
    UpdatePatient._nombreController.dispose();
    UpdatePatient._apellidoPaternoController.dispose();
    UpdatePatient._direccionController.dispose();
    UpdatePatient._numeroController.dispose();
    UpdatePatient._correoController.dispose();
    super.dispose();
  }

  // Función para actualizar el paciente en Firebase
  Future<void> _updatePatient() async {
    if (_validateInputs()) {
      try {
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(widget.patientId)
            .update({
          'nombre': UpdatePatient._nombreController.text,
          'apellido_paterno': UpdatePatient._apellidoPaternoController.text,
          'direccion': UpdatePatient._direccionController.text,
          'numero': UpdatePatient._numeroController.text,
          'correo': UpdatePatient._correoController.text,
          'fecha_nacimiento': UpdatePatient._fechaNacimiento,
          'timestamp': FieldValue.serverTimestamp(),
        });
        Navigator.pop(context); // Regresar a la pantalla anterior
      } catch (e) {
        print('Error al actualizar paciente: $e');
      }
    }
  }

  bool _validateInputs() {
    // Validar que todos los campos estén llenos
    if (UpdatePatient._nombreController.text.isEmpty ||
        UpdatePatient._apellidoPaternoController.text.isEmpty ||
        UpdatePatient._direccionController.text.isEmpty ||
        UpdatePatient._numeroController.text.isEmpty ||
        UpdatePatient._correoController.text.isEmpty) {
      _showDialog('Por favor, completa todos los campos.');
      return false;
    }

    // Validar que el número solo contenga dígitos
    if (!RegExp(r'^[0-9]+$').hasMatch(UpdatePatient._numeroController.text)) {
      _showDialog('El número de teléfono solo puede contener dígitos.');
      return false;
    }

    // Validar que el correo electrónico contenga un arroba
    if (!UpdatePatient._correoController.text.contains('@')) {
      _showDialog('El correo electrónico debe contener un arroba (@).');
      return false;
    }

    return true;
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actualizar Paciente'),
      ),
      drawer: const Menu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _updatePatient,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Actualizar Paciente'),
            ),
            SizedBox(height: 20),
            _buildTextField('Nombre', UpdatePatient._nombreController),
            SizedBox(height: 20),
            _buildTextField(
                'Apellido Paterno', UpdatePatient._apellidoPaternoController),
            SizedBox(height: 20),
            _buildTextField('Dirección', UpdatePatient._direccionController),
            SizedBox(height: 20),
            _buildTextField('Número', UpdatePatient._numeroController,
                keyboardType: TextInputType.phone),
            SizedBox(height: 20),
            _buildTextField('Email', UpdatePatient._correoController),
            SizedBox(height: 20),
            _buildDateField(context),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Método para construir un campo de texto
  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  // Método para construir el campo de fecha de nacimiento
  Widget _buildDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha de Nacimiento',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: UpdatePatient._fechaNacimiento,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (selectedDate != null &&
                selectedDate != UpdatePatient._fechaNacimiento) {
              setState(() {
                UpdatePatient._fechaNacimiento = selectedDate;
              });
            }
          },
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${UpdatePatient._fechaNacimiento.toLocal()}'.split(' ')[0],
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
