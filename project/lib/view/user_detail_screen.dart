import 'package:flutter/material.dart';
import 'package:project/repository/auth_session.dart';
import 'package:project/repository/database_helper.dart';

class UserDetailScreen extends StatefulWidget {
  final int userId;
  final VoidCallback? onUserUpdated;

  const UserDetailScreen({
    super.key,
    required this.userId,
    this.onUserUpdated,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late DatabaseHelper _dbHelper;
  Map<String, dynamic>? _userData;
  String _selectedRole = 'Waiter';
  bool _isEditing = false;

  final List<String> roles = ['Admin', 'Waiter', 'Bartender'];

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper.instance;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _dbHelper.getUserById(widget.userId);
    if (user != null) {
      setState(() {
        _userData = user;
        _selectedRole = user['Role'] ?? 'Waiter';
      });
    }
  }

  Future<void> _updateUserRole() async {
    try {
      await _dbHelper.updateUserRole(widget.userId, _selectedRole);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật vai trò thành công')),
        );
        widget.onUserUpdated?.call();
        setState(() {
          _isEditing = false;
        });
        _loadUserData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthSession.hasAnyRole(['Admin'])) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thông tin người dùng')),
        body: const Center(
          child: Text('Bạn không có quyền truy cập màn hình này.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin người dùng'),
        backgroundColor: Colors.blue,
      ),
      body: _userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar section
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: _getRoleColor(_userData!['Role']),
                        child: Text(
                          _userData!['FullName'][0],
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Full Name (Read-only)
                    _buildReadOnlyField(
                      'Họ và tên',
                      _userData!['FullName'],
                    ),
                    const SizedBox(height: 16),

                    // Username (Read-only)
                    _buildReadOnlyField(
                      'Tên đăng nhập',
                      _userData!['Username'],
                    ),
                    const SizedBox(height: 16),

                    // Password (Read-only)
                    _buildReadOnlyField(
                      'Mật khẩu',
                      '•' * _userData!['Password'].length,
                    ),
                    const SizedBox(height: 16),

                    // Role (Editable only)
                    if (!_isEditing)
                      _buildReadOnlyField(
                        'Vai trò',
                        _userData!['Role'],
                        roleColor: _getRoleColor(_userData!['Role']),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Vai trò',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<String>(
                            value: _selectedRole,
                            isExpanded: true,
                            items: roles.map((String role) {
                              return DropdownMenuItem<String>(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedRole = newValue;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    const SizedBox(height: 32),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isEditing ? Colors.green : Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              if (_isEditing) {
                                _updateUserRole();
                              } else {
                                setState(() {
                                  _isEditing = true;
                                });
                              }
                            },
                            child: Text(
                              _isEditing ? 'Lưu' : 'Sửa vai trò',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        if (_isEditing) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _selectedRole =
                                      _userData!['Role'] ?? 'Waiter';
                                });
                              },
                              child: const Text(
                                'Hủy',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildReadOnlyField(
    String label,
    String value, {
    Color? roleColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: roleColor ?? Colors.black87,
              fontWeight: roleColor != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
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
