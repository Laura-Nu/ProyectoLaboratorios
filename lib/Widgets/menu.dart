import 'package:flutter/material.dart';

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
            /*DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[800],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.blue),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Interfaz Usuario',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),// */
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
              onTap: () => Navigator.pushReplacementNamed(context, '/perfil'),
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