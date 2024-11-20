import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laboratorios/Widgets/menu.dart';

class CreateAnalysis extends StatefulWidget {
  @override
  _CreateAnalysisState createState() => _CreateAnalysisState();
}

class _CreateAnalysisState extends State<CreateAnalysis> {
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController inicioRangoController = TextEditingController();
  final TextEditingController finRangoController = TextEditingController();
  final TextEditingController unidadRangoController = TextEditingController();

  String? estadoSeleccionado; // Variable para el valor seleccionado
  final _formKey = GlobalKey<FormState>();

  Future<void> _addAnalisis(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Referencia al documento del contador
        DocumentReference counterRef =
            FirebaseFirestore.instance.collection('counters').doc('analisis');

        // Usar una transacción para incrementar el contador
        int nextId = await FirebaseFirestore.instance
            .runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(counterRef);

          if (!snapshot.exists) {
            throw Exception("El contador no existe.");
          }

          // Leer el valor actual del contador
          int currentId = snapshot['last_id'] as int;
          int updatedId = currentId + 1;

          // Actualizar el contador en Firestore
          transaction.update(counterRef, {'last_id': updatedId});
          return updatedId; // Devolver el nuevo ID
        });

        // Usar el nuevo ID para crear el análisis
        await FirebaseFirestore.instance
            .collection('analisis')
            .doc(nextId.toString())
            .set({
          'codigo': nextId.toString(),
          'descripcion': descripcionController.text,
          'estado': estadoSeleccionado,
          'nombre': nombreController.text,
          'precio': int.parse(precioController.text),
          'rango': {
            'inicio': int.parse(inicioRangoController.text),
            'fin': int.parse(finRangoController.text),
            'unidad': unidadRangoController.text,
          },
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Devolver los datos al usuario
        final newAnalisis = {
          'id': nextId.toString(),
          'codigo': nextId.toString(),
          'descripcion': descripcionController.text,
          'estado': estadoSeleccionado,
          'nombre': nombreController.text,
          'precio': int.parse(precioController.text),
          'rango': {
            'inicio': int.parse(inicioRangoController.text),
            'fin': int.parse(finRangoController.text),
            'unidad': unidadRangoController.text,
          },
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
        title: Text('AGREGAR NUEVO ANALISIS'),
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
              buildTextField('NOMBRE', nombreController),
              buildTextField('DESCRIPCION', descripcionController),
              buildDropdownField(),
              buildNumberField('PRECIO', precioController),
              buildNumberField('INICIO DE RANGO', inicioRangoController),
              buildNumberField('FIN DE RANGO', finRangoController),
              buildTextField('UNIDAD', unidadRangoController),
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
            value: estadoSeleccionado,
            items: [
              DropdownMenuItem(value: 'Activo', child: Text('Activo')),
              DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
              DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
            ],
            onChanged: (value) {
              setState(() {
                estadoSeleccionado = value;
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
