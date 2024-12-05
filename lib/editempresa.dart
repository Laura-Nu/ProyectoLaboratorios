/*import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditEmpresa extends StatefulWidget {
  @override
  _EditEmpresaState createState() => _EditEmpresaState();
}

class _EditEmpresaState extends State<EditEmpresa> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _logoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmpresaData();
  }

  // Cargar los datos guardados en la aplicación
  _loadEmpresaData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _nombreController.text = prefs.getString('nombre_empresa') ?? '';
    _logoController.text = prefs.getString('logo_url') ?? '';
  }

  // Guardar los cambios en la aplicación
  _saveEmpresaData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('nombre_empresa', _nombreController.text);
    await prefs.setString('logo_url', _logoController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Datos guardados correctamente')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Empresa'),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre de la Empresa:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(hintText: 'Ingrese el nombre de la empresa'),
            ),
            SizedBox(height: 20),
            Text('Logo URL:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _logoController,
              decoration: InputDecoration(hintText: 'Ingrese la URL del logo'),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveEmpresaData,
              child: Text('Guardar Cambios'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
            ),
          ],
        ),
      ),
    );
  }
}*/