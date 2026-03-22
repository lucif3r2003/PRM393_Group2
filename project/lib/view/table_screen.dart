import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project/entity/user.dart';
import 'package:project/repository/database_helper.dart';
import 'package:project/entity/table.dart' as entity;
import 'package:project/view/login_screen.dart';

class TableScreen extends StatefulWidget {
  final User user;
  const TableScreen({super.key, required this.user});

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  // Dùng entity.Table thay vì Table
  List<entity.Table> tables = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTables();
  }

  Future<void> loadTables() async {
    try {
      List<entity.Table> data = [];

      if (kIsWeb) {
        // Dữ liệu giả lập để Web không bị treo
        data = [
          entity.Table(
            tableId: 1,
            tableName: "Bàn 01 (Web)",
            status: "Available",
          ),
          entity.Table(
            tableId: 2,
            tableName: "Bàn 02 (Web)",
            status: "Occupied",
          ),
        ];
      } else {
        // Chạy SQLite thật trên Android
        data = await DatabaseHelper.instance.getAllTables();
      }

      setState(() {
        tables = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Lỗi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chọn Bàn Phục Vụ"),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Thông tin nhân viên
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.brown[50],
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.brown,
                  child: Text(widget.user.fullName[0]),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("Vai trò: ${widget.user.role}"),
                  ],
                ),
              ],
            ),
          ),

          // Danh sách bàn dưới dạng Grid
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(15),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: tables.length,
                    itemBuilder: (context, index) {
                      final table = tables[index];
                      bool isOccupied = table.status == "Occupied";

                      return GestureDetector(
                        onTap: () {
                          // Xử lý khi chọn bàn (ví dụ chuyển sang màn hình Order)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Bạn đã chọn ${table.tableName}"),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isOccupied
                                ? Colors.red[100]
                                : Colors.green[100],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isOccupied ? Colors.red : Colors.green,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.table_bar,
                                size: 40,
                                color: isOccupied ? Colors.red : Colors.green,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                table.tableName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(isOccupied ? "Có khách" : "Bàn trống"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
