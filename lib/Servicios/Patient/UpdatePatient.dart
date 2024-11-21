import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:laboratorios/Widgets/menu.dart';

class UpdatePatient extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> patientData;

  UpdatePatient({required this.patientId, required this.patientData});

  @override
  _UpdatePatientState createState() => _UpdatePatientState();
}

class _UpdatePatientState extends State<UpdatePatient> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _apellidoMaternoController;
  late TextEditingController _direccionController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;
  DateTime? _fechaNacimiento;

  @override
  void initState() {
    super.initState();
    _nombreController =
        TextEditingController(text: widget.patientData['nombre']);
    _apellidoController =
        TextEditingController(text: widget.patientData['apellido']);
    _apellidoMaternoController =
        TextEditingController(text: widget.patientData['apellidoMaterno']);
    _direccionController =
        TextEditingController(text: widget.patientData['direccion']);
    _telefonoController =
        TextEditingController(text: widget.patientData['telefono']);
    _emailController = TextEditingController(text: widget.patientData['email']);

    // Convertir Timestamp a DateTime si es necesario
    if (widget.patientData['fechaNacimiento'] is Timestamp) {
      _fechaNacimiento =
          (widget.patientData['fechaNacimiento'] as Timestamp).toDate();
    } else if (widget.patientData['fechaNacimiento'] is DateTime) {
      _fechaNacimiento = widget.patientData['fechaNacimiento'];
    }
  }

  Future<void> _updatePatient() async {
    if (_formKey.currentState!.validate()) {
      final updatedPatientData = {
        'id': widget.patientId,
        'nombre': _nombreController.text,
        'apellido': _apellidoController.text,
        'apellidoMaterno': _apellidoMaternoController.text,
        'direccion': _direccionController.text,
        'telefono': _telefonoController.text,
        'email': _emailController.text,
        'fechaNacimiento': _fechaNacimiento,
      };

      await FirebaseFirestore.instance
          .collection('pacientes')
          .doc(widget.patientId)
          .update(updatedPatientData);

      // Devuelve los datos actualizados
      Navigator.pop(context, updatedPatientData);
    }
  }

  Future<void> _selectFechaNacimiento(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fechaNacimiento) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ACTUALIZAR PACIENTE'),
      ),
      drawer: const Menu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _updatePatient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Actualizar Paciente'),
                  ),
                ],
              ),
              Text(
                'NOMBRES',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 20),
              Text(
                'APELLIDO PATERNO',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _apellidoController,
                decoration: InputDecoration(border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 20),
              Text(
                'APELLIDO MATERNO',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _apellidoMaternoController,
                decoration: InputDecoration(border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 20),
              Text(
                'DIRECCION',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _direccionController,
                decoration: InputDecoration(border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 20),
              Text(
                'FECHA DE NACIMIENTO',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                readOnly: true,
                onTap: () => _selectFechaNacimiento(context),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: _fechaNacimiento == null
                      ? 'Selecciona una fecha'
                      : '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}',
                ),
                validator: (value) =>
                    _fechaNacimiento == null ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 20),
              Text(
                'TELEFONO',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _telefonoController,
                decoration: InputDecoration(border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) =>
                    value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 20),
              Text(
                'EMAIL',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(border: OutlineInputBorder()),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Campo obligatorio';
                  } else if (!value.contains('@')) {
                    return 'Correo inválido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
