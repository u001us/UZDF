import 'package:flutter/material.dart';
import 'blog_screen.dart'; // Обязательно должен быть этот импорт

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. ШАПКА: Аватарка и Профиль ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "С возвращением,",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        Text(
                          "Пилот DJI",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none, size: 28),
                  onPressed: () {},
                )
              ],
            ),
            const SizedBox(height: 30),

            // --- 2. ГЛАВНАЯ НОВОСТЬ (БЛОГ) ---
            const Text(
              "Актуальные новости",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.campaign, color: Colors.white),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Новые правила полетов в Ташкенте",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "С 1 июня обновлены зоны запрета полетов. Узнайте, где теперь разрешено летать без уведомления...",
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blueAccent,
                      ),
                      onPressed: () {
                        // Переход на страницу деталей новости
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BlogDetailScreen(index: 0),
                          ),
                        );
                      },
                      child: const Text("Читать далее"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- 3. СПИСОК КУРСОВ ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Учебные курсы",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("Все", style: TextStyle(color: Colors.blueAccent)),
                )
              ],
            ),
            const SizedBox(height: 10),

            // Карточки курсов
            _buildCourseCard(
              title: "Introduction to Drones",
              subtitle: "Основы управления и безопасности",
              icon: Icons.flight_takeoff,
              color: Colors.orange.shade100,
              iconColor: Colors.orange,
            ),
            _buildCourseCard(
              title: "Intermediate to Drones",
              subtitle: "Сложные маневры и съемка",
              icon: Icons.videocam,
              color: Colors.purple.shade100,
              iconColor: Colors.purple,
            ),
            _buildCourseCard(
              title: "Продвинутый уровень",
              subtitle: "Полеты в сложных условиях",
              icon: Icons.speed,
              color: Colors.red.shade100,
              iconColor: Colors.red,
            ),
            _buildCourseCard(
              title: "Профессионал",
              subtitle: "Коммерческая съемка и лицензия",
              icon: Icons.verified,
              color: Colors.green.shade100,
              iconColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  // Функция для создания карточки курса
  Widget _buildCourseCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blueAccent),
        ],
      ),
    );
  }
}