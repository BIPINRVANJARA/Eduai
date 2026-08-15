import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class OnboardingSlide {
  final String tag;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final List<Color> gradient;

  const OnboardingSlide({
    required this.tag,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.gradient,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      tag: 'ACADEMIC REPOSITORY',
      title: 'Timetables, Manuals &\nAssignments on Demand',
      description:
          'Access class schedules, lab manuals, assignments, and curriculum documents with instant preview and download.',
      icon: Icons.calendar_month_rounded,
      accentColor: AppColors.primary,
      gradient: [Color(0xFFB7EC4B), Color(0xFF4ADE80)],
    ),
    OnboardingSlide(
      tag: 'CAMPUS AI COPILOT',
      title: 'Bilingual AI Assistant in\nGujarati & English',
      description:
          'Ask anything about your coursework, timetable, or student progress in natural Gujarati or English.',
      icon: Icons.auto_awesome_rounded,
      accentColor: AppColors.cyanAccent,
      gradient: [Color(0xFF38BDF8), Color(0xFF818CF8)],
    ),
    OnboardingSlide(
      tag: 'REAL-TIME BROADCASTS',
      title: 'Never Miss a Campus\nAlert or Exam Notice',
      description:
          'Receive instant broadcast updates for exam schedules, attendance thresholds, and institution announcements.',
      icon: Icons.notifications_active_rounded,
      accentColor: Color(0xFFFBBF24),
      gradient: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    ),
    OnboardingSlide(
      tag: 'PORTAL SECURITY',
      title: 'Tailored Portals for\nStudents & Parents',
      description:
          'Seamless authentication and direct access to personal attendance, results, and institution data.',
      icon: Icons.shield_rounded,
      accentColor: Color(0xFFA78BFA),
      gradient: [Color(0xFFA78BFA), Color(0xFF818CF8)],
    ),
  ];

  void _onNext() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentIndex == _slides.length - 1;
    final currentSlide = _slides[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background ambient glowing orbs
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            top: -60,
            right: _currentIndex.isEven ? -60 : 20,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentSlide.accentColor.withOpacity(0.08),
                boxShadow: [
                  BoxShadow(
                    color: currentSlide.accentColor.withOpacity(0.12),
                    blurRadius: 120,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header (Brand + Skip)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/app_logo.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Eduai',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      if (!isLast)
                        TextButton(
                          onPressed: () => context.go('/auth'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ),

                // Slide Carousel
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentIndex = i),
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),

                            // Apple-style Frosted Hero Glass Card
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    slide.accentColor.withOpacity(0.18),
                                    AppColors.surfaceLight.withOpacity(0.4),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: slide.accentColor.withOpacity(0.4),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: slide.accentColor.withOpacity(0.2),
                                    blurRadius: 40,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  slide.icon,
                                  size: 72,
                                  color: slide.accentColor,
                                ),
                              ),
                            )
                                .animate(key: ValueKey(index))
                                .scale(duration: 500.ms, curve: Curves.easeOutBack)
                                .fadeIn(duration: 400.ms),

                            const Spacer(),

                            // Category Tag
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: slide.accentColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: slide.accentColor.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                slide.tag,
                                style: TextStyle(
                                  color: slide.accentColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Title
                            Text(
                              slide.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                height: 1.25,
                                letterSpacing: -0.5,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Description
                            Text(
                              slide.description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Controls (Pill Indicators + Luxury CTA Button)
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                  child: Column(
                    children: [
                      // Smooth Expanding Pill Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_slides.length, (idx) {
                          final isSelected = idx == _currentIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: isSelected ? 28 : 6,
                            decoration: BoxDecoration(
                              color: isSelected ? currentSlide.accentColor : AppColors.cardBorder,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 28),

                      // CTA Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentSlide.accentColor,
                            foregroundColor: AppColors.background,
                            elevation: 0,
                            shadowColor: currentSlide.accentColor.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLast ? 'Get Started' : 'Continue',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
