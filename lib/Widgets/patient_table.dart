import 'package:flutter/material.dart';

class PatientTable extends StatelessWidget {
  final List<Map<String, dynamic>> filteredPatients;
  final Function(String, String) onGenerateReport;

  const PatientTable({
    Key? key,
    required this.filteredPatients,
    required this.onGenerateReport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 40,
            headingRowHeight: 48,
            dataRowHeight: 56,
            columns: [
              DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Apellido', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Teléfono', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Dirección', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Generar Reporte', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: filteredPatients.map((patient) {
              return DataRow(cells: [
                DataCell(Text(patient['nombre'])),
                DataCell(Text(patient['apellido'])),
                DataCell(Text(patient['telefono'] ?? '')),
                DataCell(Text(patient['direccion'] ?? '')),
                DataCell(
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: EdgeInsets.symmetric(horizontal: 13.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () => onGenerateReport(
                      patient['id'],
                      '${patient['nombre']} ${patient['apellido']}',
                    ),
                    child: Text(
                      'Generar Reporte',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
