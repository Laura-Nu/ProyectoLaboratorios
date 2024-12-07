import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Para seleccionar imagenes
import 'package:provider/provider.dart';
import 'package:laboratorios/Providers/empresa_provider.dart'; // Asegúrate de que esta importación esté correcta

class EditEmpresa extends StatefulWidget {
  const EditEmpresa({super.key});

  @override
  _EditEmpresaState createState() => _EditEmpresaState();
}

class _EditEmpresaState extends State<EditEmpresa> {
  TextEditingController _nombreController = TextEditingController();
  String _logoPath = ''; // Ruta del logo
  final ImagePicker _picker = ImagePicker(); // Para seleccionar imágenes

  @override
  void initState() {
    super.initState();
    // Puedes cargar los valores actuales de nombre y logo al iniciar la pantalla
    _cargarDatosExistentes();
  }

  // Cargar los datos existentes de la empresa
  void _cargarDatosExistentes() {
    // Usamos el provider para obtener los valores actuales del nombre y logo
    _nombreController.text = Provider.of<EmpresaProvider>(context, listen: false).nombre;
    _logoPath = Provider.of<EmpresaProvider>(context, listen: false).logoPath;
  }

  // Función para seleccionar una imagen del dispositivo
  Future<void> _seleccionarImagen() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery); // Usamos galería, pero puedes cambiar a cámara si es necesario.
    
    if (pickedFile != null) {
      setState(() {
        _logoPath = pickedFile.path; // Guardamos la ruta de la imagen seleccionada
      });
    }
  }

  // Función que guarda los cambios
  void _guardarCambios() {
    String nuevoNombre = _nombreController.text;
    String nuevaRutaLogo = _logoPath;

    if (nuevoNombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío')),
      );
      return;
    }

    if (nuevaRutaLogo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar un logo')),
      );
      return;
    }

    // Actualizamos los valores en el Provider
    Provider.of<EmpresaProvider>(context, listen: false).actualizarNombre(nuevoNombre);
    Provider.of<EmpresaProvider>(context, listen: false).actualizarLogo(nuevaRutaLogo);

    // Volver a la pantalla anterior (o donde desees)
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Empresa"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de texto para el nombre de la empresa
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la Empresa',
              ),
            ),
            const SizedBox(height: 20),
            
            // Botón para seleccionar el logo
            GestureDetector(
              onTap: _seleccionarImagen,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _logoPath.isEmpty
                    ? const Icon(Icons.add_a_photo, size: 40, color: Colors.blue)
                    : Image.file(File(_logoPath), fit: BoxFit.cover)
              ),
            ),
            const SizedBox(height: 20),

            // Botón de guardar cambios
            Center(
              child: ElevatedButton(
                onPressed: _guardarCambios,
                child: const Text('Guardar Cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
