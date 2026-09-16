import 'product.dart';

class CartItem {
  final String id;
  final String productId;
  final String name;
  final double price;
  final String image;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'].toString(),
      productId: map['product_id'].toString(),
      name: map['name'].toString(),
      price: (map['price'] as num).toDouble(),
      image: getProductImage(map['product_id'].toString()),
      quantity: (map['quantity'] as num).toInt(),
    );
  }

  double get totalPrice => price * quantity;

  // Supaya kode lama main.dart yang memakai item.product tetap bisa digunakan
  Product get product {
    return Product(
      id: productId,
      name: name,
      price: price,
      description: '',
      image: image,
    );
  }
}

// Gambar tidak disimpan ke SQLite.
// Gambar ditentukan berdasarkan ID produk.
String getProductImage(String productId) {
  switch (productId) {
    case '1':
      return 'assets/nasgor goreng.png';
    case '2':
      return 'assets/ayam bakar pedas.jpg.jpeg';
    case '3':
      return 'assets/cumi bakar.jpg.jpeg';
    case '4':
      return 'assets/mie pedas.jpg.jpeg';
    case '5':
      return 'assets/martabak.jpg.jpeg';
    case '6':
      return 'assets/nasi padang.jpg.jpeg';
    default:
      return '';
  }
}