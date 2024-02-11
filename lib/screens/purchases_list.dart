import 'dart:convert';

import 'package:consumir_api/screens/detail_purchase.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({Key? key}) : super(key: key);

  @override
  State<PurchasesScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<PurchasesScreen> {
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
    purchases = json.decode(response.body)
        .toList();
      
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
        purchase['']['name_provider'].toLowerCase().contains(query.toLowerCase()))
    .toList()
    ..sort((a, b) => b['id_purchase'].compareTo(a['id_purchase']));
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
                          labelText: 'Buscar Compras',
                          suffixIcon: Icon(Icons.search),
                    ),
                  ),
                      
                      ),
                  
                 
                ),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                     const Row(
                        children: [
                           Text("Fecha", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(width: 60),
                           Text("Proveedor", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(width: 60),
                          Text("Valor", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),

                      const SizedBox(height: 10),
                      for (final purchase in searchResults.isNotEmpty ? searchResults : purchases)
                        GestureDetector(
                        onTap: () {
                          purchaseId = purchase['id_purchase'];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PurchaseDetailScreen(purchaseId: purchaseId),
                            ),
                          );
                        },

                          child: Container(
                             width: 320,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color.fromARGB(255, 170, 170, 170),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 100,
                                  child:  Text(
                                      ' ${DateFormat('dd/MM/yyyy').format(DateTime.parse(purchase['purchase_date']))}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                ),
                                Container(
                                  width: 100,
                                  child: Text(
                                  ' ${purchase['provider']['name_provider'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                ),
                                Container(
                                  width: 100,
                                  child: Text(
                                  ' ${purchase['total_purchase'] == null ? 'N/A' : precioFormatter.format(double.parse(purchase['total_purchase']))}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                ),
                                                   
                              ],
                            ),
                          ), 
                        ),
                         
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
      ],
    ),
  );
}


}