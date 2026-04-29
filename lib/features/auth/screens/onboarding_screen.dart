import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/shared_prefs_provider.dart';

// ── Page data ─────────────────────────────────────────────────────────────────

class _PageData {
  const _PageData({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;
}

const _pages = [
  _PageData(
    icon: Icons.backpack_rounded,
    title: 'Plan Your Journey',
    body:
        'Prepare every detail before you travel — from packing checklists to permit management — all in one place.',
  ),
  _PageData(
    icon: Icons.menu_book_rounded,
    title: 'Step-by-Step Rituals',
    body:
        'Perform each ritual with confidence using live audio guides, Arabic du\'as, and real-time tracking.',
  ),
  _PageData(
    icon: Icons.mosque_rounded,
    title: 'Your Guide for\nSacred Journeys',
    body:
        'Siraj will lead you through every step of your Umrah and Hajj experience.',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) => setState(() => _currentPage = index);

  bool get _isLastPage => _currentPage == _pages.length - 1;

  Future<void> _markOnboardingDone() async {
    ref
        .read(sharedPrefsProvider)
        .setBool(AppConstants.prefKeyOnboardingDone, true);
  }

  void _goToSignIn() {
    _markOnboardingDone();
    context.go(AppRoutes.signIn);
  }

  void _goToSignUp() {
    _markOnboardingDone();
    context.go(AppRoutes.signUp);
  }

  void _next() {
    _controller.nextPage(
      duration: AppConstants.animNormal,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // ── Background gradient ────────────────────────────────────────────
          _Background(pageIndex: _currentPage),

          // ── Page content ──────────────────────────────────────────────────
          PageView.builder(
            controller: _controller,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) =>
                _PageContent(data: _pages[index], isLast: index == _pages.length - 1),
          ),

          // ── Bottom overlay (dots + buttons) ───────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DotIndicator(
                        count: _pages.length, current: _currentPage),
                    const SizedBox(height: 32),
                    if (_isLastPage) ...[
                      _AuthButtons(
                        onSignUp: _goToSignUp,
                        onSignIn: _goToSignIn,
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: _goToSignIn,
                            child: Text('Skip',
                                style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.textSecondary)),
                          ),
                          _NextButton(onTap: _next),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Background ────────────────────────────────────────────────────────────────

class _Background extends StatelessWidget {
  const _Background({required this.pageIndex});
  final int pageIndex;

  // Each page has a slightly different warm-dark gradient stop to give variety.
  static const _topColors = [
    Color(0xFF1E1A0E), // page 0 – amber tint
    Color(0xFF0E1218), // page 1 – cool blue-dark
    Color(0xFF2C2008), // page 2 – rich gold-brown (mosque night)
  ];

  @override
  Widget build(BuildContext context) {
    final topColor = _topColors[pageIndex.clamp(0, _topColors.length - 1)];
    return AnimatedContainer(
      duration: AppConstants.animSlow,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, AppColors.backgroundDark],
          stops: const [0.0, 0.65],
        ),
      ),
    );
  }
}

// ── Single onboarding page ────────────────────────────────────────────────────

class _PageContent extends StatelessWidget {
  const _PageContent({required this.data, required this.isLast});
  final _PageData data;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── Siraj logo ───────────────────────────────────────────────────
            Center(child: _SirajLogo()),

            // ── Hero icon ────────────────────────────────────────────────────
            Expanded(
              child: Center(
                child: AnimatedSwitcher(
                  duration: AppConstants.animNormal,
                  child: Icon(
                    data.icon,
                    key: ValueKey(data.icon),
                    size: 120,
                    color: AppColors.primaryGold.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),

            // ── Text block ───────────────────────────────────────────────────
            Text(
              data.title,
              style: AppTextStyles.displayMedium,
            ),
            const SizedBox(height: 12),
            Text(
              data.body,
              style: AppTextStyles.bodyLarge,
            ),

            // Leave space for the bottom overlay (dots + buttons)
            const SizedBox(height: 160),
          ],
        ),
      ),
    );
  }
}

// ── Siraj logo ────────────────────────────────────────────────────────────────

class _SirajLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.nightlight_round,
          color: AppColors.primaryGold,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          'Siraj',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primaryGold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

// ── Dot indicator ─────────────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: AppConstants.animNormal,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryGold : AppColors.textMuted,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ── Next button ───────────────────────────────────────────────────────────────

class _NextButton extends StatelessWidget {
  const _NextButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: AppColors.primaryGold,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_forward_rounded,
          color: AppColors.textOnGold,
          size: 24,
        ),
      ),
    );
  }
}

// ── Auth Buttons (last page) ──────────────────────────────────────────────────

class _AuthButtons extends StatelessWidget {
  const _AuthButtons({required this.onSignUp, required this.onSignIn});
  final VoidCallback onSignUp;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onSignUp,
            child: const Text('SIGN UP'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: onSignIn,
            child: const Text('SIGN IN'),
          ),
        ),
      ],
    );
  }
}
