import 'package:flutter/material.dart';
import 'package:laboratorios/Servicios/User/interfazUsuario.dart';
import 'package:laboratorios/Servicios/Sales/GestionVentas.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

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
                  MaterialPageRoute(builder: (context) => interfazUsuario()),
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
                  MaterialPageRoute(builder: (context) => GestionVentas()),
                );
              },
              textColor: Colors.white,
            ),
            _buildDrawerItem(
              icon: Icons.design_services,
              title: 'SERVICIOS',
              onTap: () => Navigator.pushReplacementNamed(context, '/servicios'),
              textColor: Colors.white,
            ),
            _buildDrawerItem(
              icon: Icons.shopping_cart,
              title: 'COMPRAS',
              onTap: () => Navigator.pushReplacementNamed(context, '/compras'),
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
              title: 'Log Up',
              onTap: () {
                // Implementar lógica de cierre de sesión
                Navigator.pushReplacementNamed(context, '/login');
              },
              textColor: Colors.white,
            ),
          ],
        ),
      ),
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