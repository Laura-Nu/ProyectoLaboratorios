# Laboratorios Clínicos

## Tabla de Contenidos
- [Descripción](#descripción)
- [Versión Actual](#versión-actual)
- [Tecnologías Utilizadas](#tecnologías-utilizadas)
- [Instalación y Base de Datos](#instalación-y-base-de-datos)
- [Cómo Usar](#cómo-usar)
- [Contacto](#contacto)

---

## Descripción
Sistema genérico para la gestión de laboratorios clínicos. Funcionalidades principales:

- **Sistema Superadministrador:** 
  - El superadministrador puede asignar un logo, nombre de empresa y dirección a un usuario desde la base de datos.
  - Asigna y gestiona usuarios (dueños de laboratorios) con sus respectivas cuentas.

- **Gestión de Pacientes:** 
  - CRUD para registrar datos básicos de pacientes.

- **Gestión de Análisis:** 
  - CRUD para gestionar análisis clínicos, incluyendo nombre, descripción, precio y rango.

- **Realización de Ventas:** 
  - Asignación de un paciente y múltiples análisis a una venta.
  - Cálculo automático del total en $ y exportación de la venta a PDF.

- **Planes de Uso y Bloqueos:**
  - Cada usuario tiene un mes gratuito desde su primer inicio de sesión.
  - El superadministrador puede asignar meses adicionales al usuario.
  - Al acercarse la fecha de expiración, el sistema envía una notificación para realizar el pago.
  - Si el usuario no realiza el pago, su cuenta se bloquea mostrando un mensaje con instrucciones para contactar soporte.

---

## Versión Actual
**Versión:** 1.0

---

## Tecnologías Utilizadas
- **Lenguajes de Programación:** Dart
- **Frameworks y Bibliotecas:** Flutter
- **Herramientas y Servicios:** Firebase

---

## Instalación y Base de Datos
- [Manual Técnico](#)
- [Manual de Base de Datos](https://youtu.be/twhy2IhC4L8)

---

## Cómo Usar
- [Manual de Usuario](https://youtu.be/waniw7T5MpM)

---

## Contacto
Desarrollado por:

- **Hernán Jorge Salcedo Rosenthal** (Versión 1.0)
- **Greisa Karen Águila Luján** (Versión 1.0)
- **Ignacio Antonio Benavides Vargas** (Versión 1.0)
- **Jared Nathanael Juan Quinteros García** (Versión 1.0)
