import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class UpdateAnalysis extends StatefulWidget {
  final String analisisId;
  final Map<String, dynamic> analisisData;

  UpdateAnalysis({required this.analisisId, required this.analisisData});

  @override
  _UpdateAnalysisState createState() => _UpdateAnalysisState();
}

class _UpdateAnalysisState extends State<UpdateAnalysis> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController codigoController;
  late TextEditingController descripcionController;
  late TextEditingController estadoController;
  late TextEditingController nombreController;
  late TextEditingController precioController;
  late TextEditingController rangoController;

  @override
  void initState() {
    super.initState();
    codigoController =
        TextEditingController(text: widget.analisisData['codigo']);
    descripcionController =
        TextEditingController(text: widget.analisisData['descripcion']);
    estadoController =
        TextEditingController(text: widget.analisisData['estado']);
    nombreController =
        TextEditingController(text: widget.analisisData['nombre']);
    precioController =
        TextEditingController(text: widget.analisisData['precio'].toString());
    rangoController =
        TextEditingController(text: widget.analisisData['rango'].toString());
  }

  Future<void> _updateAnalisis(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('analisis')
            .doc(widget.analisisId)
            .update({
          'codigo': codigoController.text,
          'descripcion': descripcionController.text,
          'estado': estadoController.text,
          'nombre': nombreController.text,
          'precio': int.parse(precioController.text),
          'rango': int.parse(rangoController.text),
        });

        Navigator.pop(context, true);
      } catch (e) {
        print('Error al actualizar análisis: $e');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar análisis')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Editar Análisis")),
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
                  await _updateAnalisis(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Actualizar Análisis'),
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
