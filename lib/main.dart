import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/home_screen.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VibeCheck AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF3D1F5C),
        scaffoldBackgroundColor: const Color(0xFF0A0312),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3D1F5C),
          secondary: Color(0xFF6B4A8E),
          surface: Color(0xFF1A0B2E),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFFB8A8D4),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A0B2E),
          selectedItemColor: Color(0xFF8B6DAF),
          unselectedItemColor: Color(0xFF4A3361),
          elevation: 0,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0312),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
