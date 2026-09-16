import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';

class MatchedOnboardingScreen extends StatefulWidget {
  const MatchedOnboardingScreen({super.key, this.initialPage = 0});

  final int initialPage;

  @override
  State<MatchedOnboardingScreen> createState() => _MatchedOnboardingScreenState();
}

class _MatchedOnboardingScreenState extends State<MatchedOnboardingScreen> {
  late final PageController controller;
  late int index;

  static const pages = <_OnboardingData>[
    _OnboardingData(
      title: 'أهلاً بك في مزرعتي',
      message: 'كل احتياجات مزرعتك في مكان واحد.',
      kind: _OnboardingKind.welcome,
    ),
    _OnboardingData(
      title: 'شارك في المزادات بثقة',
      message: 'زايد على الحيوانات والمنتجات الزراعية والمعدات واستمتع بتجربة آمنة وواضحة.',
      kind: _OnboardingKind.auction,
    ),
    _OnboardingData(
      title: 'تابع طلبك حتى يصل إليك',
      message: 'توصيل موثوق وتتبع واضح من المزرعة إلى بابك.',
      kind: _OnboardingKind.tracking,
    ),
  ];

  @override
  void initState() {
    super.initState();
    index = widget.initialPage.clamp(0, pages.length - 1);
    controller = PageController(initialPage: index);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void next() {
    if (index < pages.length - 1) {
      controller.animateToPage(
        index + 1,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(22, 16, 22, 22),
            child: Column(
              children: [
                const Center(child: AppLogo(size: 62)),
                const SizedBox(height: 12),
                Expanded(
                  child: PageView.builder(
                    controller: controller,
                    itemCount: pages.length,
                    onPageChanged: (value) => setState(() => index = value),
                    itemBuilder: (context, pageIndex) {
                      final page = pages[pageIndex];
                      return Column(
                        children: [
                          Expanded(child: _OnboardingIllustration(kind: page.kind)),
                          const SizedBox(height: 18),
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.forestDark,
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            page.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                              height: 1.65,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              pages.length,
                              (dot) => AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: dot == index ? 22 : 7,
                                height: 7,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: dot == index ? AppColors.forest : const Color(0xFFE4DCCB),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                if (index == 1)
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text('تخطي'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 54,
                          child: FilledButton(
                            onPressed: next,
                            child: const Text('التالي', style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: next,
                      child: Text(
                        index == pages.length - 1 ? 'ابدأ الآن' : 'التالي',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}

enum _OnboardingKind { tracking, auction, welcome }

class _OnboardingData {
  const _OnboardingData({
    required this.title,
    required this.message,
    required this.kind,
  });

  final String title;
  final String message;
  final _OnboardingKind kind;
}

class _OnboardingIllustration extends StatelessWidget {
  const _OnboardingIllustration({required this.kind});

  final _OnboardingKind kind;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            PositionedDirectional(
              top: 8,
              start: 2,
              child: Transform.rotate(
                angle: -.35,
                child: Icon(Icons.eco_rounded, size: 74, color: AppColors.forest.withValues(alpha: .11)),
              ),
            ),
            PositionedDirectional(
              bottom: 3,
              end: 0,
              child: Transform.rotate(
                angle: .55,
                child: Icon(Icons.eco_rounded, size: 84, color: AppColors.terracotta.withValues(alpha: .10)),
              ),
            ),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(maxHeight: constraints.maxHeight - 4),
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCF5),
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: const Color(0xFFE8E0CF)),
              ),
              child: switch (kind) {
                _OnboardingKind.tracking => const _TrackingIllustration(),
                _OnboardingKind.auction => const _AuctionIllustration(),
                _OnboardingKind.welcome => const _WelcomeIllustration(),
              },
            ),
          ],
        );
      },
    );
  }
}

class _TrackingIllustration extends StatelessWidget {
  const _TrackingIllustration();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(18),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 22,
              left: 20,
              right: 20,
              bottom: 48,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(90),
                child: AppDataImage('assets/images/home/date_seedlings.png', fit: BoxFit.cover),
              ),
            ),
            PositionedDirectional(
              bottom: 28,
              start: 26,
              child: Container(
                width: 105,
                height: 78,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7D5B2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.terracotta.withValues(alpha: .25)),
                ),
                alignment: Alignment.center,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppLogo(size: 34),
                    SizedBox(height: 4),
                    Text('طلبك', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900, fontSize: 11)),
                  ],
                ),
              ),
            ),
            PositionedDirectional(
              bottom: 24,
              end: 30,
              child: CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.forest,
                child: const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 34),
              ),
            ),
          ],
        ),
      );
}

class _AuctionIllustration extends StatelessWidget {
  const _AuctionIllustration();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(18),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 270,
              height: 270,
              decoration: const BoxDecoration(
                color: Color(0xFFF1D6C5),
                shape: BoxShape.circle,
              ),
            ),
            Positioned(
              top: 32,
              left: 40,
              right: 40,
              bottom: 68,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(110),
                child: AppDataImage('assets/images/home/najdi_sheep.png', fit: BoxFit.cover),
              ),
            ),
            PositionedDirectional(
              bottom: 28,
              start: 52,
              child: CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.surface,
                child: const Icon(Icons.gavel_rounded, color: AppColors.forestDark, size: 36),
              ),
            ),
            PositionedDirectional(
              bottom: 42,
              end: 48,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.forest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('مزاد موثوق', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      );
}

class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(size: 92, showName: true),
            const SizedBox(height: 24),
            SizedBox(
              height: 190,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PositionedDirectional(
                    start: 18,
                    child: _RoundPhoto(source: 'assets/images/home/local_calf.png', size: 128),
                  ),
                  const _RoundPhoto(source: 'assets/images/home/fresh_herbs.png', size: 150),
                  PositionedDirectional(
                    end: 18,
                    child: _RoundPhoto(source: 'assets/images/home/livestock_feed.png', size: 128),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.forestSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.eco_rounded, color: AppColors.forest),
                  SizedBox(width: 7),
                  Text('زراعة • حيوانات • أعلاف • مزادات', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w800, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _RoundPhoto extends StatelessWidget {
  const _RoundPhoto({required this.source, required this.size});

  final String source;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.forest.withValues(alpha: .35), width: 2),
        ),
        child: ClipOval(child: AppDataImage(source, fit: BoxFit.cover)),
      );
}
