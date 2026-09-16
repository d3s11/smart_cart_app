import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/product.dart';
import 'models/cart_item.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CartProvider()..loadCart(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProductProvider(),
        ),
      ],
      child: const SmartCartApp(),
    ),
  );
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

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  bool _isLoading = true;
  String? _error;

  // ==========================================================
  // PRODUK DEFAULT
  // ==========================================================

  final List<Product> defaultProducts = [
    Product(
      id: '1',
      name: 'Nasi Jawa',
      price: 15000,
      description: 'Nasi Jawa',
      image: 'assets/nasgor goreng.png',
    ),
    Product(
      id: '2',
      name: 'Ayam Bakar',
      price: 20000,
      description: 'Ayam Bakar',
      image: 'assets/ayam bakar pedas.jpg.jpeg',
    ),
    Product(
      id: '3',
      name: 'Cumi Gurih',
      price: 35000,
      description: 'Cumi Gurih',
      image: 'assets/cumi bakar.jpg.jpeg',
    ),
    Product(
      id: '4',
      name: 'Mie PB',
      price: 10000,
      description: 'Mie PB',
      image: 'assets/mie pedas.jpg.jpeg',
    ),
    Product(
      id: '5',
      name: 'Martabak Manis',
      price: 10000,
      description: 'Martabak Manis',
      image: 'assets/martabak.jpg.jpeg',
    ),
    Product(
      id: '6',
      name: 'Nasi Padang',
      price: 25000,
      description: 'Nasi Padang',
      image: 'assets/nasi padang.jpg.jpeg',
    ),
  ];

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prepareProducts();
    });
  }

  // ==========================================================
  // LOAD DATA + SEED PRODUK DEFAULT
  // ==========================================================

  Future<void> _prepareProducts() async {
    try {
      final provider = context.read<ProductProvider>();

      await provider.seedDefaultProducts(defaultProducts);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  // ==========================================================
  // FORMAT RUPIAH
  // ==========================================================

  String formatRupiah(double price) {
    return 'Rp${price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }

  // ==========================================================
  // FORM TAMBAH PRODUK
  // ==========================================================

  Future<void> _showAddProductForm() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return const AddProductDialog();
      },
    );

    if (!mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil ditambahkan'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // ==========================================================
  // BUILD PRODUCT PAGE
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

        actions: [
          // ==================================================
          // ICON CART
          // ==================================================

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
                          builder: (context) => const CartPage(),
                        ),
                      );
                    },
                  ),

                  // =================================================
                  // JUMLAH ITEM CART
                  // =================================================

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
      // DAFTAR PRODUK
      // ======================================================

      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final products = productProvider.products;

          // ==================================================
          // LOADING
          // ==================================================

          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ==================================================
          // ERROR
          // ==================================================

          if (_error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Terjadi error:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // ==================================================
          // DATA KOSONG
          // ==================================================

          if (products.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada produk',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            );
          }

          // ==================================================
          // GRID PRODUK
          // ==================================================

          return GridView.builder(
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
                      // ==========================================
                      // GAMBAR PRODUK
                      // ==========================================

                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(6),

                          child: product.image.isNotEmpty
                              ? Image.asset(
                                  product.image,
                                  width: double.infinity,
                                  fit: BoxFit.cover,

                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    return Container(
                                      width: double.infinity,
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
                                )
                              : Container(
                                  width: double.infinity,
                                  color: Colors.grey.shade200,

                                  child: const Center(
                                    child: Icon(
                                      Icons.fastfood,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // ==========================================
                      // NAMA
                      // ==========================================

                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),

                      // ==========================================
                      // HARGA
                      // ==========================================

                      Text(
                        formatRupiah(product.price),

                        style: const TextStyle(
                          color: Color(0xFF8B5E22),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(height: 5),

                      // ==========================================
                      // TOMBOL TAMBAH KE CART
                      // ==========================================

                      SizedBox(
                        width: double.infinity,
                        height: 30,

                        child: ElevatedButton(
                          onPressed: () async {
                            final cartItem = CartItem(
                              id: product.id,
                              productId: product.id,
                              name: product.name,
                              price: product.price,
                              image: product.image,
                              quantity: 1,
                            );

                            await context
                                .read<CartProvider>()
                                .addToCart(cartItem);

                            if (!context.mounted) return;

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
          );
        },
      ),

      // ======================================================
      // FAB TAMBAH PRODUK
      // ======================================================

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductForm,

        backgroundColor: const Color(0xFF996A2A),
        foregroundColor: Colors.white,

        child: const Icon(Icons.add),
      ),
    );
  }
}

// ============================================================
// DIALOG TAMBAH PRODUK
// ============================================================
//
// Controller dibuat di dalam StatefulWidget dialog.
// Jadi controller hanya hidup selama form masih terbuka.
// Ini mencegah masalah controller ter-dispose ketika dialog
// masih melakukan animasi/rebuild.
//

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() =>
      _AddProductDialogState();
}

class _AddProductDialogState
    extends State<AddProductDialog> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController priceController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  bool _isSaving = false;

  // ==========================================================
  // DISPOSE CONTROLLER
  // ==========================================================

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  // ==========================================================
  // SIMPAN PRODUK
  // ==========================================================

  Future<void> _saveProduct() async {
    final name = nameController.text.trim();

    final price =
        double.tryParse(priceController.text.trim());

    final description =
        descriptionController.text.trim();

    // ========================================================
    // VALIDASI
    // ========================================================

    if (name.isEmpty || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nama produk dan harga wajib diisi!',
          ),
        ),
      );

      return;
    }

    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harga harus lebih dari 0!',
          ),
        ),
      );

      return;
    }

    // ========================================================
    // CEGAH DOUBLE TAP
    // ========================================================

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final productProvider =
          context.read<ProductProvider>();

      // ======================================================
      // ID PRODUK BARU
      // ======================================================

      final id =
          DateTime.now().millisecondsSinceEpoch.toString();

      // ======================================================
      // BUAT PRODUK
      // ======================================================

      final newProduct = Product(
        id: id,
        name: name,
        price: price,
        description: description,
        image: '',
      );

      // ======================================================
      // SIMPAN KE SQLITE
      // ======================================================

      await productProvider.addProduct(newProduct);

      if (!mounted) return;

      // ======================================================
      // TUTUP DIALOG
      // ======================================================

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan produk: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // BUILD DIALOG
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Tambah Produk',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            // ==================================================
            // NAMA
            // ==================================================

            TextField(
              controller: nameController,

              textInputAction:
                  TextInputAction.next,

              decoration: const InputDecoration(
                labelText: 'Nama Produk',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fastfood),
              ),
            ),

            const SizedBox(height: 12),

            // ==================================================
            // HARGA
            // ==================================================

            TextField(
              controller: priceController,

              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),

              decoration: const InputDecoration(
                labelText: 'Harga',
                hintText: 'Contoh: 15000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payments),
              ),
            ),

            const SizedBox(height: 12),

            // ==================================================
            // DESKRIPSI
            // ==================================================

            TextField(
              controller: descriptionController,

              maxLines: 3,

              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
          ],
        ),
      ),

      // ========================================================
      // BUTTON
      // ========================================================

      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.pop(context, false);
                },

          child: const Text('Batal'),
        ),

        ElevatedButton(
          onPressed: _isSaving
              ? null
              : _saveProduct,

          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFF996A2A),
            foregroundColor: Colors.white,
          ),

          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Simpan'),
        ),
      ],
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

  String formatRupiah(double price) {
    return 'Rp${price.toInt().toString().replaceAllMapped(
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
      // ISI CART
      // ======================================================

      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          // ==================================================
          // CART KOSONG
          // ==================================================

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
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // ==================================================
          // LIST CART
          // ==================================================

          return ListView.builder(
            padding: const EdgeInsets.all(10),

            itemCount: cart.items.length,

            itemBuilder: (context, index) {
              final item = cart.items[index];

              return Card(
                color: Colors.white,

                margin:
                    const EdgeInsets.only(bottom: 10),

                elevation: 2,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(8),

                  child: Row(
                    children: [
                      // ========================================
                      // GAMBAR
                      // ========================================

                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(8),

                        child: item.product.image.isNotEmpty
                            ? Image.asset(
                                item.product.image,

                                width: 70,
                                height: 70,

                                fit: BoxFit.cover,

                                errorBuilder:
                                    (context,
                                        error,
                                        stackTrace) {
                                  return Container(
                                    width: 70,
                                    height: 70,
                                    color:
                                        Colors.grey.shade200,

                                    child: const Icon(
                                      Icons.fastfood,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                width: 70,
                                height: 70,
                                color:
                                    Colors.grey.shade200,

                                child: const Icon(
                                  Icons.fastfood,
                                  color: Colors.grey,
                                ),
                              ),
                      ),

                      const SizedBox(width: 10),

                      // ========================================
                      // INFO PRODUK
                      // ========================================

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            Text(
                              item.product.name,

                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,

                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              formatRupiah(
                                item.product.price,
                              ),

                              style:
                                  const TextStyle(
                                color:
                                    Color(0xFF8B5E22),
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ==================================
                            // QUANTITY
                            // ==================================

                            Row(
                              children: [
                                // ==============================
                                // MINUS
                                // ==============================

                                IconButton(
                                  onPressed: () {
                                    context
                                        .read<CartProvider>()
                                        .decrement(item.id);
                                  },

                                  icon: const Icon(
                                    Icons
                                        .remove_circle_outline,
                                  ),

                                  iconSize: 22,

                                  padding:
                                      EdgeInsets.zero,

                                  constraints:
                                      const BoxConstraints(),
                                ),

                                // ==============================
                                // JUMLAH
                                // ==============================

                                Padding(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 8,
                                  ),

                                  child: Text(
                                    '${item.quantity}',

                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),

                                // ==============================
                                // PLUS
                                // ==============================

                                IconButton(
                                  onPressed: () {
                                    context
                                        .read<CartProvider>()
                                        .increment(item.id);
                                  },

                                  icon: const Icon(
                                    Icons
                                        .add_circle_outline,
                                  ),

                                  iconSize: 22,

                                  padding:
                                      EdgeInsets.zero,

                                  constraints:
                                      const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ========================================
                      // HAPUS
                      // ========================================

                      IconButton(
                        onPressed: () {
                          context
                              .read<CartProvider>()
                              .removeFromCart(item.id);

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Item dihapus dari keranjang'),
                              duration:
                                  Duration(seconds: 1),
                            ),
                          );
                        },

                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      // ======================================================
      // TOTAL + CHECKOUT
      // ======================================================

      bottomNavigationBar:
          Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return const SizedBox.shrink();
          }

          return Container(
            padding: const EdgeInsets.all(15),

            decoration: const BoxDecoration(
              color: Colors.white,

              boxShadow: [
                BoxShadow(
                  blurRadius: 5,
                  color: Colors.black12,
                ),
              ],
            ),

            child: SafeArea(
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
                        'Total',

                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      Text(
                        formatRupiah(
                          cart.totalPrice,
                        ),

                        style:
                            const TextStyle(
                          color:
                              Color(0xFF8B5E22),
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ============================================
                  // CHECKOUT
                  // ============================================

                  SizedBox(
                    width: double.infinity,
                    height: 45,

                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Menu checkout belum dibuat.',
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
                              BorderRadius.circular(10),
                        ),
                      ),

                      child: const Text(
                        'Checkout',

                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
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