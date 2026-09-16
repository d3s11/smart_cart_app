import 'package:flutter/material.dart';
import '../db_helper.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper.instance;

  List<Product> _products = [];

  List<Product> get products => _products;

  // ==========================================================
  // MENGAMBIL PRODUK DARI SQLITE
  // ==========================================================

  Future<void> loadProducts() async {
    final data = await _dbHelper.getProducts();

    _products = data.map((item) {
      return Product.fromMap(item);
    }).toList();

    notifyListeners();
  }

  // ==========================================================
  // MENAMBAHKAN SATU PRODUK
  // ==========================================================

  Future<void> addProduct(Product product) async {
    await _dbHelper.insertProduct(product.toMap());
    await loadProducts();
  }

  // ==========================================================
  // MENAMBAHKAN PRODUK DEFAULT SEKALIGUS
  // ==========================================================

  Future<void> seedDefaultProducts(
    List<Product> defaultProducts,
  ) async {
    await loadProducts();

    final existingIds = _products
        .map((product) => product.id)
        .toSet();

    for (final product in defaultProducts) {
      if (!existingIds.contains(product.id)) {
        await _dbHelper.insertProduct(product.toMap());
      }
    }

    // Setelah semua selesai, baru load sekali
    await loadProducts();
  }
}