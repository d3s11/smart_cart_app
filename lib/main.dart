import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const SmartCartApp(),
    ),
  );
}

// ============================================================
// MODEL PRODUCT
// ============================================================

class Product {
  final int id;
  final String name;
  final int price;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
  });
}

// ============================================================
// MODEL CART ITEM
// ============================================================

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  int get totalPrice {
    return product.price * quantity;
  }
}

// ============================================================
// STATE MANAGEMENT - CART PROVIDER
// ============================================================

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  // Mengambil daftar item keranjang
  List<CartItem> get items => _items;

  // ==========================================================
  // TAMBAH PRODUK KE KERANJANG
  // ==========================================================

  void addToCart(Product product) {
    final index = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    // Kalau produk sudah ada
    if (index >= 0) {
      _items[index].quantity++;
    }

    // Kalau produk belum ada
    else {
      _items.add(
        CartItem(
          product: product,
          quantity: 1,
        ),
      );
    }

    notifyListeners();
  }

  // ==========================================================
  // MENAMBAH JUMLAH
  // ==========================================================

  void increment(Product product) {
    final index = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  // ==========================================================
  // MENGURANGI JUMLAH
  // ==========================================================
  void decrement(Product product) {
    final index = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }

      notifyListeners();
    }
  }

  // ==========================================================
  // HAPUS PRODUK
  // ==========================================================

  void removeFromCart(Product product) {
    _items.removeWhere(
      (item) => item.product.id == product.id,
    );

    notifyListeners();
  }

  // ==========================================================
  // JUMLAH TOTAL ITEM
  // ==========================================================

  int get totalItems {
    int total = 0;

    for (var item in _items) {
      total += item.quantity;
    }

    return total;
  }

  // ==========================================================
  // TOTAL HARGA
  // ==========================================================

  int get totalPrice {
    int total = 0;

    for (var item in _items) {
      total += item.totalPrice;
    }

    return total;
  }
}

// ============================================================
// APLIKASI UTAMA
// ============================================================

class SmartCartApp extends StatelessWidget {
  const SmartCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Smart Cart',

      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Arial',
      ),

      home: const ProductPage(),
    );
  }
}

// ============================================================
// PRODUCT PAGE
// ============================================================

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  // ==========================================================
  // DAFTAR PRODUK
  // ==========================================================

  List<Product> get products {
  return [
    Product(
      id: 1,
      name: 'Nasi Jawa',
      price: 15000,
      image: 'assets/nasgor goreng.png',
    ),

    Product(
      id: 2,
      name: 'Ayam Bakar',
      price: 20000,
      image: 'assets/ayam bakar pedas.jpg.jpeg',
    ),

    Product(
      id: 3,
      name: 'Cumi Gurih',
      price: 35000,
      image: 'assets/cumi bakar.jpg.jpeg',
    ),

    Product(
      id: 4,
      name: 'Mie PB',
      price: 10000,
      image: 'assets/mie pedas.jpg.jpeg',
    ),

    Product(
      id: 5,
      name: 'Martabak Manis',
      price: 10000,
      image: 'assets/martabak.jpg.jpeg',
    ),

    Product(
      id: 6,
      name: 'Nasi Padang',
      price: 25000,
      image: 'assets/nasi padang.jpg.jpeg',
    ),
  ];
}

  // ==========================================================
  // FORMAT RUPIAH
  // ==========================================================

  String formatRupiah(int price) {
    return 'Rp${price.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFFEE9D12),
        elevation: 0,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Craving Station',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              'Temukan Makanan Favoritmu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),

        // ====================================================
        // ICON KERANJANG + BADGE
        // ====================================================

        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                    ),

                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const CartPage(),
                        ),
                      );
                    },
                  ),

                  // BADGE JUMLAH
                  if (cart.totalItems > 0)
                    Positioned(
                      right: 5,
                      top: 5,

                      child: Container(
                        padding: const EdgeInsets.all(4),

                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),

                        child: Text(
                          '${cart.totalItems}',

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),

      // ======================================================
      // GRID PRODUK
      // ======================================================

      body: GridView.builder(
        padding: const EdgeInsets.all(8),

        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,

          crossAxisSpacing: 6,

          mainAxisSpacing: 6,

          childAspectRatio: 0.72,
        ),

        itemCount: products.length,

        itemBuilder: (context, index) {
          final product = products[index];

          return Card(
            color: Colors.white,

            elevation: 2,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),

            child: Padding(
              padding: const EdgeInsets.all(6),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // =================================================
                  // GAMBAR
                  // =================================================

                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(6),

                      child: Image.asset(
                        product.image,

                        width: double.infinity,

                        fit: BoxFit.cover,

                        errorBuilder:
                            (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,

                            child: const Center(
                              child: Icon(
                                Icons.fastfood,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // =================================================
                  // NAMA
                  // =================================================

                  Text(
                    product.name,

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),

                  // =================================================
                  // HARGA
                  // =================================================

                  Text(
                    formatRupiah(product.price),

                    style: const TextStyle(
                      color: Color(0xFF8B5E22),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // =================================================
                  // TOMBOL TAMBAH
                  // =================================================

                  SizedBox(
                    width: double.infinity,
                    height: 30,

                    child: ElevatedButton(
                      onPressed: () {
                        context
                            .read<CartProvider>()
                            .addToCart(product);

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              '${product.name} ditambahkan',
                            ),

                            duration:
                                const Duration(seconds: 1),
                          ),
                        );
                      },

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF996A2A),

                        foregroundColor: Colors.white,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20),
                        ),

                        padding: EdgeInsets.zero,
                      ),

                      child: const Text(
                        'Tambah',

                        style: TextStyle(
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// CART PAGE
// ============================================================

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  // ==========================================================
  // FORMAT RUPIAH
  // ==========================================================

  String formatRupiah(int price) {
    return 'Rp${price.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFFEE9D12),

        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Keranjang',

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ======================================================
      // ISI KERANJANG
      // ======================================================

      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          // --------------------------------------------------
          // KALAU KOSONG
          // --------------------------------------------------

          if (cart.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 10),

                  Text(
                    'Keranjang masih kosong',

                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          // --------------------------------------------------
          // KALAU ADA ISI
          // --------------------------------------------------

          return ListView.builder(
            padding: const EdgeInsets.all(8),

            itemCount: cart.items.length,

            itemBuilder: (context, index) {
              final item = cart.items[index];

              return Container(
                margin:
                    const EdgeInsets.only(bottom: 10),

                padding: const EdgeInsets.all(7),

                decoration: BoxDecoration(
                  color: const Color(0xFFEE9D12),

                  borderRadius:
                      BorderRadius.circular(8),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.grey.withOpacity(0.35),

                      blurRadius: 3,

                      offset: const Offset(1, 2),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    // ========================================
                    // GAMBAR
                    // ========================================

                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(7),

                      child: Image.asset(
                        item.product.image,

                        width: 65,

                        height: 65,

                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(width: 8),

                    // ========================================
                    // NAMA + HARGA + JUMLAH
                    // ========================================

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Text(
                            item.product.name,

                            style:
                                const TextStyle(
                              color: Colors.white,

                              fontWeight:
                                  FontWeight.bold,

                              fontSize: 13,
                            ),
                          ),

                          Text(
                            formatRupiah(
                              item.product.price,
                            ),

                            style:
                                const TextStyle(
                              color: Colors.white,

                              fontSize: 10,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // ==================================
                          // TOMBOL - JUMLAH +
                          // ==================================

                          Row(
                            children: [
                              // MINUS
                              GestureDetector(
                                onTap: () {
                                  context
                                      .read<
                                          CartProvider>()
                                      .decrement(
                                        item.product,
                                      );
                                },

                                child: const Icon(
                                  Icons
                                      .remove_circle_outline,

                                  color:
                                      Colors.white,

                                  size: 18,
                                ),
                              ),

                              const SizedBox(
                                width: 12,
                              ),

                              // JUMLAH
                              Text(
                                '${item.quantity}',

                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,

                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(
                                width: 12,
                              ),

                              // PLUS
                              GestureDetector(
                                onTap: () {
                                  context
                                      .read<
                                          CartProvider>()
                                      .increment(
                                        item.product,
                                      );
                                },

                                child: const Icon(
                                  Icons
                                      .add_circle_outline,

                                  color:
                                      Colors.white,

                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ========================================
                    // DELETE + TOTAL
                    // ========================================

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,

                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,

                          constraints:
                              const BoxConstraints(),

                          icon: const Icon(
                            Icons.delete,

                            color: Colors.red,

                            size: 18,
                          ),

                          onPressed: () {
                            context
                                .read<CartProvider>()
                                .removeFromCart(
                                  item.product,
                                );
                          },
                        ),

                        const SizedBox(height: 20),

                        Text(
                          formatRupiah(
                            item.totalPrice,
                          ),

                          style:
                              const TextStyle(
                            color: Colors.white,

                            fontSize: 10,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      // ======================================================
      // TOTAL BELANJA + CHECKOUT
      // ======================================================

      bottomNavigationBar:
          Consumer<CartProvider>(
        builder: (context, cart, child) {
          return Container(
            padding:
                const EdgeInsets.fromLTRB(
              12,
              12,
              12,
              16,
            ),

            decoration: const BoxDecoration(
              color: Color(0xFFEE9D12),
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                // ============================================
                // TOTAL
                // ============================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    const Text(
                      'Total Belanja',

                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 16,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    Text(
                      formatRupiah(
                        cart.totalPrice,
                      ),

                      style: const TextStyle(
                        color: Colors.white,

                        fontSize: 20,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ============================================
                // CHECKOUT
                // ============================================

                SizedBox(
                  width: double.infinity,

                  height: 40,

                  child: ElevatedButton(
                    onPressed: cart.items.isEmpty
                        ? null
                        : () {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Checkout berhasil!',
                                ),
                              ),
                            );
                          },

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF996A2A),

                      foregroundColor:
                          Colors.white,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(7),
                      ),
                    ),

                    child: const Text(
                      'Checkout',

                      style: TextStyle(
                        fontSize: 15,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}