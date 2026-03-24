import 'package:project/entity/order.dart';
import 'package:project/entity/order_queue_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Đảm bảo chỉ có 1 instance của DatabaseHelper được tạo ra (Singleton)
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Getter để lấy instance của database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cafeteria_system.db');
    return _database!;
  }

  // Khởi tạo và mở database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // await deleteDatabase(path); // xoa du lieu thi bo cai comment nay di

    // Mở database, nếu chưa có sẽ gọi hàm _createDB
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  // Kích hoạt khóa ngoại (Foreign Key) trong SQLite
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Chạy các lệnh CREATE TABLE khi database được tạo lần đầu
  Future _createDB(Database db, int version) async {
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

    // ✅ SỬA TÊN BẢNG THÀNH DiningTables CHO ĐỒNG BỘ
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

    // ✅ SỬA TÊN BẢNG THÀNH MealOrders CHO ĐỒNG BỘ
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

    await db.execute('''
  INSERT INTO Products (ProductName, Category, Price, Description) VALUES 
  ('Cà phê Đen', 'Cà phê', 25000, 'Cà phê rang xay nguyên chất đậm đà'),
  ('Cà phê Sữa', 'Cà phê', 29000, 'Cà phê hòa quyện cùng sữa đặc béo ngậy'),
  ('Bạc Xỉu', 'Cà phê', 32000, 'Nhiều sữa ít cà phê, hương vị nhẹ nhàng'),
  ('Cappuccino', 'Cà phê', 45000, 'Cà phê Ý với lớp bọt sữa mịn màng'),
  ('Trà Đào Cam Sả', 'Trà', 39000, 'Trà thanh mát kết hợp đào và hương sả'),
  ('Trà Vải', 'Trà', 35000, 'Trà đen cùng trái vải tươi ngọt lịm'),
  ('Trà Sữa Trân Châu', 'Trà', 40000, 'Trà sữa truyền thống kèm trân châu đen'),
  ('Bánh Mì Thịt', 'Đồ ăn', 30000, 'Bánh mì giòn kẹp thịt xá xíu và pate'),
  ('Bánh Croissant', 'Đồ ăn', 25000, 'Bánh sừng bò thơm nức mùi bơ'),
  ('Hạt Hướng Dương', 'Khác', 15000, 'Món nhâm nhi cùng bạn bè');
''');
  } // ✅ ĐÂY LÀ DẤU NGOẶC KẾT THÚC CỦA HÀM _createDB. CÁC HÀM TRUY VẤN PHẢI NẰM DƯỚI NÓ!

  // =========================================================================
  // CÁC HÀM TRUY VẤN DỮ LIỆU (Đã được đưa ra ngoài hàm _createDB)
  // =========================================================================

  /// Lấy danh sách Đơn hàng theo Trạng thái (Pending, Preparing, Ready)
  Future<List<OrderQueueItem>> getOrderQueueByStatus(String status) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> orderMaps = await db.rawQuery('''
      SELECT m.*, t.TableName 
      FROM MealOrders m
      JOIN DiningTables t ON m.TableID = t.TableID
      WHERE m.Status = ?
      ORDER BY m.CreatedAt ASC
    ''', [status]);

    List<OrderQueueItem> queueItems = [];

    for (var orderMap in orderMaps) {
      Order order = Order.fromMap(orderMap);
      String tableName = orderMap['TableName'] as String;

      final List<Map<String, dynamic>> detailMaps = await db.rawQuery('''
        SELECT d.Quantity, d.Note, p.ProductName 
        FROM OrderDetails d
        JOIN Products p ON d.ProductID = p.ProductID
        WHERE d.OrderID = ?
      ''', [order.orderId]);

      List<OrderDetailItem> details = detailMaps.map((d) {
        return OrderDetailItem(
          quantity: d['Quantity'] as int,
          productName: d['ProductName'] as String,
          note: d['Note'] as String?,
        );
      }).toList();

      queueItems.add(OrderQueueItem(
        order: order,
        tableName: tableName,
        details: details,
      ));
    }

    return queueItems;
  }

  /// Cập nhật trạng thái của đơn hàng (Khi Bartender bấm nút)
  Future<int> updateOrderStatus(int orderId, String newStatus) async {
    final db = await instance.database;
    return await db.update(
      'MealOrders',
      {'Status': newStatus},
      where: 'OrderID = ?',
      whereArgs: [orderId],
    );
  }

  // ---- Bat Dau Phan 2 ----
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await instance.database;
    return await db.query('Products');
  }

  // Hoặc lấy sản phẩm theo danh mục (nếu có phân loại Trà, Cà phê, Bánh...)
  Future<List<Map<String, dynamic>>> getProductsByCategory(String category) async {
    final db = await instance.database;
    return await db.query(
      'Products',
      where: 'Category = ?',
      whereArgs: [category],
    );
  }
  // ---- Ket thuc phan 2 ----
  // ---- Bat Dau Phan 8 ----
// Báo cáo tổng quan: Tổng số đơn và Tổng doanh thu
  Future<Map<String, dynamic>> getGeneralReport() async {
    final db = await instance.database;
    // Lấy các đơn hàng đã hoàn thành (Ready hoặc Paid)
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        COUNT(OrderID) as TotalOrders, 
        SUM(TotalAmount) as TotalRevenue
      FROM MealOrders
      WHERE Status IN ('Ready', 'Paid')
    ''');

    // Trả về dữ liệu, nếu NULL thì gán mặc định là 0
    if (result.isNotEmpty && result.first['TotalOrders'] != 0) {
      return result.first;
    }
    return {'TotalOrders': 0, 'TotalRevenue': 0.0};
  }

  // Thống kê món ăn bán chạy nhất (Best Sellers)
  Future<List<Map<String, dynamic>>> getProductUsageReport() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT 
        p.ProductName, 
        SUM(d.Quantity) as TotalSold, 
        SUM(d.Quantity * p.Price) as Revenue
      FROM OrderDetails d
      JOIN Products p ON d.ProductID = p.ProductID
      JOIN MealOrders m ON d.OrderID = m.OrderID
      WHERE m.Status IN ('Ready', 'Paid')
      GROUP BY p.ProductID
      ORDER BY TotalSold DESC
    ''');
  }
// ---- Ket thuc phan 8 ----

  // ========== USER MANAGEMENT METHODS ==========
  /// Lấy tất cả users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await instance.database;
    return await db.query('Users', orderBy: 'UserID');
  }

  /// Lấy user theo ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'Users',
      where: 'UserID = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Thêm user mới
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.insert('Users', user);
  }

  /// Cập nhật user (chỉ role có thể chỉnh sửa)
  Future<int> updateUserRole(int userId, String newRole) async {
    final db = await instance.database;
    return await db.update(
      'Users',
      {'Role': newRole},
      where: 'UserID = ?',
      whereArgs: [userId],
    );
  }

  /// Xóa user
  Future<int> deleteUser(int userId) async {
    final db = await instance.database;
    return await db.delete(
      'Users',
      where: 'UserID = ?',
      whereArgs: [userId],
    );
  }

  // ========== PRODUCT MANAGEMENT METHODS ==========
  /// Thêm sản phẩm
  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await instance.database;
    return await db.insert('Products', product);
  }

  /// Lấy sản phẩm theo ID
  Future<Map<String, dynamic>?> getProductById(int productId) async {
    final db = await instance.database;
    final result = await db.query(
      'Products',
      where: 'ProductID = ?',
      whereArgs: [productId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Cập nhật sản phẩm
  Future<int> updateProduct(int productId, Map<String, dynamic> product) async {
    final db = await instance.database;
    return await db.update(
      'Products',
      product,
      where: 'ProductID = ?',
      whereArgs: [productId],
    );
  }

  /// Xóa sản phẩm
  Future<int> deleteProduct(int productId) async {
    final db = await instance.database;
    return await db.delete(
      'Products',
      where: 'ProductID = ?',
      whereArgs: [productId],
    );
  }
}