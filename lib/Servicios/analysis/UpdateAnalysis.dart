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
  late TextEditingController _inicioRangoController;
  late TextEditingController _finRangoController;
  late TextEditingController _unidadRangoController;
  late TextEditingController _precioController;
  late TextEditingController _codigoController;

  String? _estadoSeleccionado;

  @override
  void initState() {
    super.initState();
    // Conversión de valores numéricos a String y manejo de nulos
    _nombreController =
        TextEditingController(text: widget.AnalysisData['nombre'] ?? '');
    _descripcionController =
        TextEditingController(text: widget.AnalysisData['descripcion'] ?? '');
    _inicioRangoController = TextEditingController(
        text: widget.AnalysisData['rango_inicio']?.toString() ?? '');
    _finRangoController = TextEditingController(
        text: widget.AnalysisData['rango_fin']?.toString() ?? '');
    _unidadRangoController = TextEditingController(
        text: widget.AnalysisData['rango']?.toString() ?? '');
    _precioController = TextEditingController(
        text: widget.AnalysisData['precio']?.toString() ?? '');
    _codigoController =
        TextEditingController(text: widget.AnalysisData['codigo'] ?? '');
    _estadoSeleccionado = widget.AnalysisData['estado'];
  }

  Future<void> _updateAnalisis() async {
    if (_formKey.currentState!.validate()) {
      // Manejo de posibles conversiones erróneas con int.tryParse
      final updatedAnalisisData = {
        'id': widget.AnalysisId,
        'nombre': _nombreController.text,
        'descripcion': _descripcionController.text,
        'rango_inicio': int.tryParse(_inicioRangoController.text) ?? 0,
        'rango_fin': int.tryParse(_finRangoController.text) ?? 0,
        'rango': int.tryParse(_unidadRangoController.text) ?? 0,
        'precio': int.tryParse(_precioController.text) ?? 0,
        'estado': _estadoSeleccionado,
        'codigo': _codigoController.text,
      };

      // Actualización en Firebase
      await FirebaseFirestore.instance
          .collection('analisis')
          .doc(widget.AnalysisId)
          .update(updatedAnalisisData);

      // Regresar a la pantalla anterior con los datos actualizados
      Navigator.pop(context, updatedAnalisisData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ACTUALIZAR ANÁLISIS'),
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
              buildTextField('DESCRIPCIÓN', _descripcionController),
              buildDropdownField(),
              // buildTextField('CÓDIGO', _codigoController),
              buildNumberField('INICIO DE RANGO', _inicioRangoController),
              buildNumberField('FIN DE RANGO', _finRangoController),
              buildNumberField('RANGO', _unidadRangoController),
              buildNumberField('PRECIO', _precioController),
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

  Widget buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ESTADO',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
