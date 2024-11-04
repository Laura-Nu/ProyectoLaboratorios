import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteAnalysis extends StatelessWidget {
  final String analisisId;

  DeleteAnalysis({required this.analisisId});

  Future<void> _deleteAnalisis(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('analisis')
        .doc(analisisId)
        .delete();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Eliminar Análisis"),
      content: Text("¿Estás seguro de que quieres eliminar este análisis?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () async {
            await _deleteAnalisis(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text("Eliminar"),
        ),
      ],
    );
  }
}
