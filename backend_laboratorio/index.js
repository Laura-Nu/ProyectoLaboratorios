const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = 3000; // El puerto donde correrá tu API

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Conexión a MySQL
const db = mysql.createConnection({
  host: 'localhost',  // Dirección del servidor MySQL
  user: 'root',       // Usuario de MySQL
  password: '',       // Contraseña de MySQL (vacía por defecto en XAMPP)
  database: 'bddlaboratorio' // Nombre de la base de datos
});

db.connect(err => {
  if (err) {
    console.error('Error al conectar a la base de datos:', err);
    return;
  }
  console.log('Conexión a la base de datos exitosa');
});

app.get('/', (req, res) => {
  res.send('API está corriendo');
});

app.get('/pacientes', (req, res) => {
  const sql = 'SELECT * FROM Paciente';
  db.query(sql, (err, results) => {
    if (err) {
      return res.status(500).send(err);
    }
    res.json(results);
  });
});

app.post('/pacientes', (req, res) => {
  const { nombre, apellido, fechaNacimiento, direccion, telefono, email } = req.body;
  const sql = 'INSERT INTO Paciente (nombre, apellido, fechaNacimiento, direccion, telefono, email) VALUES (?, ?, ?, ?, ?, ?)';
  db.query(sql, [nombre, apellido, fechaNacimiento, direccion, telefono, email], (err, result) => {
    if (err) {
      return res.status(500).send(err);
    }
    res.json({ message: 'Paciente registrado exitosamente', id: result.insertId });
  });
});

app.listen(port, () => {
  console.log(`Servidor corriendo en http://localhost:${port}`);
});
