import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'glass_widgets.dart';
import 'app_state.dart';
import 'api_service.dart';
import 'news_detail_screen.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  late Future<List<dynamic>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = ApiService.fetchNews();
  }

  void _refreshNews() {
    setState(() {
      _newsFuture = ApiService.fetchNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppState().currentLanguage,
      builder: (context, lang, child) {
        final state = AppState();
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          appBar: GlassAppBar(
            title: Text(
              state.translate('news_title'),
              style: const TextStyle(fontWeight: FontWeight.w400, letterSpacing: -0.5),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _refreshNews();
                },
              )
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async => _refreshNews(),
            child: FutureBuilder<List<dynamic>>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Нет доступных новостей',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final newsList = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: newsList.length,
                  itemBuilder: (context, index) {
                    final item = newsList[index];
                    final author = item['author'] ?? 'UZDF';
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          GlassRoute(
                            page: NewsDetailScreen(news: item),
                          ),
                        );
                      },
                      child: _buildNewsCard(
                        item['title'] ?? '',
                        item['content'] ?? '',
                        author,
                        item['imageUrl'],
                        isDark,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildNewsCard(String title, String desc, String author, String? imageUrl, bool isDark) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.image_outlined, size: 48, color: isDark ? Colors.grey : Colors.grey[400]);
                      },
                    ),
                  )
                : Icon(Icons.image_outlined, size: 48, color: isDark ? Colors.grey : Colors.grey[400]),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, height: 1.5, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 16),
                Text(
                  author.toUpperCase(),
                  style: const TextStyle(color: Color(0xFF007AFF), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}