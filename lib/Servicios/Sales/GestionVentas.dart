import 'package:flutter/material.dart';
import 'package:laboratorios/Servicios/Sales/UpdateAnalisis.dart';
import 'package:laboratorios/Servicios/User/interfazUsuario.dart';
import 'package:laboratorios/Servicios/Sales/CreateAnalisis.dart';
import 'package:laboratorios/Servicios/Sales/ViewAnalisis.dart';
import 'package:laboratorios/Widgets/menu.dart';

class GestionVentas extends StatefulWidget {
<<<<<<< Updated upstream
=======
  final String userId;
  final String userRole;

  const GestionVentas({Key? key, required this.userId,required this.userRole}) : super(key: key);

>>>>>>> Stashed changes
  @override
  _GestionVentasState createState() => _GestionVentasState();
}

class _GestionVentasState extends State<GestionVentas> {
  TextEditingController searchController = TextEditingController(); // Controlador para el buscador

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GESTION DE VENTAS',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: Color(0xFF5B7FCE), // Color del AppBar
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
<<<<<<< Updated upstream
      drawer: const Menu(),
=======
      drawer: Menu(userId: widget.userId,userRol: widget.userRole),
>>>>>>> Stashed changes
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Centramos todo el contenido
          children: [
            // Fila con buscador y botón centrado
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Centramos la fila
                children: [
                  // Buscador ajustado al tamaño del grid
                  Container(
                    width: 960, // Ajustamos el ancho del buscador
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Botón de "Crear Datos" al lado del buscador
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5B7FCE), // Mismo color que el AppBar
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.push(
<<<<<<< Updated upstream
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateAnalisis(), // Navegar a GestionVentas.dart
                  ),
                );
=======
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateAnalisis(userId: widget.userId, userRole: widget.userRole),
                        ),
                      );
>>>>>>> Stashed changes
                    },
                    child: Text(
                      'CREAR DATOS',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // DataGrid (DataTable) más grande y ajustado
            Center(
              child: Container(
                width: 1100, // Aumentar el ancho del grid
                height: 400, // Aumentar la altura del grid
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black), // Borde del DataTable
                  borderRadius: BorderRadius.circular(15), // Bordes redondeados
                ),
                padding: EdgeInsets.all(8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 24.0, // Espacio entre las columnas
                    headingRowHeight: 50, // Altura de los encabezados
                    headingTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    columns: [
                      DataColumn(
                        label: Center(
                          child: Text('NOMBRES'),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Center(
                            child: Text('ANÁLISIS'),
                          ),
                        ),
                      ), // Columna más ancha para ANÁLISIS
                      DataColumn(
                        label: Center(
                          child: Text('TOTAL'),
                        ),
                        numeric: true, // Para alinear los números a la derecha
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('ACCIONES'),
                          ),
                        ),
                      ),
                    ],
                    rows: [
                      DataRow(
                        cells: [
                          DataCell(Text('Juan Pérez')),
                          DataCell(Text('Análisis de Sangre')),
                          DataCell(
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text('\$100'),
                            ),
                          ),
                          DataCell(
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    color: Colors.blue,
                                    onPressed: () {
                                      Navigator.push(
<<<<<<< Updated upstream
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UpdateAnalisis(), // Navegar a GestionVentas.dart
                                      ),
                                    );
=======
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UpdateAnalisis(
                                            ventaId: venta['ventaId'],
                                            userId: widget.userId,
                                            userRole: widget.userRole,
                                          ),
                                        ),
                                      );
>>>>>>> Stashed changes
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      // Mostrar el modal de confirmación al eliminar
                                      _showDeleteConfirmationModal(context);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.picture_as_pdf),
                                    color: Colors.green,
                                    onPressed: () {
                                        Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ViewAnalisis(), 
                                      ),
                                    );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationModal(BuildContext context) {
     showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                'ELIMINCIÓN DE DATOS',
                style: TextStyle(
                  color: Color(0xFF54595E), 
                ),
              ),
            ],
          ),
          content: Text(
            '¿ESTÁS SEGURO DE ELIMINAR ESTOS DATOS?',
            style: TextStyle(
              color: Color(0xFF54595E), 
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, 
              ),
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5B7FCE),
                foregroundColor: Colors.white, 
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => interfazUsuario(), 
                  ),
                );
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}
