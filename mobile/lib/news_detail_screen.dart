import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'glass_widgets.dart';

class NewsDetailScreen extends StatelessWidget {
  final Map<String, dynamic> news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageUrl = news['imageUrl'] as String?;
    final title = news['title'] ?? '';
    final content = news['content'] ?? '';
    final author = news['author'] ?? 'UZDF';
    final publishedAt = news['publishedAt'] != null
        ? DateTime.parse(news['publishedAt']).toLocal().toString().split(' ')[0]
        : '';

    return Scaffold(
      appBar: GlassAppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w400, letterSpacing: -0.5)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                        child: Icon(Icons.image, size: 50, color: isDark ? Colors.grey : Colors.grey[400]),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Автор: $author',
                    style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  if (publishedAt.isNotEmpty)
                    Text(
                      publishedAt,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF1C1C1E).withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
