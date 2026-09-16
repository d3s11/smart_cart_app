import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();

  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('smart_cart.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabel master produk
    await db.execute('''
      CREATE TABLE master_products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT
      )
    ''');

    // Tabel keranjang lokal
    await db.execute('''
      CREATE TABLE local_cart (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL
      )
    ''');
  }
  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await database;

    return await db.insert(
      'master_products',
      product,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await database;

    return await db.query('master_products');
  }
  Future<int> insertCart(Map<String, dynamic> cartItem) async {
    final db = await database;

    return await db.insert(
      'local_cart',
      cartItem,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await database;

    return await db.query('local_cart');
  }

  Future<int> updateCartQuantity(
    String id,
    int quantity,
  ) async {
    final db = await database;

    return await db.update(
      'local_cart',
      {
        'quantity': quantity,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCartItem(String id) async {
    final db = await database;

    return await db.delete(
      'local_cart',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}