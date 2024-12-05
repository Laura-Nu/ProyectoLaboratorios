import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laboratorios/Servicios/User/interfazUsuario.dart';
import 'package:laboratorios/Servicios/Sales/GestionVentas.dart';
import 'package:laboratorios/Login.dart';
<<<<<<< Updated upstream

class Menu extends StatelessWidget {
  const Menu({super.key});
=======
import 'package:laboratorios/Home.dart';
import 'package:laboratorios/screens/reportes.dart';
import 'package:laboratorios/Servicios/Patient/GestionPatient.dart';
import 'package:laboratorios/Servicios/analysis/GestionAnalysis.dart';
import 'package:laboratorios/creardueno.dart';
import 'package:laboratorios/editempresa.dart';

class Menu extends StatelessWidget {
  final String userId;
  final String userRol;

  const Menu({Key? key, required this.userId, required this.userRol}) : super(key: key);
>>>>>>> Stashed changes

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blue[700],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Cargar y mostrar el nombre y el logo de la empresa
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('empresa').doc('info').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return DrawerHeader(
                    decoration: BoxDecoration(color: Colors.blue[700]),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return DrawerHeader(
                    decoration: BoxDecoration(color: Colors.blue[700]),
                    child: Center(child: Text("Error al cargar datos")),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return DrawerHeader(
                    decoration: BoxDecoration(color: Colors.blue[700]),
                    child: Center(child: Text("Datos no disponibles")),
                  );
                }

                // Obtenemos los datos de la empresa
                var data = snapshot.data!;
                String nombreEmpresa = data['nombre'] ?? 'Empresa sin nombre';
                String logoUrl = data['logoUrl'] ?? '';

                return DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue[700]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mostrar el logo
                      logoUrl.isNotEmpty
                          ? Image.network(
                              logoUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.business, size: 80, color: Colors.white),
                      SizedBox(height: 10),
                      // Mostrar el nombre
                      Text(
                        nombreEmpresa,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Los demás elementos del menú
            _buildDrawerItem(
              icon: Icons.menu,
              title: 'NAVEGADOR',
              onTap: () => Navigator.pushReplacementNamed(context, '/'),
              textColor: Colors.white,
            ),
            _buildDrawerItem(
              icon: Icons.home,
              title: 'HOME',
<<<<<<< Updated upstream
              onTap: () => Navigator.pushReplacementNamed(context, '/home'),
=======
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage(userId: userId, userRole: userRol)),
                );
              },
>>>>>>> Stashed changes
              textColor: Colors.white,
            ),
            _buildDrawerItem(
              icon: Icons.person,
              title: 'PERFIL',
              onTap: () {
                Navigator.push(
                  context,
<<<<<<< Updated upstream
                  MaterialPageRoute(builder: (context) => interfazUsuario()),
=======
                  MaterialPageRoute(builder: (context) => InterfazUsuario(userId: userId, userRole: userRol)),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                  MaterialPageRoute(builder: (context) => GestionVentas()),
=======
                  MaterialPageRoute(builder: (context) => GestionVentas(userId: userId, userRole: userRol)),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
              onTap: () => Navigator.pushReplacementNamed(context, '/reportes'),
=======
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
                  MaterialPageRoute(builder: (context) => GestionPatient(userId: userId, userRole: userRol)),
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
                  MaterialPageRoute(builder: (context) => GestionAnalysis(userId: userId, userRole: userRol)),
                );
              },
>>>>>>> Stashed changes
              textColor: Colors.white,
            ),
            if (userRol == "admin") ...[
              _buildDrawerItem(
                icon: Icons.create,
                title: 'CREAR DUEÑO',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistroDueno()),
                  );
                },
                textColor: Colors.white,
              ),
              
            ],
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
                );
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