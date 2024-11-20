import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:laboratorios/Widgets/menu.dart';

class UpdateAnalysis extends StatefulWidget {
  final String AnalysisId;
  final Map<String, dynamic> AnalysisData;

  UpdateAnalysis({required this.AnalysisId, required this.AnalysisData});

  @override
  _UpdateAnalysisState createState() => _UpdateAnalysisState();
}

class _UpdateAnalysisState extends State<UpdateAnalysis> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _rangoController;
  late TextEditingController _precioController;
  late TextEditingController _codigoController;

  String? _estadoSeleccionado; // Para manejar el estado seleccionado

  @override
  void initState() {
    super.initState();
    _nombreController =
        TextEditingController(text: widget.AnalysisData['nombre']);
    _descripcionController =
        TextEditingController(text: widget.AnalysisData['descripcion']);
    _rangoController =
        TextEditingController(text: widget.AnalysisData['rango'].toString());
    _precioController =
        TextEditingController(text: widget.AnalysisData['precio'].toString());
    _codigoController =
        TextEditingController(text: widget.AnalysisData['codigo']);
    _estadoSeleccionado =
        widget.AnalysisData['estado']; // Inicializa el estado actual
  }

  Future<void> _updateAnalisis() async {
    if (_formKey.currentState!.validate()) {
      final updatedAnalisisData = {
        'id': widget.AnalysisId,
        'nombre': _nombreController.text,
        'descripcion': _descripcionController.text,
        'rango': int.parse(_rangoController.text),
        'precio': int.parse(_precioController.text),
        'estado': _estadoSeleccionado,
        'codigo': _codigoController.text,
      };

      await FirebaseFirestore.instance
          .collection('analisis')
          .doc(widget.AnalysisId)
          .update(updatedAnalisisData);

      // Devuelve los datos actualizados
      Navigator.pop(context, updatedAnalisisData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ACTUALIZAR ANALISIS'),
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
                    onPressed: _updateAnalisis,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Actualizar Análisis'),
                  ),
                ],
              ),
              buildTextField('NOMBRE', _nombreController),
              buildTextField('DESCRIPCION', _descripcionController),
              buildDropdownField(), // Cambiar por combobox
              buildTextField('CODIGO', _codigoController),
              buildNumberField('PRECIO', _precioController),
              buildNumberField('RANGO', _rangoController),
              SizedBox(height: 20),
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
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
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
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
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

  Widget buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ESTADO',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _estadoSeleccionado,
            items: [
              DropdownMenuItem(value: 'Activo', child: Text('Activo')),
              DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
              DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
            ],
            onChanged: (value) {
              setState(() {
                _estadoSeleccionado = value;
              });
            },
            decoration: InputDecoration(border: OutlineInputBorder()),
            validator: (value) => value == null ? 'Seleccione un estado' : null,
          ),
        ],
      ),
    );
  }
}
