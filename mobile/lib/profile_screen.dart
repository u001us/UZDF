import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_state.dart';
import 'api_service.dart';
import 'faq_screen.dart';
import 'glass_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<Map<String, dynamic>> _allAchievements = [
    {
      'id': 'first_steps',
      'name': 'Первый взлет',
      'desc': 'Пройти любой шаг любого курса',
      'icon': '🚀',
      'reward': '+100 EXP'
    },
    {
      'id': 'theory_master',
      'name': 'Теоретик авиации',
      'desc': 'Завершить хотя бы 1 курс полностью',
      'icon': '📚',
      'reward': '+200 EXP'
    },
    {
      'id': 'certified_pilot',
      'name': 'Дипломированный ас',
      'desc': 'Завершить 3 курса полностью',
      'icon': '🎓',
      'reward': '+500 EXP'
    },
    {
      'id': 'all_courses',
      'name': 'Безопасное небо',
      'desc': 'Завершить все 5 курсов',
      'icon': '🏆',
      'reward': '+800 EXP'
    },
  ];

  int _getRequiredExpForLevel(int level) {
    if (level <= 1) return 0;
    return ((level - 1) * 100 + (level - 1) * (level - 1) * 15);
  }

  void _showOrdersDialog(AppState state, bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  state.translate('profile_orders'),
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.maxFinite,
                  height: 300,
                  child: FutureBuilder<List<dynamic>>(
                    future: ApiService.fetchMyOrders(),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF007AFF)));
                      }
                      final orders = snapshot.data ?? [];
                      if (orders.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey),
                              const SizedBox(height: 12),
                              Text(
                                'У вас пока нет заказов',
                                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.black54),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: orders.length,
                        itemBuilder: (ctx2, idx) {
                          final order = orders[idx];
                          final rawStatus = order['status']?.toString() ?? 'PENDING';
                          final status = rawStatus.split('|').first;
                          final statusLabel = status == 'COMPLETED' ? 'Выполнен' : status == 'CANCELLED' ? 'Отменен' : 'Ожидает доставки';
                          final statusColor = status == 'COMPLETED' ? Colors.green : status == 'CANCELLED' ? Colors.red : Colors.orange;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                              _showOrderDeliveryForm(order, isDark);
                            },
                            child: _buildOrderTile(
                              'Заказ #${order['id']}',
                              '\$${(order['totalAmount'] ?? 0.0).toStringAsFixed(2)}',
                              statusLabel,
                              statusColor,
                              isDark,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child: const Text('Закрыть', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOrderDeliveryForm(Map<String, dynamic> order, bool isDark) {
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: GlassContainer(
          borderRadius: 22,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Данные доставки — Заказ #${order['id']}',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressCtrl,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
                decoration: getGlassInputDecoration(
                  hintText: 'Адрес доставки',
                  prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.grey),
                  context: context,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityCtrl,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
                decoration: getGlassInputDecoration(
                  hintText: 'Город',
                  prefixIcon: const Icon(Icons.location_city_outlined, color: Colors.grey),
                  context: context,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactCtrl,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
                decoration: getGlassInputDecoration(
                  hintText: 'Контактный телефон',
                  prefixIcon: const Icon(Icons.phone_outlined, color: Colors.grey),
                  context: context,
                ),
              ),
              const SizedBox(height: 20),
              GlassButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(ctx);
                  final ok = await ApiService.updateOrderDelivery(
                    order['id'] as int,
                    addressCtrl.text.trim(),
                    cityCtrl.text.trim(),
                    contactCtrl.text.trim(),
                  );
                  if (ctx.mounted) {
                    navigator.pop();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(ok ? 'Данные доставки сохранены' : 'Ошибка при сохранении'),
                        backgroundColor: ok ? Colors.green : Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Сохранить данные доставки', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTile(String title, String price, String status, Color statusColor, bool isDark) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      opacity: isDark ? 0.08 : 0.45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1C1C1E))),
              const SizedBox(height: 4),
              Text(price, style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w600)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(AppState state, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (ctx) {
        return GlassContainer(
          borderRadius: 22,
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF0088CC).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.telegram, color: Color(0xFF0088CC), size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                'Техническая поддержка',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Наш бот поддержки доступен 24/7 в Telegram. Опишите вашу проблему и мы ответим в кратчайшие сроки.',
                style: TextStyle(color: Colors.grey, height: 1.4, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GlassButton(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0088CC),
                    Color(0xFF006699),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(ctx);
                  final uri = Uri.parse(ApiService.telegramBotUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    if (ctx.mounted) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Не удалось открыть Telegram. Убедитесь, что он установлен.')),
                      );
                    }
                  }
                  if (ctx.mounted) navigator.pop();
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.open_in_new, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('@uzdf_support_bot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(ctx);
                },
                child: const Text('Закрыть', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileBottomSheet(AppState state, bool isDark) {
    final user = ApiService.currentUser ?? {};
    final nameCtrl = TextEditingController(text: user['name'] ?? '');
    final emailCtrl = TextEditingController(text: user['email'] ?? '');
    final phoneCtrl = TextEditingController(text: user['phone'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: GlassContainer(
          borderRadius: 22,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                state.translate('profile_settings'),
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
                decoration: getGlassInputDecoration(
                  hintText: state.translate('form_name'),
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                  context: context,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
                decoration: getGlassInputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                  context: context,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
                decoration: getGlassInputDecoration(
                  hintText: state.translate('form_phone'),
                  prefixIcon: const Icon(Icons.phone_outlined, color: Colors.grey),
                  context: context,
                ),
              ),
              const SizedBox(height: 20),
              GlassButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final email = emailCtrl.text.trim();
                  final phone = phoneCtrl.text.trim();
                  if (name.isEmpty || email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Имя и Email обязательны'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  final messenger = ScaffoldMessenger.of(context);
                  final successMsg = state.translate('profile_save_success');
                  final errorMsg = state.translate('profile_save_error');

                  final ok = await ApiService.updateProfile({
                    'name': name,
                    'email': email,
                    'phone': phone,
                  });
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    if (ok) {
                      setState(() {});
                    }
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(ok ? successMsg : errorMsg),
                        backgroundColor: ok ? Colors.green : Colors.red,
                      ),
                    );
                  }
                },
                child: Text(state.translate('profile_save'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showTermsBottomSheet(AppState state, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) {
        return GlassContainer(
          borderRadius: 22,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                state.translate('profile_terms'),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    'Пользовательское соглашение UZDF Uzbekistan.\n\n'
                    '1. Общие положения\n'
                    'Используя данное мобильное приложение, вы соглашаетесь с условиями предоставления услуг, правилами полетов дронов и требованиями законодательства Республики Узбекистан касательно использования воздушного пространства.\n\n'
                    '2. Ограничение ответственности\n'
                    'Приложение предоставляет информационные карты зон полетов (зеленые, желтые и красные зоны). Пользователь несет персональную юридическую ответственность за соблюдение правил безопасности пилотирования БПЛА.\n\n'
                    '3. Конфиденциальность\n'
                    'Мы сохраняем данные вашего профиля и историю заказов исключительно для обеспечения функционала приложения.',
                    style: TextStyle(color: isDark ? Colors.grey[300] : const Color(0xFF1C1C1E).withOpacity(0.8), height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GlassButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: const Text('Я согласен', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppState().currentLanguage,
      builder: (context, lang, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: AppState().isDarkMode,
          builder: (context, isDark, child) {
            final state = AppState();
            return _buildProfileView(state, isDark, lang);
          },
        );
      },
    );
  }

  Widget _buildProfileView(AppState state, bool isDark, String lang) {
    final user = ApiService.currentUser ?? {};
    final name = user['name'] ?? 'Иван Иванов';
    final email = user['email'] ?? 'ivan@uzdf.uz';
    final lives = user['courseLives'] ?? 3;

    return Scaffold(
      appBar: GlassAppBar(
        title: Text(
          state.translate('profile_title'),
          style: const TextStyle(fontWeight: FontWeight.w400, letterSpacing: -0.5),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Card
          Stack(
            children: [
              GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF).withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF007AFF), width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF007AFF)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (user['phone'] != null && user['phone'].toString().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone, color: Colors.grey, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  user['phone'],
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.favorite, color: Colors.redAccent, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Попытки: $lives',
                                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF007AFF), size: 20),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showEditProfileBottomSheet(state, isDark);
                  },
                  tooltip: 'Редактировать профиль',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildGamificationSection(user, isDark),
          // Group 1: Settings
          _buildGroupHeader('Настройки системы'),
          _buildCardGroup(
            isDark: isDark,
            children: [
              // Theme
              ListTile(
                leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: const Color(0xFF007AFF)),
                title: Text(
                  isDark ? state.translate('theme_dark') : state.translate('theme_light'),
                  style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
                ),
                trailing: Switch(
                  value: isDark,
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFF007AFF),
                  onChanged: (val) {
                    HapticFeedback.lightImpact();
                    state.toggleTheme();
                  },
                ),
              ),
              Divider(height: 1, indent: 56, color: Colors.white.withOpacity(0.15)),
              // Language
              ListTile(
                leading: const Icon(Icons.language, color: Color(0xFF007AFF)),
                title: Text(
                  state.translate('profile_lang'),
                  style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ['RU', 'UZ', 'EN'].map((code) {
                    final isSelected = lang == code.toLowerCase();
                    return GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        state.setLanguage(code.toLowerCase());
                        await ApiService.updateProfile({'language': code.toLowerCase()});
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF007AFF) : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF007AFF) : Colors.white.withOpacity(0.15),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          code,
                          style: TextStyle(
                            color: isSelected ? Colors.white : (isDark ? Colors.grey : const Color(0xFF1C1C1E)),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Divider(height: 1, indent: 56, color: Colors.white.withOpacity(0.15)),
              ListTile(
                leading: const Icon(Icons.wifi, color: Color(0xFF007AFF)),
                title: Text(
                  'Настройка подключения',
                  style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showConnectionDialog(context, isDark);
                },
              ),
            ],
          ),

          // Group 2: Account Actions
          _buildGroupHeader('Информационные панели'),
          _buildCardGroup(
            isDark: isDark,
            children: [
              _buildListRow(
                Icons.shopping_bag_outlined,
                state.translate('profile_orders'),
                isDark,
                () => _showOrdersDialog(state, isDark),
              ),
              Divider(height: 1, indent: 56, color: Colors.white.withOpacity(0.15)),
              _buildListRow(
                Icons.support_agent_outlined,
                state.translate('profile_support'),
                isDark,
                () => _showSupportDialog(state, isDark),
              ),
              Divider(height: 1, indent: 56, color: Colors.white.withOpacity(0.15)),
              _buildListRow(
                Icons.description_outlined,
                state.translate('profile_terms'),
                isDark,
                () => _showTermsBottomSheet(state, isDark),
              ),
              Divider(height: 1, indent: 56, color: Colors.white.withOpacity(0.15)),
              _buildListRow(
                Icons.help_outline,
                state.translate('profile_faq'),
                isDark,
                () => Navigator.push(
                  context,
                  GlassRoute(page: const FaqScreen()),
                ),
              ),
            ],
          ),

          // Group 3: Log out
          _buildCardGroup(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFF43F5E)),
                title: Text(
                  state.translate('profile_logout'),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF43F5E)),
                ),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFFF43F5E)),
                onTap: () async {
                  HapticFeedback.lightImpact();
                  await ApiService.clearSession();
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGamificationSection(Map<String, dynamic> user, bool isDark) {
    final exp = user['exp'] ?? 0;
    final level = user['level'] ?? 1;
    final prevLevelExp = _getRequiredExpForLevel(level);
    final nextLevelExp = _getRequiredExpForLevel(level + 1);
    final range = nextLevelExp - prevLevelExp;
    final progress = exp - prevLevelExp;
    final percent = range > 0 ? (progress / range).clamp(0.0, 1.0) : 0.0;
    
    final userAchievements = user['achievements'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGroupHeader('Игровой Прогресс'),
        GlassContainer(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Уровень $level',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                    ),
                  ),
                  Text(
                    '$exp / $nextLevelExp EXP',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF007AFF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 8,
                  backgroundColor: isDark ? const Color(0xFF050814).withOpacity(0.3) : const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
                ),
              ),
            ],
          ),
        ),
        
        _buildGroupHeader('Достижения Пилота'),
        GlassContainer(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _allAchievements.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, idx) {
              final ach = _allAchievements[idx];
              final isUnlocked = userAchievements.any((ua) => ua['achievementId'] == ach['id']);
              
              return GlassContainer(
                padding: const EdgeInsets.all(8),
                opacity: isUnlocked ? (isDark ? 0.22 : 0.75) : (isDark ? 0.08 : 0.35),
                border: Border.all(
                  color: isUnlocked 
                      ? Colors.green.withOpacity(0.5) 
                      : Colors.white.withOpacity(0.15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isUnlocked ? ach['icon'] : '🔒',
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ach['name'],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Text(
                        ach['desc'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ach['reward'],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? Colors.green : const Color(0xFF007AFF),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroupHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey.withOpacity(0.8),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildCardGroup({required List<Widget> children, required bool isDark}) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.zero,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListRow(IconData icon, String title, bool isDark, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF007AFF)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  void _showConnectionDialog(BuildContext context, bool isDark) {
    final controller = TextEditingController();
    bool isTesting = false;
    String statusMessage = '';
    Color statusColor = Colors.grey;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.wifi, color: Color(0xFF007AFF)),
                        const SizedBox(width: 10),
                        Text(
                          'Подключение к ПК',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<String>(
                      future: ApiService.getBaseUrl(),
                      builder: (context, snapshot) {
                        final url = snapshot.data ?? 'Определяется...';
                        return Text(
                          'Текущий адрес: $url',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Введите IP-адрес вашего компьютера:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller,
                      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
                      decoration: getGlassInputDecoration(
                        hintText: 'например, 192.168.1.100:3000',
                        context: context,
                      ),
                    ),
                    if (statusMessage.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        statusMessage,
                        style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            await ApiService.resetBaseUrl();
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Сброшено к автоматическому поиску')),
                              );
                              setState(() {});
                            }
                          },
                          child: const Text('Сбросить', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 120,
                          child: GlassButton(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            onPressed: isTesting
                                ? null
                                : () async {
                                    final input = controller.text.trim();
                                    if (input.isEmpty) return;
                                    setStateDialog(() {
                                      isTesting = true;
                                      statusMessage = 'Проверка подключения...';
                                      statusColor = const Color(0xFF007AFF);
                                    });
                                    final success = await ApiService.testAndSetCustomBaseUrl(input);
                                    setStateDialog(() {
                                      isTesting = false;
                                    });
                                    if (success) {
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Colors.green,
                                            content: Text('Подключено! Новый адрес сохранен.'),
                                          ),
                                        );
                                        setState(() {});
                                      }
                                    } else {
                                      setStateDialog(() {
                                        statusMessage = '❌ Ошибка соединения! Проверьте IP и Firewall на ПК.';
                                        statusColor = Colors.red;
                                      });
                                    }
                                  },
                            child: isTesting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Сохранить', style: TextStyle(fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
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
