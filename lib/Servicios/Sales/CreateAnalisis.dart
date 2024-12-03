import 'package:flutter/material.dart';
import 'package:laboratorios/Servicios/Sales/GestionVentas.dart';

class CreateAnalisis extends StatefulWidget {
  @override
  _CrearAnalisisState createState() => _CrearAnalisisState();
}

class _CrearAnalisisState extends State<CreateAnalisis> {
  final TextEditingController _nombreController = TextEditingController();
  final List<Map<String, dynamic>> _analisisList = [];
  String? _selectedAnalisis;
  final Map<String, double> _analisisPrecios = {
    'Hemograma': 173.75,
    'Perfil Lipídico': 208.50,
    'Glucosa en Sangre': 104.25,
    'Cultivos Bacterianos': 313.75,
  };

  void _addAnalisis() {
    if (_selectedAnalisis != null) {
      setState(() {
        _analisisList.add({
          'analisis': _selectedAnalisis!,
          'precio': _analisisPrecios[_selectedAnalisis]!,
        });
      });
    }
  }

  void _removeAnalisis(int index) {
    setState(() {
      _analisisList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crear Análisis',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: Color(0xFF5B7FCE),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, 
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Container(
                  width: 120, 
                  child: Text(
                    'NOMBRE:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 10), 
                Container(
                  width: 760, 
                  child: TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      hintText: 'Ingrese el nombre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Container(
                  width: 120, 
                  child: Text(
                    'ANÁLISIS:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 10), 
                Container(
                  width: 760, 
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2), 
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: Text('Seleccione un análisis'),
                    value: _selectedAnalisis,
                    underline: SizedBox(), 
                    items: _analisisPrecios.keys
                        .map((String analisis) => DropdownMenuItem<String>(
                              value: analisis,
                              child: Text(analisis),
                            ))
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedAnalisis = newValue;
                        _addAnalisis(); 
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // DataGrid (DataTable) para mostrar los análisis y precios añadidos
            Center(
              child: Container(
                width: 900, 
                height: 300, 
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black), 
                  borderRadius: BorderRadius.circular(15), 
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 40.0, 
                    headingRowHeight: 50,
                    headingTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    columns: [
                      DataColumn(label: Text('ANÁLISIS')),
                      DataColumn(label: Text('PRECIO')),
                      DataColumn(label: Text('ACCIONES')),
                    ],
                    rows: _analisisList
                        .asMap()
                        .entries
                        .map((entry) => DataRow(
                              cells: [
                                DataCell(Text(entry.value['analisis'])),
                                DataCell(Text('\$${entry.value['precio']}')),
                                DataCell(
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeAnalisis(entry.key),
                                  ),
                                ),
                              ],
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
            Spacer(), 

            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5B7FCE),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                ),
                onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GestionVentas(), 
                  ),
                );
                },
                child: Text(
                  'CREAR',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
