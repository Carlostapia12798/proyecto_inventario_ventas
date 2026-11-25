
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // ==========================================
  // CONFIGURACION DE LA BASE DE DATOS
  // ==========================================

  static final DatabaseHelper instance =
      DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  // Obtener la conexion
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('inventario.db');

    return _database!;
  }

  // Abrir o crear la base de datos
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  // ==========================================
  // CREACION DE TABLAS
  // ==========================================

  Future<void> _createDB(
      Database db, int version) async {

    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        precio REAL NOT NULL CHECK(precio >= 0),
        stock INTEGER NOT NULL CHECK(stock >= 0)
      )
    ''');

    await db.execute('''
      CREATE TABLE ventas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        producto_id INTEGER NOT NULL,
        cantidad INTEGER NOT NULL CHECK(cantidad > 0),
        precio_unitario REAL NOT NULL,
        total REAL NOT NULL,
        fecha TEXT NOT NULL,
        FOREIGN KEY (producto_id)
        REFERENCES productos(id)
        ON DELETE RESTRICT
      )
    ''');
  }

  // ==========================================
  // OPERACIONES DE PRODUCTOS
  // ==========================================

  // AGREGAR PRODUCTO
  Future<int> addProduct({
    required String nombre,
    required String descripcion,
    required double precio,
    required int stock,
  }) async {

    if (nombre.trim().isEmpty) {
      throw Exception('El nombre es obligatorio');
    }

    if (precio < 0 || stock < 0) {
      throw Exception('Precio o stock inválido');
    }

    final db = await database;

    return await db.insert('productos', {
      'nombre': nombre.trim(),
      'descripcion': descripcion.trim(),
      'precio': precio,
      'stock': stock,
    });
  }

  // CONSULTAR TODOS LOS PRODUCTOS
  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await database;

    return await db.query(
      'productos',
      orderBy: 'nombre ASC',
    );
  }

  // BUSCAR PRODUCTO POR ID
  Future<Map<String, dynamic>?> getProductById(
      int id) async {

    final db = await database;

    final resultado = await db.query(
      'productos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (resultado.isEmpty) return null;

    return resultado.first;
  }

  // EDITAR PRODUCTO
  Future<int> updateProduct({
    required int id,
    required String nombre,
    required String descripcion,
    required double precio,
    required int stock,
  }) async {

    if (nombre.trim().isEmpty) {
      throw Exception('El nombre es obligatorio');
    }

    if (precio < 0 || stock < 0) {
      throw Exception('Precio o stock inválido');
    }

    final db = await database;

    return await db.update(
      'productos',
      {
        'nombre': nombre.trim(),
        'descripcion': descripcion.trim(),
        'precio': precio,
        'stock': stock,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==========================================
  // OPERACIONES DE VENTAS
  // ==========================================

  // REGISTRAR VENTA Y DESCONTAR INVENTARIO
  Future<int> registerSale({
    required int productoId,
    required int cantidad,
  }) async {

    if (cantidad <= 0) {
      throw Exception(
        'La cantidad debe ser mayor que cero',
      );
    }

    final db = await database;

    return await db.transaction((txn) async {

      // Buscar producto
      final resultado = await txn.query(
        'productos',
        where: 'id = ?',
        whereArgs: [productoId],
      );

      if (resultado.isEmpty) {
        throw Exception('El producto no existe');
      }

      final producto = resultado.first;

      final int stockActual =
          producto['stock'] as int;

      final double precio =
          (producto['precio'] as num).toDouble();

      // Comprobar inventario
      if (cantidad > stockActual) {
        throw Exception(
          'Stock insuficiente. '
          'Disponibles: $stockActual unidades',
        );
      }

      // Descontar inventario
      final actualizado = await txn.update(
        'productos',
        {
          'stock': stockActual - cantidad,
        },
        where: 'id = ? AND stock >= ?',
        whereArgs: [productoId, cantidad],
      );

      if (actualizado != 1) {
        throw Exception(
          'No hay suficientes unidades disponibles',
        );
      }

      // Calcular importe
      final double total = precio * cantidad;

      // Guardar venta
      final ventaId = await txn.insert('ventas', {
        'producto_id': productoId,
        'cantidad': cantidad,
        'precio_unitario': precio,
        'total': total,
        'fecha': DateTime.now().toIso8601String(),
      });

      return ventaId;
    });
  }

  // CONSULTAR HISTORIAL DE VENTAS
  Future<List<Map<String, dynamic>>> getSalesHistory()
      async {

    final db = await database;

    return await db.rawQuery('''
      SELECT
        ventas.id,
        ventas.producto_id,
        productos.nombre AS producto,
        ventas.cantidad,
        ventas.precio_unitario,
        ventas.total,
        ventas.fecha
      FROM ventas
      INNER JOIN productos
      ON ventas.producto_id = productos.id
      ORDER BY ventas.id DESC
    ''');
  }

  // ==========================================
  // CERRAR CONEXION
  // ==========================================

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
