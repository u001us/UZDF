import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_state.dart';
import 'api_service.dart';
import 'glass_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppState().currentLanguage,
      builder: (context, lang, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: AppState().isDarkMode,
          builder: (context, isDark, child) {
            final state = AppState();

            return Scaffold(
              appBar: GlassAppBar(
                title: Text(
                  state.translate('settings_title'),
                  style: const TextStyle(fontWeight: FontWeight.w400, letterSpacing: -0.5),
                ),
              ),
              body: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Profile Quick Panel
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF007AFF).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF007AFF), width: 1.5),
                          ),
                          child: const Center(
                            child: Text(
                              'U',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF007AFF),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Иван Иванов",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "+998 90 123 45 67",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildGroupHeader('Настройки приложения'),
                  // Group 1: Theme & Language & Connection Config
                  _buildCardGroup(
                    isDark: isDark,
                    children: [
                      // Theme toggler
                      ListTile(
                        leading: Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          color: const Color(0xFF007AFF),
                        ),
                        title: Text(
                          isDark ? state.translate('theme_dark') : state.translate('theme_light'),
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                            fontWeight: FontWeight.w600,
                          ),
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
                      Divider(height: 1, indent: 56, color: Colors.white.withValues(alpha: 0.15)),
                      // Language selector
                      ListTile(
                        leading: const Icon(
                          Icons.language,
                          color: Color(0xFF007AFF),
                        ),
                        title: Text(
                          state.translate('profile_lang'),
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: DropdownButton<String>(
                          value: lang,
                          underline: const SizedBox(),
                          dropdownColor: isDark ? const Color(0xFF1A1F36) : Colors.white,
                          iconEnabledColor: const Color(0xFF007AFF),
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                            fontWeight: FontWeight.bold,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'ru', child: Text('RU')),
                            DropdownMenuItem(value: 'uz', child: Text('UZ')),
                            DropdownMenuItem(value: 'en', child: Text('EN')),
                          ],
                          onChanged: (newLang) {
                            HapticFeedback.lightImpact();
                            if (newLang != null) {
                              state.setLanguage(newLang);
                            }
                          },
                        ),
                      ),
                      Divider(height: 1, indent: 56, color: Colors.white.withValues(alpha: 0.15)),
                      // Connection config
                      ListTile(
                        leading: const Icon(
                          Icons.settings,
                          color: Color(0xFF007AFF),
                        ),
                        title: Text(
                          state.translate('settings_app_config'),
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showConnectionDialog(context, isDark);
                        },
                      ),
                    ],
                  ),

                  _buildGroupHeader('Информация и действия'),
                  // Group 2: Achievements, Cart, Support
                  _buildCardGroup(
                    isDark: isDark,
                    children: [
                      _settingItem(Icons.emoji_events, state.translate('settings_achievements'), isDark),
                      Divider(height: 1, indent: 56, color: Colors.white.withValues(alpha: 0.15)),
                      _settingItem(Icons.shopping_cart, state.translate('settings_cart'), isDark),
                      Divider(height: 1, indent: 56, color: Colors.white.withValues(alpha: 0.15)),
                      _settingItem(Icons.help_outline, state.translate('settings_support'), isDark),
                    ],
                  ),
                  
                  // Group 3: Logout
                  _buildCardGroup(
                    isDark: isDark,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: Text(
                          state.translate('profile_logout'),
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          await ApiService.clearSession();
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
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
          color: Colors.grey.withValues(alpha: 0.8),
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

  Widget _settingItem(IconData icon, String title, bool isDark, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF007AFF)),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) {
          onTap();
        }
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
                            color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black54,
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