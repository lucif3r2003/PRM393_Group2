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

    await db.execute('''
      CREATE TABLE Tables (
        TableID $idAuto,
        TableName $textType,
        Status $textType
      )
    ''');

    

// Bảng Products (Đã thêm trường Description để ghi công thức)
    await db.execute('''
      CREATE TABLE Products (
        ProductID INTEGER PRIMARY KEY AUTOINCREMENT,
        ProductName TEXT NOT NULL,
        Category TEXT NOT NULL,
        Price REAL NOT NULL,
        Description TEXT 
      )
    ''');

    // Bảng Ingredients (Đơn thuần dùng để quản lý ghi chép tồn kho)
    await db.execute('''
      CREATE TABLE Ingredients (
        IngredientID INTEGER PRIMARY KEY AUTOINCREMENT,
        IngredientName TEXT NOT NULL,
        StockQuantity REAL NOT NULL,
        Unit TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Orders (
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
}
}