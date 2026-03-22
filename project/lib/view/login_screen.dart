import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project/entity/user.dart';
import 'package:project/repository/database_helper.dart';
import 'package:project/view/table_screen.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // Dùng để kiểm tra môi trường Web

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String error = "";
  bool isLoading = false;

  // FIX 1: Đã sửa lại Client ID chính xác (xóa chữ 'm' thừa)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '25841198600-g1tnujimbbgi5tcth6p6297thbbalcu.apps.googleusercontent.com',
  );

  void loginNormal() async {
    setState(() => error = "");
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => error = "Vui lòng nhập tài khoản và mật khẩu");
      return;
    }

    setState(() => isLoading = true);

    try {
      User? user;

      // FIX 2: Cho phép đăng nhập giả lập trên Web để test
      if (kIsWeb) {
        await Future.delayed(const Duration(seconds: 1)); // Giả lập mạng
        if (username == "admin" && password == "123") {
          user = User(
            username: "admin",
            password: "",
            fullName: "Admin Web",
            role: "Manager",
          );
        }
      } else {
        // Chạy SQLite trên Android/iOS
        user = await DatabaseHelper.instance.login(username, password);
      }

      setState(() => isLoading = false);

      if (user != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TableScreen(user: user!)),
        );
      } else {
        setState(() => error = "Sai tài khoản hoặc mật khẩu!");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        error = "Lỗi: $e";
      });
    }
  }

  // LOGIN GOOGLE
  Future<void> loginGoogle() async {
    setState(() => isLoading = true);
    try {
      // Sử dụng biến _googleSignIn đã khai báo clientId phía trên
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await fb_auth.FirebaseAuth.instance
          .signInWithCredential(credential);
      final fbUser = userCredential.user;

      final user = User(
        username: fbUser?.email ?? "",
        password: "",
        fullName: fbUser?.displayName ?? "Google User",
        role: "Waiter",
      );

      setState(() => isLoading = false);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TableScreen(user: user)),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
        error = "Lỗi đăng nhập Google: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          // Sửa lỗi Overflow
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.coffee, size: 80, color: Colors.brown),
                const SizedBox(height: 10),
                const Text(
                  "Cafeteria System",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : loginNormal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "LOG IN",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 15),
                const Divider(),
                const SizedBox(height: 15),
                OutlinedButton.icon(
                  onPressed: isLoading ? null : loginGoogle,
                  icon: Image.network(
                    'https://tinyurl.com/yckm889n',
                    height: 24,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.login),
                  ),
                  label: const Text("Sign in with Google"),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
