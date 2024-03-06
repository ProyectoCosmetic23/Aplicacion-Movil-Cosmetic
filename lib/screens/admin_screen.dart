import 'package:flutter/material.dart';
import 'package:consumir_api/models/purchase_model.dart';
import 'package:consumir_api/screens/detail_purchase.dart';
import 'package:consumir_api/screens/home_page.dart';
import 'package:consumir_api/screens/products_list.dart';
import 'package:consumir_api/screens/purchases_list.dart';
import '../widgets/menu_appbar.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Home(),
    ProductsScreen(),
    PurchasesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MenuAppbar(),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Compras',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromRGBO(102, 51, 153, 1),
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Si el índice seleccionado es 3 (índice basado en 0), abre PurchaseDetailScreen
      if (index == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PurchaseDetailScreen(purchaseId: 1), // Aquí define el purchaseId según tus requisitos
          ),
        );
      }
    });
  }
}
