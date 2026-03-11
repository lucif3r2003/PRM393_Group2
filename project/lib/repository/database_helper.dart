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
}