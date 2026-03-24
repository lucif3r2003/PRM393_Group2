import 'package:flutter/material.dart';
import 'package:project/repository/database_helper.dart';
import 'package:project/entity/table.dart' as entity;
import 'package:project/view/table_detail_screen.dart'; // Import file chi tiết

class TableListScreen extends StatefulWidget {
  const TableListScreen({super.key});

  @override
  _TableListScreenState createState() => _TableListScreenState();
}

class _TableListScreenState extends State<TableListScreen> {
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Occupied':
        return Colors.redAccent;
      case 'Reserved':
        return Colors.orangeAccent;
      case 'Empty':
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sơ đồ bàn Cafe"),
        backgroundColor: Colors.brown[400],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}), // Làm mới danh sách
          ),
        ],
      ),
      body: FutureBuilder<List<entity.Table>>(
        future: DatabaseHelper.instance.getAllTables(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Không có dữ liệu bàn."));
          }

          final tables = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1,
            ),
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final table = tables[index];
              return InkWell(
                onTap: () async {
                  // Chuyển sang màn hình chi tiết và đợi kết quả trả về để refresh
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TableDetailScreen(table: table),
                    ),
                  );
                  setState(() {}); // Refresh lại màu sắc bàn sau khi quay về
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _getStatusColor(table.status),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.table_restaurant,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        table.tableName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        table.status,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
