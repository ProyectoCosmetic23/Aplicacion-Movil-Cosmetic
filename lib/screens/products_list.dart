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
                          labelText: 'Buscar Producto',
                          suffixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: searchResults.isNotEmpty ? searchResults.length : products.length,
                  itemBuilder: (BuildContext context, int index) {
                    final product = searchResults.isNotEmpty ? searchResults[index] : products[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Row(
                          children: [
                            Icon(Icons.inventory_outlined),
                            SizedBox(width: 8),
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
                              ],
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Precio: ${_formatPrice(product['cost_price'])}',
                                  style: TextStyle(fontSize: 16, color: Colors.purple),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                            'Detalles Producto',
                                            style: TextStyle(
                                              color: Color.fromRGBO(102, 51, 153, 1),
                                            ),
                                          ),
                                          content: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Producto: ${product['name_product']}',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              Text(
                                                'Cantidad: ${product['quantity']}',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              Text(
                                                'Precio: ${_formatPrice(product['cost_price'])}',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              Text(
                                                'Estado: ${product['state_product']}',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                'Cerrar',
                                                style: TextStyle(
                                                  color: Color.fromRGBO(102, 51, 153, 1),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(primary: Color.fromRGBO(102, 51, 153, 1)),
                                  child: Text(
                                    'Detalles',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SlidingUpPanel(
            maxHeight: 250,
            panel: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      child: Divider(
                        color: Colors.black,
                        thickness: 2,
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
                              return ListTile(
                                title: Text(product['name_product'], style: TextStyle(color: Colors.black)),
                                subtitle: Text(cantidad.toString(), style: TextStyle(color: Colors.black)),
                                trailing: Text(
                                  'Precio: ${_formatPrice(product['cost_price'])}',
                                  style: TextStyle(color: Colors.black),
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
    return NumberFormat.currency(symbol: '', locale: 'es_CO').format(parsedPrice);
  }
}

void main() {
  runApp(MaterialApp(
    home: ProductsScreen(),
  ));
}
