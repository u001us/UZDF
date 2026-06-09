import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import 'glass_widgets.dart';
import 'app_state.dart';
import 'api_service.dart';

class CourseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final state = AppState();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final steps = course['steps'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: GlassAppBar(
        title: Text(course['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w400, letterSpacing: -0.5)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${ApiService.currentUser?['courseLives'] ?? 3}',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: LiquidBackground(
        child: steps.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book_outlined, size: 64, color: Colors.white.withOpacity(0.4)),
                      const SizedBox(height: 24),
                      Text(
                        'В этом курсе пока нет уроков',
                        style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.6)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.all(16),
                itemCount: steps.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course['description'] ?? '',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.white.withOpacity(0.75),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Divider(color: Colors.white.withOpacity(0.15)),
                          const SizedBox(height: 8),
                          Text(
                            state.translate('courses_steps'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final step = steps[index - 1];
                  final stepStatus = step['userProgress']?['status'] ?? 'not_started';
                  final isCompleted = stepStatus == 'completed';
                  final isInProgress = stepStatus == 'in_progress';
                  final isFinalExam = step['isFinalExam'] == true;
  
                  return GestureDetector(
                    onTap: () {
                      if (step['isLocked'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Завершите предыдущий урок, чтобы разблокировать этот шаг'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        GlassRoute(
                          page: StepDetailScreen(step: step),
                        ),
                      ).then((_) {
                        // Refresh on return
                      });
                    },
                    child: GlassContainer(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      borderRadius: 14,
                      border: Border.all(
                        color: isCompleted
                            ? Colors.green.withOpacity(0.5)
                            : isFinalExam
                                ? const Color(0xFF007AFF).withOpacity(0.4)
                                : Colors.white.withOpacity(0.25),
                        width: 1.0,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? Colors.green.withOpacity(0.15)
                                  : isFinalExam
                                      ? const Color(0xFF007AFF).withOpacity(0.1)
                                      : const Color(0xFF007AFF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isCompleted
                                  ? Icons.check_circle
                                  : isFinalExam
                                      ? Icons.emoji_events
                                      : step['type'] == 'quiz'
                                          ? Icons.quiz
                                          : step['type'] == 'video'
                                              ? Icons.play_circle_outline
                                              : Icons.article_outlined,
                              color: isCompleted
                                  ? Colors.green
                                  : isFinalExam
                                      ? const Color(0xFF007AFF)
                                      : const Color(0xFF007AFF),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step['title'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (isFinalExam)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Финальный экзамен',
                                          style: TextStyle(fontSize: 10, color: Color(0xFF007AFF), fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    else
                                      Text(
                                        step['type'] == 'quiz' ? 'Тест' : step['type'] == 'video' ? 'Видеоурок' : 'Теоретический урок',
                                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                                      ),
                                    if (isInProgress && !isCompleted) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'В процессе',
                                          style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (step['isLocked'] == true)
                            Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.4), size: 20)
                          else if (isCompleted)
                            const Icon(Icons.check_circle, color: Colors.green, size: 22)
                          else
                            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.4)),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class StepDetailScreen extends StatefulWidget {
  final Map<String, dynamic> step;

  const StepDetailScreen({super.key, required this.step});

  @override
  State<StepDetailScreen> createState() => _StepDetailScreenState();
}

class _StepDetailScreenState extends State<StepDetailScreen> {
  bool _isLoading = true;
  bool _isBlocked = false;
  String _blockMessage = '';

  String _status = 'not_started';
  bool _scrollCompleted = false;
  int _secondsSpent = 0;
  int _estimatedReadTime = 0;
  int _remainingVideoSeconds = 0;
  int _videoDuration = 0;

  Timer? _readingTimer;
  Timer? _videoTimer;
  ScrollController? _scrollController;

  bool _isQuiz = false;
  bool _isFinalExam = false;
  List<dynamic> _quizQuestions = [];
  final Map<String, String> _selectedAnswers = {};
  bool _quizSubmitted = false;
  bool _quizPassed = false;
  double _quizScore = 0.0;
  int _attemptsUsed = 0;
  List<dynamic> _failedTopics = [];
  DateTime? _cooldownUntil;

  @override
  void initState() {
    super.initState();
    _isQuiz = widget.step['type'] == 'quiz';
    _isFinalExam = widget.step['isFinalExam'] ?? false;
    _activateSecureMode();
    _loadStepData();
  }

  @override
  void dispose() {
    _deactivateSecureMode();
    _readingTimer?.cancel();
    _videoTimer?.cancel();
    _scrollController?.dispose();
    super.dispose();
  }

  // Prevents screenshots on Android
  Future<void> _activateSecureMode() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await FlutterWindowManagerPlus.addFlags(FlutterWindowManagerPlus.FLAG_SECURE);
      } catch (e) {
        debugPrint('Error setting FLAG_SECURE: $e');
      }
    }
  }

  Future<void> _deactivateSecureMode() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await FlutterWindowManagerPlus.clearFlags(FlutterWindowManagerPlus.FLAG_SECURE);
      } catch (e) {
        debugPrint('Error clearing FLAG_SECURE: $e');
      }
    }
  }

  Future<void> _loadStepData() async {
    setState(() {
      _isLoading = true;
      _isBlocked = false;
      _blockMessage = '';
      _quizSubmitted = false;
    });

    final stepId = widget.step['id'];

    // Call startStep to initialize/get progress
    final startRes = await ApiService.startStep(stepId);
    if (startRes == null) {
      setState(() {
        _isBlocked = true;
        _blockMessage = 'Не удалось подключиться к серверу';
        _isLoading = false;
      });
      return;
    }

    if (startRes.containsKey('error')) {
      setState(() {
        _isBlocked = true;
        _blockMessage = startRes['error'];
        _isLoading = false;
      });
      return;
    }

    final progress = startRes['progress'] as Map<String, dynamic>;
    _status = progress['status'] ?? 'not_started';
    _scrollCompleted = progress['scrollCompleted'] ?? false;
    _attemptsUsed = progress['quizAttempts'] ?? 0;
    
    if (progress['cooldownUntil'] != null) {
      _cooldownUntil = DateTime.parse(progress['cooldownUntil']);
    }

    if (_isQuiz) {
      // If completed previously, show results or allow review
      if (_status == 'completed') {
        _quizSubmitted = true;
        _quizPassed = true;
        _quizScore = (progress['timeSpentSeconds'] as num?)?.toDouble() ?? 100.0;
      }

      // Fetch quiz questions (which are shuffled and secure)
      final quizRes = await ApiService.fetchQuiz(stepId);
      if (quizRes == null) {
        setState(() {
          _isBlocked = true;
          _blockMessage = 'Не удалось получить вопросы теста';
          _isLoading = false;
        });
        return;
      }
      if (quizRes.containsKey('error')) {
        setState(() {
          _isBlocked = true;
          _blockMessage = quizRes['error'];
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _quizQuestions = quizRes['questions'] as List<dynamic>? ?? [];
        _attemptsUsed = quizRes['attemptsUsed'] ?? _attemptsUsed;
        _isLoading = false;
      });
    } else {
      if (widget.step['type'] == 'text') {
        _estimatedReadTime = startRes['estimatedReadTimeSeconds'] ?? 0;
        _scrollController = ScrollController();
        _scrollController!.addListener(_onScroll);

        _secondsSpent = progress['timeSpentSeconds'] ?? 0;
        _readingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_status != 'completed') {
            setState(() {
              _secondsSpent++;
            });
          }
        });

        // Auto-complete scroll for very short texts (no scrollable content)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController != null && _scrollController!.hasClients) {
            final maxExtent = _scrollController!.position.maxScrollExtent;
            if (maxExtent < 20) {
              setState(() {
                _scrollCompleted = true;
              });
            }
          }
        });
      } else if (widget.step['type'] == 'video') {
        _videoDuration = startRes['videoDurationSeconds'] ?? 0;
        
        if (progress['lessonStartedAt'] != null) {
          final startedAt = DateTime.parse(progress['lessonStartedAt']);
          final elapsed = DateTime.now().difference(startedAt).inSeconds;
          _remainingVideoSeconds = _videoDuration - elapsed;
          if (_remainingVideoSeconds < 0) _remainingVideoSeconds = 0;
        } else {
          _remainingVideoSeconds = _videoDuration;
        }

        if (_remainingVideoSeconds > 0 && _status != 'completed') {
          _videoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (_remainingVideoSeconds > 0) {
              setState(() {
                _remainingVideoSeconds--;
              });
            } else {
              _videoTimer?.cancel();
            }
          });
        }
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController == null || !_scrollController!.hasClients) return;
    final maxScroll = _scrollController!.position.maxScrollExtent;
    final currentScroll = _scrollController!.position.pixels;
    // Also handle short content (maxScroll < 20)
    if (maxScroll < 20 || currentScroll >= maxScroll - 40) {
      if (!_scrollCompleted) {
        setState(() {
          _scrollCompleted = true;
        });
      }
    }
  }

  Future<void> _completeLesson() async {
    setState(() {
      _isLoading = true;
    });

    final res = await ApiService.completeStepSecure(
      stepId: widget.step['id'],
      scrollCompleted: _scrollCompleted,
      timeSpentSeconds: _secondsSpent,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (res == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка соединения с сервером')),
      );
      return;
    }

    if (res.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'])),
      );
      return;
    }

    setState(() {
      _status = 'completed';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message'] ?? 'Урок завершен!')),
    );
  }

  Future<void> _submitQuizAnswers() async {
    if (_selectedAnswers.length < _quizQuestions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, ответьте на все вопросы перед отправкой.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final answersPayload = _selectedAnswers.entries.map((e) => {
      'question': e.key,
      'selectedOption': e.value
    }).toList();

    final res = await ApiService.submitQuiz(widget.step['id'], answersPayload);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (res == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка соединения с сервером')),
      );
      return;
    }

    if (res.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'])),
      );
      return;
    }

    setState(() {
      _quizSubmitted = true;
      _quizPassed = res['success'] ?? false;
      _quizScore = (res['score'] as num?)?.toDouble() ?? 0.0;
      _attemptsUsed = res['attemptsUsed'] ?? _attemptsUsed + 1;
      _failedTopics = res['failedTopics'] ?? [];
      
      if (res['cooldownUntil'] != null) {
        _cooldownUntil = DateTime.parse(res['cooldownUntil']);
      }

      if (_quizPassed) {
        _status = 'completed';
        if (res['certificateIssued'] == true) {
          _showCertificateIssuedDialog(res['certificateUuid']);
        }
      }
    });
  }

  void _showCertificateIssuedDialog(String? uuid) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: GlassContainer(
            borderRadius: 22,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, color: Color(0xFF007AFF), size: 48),
                const SizedBox(height: 12),
                const Text('Поздравляем!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                  'Вы успешно прошли все испытания курса и получили официальный сертификат!\n\nUUID: $uuid',
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GlassButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Back to course list
                  },
                  child: const Text('Отлично'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _simulateViolation() async {
    final res = await ApiService.logViolation(widget.step['id']);
    if (res == null) return;

    if (!mounted) return;

    final violationCount = res['violationCount'] ?? 0;
    final blocked = res['blocked'] ?? false;

    if (blocked) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: GlassContainer(
            borderRadius: 22,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('ДОСТУП ЗАБЛОКИРОВАН', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                const Text(
                  'Система зафиксировала 5 нарушений политики безопасности (скриншоты/запись экрана).\n\nДоступ к курсу заблокирован на 24 часа.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GlassButton(
                  gradient: const LinearGradient(colors: [Colors.redAccent, Colors.red]),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Понятно', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (violationCount >= 3) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: GlassContainer(
            borderRadius: 22,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('ПРЕДУПРЕЖДЕНИЕ', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                  'Скриншоты и запись экрана в приложении запрещены!\n\nУ вас зафиксировано $violationCount из 5 нарушений. После 5 нарушений доступ к курсу будет заблокирован на 24 часа.',
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GlassButton(
                  gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.orange]),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Я понял', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('⚠️ Скриншот зафиксирован! Попытка $violationCount из 5.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = step['type'] ?? 'text';

    if (_isBlocked) {
      return Scaffold(
        appBar: const GlassAppBar(),
        body: LiquidBackground(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 64, color: Colors.redAccent),
                  const SizedBox(height: 24),
                  const Text(
                    'Доступ заблокирован',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _blockMessage,
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  GlassButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Назад'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF007AFF))),
      );
    }

    return Scaffold(
      appBar: GlassAppBar(
        title: Text(step['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w400, letterSpacing: -0.5)),
        actions: [
          if (type == 'video')
            IconButton(
              icon: Icon(Icons.screenshot_monitor, color: Colors.white.withOpacity(0.6)),
              tooltip: 'Симулировать скриншот',
              onPressed: () {
                HapticFeedback.lightImpact();
                _simulateViolation();
              },
            )
        ],
      ),
      body: LiquidBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        step['title'] ?? '',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      if (!_isQuiz) ...[
                        Text(
                          step['content'] ?? '',
                          style: TextStyle(fontSize: 16, height: 1.6, color: Colors.white.withOpacity(0.85)),
                        ),
                        if (type == 'video' && step['content'] != null && (step['content'] as String).startsWith('http')) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.15)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.video_library, size: 48, color: Color(0xFFF43F5E)),
                                const SizedBox(height: 12),
                                const Text(
                                  'Видео доступно по ссылке:',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  step['content'],
                                  style: const TextStyle(color: Color(0xFF007AFF), decoration: TextDecoration.underline),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ] else ...[
                        // Quiz form
                        if (_quizSubmitted) _buildQuizResults() else _buildQuizQuestionsList(),
                      ],
                    ],
                  ),
                ),
              ),
              if (!_isQuiz) _buildBottomActionBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizQuestionsList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _isFinalExam ? 'Финальный экзамен модуля' : 'Промежуточный тест',
          style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          'Необходимо набрать минимум ${_isFinalExam ? "95%" : "80%"} правильных ответов.',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
        ),
        const SizedBox(height: 24),
        ..._quizQuestions.map((q) {
          final questionText = q['question'];
          final options = q['options'] as List<dynamic>;

          return GlassContainer(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    questionText,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ...options.map((opt) {
                    final isSelected = _selectedAnswers[questionText] == opt;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF007AFF).withOpacity(0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? const Color(0xFF007AFF) : Colors.white.withOpacity(0.2)),
                      ),
                      child: ListTile(
                        dense: true,
                        title: Text(opt.toString(), style: const TextStyle(color: Colors.white)),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedAnswers[questionText] = opt.toString();
                          });
                        },
                      ),
                    );
                  })
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        GlassButton(
          onPressed: _selectedAnswers.length < _quizQuestions.length ? null : _submitQuizAnswers,
          child: const Text('Сдать тест', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildQuizResults() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remainingCooldownMinutes = _cooldownUntil != null ? _cooldownUntil!.difference(DateTime.now()).inMinutes : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Icon(
              _quizPassed ? Icons.check_circle : Icons.cancel,
              size: 72,
              color: _quizPassed ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _quizPassed ? 'ТЕСТ СДАН!' : 'ТЕСТ ПРОВАЛЕН',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _quizPassed ? Colors.green : Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GlassContainer(
            borderRadius: 16,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildResultRow('Ваш результат:', '${_quizScore.toStringAsFixed(0)}%', isDark),
                  Divider(color: Colors.white.withOpacity(0.15)),
                  _buildResultRow('Использовано попыток:', '$_attemptsUsed из 5', isDark),
                  if (!_quizPassed && _cooldownUntil != null && remainingCooldownMinutes > 0) ...[
                    Divider(color: Colors.white.withOpacity(0.15)),
                    _buildResultRow('Повтор доступен через:', '$remainingCooldownMinutes мин', isDark),
                  ]
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (!_quizPassed && _failedTopics.isNotEmpty) ...[
            const Text(
              'Темы, которые нужно повторить:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            ..._failedTopics.map((topic) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(topic.toString(), style: TextStyle(color: Colors.white.withOpacity(0.6)))),
                ],
              ),
            )),
            const SizedBox(height: 32),
          ],
          if (!_quizPassed)
            GlassButton(
              opacity: 0.1,
              onPressed: remainingCooldownMinutes > 0 || _attemptsUsed >= 5
                  ? null
                  : () {
                      setState(() {
                        _quizSubmitted = false;
                        _selectedAnswers.clear();
                      });
                    },
              child: Text(
                _attemptsUsed >= 5
                    ? 'Попытки исчерпаны (обратитесь к админу)'
                    : (remainingCooldownMinutes > 0 ? 'Тест заблокирован на кулдаун' : 'Попробовать снова'),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: const Text('Вернуться к списку уроков', style: TextStyle(color: Color(0xFF007AFF))),
          )
        ],
      ),
    );
  }

  Widget _buildResultRow(String title, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_status == 'completed') {
      return Container(
        color: Colors.white.withOpacity(0.05),
        padding: const EdgeInsets.all(16.0),
        child: const GlassButton(
          onPressed: null,
          child: Text('Урок пройден ✓', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    }

    final isText = widget.step['type'] == 'text';

    if (isText) {
      final textReady = _scrollCompleted && _secondsSpent >= _estimatedReadTime;
      final remainingRead = _estimatedReadTime - _secondsSpent;

      return Container(
        color: Colors.white.withOpacity(0.05),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!textReady) ...[
              if (!_scrollCompleted)
                const Text(
                  '👇 Прокрутите текст до самого конца страницы',
                  style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              if (remainingRead > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '⏳ Внимательно ознакомьтесь с материалом. Осталось: $remainingRead сек.',
                    style: const TextStyle(color: Color(0xFF007AFF), fontSize: 12, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 12),
            ],
            GlassButton(
              opacity: textReady ? -1.0 : 0.05,
              onPressed: textReady ? _completeLesson : null,
              child: const Text('Завершить урок', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      // Video lesson
      final videoReady = _remainingVideoSeconds <= 0;
      final m = (_remainingVideoSeconds / 60).floor().toString().padLeft(2, '0');
      final s = (_remainingVideoSeconds % 60).toString().padLeft(2, '0');

      return Container(
        color: Colors.white.withOpacity(0.05),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!videoReady) ...[
              Text(
                '⏳ Следующий шаг доступен через $m:$s',
                style: const TextStyle(color: Color(0xFF007AFF), fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
            GlassButton(
              opacity: videoReady ? -1.0 : 0.05,
              onPressed: videoReady ? _completeLesson : null,
              child: const Text('Следующий шаг', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }
}
