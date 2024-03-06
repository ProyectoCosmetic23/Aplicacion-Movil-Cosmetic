import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'detail_purchase.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({Key? key}) : super(key: key);

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> purchases = [];
  List<dynamic> searchResults = [];

  var purchaseId = 0;
  String editedEstado = '';
  bool isPanelOpen = false;

  @override
  void initState() {
    super.initState();
    fetchPurchases();
  }

  Future<String> getAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';

    return token;
  }

  Future<void> fetchPurchases() async {
    final String token = await getAuthToken();
    final response = await http.get(
      Uri.parse('https://cosmetic-api-yrcb.onrender.com/api/purchases'),
      headers: {
        'X-Token': '$token',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        purchases = json.decode(response.body).toList();
        searchResults = purchases; // Initialize searchResults with all purchases
      });
    } else {
      print('Error en la respuesta HTTP: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');
      throw Exception('Error al cargar la lista de compras');
    }
  }

  void searchItems(String query) {
    setState(() {
      searchResults = purchases
          .where((purchase) =>
              purchase['name_provider'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  final precioFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '');

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
                Column(
                  children: searchResults.map((purchase) {
                    var state_purchase;
                    return GestureDetector(
                      onTap: () {
                        purchaseId = purchase['id_purchase'];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PurchaseDetailScreen(purchaseId: purchaseId),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.all(5),
                        child: Stack(
                          children: [
                            ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'No: ${purchase['invoice_number'] ?? 'N/A'}',
                                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Proveedor: ${purchase['provider']['name_provider'] ?? 'N/A'}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Fecha: ${purchase['purchase_date'] != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(purchase['purchase_date'])) : 'N/A'}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Valor: ${purchase['total_purchase'] == null ? 'N/A' : _formatPrice(purchase['total_purchase'])}',
                                    style: TextStyle(fontSize: 16, color: Colors.purple),
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
                                  backgroundColor: purchase['state_purchase'] ? Colors.green : Colors.red,
                                  radius: 6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(String? price) {
    if (price == null) return 'N/A';
    double parsedPrice = double.parse(price);
    NumberFormat formatter = NumberFormat.currency(locale: 'es_CO', decimalDigits: 0);
    String formattedPrice = formatter.format(parsedPrice);
    // Eliminar el símbolo "EUR" al final y agregar el símbolo "$" al principio
    return '\$$formattedPrice'.replaceAll('EUR', '');
  }
}

void main() {
  runApp(MaterialApp(
    home: PurchasesScreen(),
  ));
}
