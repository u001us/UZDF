import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_widgets.dart';
import 'app_state.dart';
import 'map_screen.dart';
import 'home_screen.dart';
import 'blog_screen.dart';
import 'store_screen.dart';
import 'profile_screen.dart';
import 'api_service.dart';
import 'auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  await AppState().init();
  runApp(const UzdfApp());
}


class UzdfApp extends StatelessWidget {
  const UzdfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppState().isDarkMode,
      builder: (context, isDark, child) {
        final baseTheme = ThemeData(brightness: isDark ? Brightness.dark : Brightness.light);
        final soraTheme = GoogleFonts.soraTextTheme(baseTheme.textTheme);
        
        final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
        final subtitleColor = isDark ? Colors.white70 : const Color(0xFF475569);
        
        final customTextTheme = soraTheme.copyWith(
          displayLarge: soraTheme.displayLarge?.copyWith(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w700, letterSpacing: -1.2, color: textColor),
          displayMedium: soraTheme.displayMedium?.copyWith(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w700, letterSpacing: -1.2, color: textColor),
          displaySmall: soraTheme.displaySmall?.copyWith(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w700, letterSpacing: -1.2, color: textColor),
          headlineLarge: soraTheme.headlineLarge?.copyWith(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w700, letterSpacing: -1.2, color: textColor),
          headlineMedium: soraTheme.headlineMedium?.copyWith(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w700, letterSpacing: -1.2, color: textColor),
          headlineSmall: soraTheme.headlineSmall?.copyWith(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w700, letterSpacing: -1.2, color: textColor),
          titleLarge: soraTheme.titleLarge?.copyWith(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w700, letterSpacing: -1.2, color: textColor),
          titleMedium: soraTheme.titleMedium?.copyWith(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w600, letterSpacing: -0.8, color: textColor),
          titleSmall: soraTheme.titleSmall?.copyWith(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w600, letterSpacing: -0.8, color: textColor),
          bodyLarge: soraTheme.bodyLarge?.copyWith(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w400, letterSpacing: -0.3, height: 1.6, color: textColor),
          bodyMedium: soraTheme.bodyMedium?.copyWith(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w400, letterSpacing: -0.3, height: 1.6, color: subtitleColor),
          bodySmall: soraTheme.bodySmall?.copyWith(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w400, letterSpacing: -0.3, height: 1.6, color: subtitleColor),
          labelLarge: soraTheme.labelLarge?.copyWith(fontFamily: 'SF Pro Display', color: textColor),
          labelMedium: soraTheme.labelMedium?.copyWith(fontFamily: 'SF Pro Display', color: subtitleColor),
          labelSmall: soraTheme.labelSmall?.copyWith(fontFamily: 'SF Pro Display', color: subtitleColor),
        );

        return MaterialApp(
          title: 'UZDF',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: isDark ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: isDark ? const Color(0xFF0A0A1A) : const Color(0xFFF8FAFC),
            primaryColor: const Color(0xFF007AFF),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF007AFF),
              brightness: isDark ? Brightness.dark : Brightness.light,
              primary: const Color(0xFF007AFF),
              secondary: const Color(0xFF007AFF),
              surface: isDark ? const Color(0xFF0A0A1A) : const Color(0xFFF8FAFC),
            ),
            cardTheme: const CardThemeData(
              elevation: 0,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(22))),
              clipBehavior: Clip.antiAlias,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              iconTheme: IconThemeData(color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
              titleTextStyle: TextStyle(
                fontFamily: 'SF Pro Display',
                fontFamilyFallback: [GoogleFonts.sora().fontFamily ?? 'Sora'],
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                letterSpacing: -0.5,
              ),
            ),
            fontFamily: 'SF Pro Display',
            fontFamilyFallback: [GoogleFonts.sora().fontFamily ?? 'Sora'],
            textTheme: customTextTheme,
            useMaterial3: true,
          ),
          home: const SplashScreen(),
          onGenerateRoute: (settings) {
            Widget? screen;
            if (settings.name == '/navigation') {
              screen = const MainNavigation();
            }
            if (screen == null) return null;
            return PageRouteBuilder(
              transitionDuration: kSlow,
              reverseTransitionDuration: kNormal,
              pageBuilder: (context, animation, secondaryAnimation) => screen!,
              transitionsBuilder: (_, animation, secondary, child) {
                final slide = Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation, curve: kSpring
                ));
                final secondarySlide = Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(-0.08, 0),
                ).animate(CurvedAnimation(
                  parent: secondary, curve: kSmooth
                ));
                return SlideTransition(
                  position: secondarySlide,
                  child: FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: slide, child: child
                    )
                  )
                );
              }
            );
          },
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _hoverController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotate;
  late Animation<double> _textFade;
  late Animation<double> _textLetterSpacing;
  late Animation<double> _subtitleFade;

  late Animation<double> _radarScale;
  late Animation<double> _radarOpacity;

  late Animation<double> _hoverOffset;

  @override
  void initState() {
    super.initState();

    // Main intro animation controller
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _logoScale = Tween<double>(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoRotate = Tween<double>(begin: -0.4, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    _textLetterSpacing = Tween<double>(begin: 16.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    // Pulse/radar controller (infinite loop)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _radarScale = Tween<double>(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOut,
      ),
    );

    _radarOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOut,
      ),
    );

    // Hover/float controller (infinite loop, reverse)
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _hoverOffset = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(
        parent: _hoverController,
        curve: Curves.easeInOut,
      ),
    );

    _mainController.forward();
    
    // Start ambient animations after the logo settles
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _pulseController.repeat();
        _hoverController.repeat(reverse: true);
      }
    });

    // 3.8 seconds delay before navigation to allow animation completion
    Timer(const Duration(milliseconds: 3800), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainNavigation(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Theme-dependent styles and assets
    final backgroundColor1 = isDark ? const Color(0xFF030712) : const Color(0xFFF4F7FF);
    final backgroundColor2 = isDark ? const Color(0xFF0B1530) : const Color(0xFFFFFFFF);
    
    final primaryColor = isDark ? const Color(0xFF00E5FF) : const Color(0xFF0066FF);

    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtitleColor = isDark ? const Color(0xFF00E5FF) : const Color(0xFF0066FF);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [backgroundColor2, backgroundColor1],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([_logoScale, _hoverOffset, _pulseController]),
                builder: (context, child) {
                  final scale = _logoScale.value;
                  final hoverY = _hoverOffset.value;
                  
                  return Transform.translate(
                    offset: Offset(0, hoverY),
                    child: Transform.scale(
                      scale: scale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Radar Pulse 2 (slight scale offset)
                          Opacity(
                            opacity: _radarOpacity.value * 0.5,
                            child: Container(
                              width: 90 * _radarScale.value,
                              height: 90 * _radarScale.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryColor,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                          // Outer Radar Pulse 1
                          Opacity(
                            opacity: _radarOpacity.value,
                            child: Container(
                              width: 130 * _radarScale.value,
                              height: 130 * _radarScale.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.5),
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                          // Main Flight Logo Card
                          RotationTransition(
                            turns: _logoRotate,
                            child: GlassContainer(
                              borderRadius: 100,
                              padding: const EdgeInsets.all(26),
                              opacity: isDark ? 0.15 : 0.6,
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/logo.png',
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 54),
              
              // Animated Text (UZDF)
              AnimatedBuilder(
                animation: Listenable.merge([_textFade, _textLetterSpacing]),
                builder: (context, child) {
                  return Opacity(
                    opacity: _textFade.value,
                    child: Text(
                      'UZDF',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                        letterSpacing: _textLetterSpacing.value,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 8),
              
              // Animated Subtitle (УЗБЕКИСТАН)
              FadeTransition(
                opacity: _subtitleFade,
                child: Text(
                  'Uzbekistan Drone Federation',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: subtitleColor.withValues(alpha: 0.9),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Список всех экранов приложения
  final List<Widget> _screens = [
    const HomeScreen(),
    const BlogScreen(),
    const MapScreen(),
    const StoreScreen(),
    const ProfileScreen(),
  ];

  Widget _buildNavIcon(IconData icon, int index, bool isDark) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _currentIndex = index);
      },
      child: Container(
        width: 56,
        height: 56,
        color: Colors.transparent, // Expand hit test target
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: kNormal,
              curve: kSpring,
              width: isSelected ? 48 : 0,
              height: isSelected ? 48 : 0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF007AFF).withOpacity(0.2),
              ),
            ),
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: kNormal,
              curve: kBounce,
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF007AFF)
                    : (isDark ? Colors.white.withOpacity(0.45) : Colors.black.withOpacity(0.4)),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ValueListenableBuilder<String?>(
      valueListenable: ApiService.tokenNotifier,
      builder: (context, token, child) {
        if (token == null) {
          return AuthScreen(
            onLoginSuccess: () {
              setState(() {
                _currentIndex = 0;
              });
            },
          );
        }

        return ValueListenableBuilder<String>(
          valueListenable: AppState().currentLanguage,
          builder: (context, lang, child) {
            return Scaffold(
              body: LiquidBackground(
                child: Stack(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey<int>(_currentIndex),
                        child: _screens[_currentIndex],
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 24,
                      child: LiquidGlassCard(
                        borderRadius: 36,
                        height: 68,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNavIcon(Icons.school, 0, isDark),
                            _buildNavIcon(Icons.article, 1, isDark),
                            _buildNavIcon(Icons.map, 2, isDark),
                            _buildNavIcon(Icons.shopping_cart, 3, isDark),
                            _buildNavIcon(Icons.person, 4, isDark),
                          ],
                        ),
                      ),
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