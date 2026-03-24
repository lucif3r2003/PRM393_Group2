import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project/repository/database_helper.dart';
import 'package:project/view/login_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  try {
    // Thử khởi tạo, nếu quá 3 giây không xong thì bỏ qua để hiện màn hình
    await DatabaseHelper.instance.database.timeout(const Duration(seconds: 3));
    print("Database ready!");
  } catch (e) {
    print("Database init error or timeout: $e");
    // Vẫn tiếp tục để hiện màn hình Login
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cafe Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
