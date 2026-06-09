import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'glass_widgets.dart';
import 'app_state.dart';
import 'api_service.dart';
import 'course_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late Future<List<dynamic>> _coursesFuture;
  late AnimationController _listController;
  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _coursesFuture = ApiService.fetchCourses();
    _listController = AnimationController(
      duration: kVerySlow,
      vsync: this,
    );
    _refreshController = AnimationController(
      duration: kSlow,
      vsync: this,
    );
    _listController.forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _refreshCourses() {
    _refreshController.forward(from: 0.0);
    setState(() {
      _coursesFuture = ApiService.fetchCourses();
      _listController.reset();
      _coursesFuture.then((_) {
        if (mounted) {
          _listController.forward();
        }
      });
    });
  }

  /// Find the current active course (in_progress or last started)
  Map<String, dynamic>? _findActiveCourse(List<dynamic> courses) {
    // First: find a course with in_progress steps
    for (final c in courses) {
      if (c['isLocked'] == true) continue;
      final steps = c['steps'] as List<dynamic>? ?? [];
      final hasInProgress = steps.any((s) => s['userProgress']?['status'] == 'in_progress');
      final hasCompleted = steps.any((s) => s['userProgress']?['status'] == 'completed');
      if (hasInProgress || hasCompleted) return c as Map<String, dynamic>;
    }
    // Fallback: first unlocked course
    for (final c in courses) {
      if (c['isLocked'] != true) return c as Map<String, dynamic>;
    }
    return null;
  }

  /// True if user has any progress in a course
  bool _hasProgress(Map<String, dynamic> course) {
    final steps = course['steps'] as List<dynamic>? ?? [];
    return steps.any((s) {
      final status = s['userProgress']?['status'];
      return status == 'in_progress' || status == 'completed';
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
          body: RefreshIndicator(
            color: const Color(0xFF007AFF),
            backgroundColor: Colors.white.withOpacity(0.1),
            strokeWidth: 2.0,
            displacement: 60,
            onRefresh: () async => _refreshCourses(),
            child: FutureBuilder<List<dynamic>>(
              future: _coursesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CustomScrollView(
                    physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: [
                      SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(color: Color(0xFF007AFF)),
                        ),
                      ),
                    ],
                  );
                }

                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: [
                      _buildSliverAppBar(state),
                      SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 16),
                          _buildPromoBanner(state, null, isDark),
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              state.translate('courses_all'),
                              style: const TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontFamilyFallback: ['Sora'],
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Center(
                            child: Text(
                              'Нет доступных курсов',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  );
                }

                final courses = snapshot.data!;
                final activeCourse = _findActiveCourse(courses);
                final bannerCourse = activeCourse ?? (courses.isNotEmpty ? courses.first as Map<String, dynamic> : null);

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    _buildSliverAppBar(state),
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 16, bottom: 100), // padding bottom to clear the floating navigation
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final delay = index * 80;
                            final itemAnimation = CurvedAnimation(
                              parent: _listController,
                              curve: Interval(
                                (delay / 800.0).clamp(0.0, 1.0),
                                ((delay + 400.0) / 800.0).clamp(0.0, 1.0),
                                curve: kSpring,
                              ),
                            );

                            Widget child;
                            if (index == 0) {
                              child = _buildPromoBanner(state, bannerCourse, isDark, activeCourse: activeCourse, courses: courses);
                            } else if (index == 1) {
                              child = Padding(
                                padding: const EdgeInsets.only(top: 24, bottom: 16, left: 16, right: 16),
                                child: Text(
                                  state.translate('courses_all'),
                                  style: const TextStyle(
                                    fontFamily: 'SF Pro Display',
                                    fontFamilyFallback: ['Sora'],
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                              );
                            } else {
                              final course = courses[index - 2] as Map<String, dynamic>;
                              final isLocked = course['isLocked'] == true;
                              final steps = course['steps'] as List<dynamic>? ?? [];
                              final stepsCount = steps.length;
                              final completedCount = steps.where((s) => s['userProgress']?['status'] == 'completed').length;
                              final progress = stepsCount > 0 ? completedCount / stepsCount : 0.0;
                              
                              String statusLabel;
                              if (isLocked) {
                                statusLabel = '🔒 Заблокировано';
                              } else if (completedCount == stepsCount && stepsCount > 0) {
                                statusLabel = '✅ Завершено';
                              } else if (completedCount > 0) {
                                statusLabel = '$completedCount/$stepsCount шагов';
                              } else {
                                statusLabel = stepsCount > 0 ? 'Шагов: $stepsCount' : 'Без шагов';
                              }

                              child = Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    if (isLocked) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Этот курс заблокирован. Пройдите предыдущие курсы по порядку!'),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      GlassRoute(
                                        page: CourseDetailScreen(course: course),
                                      ),
                                    ).then((_) => _refreshCourses());
                                  },
                                  child: _buildCourseCard(
                                    course['title'] ?? '',
                                    course['description'] ?? '',
                                    statusLabel,
                                    progress.toDouble(),
                                    isDark,
                                    isLocked: isLocked,
                                  ),
                                ),
                              );
                            }

                            return AnimatedBuilder(
                              animation: _listController,
                              builder: (_, childWidget) => FadeTransition(
                                opacity: Tween(begin: 0.0, end: 1.0).animate(itemAnimation),
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.08),
                                    end: Offset.zero,
                                  ).animate(itemAnimation),
                                  child: childWidget,
                                ),
                              ),
                              child: child,
                            );
                          },
                          childCount: courses.length + 2,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  SliverAppBar _buildSliverAppBar(AppState state) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      expandedHeight: 90,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: Colors.black.withOpacity(0.15),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48), // Spacer to balance refresh button
                    Text(
                      state.translate('courses_title'),
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontFamilyFallback: ['Sora'],
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: RotationTransition(
                        turns: _refreshController,
                        child: const Icon(Icons.refresh_rounded, color: Colors.white),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _refreshCourses();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner(
    AppState state,
    Map<String, dynamic>? bannerCourse,
    bool isDark, {
    Map<String, dynamic>? activeCourse,
    List<dynamic>? courses,
  }) {
    final hasProgress = activeCourse != null && _hasProgress(activeCourse);
    final buttonLabel = hasProgress ? 'Продолжить обучение' : state.translate('courses_start');
    final title = bannerCourse?['title'] ?? 'Базовый курс пилотирования';
    final desc = bannerCourse?['description'] ?? 'Освойте основы управления дроном за 4 недели.';

    return FloatingHero(
      child: Container(
        height: 230,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow Blob 1
            Positioned(
              top: -30,
              left: -30,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF007AFF).withOpacity(0.35),
                ),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
            ),
            // Glow Blob 2
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF5856D6).withOpacity(0.2),
                ),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
            ),
            // Hero card wrapper
            LiquidGlassCard(
              height: 220,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasProgress)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '▶ Продолжается',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontFamilyFallback: ['Sora'],
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontFamilyFallback: ['Sora'],
                      color: Colors.white.withOpacity(0.75),
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  // Premium start button
                  LiquidButton(
                    normalOpacity: 0.25,
                    pressedOpacity: 0.35,
                    onTap: bannerCourse == null
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            Navigator.push(
                              context,
                              GlassRoute(
                                page: CourseDetailScreen(course: bannerCourse),
                              ),
                            ).then((_) => _refreshCourses());
                          },
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          buttonLabel,
                          style: const TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontFamilyFallback: ['Sora'],
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF007AFF),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(String title, String desc, String status, double progress, bool isDark, {bool isLocked = false}) {
    Widget card = LiquidGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontFamilyFallback: ['Sora'],
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: Colors.white,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              if (isLocked) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.lock_rounded,
                  color: Colors.white.withOpacity(0.4),
                  size: 20,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontFamilyFallback: ['Sora'],
              color: Colors.white.withOpacity(0.65),
              height: 1.6,
              fontWeight: FontWeight.w400,
              fontSize: 14,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (!isLocked) ...[
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFF1B233D),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF007AFF)),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildStepsBadge(status),
              ] else ...[
                Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontFamilyFallback: ['Sora'],
                    color: Colors.white.withOpacity(0.4),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          )
        ],
      ),
    );

    if (isLocked) {
      return Opacity(
        opacity: 0.4,
        child: card,
      );
    }
    return card;
  }

  Widget _buildStepsBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF34C759),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: const TextStyle(
              fontFamily: 'SF Pro Display',
              fontFamilyFallback: ['Sora'],
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}