import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeletePatient extends StatelessWidget {
  final String patientId; // ID del paciente a eliminar

  DeletePatient({required this.patientId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Eliminación de Datos"),
      content: Text("¿Estás seguro de eliminar estos datos?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Cierra el diálogo
          },
          child: Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await FirebaseFirestore.instance
                  .collection('patients')
                  .doc(patientId)
                  .delete();
              Navigator.pop(context); // Cierra el diálogo
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Paciente eliminado exitosamente.')),
              );
            } catch (e) {
              print('Error al eliminar el paciente: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al eliminar el paciente.')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: Text("Confirmar"),
        ),
      ],
    );
  }
}
