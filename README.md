# 🗄️ Sistema de Inventario y Ventas – SQLite

## 📌 Descripción

Módulo de base de datos y control de inventario desarrollado como parte del proyecto académico de **Introducción al Desarrollo de Aplicaciones Móviles**.

Utiliza Flutter, Dart y SQLite para gestionar productos, registrar ventas, validar existencias y actualizar automáticamente el inventario.

## 🛠️ Tecnologías utilizadas

- **Flutter:** Desarrollo de la interfaz móvil.
- **Dart:** Lenguaje de programación.
- **SQLite:** Almacenamiento local de datos.
- **sqflite:** Conexión y gestión de la base de datos.
- **path:** Construcción de rutas de almacenamiento.

## ⚙️ Funcionalidades implementadas

- Creación de las tablas `productos` y `ventas`.
- Registro, consulta y edición de productos.
- Validación de precios, cantidades y existencias.
- Registro de ventas mediante transacciones SQLite.
- Descuento automático del inventario.
- Consulta del historial de ventas.
- Persistencia de los datos al cerrar y abrir la aplicación.
- Pantalla de pruebas para verificar las operaciones del inventario.

## 📁 Estructura del proyecto

```text
lib/
├── main.dart
├── database/
│   └── database_helper.dart
└── testing/
    └── prueba_database.dart
```

## 🧪 Prueba de funcionamiento

Se implementó una pantalla de pruebas con un producto llamado **Arroz de prueba**, configurado con un precio de RD$50.00 y un inventario inicial de 10 unidades.

| Operación | Resultado |
|---|---|
| Venta de 3 unidades | Aprobada |
| Inventario restante | 7 unidades |
| Intento de venta de 8 unidades | Rechazado |
| Persistencia de datos | Conservada en SQLite |

## 👨‍💻 Responsabilidad en el proyecto

**Integrante 2 – Base de datos y lógica de inventario.**

Desarrollo de la estructura SQLite, operaciones CRUD de productos, registro de ventas, validación de existencias y pantalla de pruebas.

---

**Proyecto académico:** Sistema de Inventario y Ventas.

**Asignatura:** Introducción al Desarrollo de Aplicaciones Móviles.

**Tecnologías:** Flutter, Dart y SQLite.