import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_state.dart';
import 'api_service.dart';
import 'glass_widgets.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late Future<List<dynamic>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ApiService.fetchProducts();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = ApiService.fetchProducts();
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
              state.translate('shop_title'),
              style: const TextStyle(fontWeight: FontWeight.w400, letterSpacing: -0.5),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _refreshProducts();
                },
              )
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              HapticFeedback.lightImpact();
              _refreshProducts();
            },
            child: FutureBuilder<List<dynamic>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Нет доступных товаров',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final products = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    final inStock = (p['stock'] as int? ?? 0) > 0;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          GlassRoute(
                            page: ProductDetailScreen(productId: p['id']),
                          ),
                        );
                      },
                      child: GlassContainer(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.2),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                                ),
                                child: p['imageUrl'] != null && (p['imageUrl'] as String).isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                                        child: Image.network(
                                          p['imageUrl'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(Icons.shopping_cart_outlined, size: 48, color: isDark ? Colors.grey : Colors.grey[400]);
                                          },
                                        ),
                                      )
                                    : Icon(Icons.shopping_cart_outlined, size: 48, color: isDark ? Colors.grey : Colors.grey[400]),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p['title'] as String? ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5,
                                      color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${p['price']}',
                                    style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w900, fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    inStock ? state.translate('shop_in_stock') : state.translate('shop_out_of_stock'),
                                    style: TextStyle(
                                      color: inStock ? Colors.green : Colors.red,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
}

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Map<String, dynamic>?> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = ApiService.fetchProductDetail(widget.productId);
  }

  void _refreshDetail() {
    setState(() {
      _detailFuture = ApiService.fetchProductDetail(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppState().currentLanguage,
      builder: (context, lang, child) {
        final state = AppState();
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return FutureBuilder<Map<String, dynamic>?>(
          future: _detailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: GlassAppBar(title: const Text('')),
                body: const Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return Scaffold(
                appBar: GlassAppBar(title: const Text('')),
                body: const Center(child: Text('Товар не найден', style: TextStyle(color: Colors.grey))),
              );
            }

            final product = snapshot.data!;
            final reviewsList = product['reviews'] as List<dynamic>? ?? [];
            final stock = product['stock'] as int? ?? 0;
            final inStock = stock > 0;

            return Scaffold(
              appBar: GlassAppBar(
                title: Text(product['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w400, letterSpacing: -0.5)),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _refreshDetail();
                    },
                  )
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GlassContainer(
                      height: 300,
                      padding: EdgeInsets.zero,
                      child: product['imageUrl'] != null && (product['imageUrl'] as String).isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.network(
                                product['imageUrl'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.shopping_cart_outlined, size: 100, color: isDark ? Colors.grey : Colors.grey[400]);
                                },
                              ),
                            )
                          : Icon(Icons.shopping_cart_outlined, size: 100, color: isDark ? Colors.grey : Colors.grey[400]),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      product['title'] ?? '',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${product['price']}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF007AFF)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      inStock ? '${state.translate('shop_in_stock')} ($stock шт.)' : state.translate('shop_out_of_stock'),
                      style: TextStyle(color: inStock ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product['description'] ?? 'Нет описания.',
                      style: TextStyle(color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    GlassButton(
                      onPressed: inStock
                          ? () {
                              HapticFeedback.lightImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Товар добавлен в корзину')),
                              );
                            }
                          : null,
                      child: Text(
                        state.translate('shop_add_to_cart'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      state.translate('shop_reviews'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (reviewsList.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Отзывов пока нет. Будьте первыми!', style: TextStyle(color: Colors.grey)),
                      )
                    else
                      ...reviewsList.map((rev) {
                        final userMap = rev['user'] as Map<String, dynamic>? ?? {};
                        final name = userMap['name'] ?? 'Аноним';
                        final ratingStars = '★' * (rev['rating'] as int? ?? 5);

                        return GlassContainer(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                                ),
                              ),
                              Text(ratingStars, style: const TextStyle(color: Colors.amber)),
                              const SizedBox(height: 8),
                              Text(
                                rev['comment'] ?? '',
                                style: TextStyle(color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
