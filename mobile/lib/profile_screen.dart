import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
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
                    color: colorScheme.onSurface,
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
                        return Center(child: CircularProgressIndicator(color: colorScheme.primary));
                      }
                      final orders = snapshot.data ?? [];
                      if (orders.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_bag_outlined, size: 48, color: colorScheme.onSurfaceVariant),
                              const SizedBox(height: 12),
                              Text(
                                'У вас пока нет заказов',
                                style: TextStyle(color: colorScheme.onSurfaceVariant),
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
                      child: Text('Закрыть', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
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
    final colorScheme = Theme.of(context).colorScheme;
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
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressCtrl,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: getGlassInputDecoration(
                  hintText: 'Адрес доставки',
                  prefixIcon: Icon(Icons.location_on_outlined, color: colorScheme.onSurfaceVariant),
                  context: context,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityCtrl,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: getGlassInputDecoration(
                  hintText: 'Город',
                  prefixIcon: Icon(Icons.location_city_outlined, color: colorScheme.onSurfaceVariant),
                  context: context,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactCtrl,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: getGlassInputDecoration(
                  hintText: 'Контактный телефон',
                  prefixIcon: Icon(Icons.phone_outlined, color: colorScheme.onSurfaceVariant),
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
    final colorScheme = Theme.of(context).colorScheme;
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              const SizedBox(height: 4),
              Text(price, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)),
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
    final colorScheme = Theme.of(context).colorScheme;
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Наш бот поддержки доступен 24/7 в Telegram. Опишите вашу проблему и мы ответим в кратчайшие сроки.',
                style: TextStyle(color: colorScheme.onSurfaceVariant, height: 1.4, fontSize: 14),
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
                child: Text('Закрыть', style: TextStyle(color: colorScheme.onSurfaceVariant)),
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
    final colorScheme = Theme.of(context).colorScheme;

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
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: getGlassInputDecoration(
                  hintText: state.translate('form_name'),
                  prefixIcon: Icon(Icons.person_outline, color: colorScheme.onSurfaceVariant),
                  context: context,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: getGlassInputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, color: colorScheme.onSurfaceVariant),
                  context: context,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: getGlassInputDecoration(
                  hintText: state.translate('form_phone'),
                  prefixIcon: Icon(Icons.phone_outlined, color: colorScheme.onSurfaceVariant),
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
    final colorScheme = Theme.of(context).colorScheme;
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
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
                    style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8), height: 1.5),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: GlassAppBar(
        title: Text(
          state.translate('profile_title'),
          style: const TextStyle(fontWeight: FontWeight.w400, letterSpacing: -0.5),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).padding.bottom + 68 + 24 + 20,
        ),
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
                        color: colorScheme.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.primary, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.primary),
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
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (user['phone'] != null && user['phone'].toString().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.phone, color: colorScheme.onSurfaceVariant, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  user['phone'],
                                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
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
                  icon: Icon(Icons.edit_outlined, color: colorScheme.primary, size: 20),
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
                leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: colorScheme.primary),
                title: Text(
                  isDark ? state.translate('theme_dark') : state.translate('theme_light'),
                  style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                ),
                trailing: Switch(
                  value: isDark,
                  activeThumbColor: colorScheme.onPrimary,
                  activeTrackColor: colorScheme.primary,
                  onChanged: (val) {
                    HapticFeedback.lightImpact();
                    state.toggleTheme();
                  },
                ),
              ),
              Divider(height: 1, indent: 56, color: colorScheme.outlineVariant),
              // Language
              ListTile(
                leading: Icon(Icons.language, color: colorScheme.primary),
                title: Text(
                  state.translate('profile_lang'),
                  style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
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
                          color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.12),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          code,
                          style: TextStyle(
                            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Divider(height: 1, indent: 56, color: colorScheme.outlineVariant),
              ListTile(
                leading: Icon(Icons.wifi, color: colorScheme.primary),
                title: Text(
                  'Настройка подключения',
                  style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                ),
                trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
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
              Divider(height: 1, indent: 56, color: colorScheme.outlineVariant),
              _buildListRow(
                Icons.support_agent_outlined,
                state.translate('profile_support'),
                isDark,
                () => _showSupportDialog(state, isDark),
              ),
              Divider(height: 1, indent: 56, color: colorScheme.outlineVariant),
              _buildListRow(
                Icons.description_outlined,
                state.translate('profile_terms'),
                isDark,
                () => _showTermsBottomSheet(state, isDark),
              ),
              Divider(height: 1, indent: 56, color: colorScheme.outlineVariant),
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
    final colorScheme = Theme.of(context).colorScheme;
    
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
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '$exp / $nextLevelExp EXP',
                    style: GoogleFonts.spaceMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AviationProgressBar(value: percent),
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
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, idx) {
              final ach = _allAchievements[idx];
              final isUnlocked = userAchievements.any((ua) => ua['achievementId'] == ach['id']);
              
              return LiquidGlassCard(
                borderRadius: 18,
                padding: const EdgeInsets.all(12), // 20% increase in padding
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isUnlocked)
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.35),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        Opacity(
                          opacity: isUnlocked ? 1.0 : 0.4,
                          child: isUnlocked
                              ? Text(
                                  ach['icon'],
                                  style: const TextStyle(fontSize: 24),
                                )
                              : ColorFiltered(
                                  colorFilter: const ColorFilter.matrix(<double>[
                                    0.2126, 0.7152, 0.0722, 0, 0,
                                    0.2126, 0.7152, 0.0722, 0, 0,
                                    0.2126, 0.7152, 0.0722, 0, 0,
                                    0,      0,      0,      1, 0,
                                  ]),
                                  child: Text(
                                    ach['icon'],
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ach['name'],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        ach['desc'],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'SF Pro Text',
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ach['reward'],
                      style: GoogleFonts.spaceMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurfaceVariant.withOpacity(0.8),
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
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
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
    final colorScheme = Theme.of(context).colorScheme;

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
                        Icon(Icons.wifi, color: colorScheme.primary),
                        const SizedBox(width: 10),
                        Text(
                          'Подключение к ПК',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: colorScheme.onSurface,
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
                            color: colorScheme.onSurfaceVariant,
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
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller,
                      style: TextStyle(color: colorScheme.onSurface),
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
                          child: Text('Сбросить', style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
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
                                      statusColor = colorScheme.primary;
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
