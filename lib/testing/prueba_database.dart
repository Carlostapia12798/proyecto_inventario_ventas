
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class PruebaDatabase extends StatefulWidget {
  const PruebaDatabase({super.key});

  @override
  State<PruebaDatabase> createState() =>
      _PruebaDatabaseState();
}

class _PruebaDatabaseState extends State<PruebaDatabase> {
  Map<String, dynamic>? producto;
  List<Map<String, dynamic>> historial = [];

  bool cargando = true;
  String mensaje = '';

  @override
  void initState() {
    super.initState();
    inicializar();
  }

  // Crear producto de prueba si no existe
  Future<void> inicializar() async {
    try {
      final db = DatabaseHelper.instance;

      final productos = await db.getProducts();

      final existentes = productos.where(
        (p) => p['nombre'] == 'Arroz de prueba',
      );

      if (existentes.isEmpty) {
        await db.addProduct(
          nombre: 'Arroz de prueba',
          descripcion: 'Producto para probar inventario',
          precio: 50.0,
          stock: 10,
        );
      }

      await actualizarDatos();
    } catch (e) {
      if (mounted) {
        setState(() {
          mensaje = 'Error: $e';
          cargando = false;
        });
      }
    }
  }

  // Actualizar producto e historial
  Future<void> actualizarDatos() async {
    final db = DatabaseHelper.instance;

    final productos = await db.getProducts();

    final resultado = productos.where(
      (p) => p['nombre'] == 'Arroz de prueba',
    );

    final ventas = await db.getSalesHistory();

    if (!mounted) return;

    setState(() {
      producto = resultado.isEmpty ? null : resultado.first;
      historial = ventas;
      cargando = false;
    });
  }

  // Registrar venta
  Future<void> vender(int cantidad) async {
    if (producto == null) return;

    try {
      await DatabaseHelper.instance.registerSale(
        productoId: producto!['id'] as int,
        cantidad: cantidad,
      );

      await actualizarDatos();

      if (!mounted) return;

      setState(() {
        mensaje = 'Venta de $cantidad unidades registrada.';
      });

    } catch (e) {
      await actualizarDatos();

      if (!mounted) return;

      setState(() {
        mensaje = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Mi Inventario'),
        backgroundColor: const Color(0xFF075985),
        foregroundColor: Colors.white,
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : producto == null
              ? Center(child: Text(mensaje))
              : RefreshIndicator(
                  onRefresh: actualizarDatos,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [

                      // INFORMACIÓN DEL PRODUCTO
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PRODUCTO',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                producto!['nombre'],
                                style: const TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 15),

                              Text(
                                'Precio: RD\$${producto!['precio']}',
                              ),

                              const Divider(height: 30),

                              const Text(
                                'UNIDADES DISPONIBLES',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),

                              Text(
                                '${producto!['stock']}',
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // BOTONES DE VENTA
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Registrar venta',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 15),

                              ElevatedButton(
                                onPressed: () => vender(3),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(15),
                                ),
                                child: const Text(
                                  'Vender 3 unidades',
                                ),
                              ),

                              const SizedBox(height: 10),

                              OutlinedButton(
                                onPressed: () => vender(8),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  padding: const EdgeInsets.all(15),
                                ),
                                child: const Text(
                                  'Intentar vender 8 unidades',
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                mensaje,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // HISTORIAL
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Historial de ventas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              if (historial.isEmpty)
                                const Text(
                                  'Todavía no hay ventas.',
                                ),

                              ...historial.map((venta) {
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    venta['producto'].toString(),
                                  ),
                                  subtitle: Text(
                                    'Cantidad: ${venta['cantidad']}',
                                  ),
                                  trailing: Text(
                                    'RD\$${venta['total']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
