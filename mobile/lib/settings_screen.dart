import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 40),
          const Center(
            child: CircleAvatar(radius: 50, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11')),
          ),
          const Center(child: Text("Andrew Smith", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          const Center(child: Text("+998 90 123 45 67", style: TextStyle(color: Colors.grey))),
          const SizedBox(height: 30),
          _settingItem(Icons.person, "Profile"),
          _settingItem(Icons.emoji_events, "Achievements"),
          _settingItem(Icons.shopping_cart, "Корзина"),
          _settingItem(Icons.settings, "Настройки приложения"),
          _settingItem(Icons.help_outline, "Тех. поддержка"),
          const Divider(),
          _settingItem(Icons.logout, "Разлогиниться", color: Colors.red),
        ],
      ),
    );
  }

  Widget _settingItem(IconData icon, String title, {Color color = Colors.black}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }
}