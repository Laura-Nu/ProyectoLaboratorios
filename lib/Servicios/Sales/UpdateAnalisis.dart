import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:laboratorios/Servicios/Sales/GestionVentas.dart';

class UpdateAnalisis extends StatefulWidget {
  final String userId;
  final String ventaId;

  const UpdateAnalisis({Key? key, required this.userId, required this.ventaId}) : super(key: key);

  @override
  _UpdateAnalisisState createState() => _UpdateAnalisisState();
}

class _UpdateAnalisisState extends State<UpdateAnalisis> {
  final TextEditingController _nombreController = TextEditingController();
  final List<Map<String, dynamic>> _analisisList = [];
  String? _selectedAnalisis;
  List<Map<String, dynamic>> _pacientesList = [];
  List<Map<String, dynamic>> _analisisDataList = [];
  String? _selectedPacienteId;

  @override
  void initState() {
    super.initState();
    _loadAllData(); // Cargar toda la información al iniciar la pantalla
  }

  Future<void> _loadAllData() async {
    await _loadAllPacientes();
    await _loadAllAnalisis();
    await _loadVentaData(); // Cargar los datos de la venta seleccionada
  }

  Future<void> _loadAllPacientes() async {
    try {
      QuerySnapshot pacientesSnapshot = await FirebaseFirestore.instance.collection('pacientes').get();
      setState(() {
        _pacientesList = pacientesSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final nombre = data['nombre'] ?? '';
          final apellido = data['apellido'] ?? '';
          return {
            'id': doc.id,
            'nombreCompleto': '$nombre $apellido',
          };
        }).toList();
      });
    } catch (e) {
      print('Error al cargar pacientes: $e');
    }
  }

  Future<void> _loadAllAnalisis() async {
    try {
      QuerySnapshot analisisSnapshot = await FirebaseFirestore.instance.collection('analisis').get();
      setState(() {
        _analisisDataList = analisisSnapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              if (data['estado'] == 'activo') {
                return {
                  'codigo': data['codigo'] ?? '',
                  'nombre': data['nombre'] ?? '',
                  'precio': data['precio'] ?? 0.0,
                };
              }
              return null; // Si el estado no es activo, retorna null
            })
            .where((element) => element != null) // Filtrar los elementos null
            .cast<Map<String, dynamic>>()
            .toList();
      });
    } catch (e) {
      print('Error al cargar análisis: $e');
    }
  }

Future<void> _loadVentaData() async {
  try {
    // Buscar el detalle de venta con el idVenta proporcionado
    print("Buscando detalleventa con ventaId: ${widget.ventaId}");
    QuerySnapshot detalleVentaQuery = await FirebaseFirestore.instance
        .collection('detalleventa')
        .where('idVenta', isEqualTo: widget.ventaId)
        .get();

    if (detalleVentaQuery.docs.isNotEmpty) {
      DocumentSnapshot detalleVentaSnapshot = detalleVentaQuery.docs.first;

      final detalleData = detalleVentaSnapshot.data() as Map<String, dynamic>;
      _selectedPacienteId = detalleData['idPaciente'] ?? '';

      // Buscar el nombre del paciente basado en el ID del paciente
      if (_selectedPacienteId != null && _selectedPacienteId!.isNotEmpty) {
        print("Cargando datos del paciente con ID: $_selectedPacienteId");
        DocumentSnapshot pacienteSnapshot = await FirebaseFirestore.instance
            .collection('pacientes')
            .doc(_selectedPacienteId)
            .get();

        if (pacienteSnapshot.exists) {
          final pacienteData = pacienteSnapshot.data() as Map<String, dynamic>;
          setState(() {
            _nombreController.text =
                '${pacienteData["nombre"] ?? "Desconocido"} ${pacienteData["apellido"] ?? ""}'.trim();
          });
          print("Nombre del paciente cargado: ${_nombreController.text}");
        } else {
          print("No se encontró el paciente con el ID: $_selectedPacienteId");
        }
      }

      // Obtener los códigos de análisis desde el detalle de venta
      List<dynamic> idAnalisisList = detalleData['idAnalisis'] ?? [];
      print("Códigos de análisis encontrados: $idAnalisisList");

      // Cargar los resultados desde la colección "ventas"
      DocumentSnapshot ventaSnapshot = await FirebaseFirestore.instance
          .collection('ventas')
          .doc(widget.ventaId)
          .get();

      final data = ventaSnapshot.data() as Map<String, dynamic>?;

      List<dynamic> resultadosList = (data != null && data['resultados'] is List)
          ? data['resultados'] as List<dynamic>
          : [];
      print("Resultados cargados: $resultadosList");

      // Construir la lista de análisis para el grid
      List<Map<String, dynamic>> analisisTempList = [];
      for (var codigo in idAnalisisList) {
        print("Buscando análisis con código: $codigo");
        QuerySnapshot analisisSnapshot = await FirebaseFirestore.instance
            .collection('analisis')
            .where('codigo', isEqualTo: codigo.toString())
            .get();

        if (analisisSnapshot.docs.isNotEmpty) {
          var analisisData = analisisSnapshot.docs.first.data() as Map<String, dynamic>;

          // Buscar si este análisis tiene un resultado previamente guardado
          final resultadoExistente = resultadosList.firstWhere(
            (resultado) => resultado['analisis'] == analisisData['nombre'],
            orElse: () => null,
          );

          analisisTempList.add({
            'analisis': analisisData['nombre'] ?? 'Análisis Desconocido',
            'precio': analisisData['precio'] ?? 0.0,
            'resultado': resultadoExistente?['resultado'] ?? '', // Valor predeterminado si no hay resultado
          });

          print(
              "Análisis encontrado: ${analisisData['nombre']}, Precio: ${analisisData['precio']}, Resultado: ${resultadoExistente?['resultado'] ?? ''}");
        } else {
          // En caso de no encontrar el análisis, añadir una entrada genérica
          analisisTempList.add({
            'analisis': 'Análisis Desconocido',
            'precio': 0.0,
            'resultado': '', // Valor predeterminado
          });
          print("No se encontró análisis con el código: $codigo");
        }
      }

      // Actualizamos la lista de análisis en el estado del widget
      setState(() {
        _analisisList.clear();
        _analisisList.addAll(analisisTempList);
      });

    } else {
      print("No se encontró el documento en detalleventa con el ID de venta: ${widget.ventaId}");
    }
  } catch (e) {
    print('Error al cargar los datos de la venta: $e');
  }
}




  void _addAnalisis() {
    if (_selectedAnalisis != null) {
      final analisisData = _analisisDataList.firstWhere(
        (analisis) => analisis['nombre'] == _selectedAnalisis,
        orElse: () => {'precio': 0.0},
      );

      setState(() {
        _analisisList.add({
          'analisis': _selectedAnalisis!,
          'precio': analisisData['precio'] ?? 0.0,
          'resultado': '', // Inicializamos resultado como vacío
        });
      });
    }
  }

  void _removeAnalisis(int index) {
    setState(() {
      _analisisList.removeAt(index);
    });
  }

  Future<void> _updateVentaData() async {
    try {
      QuerySnapshot detalleVentaQuery = await FirebaseFirestore.instance
          .collection('detalleventa')
          .where('idVenta', isEqualTo: widget.ventaId)
          .get();

      if (detalleVentaQuery.docs.isNotEmpty) {
        DocumentSnapshot detalleVentaSnapshot = detalleVentaQuery.docs.first;

        final detalleData = detalleVentaSnapshot.data() as Map<String, dynamic>;
        String detalleVentaId = detalleVentaSnapshot.id;

        await FirebaseFirestore.instance.collection('ventas').doc(widget.ventaId).update({
          'idPaciente': _selectedPacienteId,
          'total': _analisisList.fold<double>(0.0, (double sum, item) => sum + (item['precio'] ?? 0.0)),
          'resultados': _analisisList.map((item) {
            return {
              'analisis': item['analisis'],
              'resultado': item['resultado'] ?? '',
            };
          }).toList(),
        });

        await FirebaseFirestore.instance.collection('detalleventa').doc(detalleVentaId).update({
          'idPaciente': _selectedPacienteId,
          'idAnalisis': _analisisList.map((item) {
            final analisisData = _analisisDataList.firstWhere(
              (analisis) => analisis['nombre'] == item['analisis'],
              orElse: () => {'codigo': ''},
            );
            return analisisData['codigo'] ?? '';
          }).toList(),
          'subtotal': _analisisList.fold<double>(0.0, (double sum, item) => sum + (item['precio'] ?? 0.0)),
        });

        _showConfirmationModal('Datos actualizados correctamente');
      }
    } catch (e) {
      print('Error al actualizar los datos: $e');
    }
  }

  void _showConfirmationModal(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.blue, size: 40),
              SizedBox(width: 10),
              Text(
                'ACTUALIZAR DATOS',
                style: TextStyle(color: Color(0xFF54595E), fontSize: 22),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(color: Color(0xFF54595E), fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5B7FCE),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => GestionVentas(userId: widget.userId)),
                );
              },
              child: Text('Aceptar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Actualizar Análisis',
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
                  child: DropdownSearch<String>(
                    items: _pacientesList.map((p) => p['nombreCompleto'] as String).toList(),
                    selectedItem: _nombreController.text,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: 'Seleccione el nombre del paciente',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    popupProps: PopupProps.dialog(
                      showSearchBox: true,
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _nombreController.text = value ?? '';
                        _selectedPacienteId = _pacientesList.firstWhere(
                            (paciente) => paciente['nombreCompleto'] == value,
                            orElse: () => {'id': ''})['id'];
                      });
                    },
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
                    items: _analisisDataList
                        .map((analisis) => DropdownMenuItem<String>(
                              value: analisis['nombre'],
                              child: Text(analisis['nombre']),
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
                      DataColumn(label: Text('RESULTADO')),
                      DataColumn(label: Text('ACCIONES')),
                    ],
                    rows: _analisisList
                        .asMap()
                        .entries
                        .map((entry) => DataRow(
                              cells: [
                                DataCell(Text(entry.value['analisis'])),
                                DataCell(Text('\$${entry.value['precio'].toStringAsFixed(2)}')),
                                DataCell(
                                  Container(
                                    width: 100, // Ajusta el ancho del campo de texto según tus necesidades
                                    child: TextFormField(
                                      initialValue: entry.value['resultado'] ?? '',
                                      decoration: InputDecoration(
                                        hintText: 'Ingrese resultado',
                                        hintStyle: TextStyle(color: Colors.grey), // Color gris para el texto del placeholder
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.black, // Color negro para la línea
                                            width: 1.5, // Grosor de la línea
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.black87, // Negro más intenso cuando está enfocado
                                            width: 2.0, // Grosor más grande al estar enfocado
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _analisisList[entry.key]['resultado'] = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
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
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0, right: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5B7FCE),
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                    ),
                    onPressed: () {
                      _updateVentaData();
                    },
                    child: Text(
                      'ACTUALIZAR',
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
                      Navigator.pop(context);
                    },
                    child: Text(
                      'CANCELAR',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
