import 'package:flutter/material.dart';
import 'dart:io';

class EmpresaProvider with ChangeNotifier {
  String _nombre = ''; // Variable para almacenar el nombre de la empresa
  String _logoPath = ''; // Variable para almacenar la ruta del logo

  String get nombre => _nombre; // Getter para el nombre
  String get logoPath => _logoPath; // Getter para la ruta del logo

  // Función para cargar los datos de la empresa (nombre y logo)
  Future<void> cargarDatosEmpresa() async {
    try {
      _nombre = await _loadNombreEmpresa(); // Cargar el nombre
      _logoPath = await _loadLogoEmpresa(); // Cargar el logo
      notifyListeners(); // Notificar a los oyentes (actualizar UI)
    } catch (e) {
      print("Error al cargar los datos de la empresa: $e");
    }
  }

  Future<String> _loadNombreEmpresa() async {
    // Aquí puedes cargar el nombre de la empresa desde un archivo o base de datos
    return 'Laboratorios LIA'; // Ejemplo de nombre cargado
  }

  Future<String> _loadLogoEmpresa() async {
    // Aquí puedes cargar la ruta del logo desde un archivo o base de datos
    return '/path/to/logo.png'; // Ejemplo de ruta del logo
  }

  void actualizarNombre(String nuevoNombre) {
    _nombre = nuevoNombre;
    notifyListeners(); // Actualiza la UI cuando se cambia el nombre
  }

  void actualizarLogo(String nuevaRuta) {
    _logoPath = nuevaRuta;
    notifyListeners(); // Actualiza la UI cuando se cambia el logo
  }
}
