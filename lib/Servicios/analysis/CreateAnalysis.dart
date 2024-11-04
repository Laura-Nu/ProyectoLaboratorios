import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laboratorios/Widgets/menu.dart';

class CreateAnalysis extends StatefulWidget {
  @override
  _CreateAnalysisState createState() => _CreateAnalysisState();
}

class _CreateAnalysisState extends State<CreateAnalysis> {
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController rangoController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> _addAnalisis(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        DocumentReference docRef =
            await FirebaseFirestore.instance.collection('analisis').add({
          'codigo': codigoController.text,
          'descripcion': descripcionController.text,
          'estado': estadoController.text,
          'nombre': nombreController.text,
          'precio': int.parse(precioController.text),
          'rango': int.parse(rangoController.text),
          'timestamp': FieldValue.serverTimestamp(),
        });

        final newAnalisis = {
          'id': docRef.id,
          'codigo': codigoController.text,
          'descripcion': descripcionController.text,
          'estado': estadoController.text,
          'nombre': nombreController.text,
          'precio': int.parse(precioController.text),
          'rango': int.parse(rangoController.text),
        };

        Navigator.pop(context, newAnalisis);
      } catch (e) {
        print('Error al agregar análisis: $e');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al agregar análisis')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Nuevo Análisis'),
      ),
      drawer: const Menu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField('Código', codigoController),
              buildTextField('Descripción', descripcionController),
              buildTextField('Estado', estadoController),
              buildTextField('Nombre', nombreController),
              buildNumberField('Precio', precioController),
              buildNumberField('Rango', rangoController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _addAnalisis(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Agregar Análisis'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(border: OutlineInputBorder()),
            validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
          ),
        ],
      ),
    );
  }

  Widget buildNumberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(border: OutlineInputBorder()),
            validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
          ),
        ],
      ),
    );
  }
}
