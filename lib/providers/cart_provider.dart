import 'package:flutter/material.dart';
import '../db_helper.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper.instance;

  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  // Mengambil semua item cart dari SQLite
  Future<void> loadCart() async {
    final data = await _dbHelper.getCartItems();

    _items = data.map((item) {
      return CartItem.fromMap(item);
    }).toList();

    notifyListeners();
  }

  // Menambahkan item ke cart
  Future<void> addToCart(CartItem item) async {
    final index = _items.indexWhere(
      (cartItem) => cartItem.productId == item.productId,
    );

    if (index != -1) {
      // Kalau produk sudah ada, tambah quantity
      final newQuantity = _items[index].quantity + item.quantity;

      _items[index].quantity = newQuantity;

      await _dbHelper.updateCartQuantity(
        _items[index].id,
        newQuantity,
      );
    } else {
      // Kalau belum ada, masukkan item baru
      await _dbHelper.insertCart(item.toMap());
      _items.add(item);
    }

    notifyListeners();
  }

  // Menambah quantity
  Future<void> increment(String id) async {
    final index = _items.indexWhere(
      (item) => item.id == id,
    );

    if (index != -1) {
      _items[index].quantity++;

      await _dbHelper.updateCartQuantity(
        id,
        _items[index].quantity,
      );

      notifyListeners();
    }
  }

  // Mengurangi quantity
  Future<void> decrement(String id) async {
    final index = _items.indexWhere(
      (item) => item.id == id,
    );

    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;

        await _dbHelper.updateCartQuantity(
          id,
          _items[index].quantity,
        );
      } else {
        await removeFromCart(id);
        return;
      }

      notifyListeners();
    }
  }

  // Menghapus item dari cart
  Future<void> removeFromCart(String id) async {
    await _dbHelper.deleteCartItem(id);

    _items.removeWhere(
      (item) => item.id == id,
    );

    notifyListeners();
  }

  // Total jumlah barang
  int get totalItems {
    return _items.fold(
      0,
      (total, item) => total + item.quantity,
    );
  }

  // Total harga semua barang
  double get totalPrice {
    return _items.fold(
      0,
      (total, item) => total + item.totalPrice,
    );
  }
}