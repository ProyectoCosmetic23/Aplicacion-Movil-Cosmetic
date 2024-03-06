import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> products = [];
  List<dynamic> searchResults = [];

  String editedEstado = '';
  bool isPanelOpen = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<String> getAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';

    return token;
  }

  Future<void> fetchProducts() async {
    final String token = await getAuthToken();
    print('Token: $token');
    final response = await http.get(
      Uri.parse('https://cosmetic-api-yrcb.onrender.com/api/productcs'),
      headers: {
        'X-Token': '$token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
      });
    } else {
      print('Error en la respuesta HTTP: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');
      throw Exception('Error al cargar la lista de productos');
    }
  }

  void searchItems(String query) {
    setState(() {
      searchResults = products
          .where((product) =>
              product['name_product'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  final precioFormatter = NumberFormat.currency(symbol: '', locale: 'es_CO');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 80,
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(207, 248, 248, 248),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: TextField(
                        onChanged: searchItems,
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Buscar',
                          suffixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: searchResults.isNotEmpty ? searchResults.length : products.length,
                  itemBuilder: (BuildContext context, int index) {
                    final product = searchResults.isNotEmpty ? searchResults[index] : products[index];
                    return Card(
                      margin: const EdgeInsets.all(5),
                      child: Stack(
                        children: [
                          ListTile(
                            title: Row(
                              children: [
                                Container(
                                  width: 60, // Ancho fijo para el contenedor
                                  child: Icon(Icons.inventory_2, size: 50),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${product['name_product']}',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Cantidad: ${product['quantity']}',
                                    ),
                                    Text(
                                      'Precio: ${_formatPrice(product['cost_price'])}',
                                      style: TextStyle(fontSize: 16, color: Colors.purple),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 12,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 4,
                                    offset: Offset(0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                backgroundColor: product['state_product'] == 'Activo' ? Colors.green : Colors.red,
                                radius: 6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
            SlidingUpPanel(
            minHeight: calculateMinHeight(products),
            maxHeight: 500,
            panel: Column(
              children: [
              Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    GestureDetector(
      onTap: () {
        setState(() {
          isPanelOpen = !isPanelOpen;
        });
      },
      child: Container(
        width: 30,
        child: Icon(
          isPanelOpen ? Icons.arrow_downward : Icons.arrow_upward,
          color: Color.fromRGBO(102, 51, 153, 1),
          size: 30,
                      ),
                    ),
    ),
                  ],
                ),
                Text(
                  "Productos bajos de stock",
                  style: TextStyle(color: Colors.black),
                ),
                isPanelOpen
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            final cantidad = product['quantity'];
                            if (cantidad is int && cantidad < 6) {
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                child: ListTile(
                                  title: Text(product['name_product']),
                                  subtitle: Text('Cantidad: $cantidad'),
                                  trailing: Text(
                                    'Precio: ${_formatPrice(product['cost_price'])}',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          },
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
            onPanelOpened: () {
              setState(() {
                isPanelOpen = true;
              });
            },
            onPanelClosed: () {
              setState(() {
                isPanelOpen = false;
              });
            },
          ),
        ],
      ),
    );
  }

String _formatPrice(String price) {
  double parsedPrice = double.parse(price);
  NumberFormat formatter = NumberFormat.currency(locale: 'es_CO', decimalDigits: 0);
  String formattedPrice = formatter.format(parsedPrice);
  // Eliminar el símbolo "EUR" al final y agregar el símbolo "$" al principio
  return '\$$formattedPrice'.replaceAll('EUR', '');
}



  double calculateMinHeight(List<dynamic> products) {
    double totalHeight = 0;
    for (var product in products) {
      final cantidad = product['quantity'];
      if (cantidad is int && cantidad < 6) {
        totalHeight += 25; // Altura estimada de un ListTile
      }
    }
    return totalHeight;
  }
}

void main() {
  runApp(MaterialApp(
    home: ProductsScreen(),
  ));
}
