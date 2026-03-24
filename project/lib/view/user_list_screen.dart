import 'package:flutter/material.dart';
import 'package:project/repository/auth_session.dart';
import 'package:project/repository/database_helper.dart';
import 'package:project/view/user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late DatabaseHelper _dbHelper;
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper.instance;
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = _dbHelper.getAllUsers();
    });
  }

  void _deleteUser(int userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa người dùng'),
          content: const Text('Bạn có chắc chắn muốn xóa người dùng này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                await _dbHelper.deleteUser(userId);
                _loadUsers();
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xóa người dùng thành công')),
                  );
                }
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthSession.hasAnyRole(['Admin'])) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quản lý người dùng')),
        body: const Center(
          child: Text('Bạn không có quyền truy cập màn hình này.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có người dùng nào'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRoleColor(user['Role']),
                    child: Text(
                      user['FullName'][0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(user['FullName']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tên đăng nhập: ${user['Username']}'),
                      Text(
                        'Vai trò: ${user['Role']}',
                        style: TextStyle(
                          color: _getRoleColor(user['Role']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        child: const Text('Xem/Sửa'),
                        onTap: () {
                          Future.delayed(
                            Duration.zero,
                            () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                builder: (context) => UserDetailScreen(
                                  userId: user['UserID'],
                                  onUserUpdated: _loadUsers,
                                ),
                              ))
                                  .then((_) {
                                _loadUsers();
                              });
                            },
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                        onTap: () {
                          _deleteUser(user['UserID']);
                        },
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

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return Colors.red;
      case 'Waiter':
        return Colors.blue;
      case 'Bartender':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
