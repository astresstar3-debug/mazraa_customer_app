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
      message: 'كل احتياجات مزرعتك في مكان واحد',
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

  void previous() {
    if (index > 0) {
      controller.animateToPage(
        index - 1,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                const Positioned.fill(child: _OnboardingBackdrop()),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(22, 12, 22, 18),
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: controller,
                          itemCount: pages.length,
                          onPageChanged: (value) => setState(() => index = value),
                          itemBuilder: (context, pageIndex) => _OnboardingPage(
                            page: pages[pageIndex],
                            currentIndex: index,
                            pageCount: pages.length,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (index == 1)
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 55,
                                child: TextButton(
                                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                                  child: const Text(
                                    'تخطي',
                                    style: TextStyle(
                                      color: AppColors.forestDark,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: _GradientFilledButton(
                                label: 'التالي',
                                onPressed: next,
                              ),
                            ),
                          ],
                        )
                      else
                        _GradientFilledButton(
                          label: index == pages.length - 1 ? 'ابدأ الآن' : 'التالي',
                          onPressed: next,
                        ),
                      if (index == pages.length - 1) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: previous,
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('السابق'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.forestDark,
                            textStyle: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ],
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

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.page,
    required this.currentIndex,
    required this.pageCount,
  });

  final _OnboardingData page;
  final int currentIndex;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    final welcome = page.kind == _OnboardingKind.welcome;
    return Column(
      children: [
        SizedBox(height: welcome ? 10 : 2),
        AppLogo(size: welcome ? 92 : 58, showName: welcome),
        SizedBox(height: welcome ? 20 : 10),
        if (welcome) ...[
          _OnboardingTitle(page: page, large: true),
          const SizedBox(height: 15),
        ],
        Expanded(
          child: _OnboardingIllustration(kind: page.kind),
        ),
        if (!welcome) ...[
          const SizedBox(height: 14),
          _OnboardingTitle(page: page),
        ],
        const SizedBox(height: 13),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            pageCount,
            (dot) => AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: dot == currentIndex ? 10 : 9,
              height: 9,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: dot == currentIndex
                    ? AppColors.forest
                    : const Color(0xFFE8DDC4),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingTitle extends StatelessWidget {
  const _OnboardingTitle({required this.page, this.large = false});
  final _OnboardingData page;
  final bool large;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.forestDark,
              fontSize: large ? 30 : 27,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            page.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              height: 1.65,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
}

class _GradientFilledButton extends StatelessWidget {
  const _GradientFilledButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFF0C4F2D), Color(0xFF1E6B3F)],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140D4328),
              blurRadius: 18,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              PositionedDirectional(
                start: 6,
                child: Icon(Icons.eco_rounded, color: Colors.white.withValues(alpha: .23)),
              ),
              PositionedDirectional(
                end: 6,
                child: Icon(Icons.eco_rounded, color: Colors.white.withValues(alpha: .18)),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      );
}

class _OnboardingIllustration extends StatelessWidget {
  const _OnboardingIllustration({required this.kind});

  final _OnboardingKind kind;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => switch (kind) {
          _OnboardingKind.welcome => _WelcomeIllustration(height: constraints.maxHeight),
          _OnboardingKind.auction => _AuctionIllustration(height: constraints.maxHeight),
          _OnboardingKind.tracking => _TrackingIllustration(height: constraints.maxHeight),
        },
      );
}

class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 2,
            right: 2,
            top: 8,
            bottom: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(38),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const AppDataImage('assets/images/home/date_seedlings.png', fit: BoxFit.cover),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00FFF9EB), Color(0x22FFF9EB), Color(0xDFFFF9EB)],
                        stops: [0, .62, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 23,
            start: 18,
            child: _RoundPhoto(source: 'assets/images/home/najdi_sheep.png', size: 102),
          ),
          PositionedDirectional(
            bottom: 18,
            end: 24,
            child: _RoundPhoto(source: 'assets/images/home/local_calf.png', size: 116),
          ),
          Positioned(
            bottom: 5,
            child: Container(
              width: 108,
              height: 78,
              decoration: BoxDecoration(
                color: const Color(0xFFE4C79D),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.terracotta.withValues(alpha: .25)),
              ),
              alignment: Alignment.center,
              child: const AppLogo(size: 48),
            ),
          ),
          const PositionedDirectional(
            top: 16,
            start: 5,
            child: _LeafCluster(angle: -.4),
          ),
          const PositionedDirectional(
            top: 20,
            end: 7,
            child: _LeafCluster(angle: .5),
          ),
        ],
      );
}

class _AuctionIllustration extends StatelessWidget {
  const _AuctionIllustration({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            height: height * .83,
            margin: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFF4DBC8),
              borderRadius: BorderRadius.circular(150),
            ),
          ),
          Positioned(
            left: 34,
            right: 34,
            top: 23,
            bottom: 25,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(130),
              child: const AppDataImage('assets/images/home/najdi_sheep.png', fit: BoxFit.cover),
            ),
          ),
          PositionedDirectional(
            bottom: 26,
            start: 28,
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(color: Color(0x16000000), blurRadius: 12)],
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.gavel_rounded, color: AppColors.forestDark, size: 42),
            ),
          ),
          PositionedDirectional(
            bottom: 45,
            end: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.forest,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'مزاد موثوق',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
              ),
            ),
          ),
          const PositionedDirectional(top: 3, start: 3, child: _LeafCluster(angle: -.5)),
          const PositionedDirectional(bottom: 0, end: 0, child: _LeafCluster(angle: .45)),
        ],
      );
}

class _TrackingIllustration extends StatelessWidget {
  const _TrackingIllustration({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 2,
            right: 2,
            top: 4,
            bottom: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const AppDataImage('assets/images/home/date_seedlings.png', fit: BoxFit.cover),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00FFF9EB), Color(0x12FFF9EB), Color(0xC8FFF9EB)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 24,
            start: 30,
            child: Container(
              width: 118,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFE5C69B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.terracotta.withValues(alpha: .3)),
                boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 14, offset: Offset(0, 5))],
              ),
              alignment: Alignment.center,
              child: const AppLogo(size: 52),
            ),
          ),
          PositionedDirectional(
            bottom: 34,
            end: 34,
            child: Container(
              width: 74,
              height: 74,
              decoration: const BoxDecoration(color: AppColors.forest, shape: BoxShape.circle),
              child: const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 38),
            ),
          ),
          const PositionedDirectional(bottom: 1, start: 0, child: _LeafCluster(angle: -.45)),
          const PositionedDirectional(bottom: 2, end: 0, child: _LeafCluster(angle: .45)),
        ],
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
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 13, offset: Offset(0, 5))],
        ),
        child: ClipOval(child: AppDataImage(source, fit: BoxFit.cover)),
      );
}

class _LeafCluster extends StatelessWidget {
  const _LeafCluster({required this.angle});
  final double angle;

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: angle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco_rounded, size: 42, color: AppColors.forest.withValues(alpha: .45)),
            Icon(Icons.eco_rounded, size: 30, color: AppColors.terracotta.withValues(alpha: .48)),
          ],
        ),
      );
}

class _OnboardingBackdrop extends StatelessWidget {
  const _OnboardingBackdrop();

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          PositionedDirectional(
            top: 8,
            start: -18,
            child: Transform.rotate(
              angle: -.55,
              child: Icon(Icons.eco_rounded, size: 92, color: AppColors.forest.withValues(alpha: .08)),
            ),
          ),
          PositionedDirectional(
            top: 15,
            end: -16,
            child: Transform.rotate(
              angle: .55,
              child: Icon(Icons.eco_rounded, size: 88, color: AppColors.terracotta.withValues(alpha: .07)),
            ),
          ),
          PositionedDirectional(
            bottom: -24,
            start: -28,
            child: Icon(Icons.eco_rounded, size: 125, color: AppColors.forest.withValues(alpha: .10)),
          ),
          PositionedDirectional(
            bottom: -30,
            end: -35,
            child: Icon(Icons.eco_rounded, size: 136, color: AppColors.terracotta.withValues(alpha: .08)),
          ),
        ],
      );
}
