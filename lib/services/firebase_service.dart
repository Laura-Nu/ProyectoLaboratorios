import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
   // Función para obtener los análisis realizados por un paciente específico
  Future<List<Map<String, dynamic>>> getAnalisisPorPaciente(String patientId) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('detalleventa')
          .where('idPaciente', isEqualTo: patientId)
          .get();

      List<Map<String, dynamic>> analisisList = [];

      // Procesa cada documento en la consulta
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String idVenta = data['idVenta'];

        DocumentSnapshot ventaDoc = await firestore.collection('ventas').doc(idVenta).get();
        DateTime fechaVenta = (ventaDoc['fechaVenta'] as Timestamp).toDate();
        double total = ventaDoc['total'];

        analisisList.add({
          'nombre': data['idAnalisis'],
          'fecha': fechaVenta,
          'total': total,
        });
      }

      return analisisList;
    } catch (e) {
      print('Error al obtener análisis por paciente: $e');
      return [];
    }
  }
}
