
import 'package:flutter/material.dart';
import 'testing/prueba_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const InventarioApp());
}

class InventarioApp extends StatelessWidget {
  const InventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventario y Ventas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const PruebaDatabase(),
    );
  }
}
