import 'dart:io'; 
class Empresa {
  String nombre;  // Nombre de la empresa
  File? logo;     // Logotipo de la empresa (almacenado como archivo)

  // Constructor de la clase Empresa
  Empresa({required this.nombre, this.logo});
}
