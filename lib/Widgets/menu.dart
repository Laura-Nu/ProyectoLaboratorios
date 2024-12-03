import 'package:flutter/material.dart';
import 'package:laboratorios/Servicios/Patient/GestionPatient.dart';
import 'package:laboratorios/Servicios/User/interfazUsuario.dart';
import 'package:laboratorios/Servicios/Sales/GestionVentas.dart';
import 'package:laboratorios/Servicios/analysis/GestionAnalysis.dart';
import 'package:laboratorios/Login.dart';

class Menu extends StatelessWidget {
  final String userId;

  const Menu({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blue[700],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerItem(
              icon: Icons.menu,
              title: 'NAVEGADOR',
              onTap: () => Navigator.pushReplacementNamed(context, '/'),
              textColor: Colors.white,
            ),
            _buildDrawerItem(
              icon: Icons.home,
              title: 'HOME',
              onTap: () => Navigator.pushReplacementNamed(context, '/home'),
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
              icon: Icons.design_services,
              title: 'PACIENTES',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GestionPatient()),
                );
              },
              textColor: Colors.white,
            ),
            _buildDrawerItem(
              icon: Icons.shopping_cart,
              title: 'ANALISIS',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GestionAnalysis()),
                );
              },
              textColor: Colors.white,
            ),
            _buildDrawerItem(
              icon: Icons.report,
              title: 'REPORTES',
              onTap: () => Navigator.pushReplacementNamed(context, '/reportes'),
              textColor: Colors.white,
            ),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Log Out',
              onTap: () {
                _showLogoutConfirmationDialog(context);
              },
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

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
                ); // Navega al LoginPage
              },
              child: Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
  }

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
