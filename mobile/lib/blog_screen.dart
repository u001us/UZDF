import 'package:flutter/material.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Новости и Блог", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: 10, // Увеличим количество для примера
        padding: const EdgeInsets.all(15),
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BlogDetailScreen(index: index)),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Картинка новости
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    "https://picsum.photos/600/300?random=$index",
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Заголовок новости №${index + 1}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Узнайте последние подробности об изменениях в законодательстве для владельцев дронов в Узбекистане...",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Читать далее →",
                        style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                      ),
                    ],
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

class BlogDetailScreen extends StatelessWidget {
  final int index;
  const BlogDetailScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Добавили прокрутку
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхняя часть с картинкой и кнопкой назад
            Stack(
              children: [
                Image.network(
                  "https://picsum.photos/600/400?random=$index",
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Как безопасно летать в Ташкенте: Полный гид №$index",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Опубликовано: 09 Мая, 2024",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const Divider(height: 30),
                  Text(
                    "Здесь находится полный текст статьи. Использование беспилотных летательных аппаратов (БПЛА) в Узбекистане регулируется специальными правилами. "
                    "\n\nВо-первых, необходимо знать границы красных и желтых зон. Во-вторых, ваш дрон должен быть зарегистрирован. Наша платформа SkyCheck помогает автоматизировать этот процесс и сделать полеты безопасными для всех участников воздушного движения.",
                    style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 40),
                  
                  // Кнопки Навигации (Новее / Старее)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Кнопка влево (Новее)
                      ElevatedButton.icon(
                        onPressed: index > 0 ? () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BlogDetailScreen(index: index - 1)));
                        } : null, // Если новость самая первая, кнопка не активна
                        icon: const Icon(Icons.arrow_back_ios, size: 16),
                        label: const Text("Новее"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                      ),
                      
                      // Кнопка вправо (Старее)
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BlogDetailScreen(index: index + 1)));
                        },
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        label: const Text("Старее"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}