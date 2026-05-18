import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'home_screen.dart';
import 'blog_screen.dart';     // Добавили этот импорт
import 'store_screen.dart';    // Добавили этот импорт
import 'settings_screen.dart'; // Добавили этот импорт

void main() {
  runApp(const SkyCheckApp());
}

class SkyCheckApp extends StatelessWidget {
  const SkyCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyCheck Tashkent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Список всех экранов приложения
  final List<Widget> _screens = [
    const HomeScreen(),      // Индекс 0
    const BlogScreen(),      // Индекс 1
    const MapScreen(),       // Индекс 2
    const StoreScreen(),     // Индекс 3
    const SettingsScreen(),  // Индекс 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack( // Используем IndexedStack, чтобы экраны не перезагружались при переключении
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Курсы"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "Блог"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Карта"),
          BottomNavigationBarItem(icon: Icon(Icons.flight), label: "Дроны"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Настройки"),
        ],
      ),
    );
  }
}