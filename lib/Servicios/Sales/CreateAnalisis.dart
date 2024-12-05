import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:laboratorios/Servicios/Sales/GestionVentas.dart';

class CreateAnalisis extends StatefulWidget {
  final String userId;

  const CreateAnalisis({Key? key, required this.userId}) : super(key: key);

  @override
  _CrearAnalisisState createState() => _CrearAnalisisState();
}

class _CrearAnalisisState extends State<CreateAnalisis> {
  final TextEditingController _nombreController = TextEditingController();
  final List<Map<String, dynamic>> _analisisList = [];
  String? _selectedAnalisis;
  String? _selectedPacienteId;
  List<Map<String, dynamic>> _pacientesList = [];
  List<Map<String, dynamic>> _analisisDataList = [];

  @override
  void initState() {
    super.initState();
    _loadAllPacientes();
    _loadAllAnalisis();
  }

  Future<void> _loadAllPacientes() async {
    try {
      QuerySnapshot pacientesSnapshot =
          await FirebaseFirestore.instance.collection('pacientes').get();
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
      QuerySnapshot analisisSnapshot =
          await FirebaseFirestore.instance.collection('analisis').get();
      setState(() {
        _analisisDataList = analisisSnapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              if (data['estado'] == 'Activo') {
                return {
                  'codigo': data['codigo'] ?? '',
                  'nombre': data['nombre'] ?? '',
                  'precio': data['precio'] ?? 0.0,
                };
              }
              return null;
            })
            .where((element) => element != null)
            .cast<Map<String, dynamic>>()
            .toList();
      });
    } catch (e) {
      print('Error al cargar análisis: $e');
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
          'codigo': analisisData['codigo'],
          'precio': analisisData['precio'],
        });
      });
    }
  }

  void _removeAnalisis(int index) {
    setState(() {
      _analisisList.removeAt(index);
    });
  }

  Future<void> _crearVenta() async {
    if (_selectedPacienteId == null || _analisisList.isEmpty) {
      print('Debe seleccionar un paciente y al menos un análisis.');
      return;
    }

    try {
      // Calcular el total del precio de los análisis seleccionados
      double total =
          _analisisList.fold(0, (sum, item) => sum + item['precio']);

      // Crear el documento de venta
      DocumentReference ventaRef =
          await FirebaseFirestore.instance.collection('ventas').add({
        'estadoPago': true,
        'fechaVenta': Timestamp.now(),
        'idPaciente': _selectedPacienteId,
        'userId': widget.userId,
        'total': total,
      });

      // Crear el documento de detalle de venta
      await FirebaseFirestore.instance.collection('detalleventa').add({
        'idPaciente': _selectedPacienteId,
        'idVenta': ventaRef.id,
        'idAnalisis': _analisisList.map((analisis) => analisis['codigo']).toList(),
        'subtotal': total,
      });

      // Mostrar un modal de confirmación
      _mostrarModalConfirmacion();
    } catch (e) {
      print('Error al crear la venta: $e');
    }
  }

  void _mostrarModalConfirmacion() {
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
                'VENTA EXITOSA',
                style: TextStyle(
                  color: Color(0xFF54595E),
                ),
              ),
            ],
          ),
          content: Text(
            'Los datos se han guardado correctamente.',
            style: TextStyle(
              color: Color(0xFF54595E),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5B7FCE),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GestionVentas(userId: widget.userId),
                  ),
                );
              },
              child: Text('Aceptar'),
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
                  child: DropdownSearch<String>(
                    items: _pacientesList.map((e) => e['nombreCompleto'] as String).toList(),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: 'Ingrese el nombre del paciente',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    popupProps: PopupProps.dialog(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          hintText: 'Buscar paciente',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _nombreController.text = value ?? '';
                        _selectedPacienteId = _pacientesList.firstWhere(
                            (paciente) => paciente['nombreCompleto'] == value)['id'];
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
                      DataColumn(label: Text('ACCIONES')),
                    ],
                    rows: _analisisList
                        .asMap()
                        .entries
                        .map((entry) => DataRow(
                              cells: [
                                DataCell(Text(entry.value['analisis'])),
                                DataCell(Text('Bs ${entry.value['precio']}')),
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
                onPressed: _crearVenta,
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