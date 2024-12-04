import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laboratorios/Widgets/menu.dart';

class CreatePatient extends StatefulWidget {

  final String userId;

  const CreatePatient({Key? key, required this.userId}) : super(key: key);

  @override
  _CreatePatientState createState() => _CreatePatientState();
}

class _CreatePatientState extends State<CreatePatient> {
  // Controladores para capturar los datos de los campos
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoPaternoController =
      TextEditingController();
  final TextEditingController apellidoMaternoController =
      TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  DateTime? fechaNacimiento;

  final _formKey = GlobalKey<FormState>();

  // Función para agregar paciente a Firebase
  Future<void> _addPatient(BuildContext context) async {
    if (_formKey.currentState!.validate() && fechaNacimiento != null) {
      try {
        // Agregar paciente a Firestore
        DocumentReference docRef =
            await FirebaseFirestore.instance.collection('pacientes').add({
          'nombre': nombreController.text,
          'apellido': apellidoPaternoController.text,
          'apellidoMaterno': apellidoMaternoController.text,
          'direccion': direccionController.text,
          'telefono': telefonoController.text,
          'email': correoController.text,
          'fechaNacimiento': fechaNacimiento,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Retornar los datos del paciente
        final newPatient = {
          'id': docRef.id,
          'nombre': nombreController.text,
          'apellido': apellidoPaternoController.text,
          'apellidoMaterno': apellidoMaternoController.text,
          'direccion': direccionController.text,
          'telefono': telefonoController.text,
          'email': correoController.text,
          'fechaNacimiento': fechaNacimiento,
        };

        Navigator.pop(context,
            newPatient); // Pasar los datos del nuevo paciente de vuelta a la pantalla anterior
      } catch (e) {
        print('Error al agregar paciente: $e');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al agregar paciente')));
      }
    } else if (fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, llene todos los campos')));
    }
  }

  // Función para seleccionar la fecha de nacimiento
  Future<void> _selectFechaNacimiento(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != fechaNacimiento) {
      setState(() {
        fechaNacimiento = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AGREGAR NUEVO PACIENTE'),
      ),
      drawer: Menu(userId: widget.userId),
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
                    onPressed: () async {
                      await _addPatient(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Agregar Paciente'),
                  ),
                ],
              ),
              Text(
                'NOMBRES',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: nombreController,
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
                controller: apellidoPaternoController,
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
                controller: apellidoMaternoController,
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
                controller: direccionController,
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
                  hintText: fechaNacimiento == null
                      ? 'Selecciona una fecha'
                      : '${fechaNacimiento!.day}/${fechaNacimiento!.month}/${fechaNacimiento!.year}',
                ),
                validator: (value) =>
                    fechaNacimiento == null ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 20),
              Text(
                'TELEFONO',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: telefonoController,
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
                controller: correoController,
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