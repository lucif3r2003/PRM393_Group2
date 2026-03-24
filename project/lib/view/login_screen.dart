import 'package:flutter/material.dart';
import 'package:project/repository/auth_session.dart';
import 'package:project/repository/database_helper.dart';
import 'package:project/view/admin_home_screen.dart';
import 'package:project/view/list_table_screen.dart';
import 'package:project/view/order_queue.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    String username = _userController.text.trim();
    String password = _passController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tài khoản và mật khẩu")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await DatabaseHelper.instance.login(username, password);

      if (user != null) {
        AuthSession.currentUser = user;
        if (!mounted) return;

        Widget nextScreen;
        if (user.role == 'Admin') {
          nextScreen = const AdminHomeScreen();
        } else if (user.role == 'Bartender') {
          nextScreen = const OrderQueueScreen();
        } else {
          nextScreen = TableListScreen(
            waiterId: user.userId!,
            waiterName: user.fullName,
          );
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tài khoản hoặc mật khẩu không đúng!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi hệ thống: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.coffee_maker, size: 80, color: Colors.brown),
              const SizedBox(height: 10),
              const Text(
                "CAFE MANAGER",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _userController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("ĐĂNG NHẬP"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
