import 'dart:convert';
import 'package:consumir_api/models/purchase_model.dart';
import 'package:consumir_api/widgets/menu_appbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

String formatDate(dynamic date) {
  try {
    if (date != null) {
      final cleanDate = date.toString().split(' ')[0];
      final formattedDate = DateFormat('yyyy-MM-dd').parse(cleanDate);
      return DateFormat('dd/MM/yyyy').format(formattedDate);
    } else {
      return 'N/A'; // Retornar un valor predeterminado si la fecha es nula
    }
  } catch (e) {
    print('Error parsing date: $e');
    return 'Fecha inválida';
  }
}

String _formatPrice(String? price) {
  if (price == null) return 'N/A';
  double parsedPrice = double.parse(price);
  NumberFormat formatter =
      NumberFormat.currency(locale: 'es_CO', decimalDigits: 0);
  String formattedPrice = formatter.format(parsedPrice);
  // Eliminar el símbolo "EUR" al final y agregar el símbolo "$" al principio
  return '\$$formattedPrice'.replaceAll('EUR', '');
}

class PurchaseDetailScreen extends StatefulWidget {
  final int purchaseId;

  const PurchaseDetailScreen({required this.purchaseId, Key? key})
      : super(key: key);

  @override
  State<PurchaseDetailScreen> createState() => _PurchaseDetailScreenState();
}

class _PurchaseDetailScreenState extends State<PurchaseDetailScreen> {
  Map<String, dynamic> purchases = {};

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
      Uri.parse(
          'https://cosmetic-api-yrcb.onrender.com/api/purchases/${widget.purchaseId}'),
      headers: {
        'X-Token': '$token',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        purchases = json.decode(response.body);
      });
    } else {
      print('Error en la respuesta HTTP: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');
      throw Exception('Error al cargar la lista de compras');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MenuAppbar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              children: [
                Text('No: ',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Text('${purchases['invoice_number'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 14)),
              ],
            ),
            Row(
              children: [
                Text('Proveedor:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Text('${purchases?['provider']?['name_provider'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 14)),
              ],
            ),
            Row(
              children: [
                Text('Fecha de Compra: ',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Text('${formatDate(purchases?['purchase_date'])}',
                    style: TextStyle(fontSize: 14)),
              ],
            ),
            Row(
              children: [
                Text('Fecha de Registro: ',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Text(
                  '${formatDate(purchases?['record_date_purchase']) ?? 'N/A'}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            Row(
              children: [
                Text('Total de Compra:',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.purple,
                        fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Text(
                  '${_formatPrice(purchases?['total_purchase']) ?? 'N/A'}',
                  style: TextStyle(fontSize: 18, color: Colors.purple),
                ),
              ],
            ),
            SizedBox(
                height:
                    15), // Espacio entre el contenido anterior y la línea separadora
            Divider(), // Línea separadora
            SizedBox(height: 15), // Espacio entre la línea separadora y el Card

            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Detalles',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        SizedBox(
                            height:
                                20), // Espacio entre el título y los detalles del producto
                        ...(purchases?['purchase_details'] as List<dynamic>?)
                                ?.map((productDetail) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // Alinear los elementos al inicio
                                    children: [
                                      Icon(Icons.inventory_2,
                                          size: 50), // Icono más grande
                                      SizedBox(
                                          width:
                                              8), // Espacio entre el icono y la información del producto
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start, // Alinear los elementos al inicio
                                        children: [
                                          Text(
                                            'Producto:  ${(purchases?['purchase_details'] as List<dynamic>?)?.isNotEmpty ?? false ? (purchases?['purchase_details'] as List<dynamic>?)?.first['product']['name_product'] ?? 'N/A' : 'N/A'}',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                              'Precio de Compra: ${productDetail['cost_price']}',
                                              style: TextStyle(fontSize: 14)),
                                          Text(
                                              'Precio de IVA: ${productDetail['vat']}',
                                              style: TextStyle(fontSize: 14)),
                                          Text(
                                              'Precio de Venta: ${productDetail['selling_price']}',
                                              style: TextStyle(fontSize: 14)),
                                          Text(
                                              'Cantidad: ${productDetail['product_quantity']}',
                                              style: TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          20), // Espacio entre los detalles de los productos
                                ],
                              );
                            })?.toList() ??
                            [],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
