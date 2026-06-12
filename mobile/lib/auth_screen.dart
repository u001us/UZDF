import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'glass_widgets.dart';
import 'api_service.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const AuthScreen({super.key, required this.onLoginSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '623890287900-og7m9d6pi7i6ptk525afmc7kdalp2php.apps.googleusercontent.com',
  );

  bool _isLoginTab = true;
  bool _isLoading = false;
  String? _verificationEmail;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar('Заполните все поля');
      return;
    }

    if (!email.contains('@')) {
      _showSnackbar('Неверный формат Email');
      return;
    }

    setState(() => _isLoading = true);

    if (_isLoginTab) {
      // Log in
      final success = await ApiService.login(email, password);
      if (success) {
        await ApiService.fetchProfile();
        widget.onLoginSuccess();
      } else {
        _showSnackbar('Ошибка авторизации. Проверьте учетные данные.');
      }
    } else {
      // Register
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final confirmPass = _confirmPasswordController.text;

      if (name.isEmpty) {
        _showSnackbar('Заполните имя');
        setState(() => _isLoading = false);
        return;
      }
      if (phone.isEmpty || phone.length < 7) {
        _showSnackbar('Введите номер телефона');
        setState(() => _isLoading = false);
        return;
      }
      if (password.length < 6) {
        _showSnackbar('Пароль должен быть не менее 6 символов');
        setState(() => _isLoading = false);
        return;
      }
      if (password != confirmPass) {
        _showSnackbar('Пароли не совпадают');
        setState(() => _isLoading = false);
        return;
      }

      final result = await ApiService.register(name, email, password, phone);
      if (result != null) {
        if (result['message'] == 'VERIFICATION_REQUIRED') {
          setState(() {
            _verificationEmail = email;
            _codeController.clear();
          });
          _showSnackbar('Код подтверждения отправлен на вашу почту');
        } else if (result.containsKey('error')) {
          _showSnackbar(result['error']);
        } else {
          await ApiService.fetchProfile();
          widget.onLoginSuccess();
        }
      } else {
        _showSnackbar('Ошибка регистрации. Возможно, email уже используется.');
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVerifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty || code.length != 6) {
      _showSnackbar('Введите 6-значный код подтверждения');
      return;
    }

    setState(() => _isLoading = true);
    final result = await ApiService.verifyCode(_verificationEmail!, code);
    if (result != null && result['success'] == true) {
      await ApiService.fetchProfile();
      widget.onLoginSuccess();
    } else {
      final errMsg = result?['error'] ?? 'Неверный код подтверждения';
      _showSnackbar(errMsg);
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => _isLoading = true);
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        final success = await ApiService.loginWithGoogleReal(idToken);
        if (success) {
          await ApiService.fetchProfile();
          widget.onLoginSuccess();
        } else {
          _showSnackbar('Ошибка авторизации на сервере UZDF');
        }
      } else {
        _showSnackbar('Не удалось получить Google ID Token');
      }
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      _showSnackbar('Ошибка входа через Google: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
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
                        hintText: 'например, 190.191.3.112:3000',
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
                                        statusMessage = 'Ошибка подключения. Проверьте адрес и порт.';
                                        statusColor = Colors.redAccent;
                                      });
                                    }
                                  },
                            child: const Text('Готово'),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [Color(0xFF0A1128), Color(0xFF000000)],
                )
              : const RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [Color(0xFFF0F4FF), Color(0xFFFFFFFF)],
                ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Brand Logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipOval(
                            child: Image.asset(
                              'assets/logo.png',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'UZDF',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black87,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _verificationEmail != null
                            ? 'Подтвердите ваш адрес электронной почты'
                            : (_isLoginTab ? 'Войдите в аккаунт пилота БПЛА' : 'Создайте новый аккаунт пилота'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 36),

                      // Auth Card Container
                      GlassContainer(
                        padding: const EdgeInsets.all(24),
                        child: _verificationEmail != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Подтверждение почты',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Мы отправили 6-значный код подтверждения на почту:\n$_verificationEmail',
                                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 28),
                                  _buildTextField(
                                    controller: _codeController,
                                    hintText: 'Код подтверждения (6 цифр)',
                                    icon: Icons.security_outlined,
                                    isDark: isDark,
                                    keyboardType: TextInputType.number,
                                  ),
                                  const SizedBox(height: 24),
                                  GlassButton(
                                    onPressed: _isLoading ? null : _handleVerifyCode,
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          )
                                        : const Text(
                                            'Подтвердить',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () {
                                            setState(() {
                                              _verificationEmail = null;
                                              _codeController.clear();
                                            });
                                          },
                                    child: const Text(
                                      'Изменить почту / Назад',
                                      style: TextStyle(color: Color(0xFF0066FF)),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Tabs selector
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => setState(() => _isLoginTab = true),
                                          child: Column(
                                            children: [
                                              Text(
                                                'Войти',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: _isLoginTab
                                                      ? const Color(0xFF007AFF)
                                                      : Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                height: 2,
                                                color: _isLoginTab
                                                    ? const Color(0xFF007AFF)
                                                    : Colors.transparent,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => setState(() => _isLoginTab = false),
                                          child: Column(
                                            children: [
                                              Text(
                                                'Регистрация',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: !_isLoginTab
                                                      ? const Color(0xFF007AFF)
                                                      : Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                height: 2,
                                                color: !_isLoginTab
                                                    ? const Color(0xFF007AFF)
                                                    : Colors.transparent,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 28),

                                  // Form Inputs
                                  if (!_isLoginTab) ...[
                                    _buildTextField(
                                      controller: _nameController,
                                      hintText: 'Имя',
                                      icon: Icons.person_outline,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: _phoneController,
                                      hintText: 'Номер телефона (+998...)',
                                      icon: Icons.phone_outlined,
                                      isDark: isDark,
                                      keyboardType: TextInputType.phone,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  _buildTextField(
                                    controller: _emailController,
                                    hintText: 'Email',
                                    icon: Icons.email_outlined,
                                    isDark: isDark,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _passwordController,
                                    hintText: 'Пароль',
                                    icon: Icons.lock_outline,
                                    isDark: isDark,
                                    obscureText: true,
                                  ),
                                  if (!_isLoginTab) ...[
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: _confirmPasswordController,
                                      hintText: 'Подтвердите пароль',
                                      icon: Icons.lock_outline,
                                      isDark: isDark,
                                      obscureText: true,
                                    ),
                                  ],
                                  const SizedBox(height: 32),

                                  // Submit Button
                                  GlassButton(
                                    onPressed: _isLoading ? null : _handleAuth,
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          )
                                        : Text(
                                            _isLoginTab ? 'Войти в аккаунт' : 'Зарегистрироваться',
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                  ),
                                ],
                              ),
                      ),
                      if (_verificationEmail == null) ...[
                        const SizedBox(height: 24),

                        // Divider "или"
                        Row(
                          children: [
                            Expanded(child: Divider(color: isDark ? Colors.grey[800] : Colors.grey[300])),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('или', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            ),
                            Expanded(child: Divider(color: isDark ? Colors.grey[800] : Colors.grey[300])),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Google Sign-In Button
                        GlassButton(
                          opacity: isDark ? 0.08 : 0.5,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.05),
                              Colors.white.withValues(alpha: 0.02),
                            ],
                          ),
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.g_mobiledata_rounded,
                                size: 24,
                                color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Войти через Google',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.wifi_find_rounded, color: Colors.white70),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showConnectionDialog(context, isDark);
                  },
                  tooltip: 'Настройка подключения',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: getGlassInputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: isDark ? Colors.white60 : Colors.black45),
        context: context,
      ),
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
    );
  }
}
