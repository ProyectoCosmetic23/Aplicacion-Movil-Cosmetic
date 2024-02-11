import 'dart:convert';
import 'package:consumir_api/widgets/menu_appbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

String formatDate(DateTime? date) {
  return date == null ? 'N/A' : DateFormat('dd/MM/yyyy').format(date);
}

String formatCurrency(dynamic amount) {
  if (amount == null) return 'N/A';

  double? numericAmount = amount is String ? double.tryParse(amount) : amount is num ? amount.toDouble() : amount;
  if (numericAmount == null) return 'N/A';

  final colombianPesoFormat = NumberFormat.currency(locale: 'es_CO', symbol: 'COP');
  return colombianPesoFormat.format(numericAmount);
}




class PurchaseDetailScreen extends StatefulWidget {
  final int purchaseId;

  const PurchaseDetailScreen({required this.purchaseId, Key? key}) : super(key: key);

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
      Uri.parse('https://cosmetic-api-yrcb.onrender.com/api/purchases/${widget.purchaseId}'),
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
           
          const SizedBox(height: 10),
            Row(
              children: [
                Text('Fecha de Compra: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold ),
              ),
                SizedBox(width: 10),
                Text('${purchases?['purchase_date'] ?? 'N/A'}',style: TextStyle(fontSize: 18))
              ],), 
            Row(
              children: [
                Text('Fecha de Registro:', style: TextStyle(fontSize: 18 ,fontWeight: FontWeight.bold),),
                SizedBox(width: 10),
                Text(
                '${formatDate(DateTime.parse(purchases?['record_date_purchase'])) ?? 'N/A'}',
                style: TextStyle(fontSize: 18),
              )

              ],) ,
            Row(
              children: [
                Text('Proveedor:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                SizedBox(width: 10),
                Text('${purchases?['provider']['name_provider'] ?? 'N/A'}',style: TextStyle(fontSize: 18))
              ],) ,
            Container(
            width: 200,
            child: Wrap(
              children: [
                Text('Observación:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                SizedBox(width: 10),
                Text(
                  '${purchases?['observation_purchase'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 18),
                  overflow: TextOverflow.clip,
                  softWrap: true,
                ),
              ],
            ),
          ),
            Row(
              children: [
                Text('Total de Compra:', style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                SizedBox(width: 10),
               Text(
              '${formatCurrency(purchases?['total_purchase']) ?? 'N/A'}',
              style: TextStyle(fontSize: 18),
            )
              ],
            ) ,
            SizedBox(height: 15),
  
           Expanded(
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      columns: [
        DataColumn(label: Text('Producto',style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Categoría' ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold) ,)),
        DataColumn(label: Text('Precio de Compra',style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),)),
        DataColumn(label: Text('Precio de IVA',style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Precio de Venta',style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Cantidad',style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
      ],
      rows: List<DataRow>.generate(
        (purchases?['purchase_details'] as List<dynamic>?)?.length ?? 0,
        (index) {
          final productDetail = (purchases?['purchase_details'] as List<dynamic>?)?.elementAt(index);

          if (productDetail == null) {
            return DataRow(cells: []);
          }

          return DataRow(
            cells: [
              DataCell(Text('${productDetail['id_product']}')),
              DataCell(Text('${productDetail['id_category']}')),
              DataCell(Text('${productDetail['cost_price']}')),
              DataCell(Text('${productDetail['vat']}')),
              DataCell(Text('${productDetail['selling_price']}')),
              DataCell(Text('${productDetail['product_quantity']}')),
            ],
          );
        },
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
