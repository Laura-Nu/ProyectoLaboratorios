import 'package:flutter/material.dart';
import 'package:laboratorios/Servicios/User/interfazUsuario.dart';
import 'package:laboratorios/Servicios/Sales/GestionVentas.dart';
import 'package:laboratorios/Login.dart';
import 'package:laboratorios/Home.dart';
import 'package:laboratorios/screens/reportes.dart';
import 'package:laboratorios/Servicios/Patient/GestionPatient.dart';
import 'package:laboratorios/Servicios/analysis/GestionAnalysis.dart';
import 'package:laboratorios/Servicios/User/crearusuario.dart';
import 'package:laboratorios/Servicios/EditEmpresa.dart';
import 'dart:io';
import 'package:provider/provider.dart'; // Importa Provider

import 'package:laboratorios/Providers/empresa_provider.dart'; // Asegúrate de importar tu provider

class Menu extends StatelessWidget {
  final String userId;

  // Constructor
  const Menu({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EmpresaProvider>(
      builder: (context, empresaProvider, child) {
        final empresaNombre = empresaProvider.nombre;
        final logoPath = empresaProvider.logoPath;

        return Drawer(
          child: Container(
            color: Colors.blue[700],
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Header con el nombre de la empresa y el logo
                UserAccountsDrawerHeader(
                  accountName: Text(
                    empresaNombre.isNotEmpty ? empresaNombre : 'Nombre de la Empresa',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  accountEmail: Text(
                    '', // Puedes agregar el correo si lo deseas
                    style: TextStyle(color: Colors.white),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: logoPath.isNotEmpty 
                        ? FileImage(File(logoPath)) // Usar la ruta del logo si está disponible
                        : AssetImage('assets/logo.png') as ImageProvider, // Usar un logo predeterminado si no hay logo cargado
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[800],
                  ),
                ),
                // Lista de opciones en el Drawer
                _buildDrawerItem(
                  icon: Icons.menu,
                  title: 'NAVEGADOR',
                  onTap: () => Navigator.pushReplacementNamed(context, '/'),
                  textColor: Colors.white,
                ),
                _buildDrawerItem(
                  icon: Icons.edit,
                  title: 'Dueño',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CrearUsuarioPage()),
                    );
                  },
                  textColor: Colors.white,
                ),
                _buildDrawerItem(
                  icon: Icons.build,
                  title: 'Empresa',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditEmpresa()),
                    );
                  },
                  textColor: Colors.white,
                ),
                _buildDrawerItem(
                  icon: Icons.home,
                  title: 'Home',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage(userId: userId)),
                    );
                  },
                  textColor: Colors.white,
                ),
                _buildDrawerItem(
                  icon: Icons.person,
                  title: 'PERFIL',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InterfazUsuario(userId: userId)),
                    );
                  },
                  textColor: Colors.white,
                ),
                _buildDrawerItem(
                  icon: Icons.person,
                  title: 'VENTAS',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GestionVentas(userId: userId)),
                    );
                  },
                  textColor: Colors.white,
                ),
                _buildDrawerItem(
                  icon: Icons.report,
                  title: 'REPORTES',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReportPage()),
                    );
                  },
                  textColor: Colors.white,
                ),
                _buildDrawerItem(
                  icon: Icons.person,
                  title: 'PACIENTES',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GestionPatient(userId: userId)),
                    );
                  },
                  textColor: Colors.white,
                ),
                _buildDrawerItem(
                  icon: Icons.analytics,
                  title: 'ANALISIS',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GestionAnalysis(userId: userId)),
                    );
                  },
                  textColor: Colors.white,
                ),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Cerrar Sesión',
                  onTap: () {
                    _showLogoutConfirmationDialog(context);
                  },
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Método para mostrar el diálogo de confirmación de cierre de sesión
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmación'),
          content: Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
  }

  // Método para construir los ítems del Drawer
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      onTap: onTap,
    );
  }
}
