import 'package:flutter/material.dart';

class ViewAnalisis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: 325,
            child: Text(
              'LABORATORIO CLÍNICO',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          
          Positioned(
            top: 80,
            left: 325, 
            child: Row(
              children: [
                Text('Nombre: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Lucas Olguin'),
              ],
            ),
          ),
          Positioned(
            top: 110,
            left: 325, 
            child: Row(
              children: [
                Text('Sexo: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Masculino'),
              ],
            ),
          ),
          Positioned(
            top: 140,
            left: 325, 
            child: Row(
              children: [
                Text('Médico: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Juanito'),
              ],
            ),
          ),
          Positioned(
            top: 170,
            left: 325, 
            child: Row(
              children: [
                Text('Fecha de Nacimiento: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('12/05/2000'),
              ],
            ),
          ),

          Positioned(
            top: 80,
            right: 295,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Orden de laboratorio: 1234567982'),
                Text('Fecha de Recepción: 21/10/2024'),
                Text('Fecha de Entrega: 22/10/2024'),
              ],
            ),
          ),
          
          Positioned(
            top: 220,
            left: 325,
            child: Container(
              width: 550, 
              height: 300, 
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
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
                    DataColumn(label: Text('Importe')),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text('Hemograma')),
                      DataCell(Text('173.75')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Perfil Lipídico')),
                      DataCell(Text('208.50')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Glucosa en Sangre')),
                      DataCell(Text('104.25')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Cultivos Bacterianos')),
                      DataCell(Text('313.75')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Electrolitos')),
                      DataCell(Text('125.10')),
                    ]),
                  ],
                ),
              ),
            ),
          ),
          
          // Grid de subtotales (debajo de la información del laboratorio)
          Positioned(
            top: 220,
            right: 290,
            child: Container(
              width: 350, // Ancho del grid
              height: 300, // Altura del grid
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Subtotal', '925.35'),
                    _buildDetailRow('Descuento', '0.00'),
                    _buildDetailRow('Total', '925.35'),
                    _buildDetailRow('Importe Pagado', '925.35'),
                    _buildDetailRow('Saldo', '0.00'),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            right: 40,
            child: Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5B7FCE), 
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'VOLVER',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5B7FCE), 
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Generando PDF...')),
                    );
                  },
                  child: Text(
                    'GENERAR PDF',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
