class Purchase {
  final String id;
  final String invoiceNumber;
  final String purchaseDate;
  final String observation;
  final double total;
  final List<Product> products;

  Purchase({
    required this.id,
    required this.invoiceNumber,
    required this.purchaseDate,
    required this.observation,
    required this.total,
    required this.products,
  });
}

class Product {
  final String id;
  final String name;
  final double costPrice;
  final double sellingPrice;
  final double vat;
  final int quantity;

  Product({
    required this.id,
    required this.name,
    required this.costPrice,
    required this.sellingPrice,
    required this.vat,
    required this.quantity,
  });
}

