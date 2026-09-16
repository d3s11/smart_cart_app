class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
  });

  // Data yang disimpan ke SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
    };
  }

  // Data dari SQLite menjadi object Product
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'].toString(),
      name: map['name'].toString(),
      price: (map['price'] as num).toDouble(),
      description: map['description'] ?? '',
      image: getProductImage(map['id'].toString()),
    );
  }
}
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