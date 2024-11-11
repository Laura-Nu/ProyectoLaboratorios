import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteAnalysis extends StatelessWidget {
  final String analisisId;
  final VoidCallback onDelete; // Callback para actualizar la pantalla

  DeleteAnalysis({required this.analisisId, required this.onDelete});

  Future<void> _deleteAnalisis(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('analisis')
        .doc(analisisId)
        .delete();
    onDelete(); // Llamar a la función callback para actualizar la pantalla
    Navigator.pop(context); // Cerrar el diálogo
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Eliminar Análisis'),
      content: Text('¿Está seguro de que desea eliminar este análisis?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => _deleteAnalisis(context),
          child: Text('Eliminar', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
