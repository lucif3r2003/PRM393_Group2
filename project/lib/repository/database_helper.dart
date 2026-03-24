import 'package:path/path.dart';
import 'package:project/entity/order.dart';
import 'package:project/entity/order_queue_item.dart';
import 'package:project/entity/table.dart' as entity;
import 'package:project/entity/user.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cafeteria_system.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 2,
      onConfigure: _onConfigure,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS OrderDetails');
    await db.execute('DROP TABLE IF EXISTS MealOrders');
    await db.execute('DROP TABLE IF EXISTS Ingredients');
    await db.execute('DROP TABLE IF EXISTS Products');
    await db.execute('DROP TABLE IF EXISTS DiningTables');
    await db.execute('DROP TABLE IF EXISTS Users');
    await _createDB(db, newVersion);
  }

  Future<void> _createDB(Database db, int version) async {
    const idAuto = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE Users (
        UserID $idAuto,
        Username TEXT UNIQUE NOT NULL,
        Password $textType,
        FullName $textType,
        Role $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE DiningTables (
        TableID $idAuto,
        TableName $textType,
        Status $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE Products (
        ProductID $idAuto,
        ProductName $textType,
        Category $textType,
        Price $realType,
        Description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Ingredients (
        IngredientID $idAuto,
        IngredientName $textType,
        StockQuantity $realType,
        Unit $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE MealOrders (
        OrderID $idAuto,
        TableID $intType,
        WaiterID $intType,
        TotalAmount $realType,
        Status $textType,
        CreatedAt $textType,
        FOREIGN KEY (TableID) REFERENCES DiningTables (TableID),
        FOREIGN KEY (WaiterID) REFERENCES Users (UserID)
      )
    ''');

    await db.execute('''
      CREATE TABLE OrderDetails (
        OrderDetailID $idAuto,
        OrderID $intType,
        ProductID $intType,
        Quantity $intType,
        Note TEXT,
        FOREIGN KEY (OrderID) REFERENCES MealOrders (OrderID) ON DELETE CASCADE,
        FOREIGN KEY (ProductID) REFERENCES Products (ProductID)
      )
    ''');

    await _seedUsers(db);
    await _seedTables(db);
    await _seedProducts(db);
  }

  Future<void> _seedUsers(Database db) async {
    final users = [
      {
        'Username': 'admin',
        'Password': '123',
        'FullName': 'Quản lý cửa hàng',
        'Role': 'Admin',
      },
      {
        'Username': 'waiter1',
        'Password': '123',
        'FullName': 'Nhân viên phục vụ 1',
        'Role': 'Waiter',
      },
      {
        'Username': 'bar1',
        'Password': '123',
        'FullName': 'Nhân viên pha chế',
        'Role': 'Bartender',
      },
    ];

    for (final user in users) {
      await db.insert('Users', user);
    }
  }

  Future<void> _seedTables(Database db) async {
    final tables = [
      {'TableName': 'Bàn 1', 'Status': 'Empty'},
      {'TableName': 'Bàn 2', 'Status': 'Empty'},
      {'TableName': 'Bàn 3', 'Status': 'Empty'},
      {'TableName': 'Bàn 4', 'Status': 'Occupied'},
      {'TableName': 'Bàn 5', 'Status': 'Occupied'},
      {'TableName': 'Bàn 6', 'Status': 'Reserved'},
      {'TableName': 'Bàn 7', 'Status': 'Reserved'},
      {'TableName': 'Bàn 8', 'Status': 'Empty'},
    ];

    for (final table in tables) {
      await db.insert('DiningTables', table);
    }
  }

  Future<void> _seedProducts(Database db) async {
    await db.execute('''
      INSERT INTO Products (ProductName, Category, Price, Description) VALUES
      ('Cà phê Đen', 'Cà phê', 25000, 'Cà phê rang xay nguyên chất đậm đà'),
      ('Cà phê Sữa', 'Cà phê', 29000, 'Cà phê hòa quyện cùng sữa đặc béo ngậy'),
      ('Bạc Xỉu', 'Cà phê', 32000, 'Nhiều sữa ít cà phê, hương vị nhẹ nhàng'),
      ('Cappuccino', 'Cà phê', 45000, 'Cà phê Ý với lớp bọt sữa mịn màng'),
      ('Trà Đào Cam Sả', 'Trà', 39000, 'Trà thanh mát kết hợp đào và hương sả'),
      ('Trà Vải', 'Trà', 35000, 'Trà đen cùng trái vải tươi ngọt lịm'),
      ('Trà Sữa Trân Châu', 'Trà', 40000, 'Trà sữa truyền thống kèm trân châu đen'),
      ('Bánh Croissant', 'Đồ ăn', 25000, 'Bánh sừng bò thơm nức mùi bơ'),
      ('Hạt Hướng Dương', 'Khác', 15000, 'Món nhâm nhi cùng bạn bè')
    ''');
  }

  Future<User?> login(String username, String password) async {
    final db = await database;
    final maps = await db.query(
      'Users',
      where: 'Username = ? AND Password = ?',
      whereArgs: [username, password],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<List<entity.Table>> getAllTables() async {
    final db = await database;
    final result = await db.query('DiningTables', orderBy: 'TableID');
    return result.map((json) => entity.Table.fromMap(json)).toList();
  }

  Future<int> updateTableStatus(int tableId, String newStatus) async {
    final db = await database;
    return db.update(
      'DiningTables',
      {'Status': newStatus},
      where: 'TableID = ?',
      whereArgs: [tableId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return db.query('Users', orderBy: 'UserID');
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    final result = await db.query(
      'Users',
      where: 'UserID = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return db.insert('Users', user);
  }

  Future<int> updateUserRole(int userId, String newRole) async {
    final db = await database;
    return db.update(
      'Users',
      {'Role': newRole},
      where: 'UserID = ?',
      whereArgs: [userId],
    );
  }

  Future<int> deleteUser(int userId) async {
    final db = await database;
    return db.delete('Users', where: 'UserID = ?', whereArgs: [userId]);
  }

  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await database;
    return db.insert('Products', product);
  }

  Future<Map<String, dynamic>?> getProductById(int productId) async {
    final db = await database;
    final result = await db.query(
      'Products',
      where: 'ProductID = ?',
      whereArgs: [productId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateProduct(int productId, Map<String, dynamic> product) async {
    final db = await database;
    return db.update(
      'Products',
      product,
      where: 'ProductID = ?',
      whereArgs: [productId],
    );
  }

  Future<int> deleteProduct(int productId) async {
    final db = await database;
    return db.delete('Products', where: 'ProductID = ?', whereArgs: [productId]);
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await database;
    return db.query('Products', orderBy: 'ProductName');
  }

  Future<List<Map<String, dynamic>>> getProductsByCategory(String category) async {
    final db = await database;
    return db.query('Products', where: 'Category = ?', whereArgs: [category]);
  }

  Future<int> createOrder({
    required int tableId,
    required int waiterId,
    required List<Map<String, dynamic>> items,
  }) async {
    final db = await database;
    if (items.isEmpty) {
      throw Exception('Danh sách món đang trống');
    }

    return db.transaction((txn) async {
      var total = 0.0;
      for (final item in items) {
        final quantity = (item['quantity'] as int?) ?? 0;
        final price = (item['price'] as num?)?.toDouble() ?? 0.0;
        total += quantity * price;
      }

      final orderId = await txn.insert('MealOrders', {
        'TableID': tableId,
        'WaiterID': waiterId,
        'TotalAmount': total,
        'Status': 'Pending',
        'CreatedAt': DateTime.now().toIso8601String(),
      });

      for (final item in items) {
        await txn.insert('OrderDetails', {
          'OrderID': orderId,
          'ProductID': item['productId'],
          'Quantity': item['quantity'],
          'Note': item['note'],
        });
      }

      await txn.update(
        'DiningTables',
        {'Status': 'Occupied'},
        where: 'TableID = ?',
        whereArgs: [tableId],
      );

      return orderId;
    });
  }

  Future<Map<String, dynamic>?> getOrderById(int orderId) async {
    final db = await database;
    final rows = await db.query(
      'MealOrders',
      where: 'OrderID = ?',
      whereArgs: [orderId],
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, dynamic>>> getOrderItems(int orderId) async {
    final db = await database;
    return db.rawQuery(
      '''
      SELECT d.OrderDetailID, d.Quantity, d.Note, p.ProductName, p.Price
      FROM OrderDetails d
      JOIN Products p ON d.ProductID = p.ProductID
      WHERE d.OrderID = ?
      ORDER BY d.OrderDetailID
      ''',
      [orderId],
    );
  }

  Future<String> getOrderStatus(int orderId) async {
    final order = await getOrderById(orderId);
    if (order == null) return 'Unknown';
    return order['Status'] as String;
  }

  Future<void> completePayment(int orderId) async {
    final db = await database;
    await db.transaction((txn) async {
      final orderRows = await txn.query(
        'MealOrders',
        where: 'OrderID = ?',
        whereArgs: [orderId],
      );
      if (orderRows.isEmpty) return;

      final tableId = orderRows.first['TableID'] as int;

      await txn.update(
        'MealOrders',
        {'Status': 'Paid'},
        where: 'OrderID = ?',
        whereArgs: [orderId],
      );

      await txn.update(
        'DiningTables',
        {'Status': 'Empty'},
        where: 'TableID = ?',
        whereArgs: [tableId],
      );
    });
  }

  Future<List<OrderQueueItem>> getOrderQueueByStatus(String status) async {
    final db = await database;
    final orderMaps = await db.rawQuery(
      '''
      SELECT m.*, t.TableName
      FROM MealOrders m
      JOIN DiningTables t ON m.TableID = t.TableID
      WHERE m.Status = ?
      ORDER BY m.CreatedAt ASC
      ''',
      [status],
    );

    final queueItems = <OrderQueueItem>[];

    for (final orderMap in orderMaps) {
      final order = Order.fromMap(orderMap);
      final tableName = orderMap['TableName'] as String;

      final detailMaps = await db.rawQuery(
        '''
        SELECT d.Quantity, d.Note, p.ProductName
        FROM OrderDetails d
        JOIN Products p ON d.ProductID = p.ProductID
        WHERE d.OrderID = ?
        ''',
        [order.orderId],
      );

      final details = detailMaps
          .map(
            (d) => OrderDetailItem(
              quantity: d['Quantity'] as int,
              productName: d['ProductName'] as String,
              note: d['Note'] as String?,
            ),
          )
          .toList();

      queueItems.add(
        OrderQueueItem(order: order, tableName: tableName, details: details),
      );
    }

    return queueItems;
  }

  Future<int> updateOrderStatus(int orderId, String newStatus) async {
    final db = await database;
    return db.update(
      'MealOrders',
      {'Status': newStatus},
      where: 'OrderID = ?',
      whereArgs: [orderId],
    );
  }

  Future<Map<String, dynamic>> getGeneralReport() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT
        COUNT(OrderID) AS TotalOrders,
        COALESCE(SUM(TotalAmount), 0) AS TotalRevenue
      FROM MealOrders
      WHERE Status IN ('Ready', 'Paid')
    ''');

    if (result.isEmpty) {
      return {'TotalOrders': 0, 'TotalRevenue': 0.0};
    }
    return result.first;
  }

  Future<List<Map<String, dynamic>>> getProductUsageReport() async {
    final db = await database;
    return db.rawQuery('''
      SELECT
        p.ProductName,
        SUM(d.Quantity) AS TotalSold,
        SUM(d.Quantity * p.Price) AS Revenue
      FROM OrderDetails d
      JOIN Products p ON d.ProductID = p.ProductID
      JOIN MealOrders m ON d.OrderID = m.OrderID
      WHERE m.Status IN ('Ready', 'Paid')
      GROUP BY p.ProductID
      ORDER BY TotalSold DESC
    ''');
  }
}
