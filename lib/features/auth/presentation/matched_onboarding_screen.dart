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
      message: 'زايد على الحيوانات والمنتجات الزراعية والمعدات ومستلزمات النحل.',
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void previous() {
    if (index > 0) {
      controller.animateToPage(
        index - 1,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        body: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(child: _BotanicalBackdrop()),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 18),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: controller,
                        itemCount: pages.length,
                        onPageChanged: (value) => setState(() => index = value),
                        itemBuilder: (context, pageIndex) => _OnboardingPage(
                          page: pages[pageIndex],
                          pageIndex: pageIndex,
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
                              height: 58,
                              child: TextButton(
                                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.forestDark,
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                child: const Text('تخطي'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            flex: 3,
                            child: _GradientFilledButton(label: 'التالي', onPressed: next),
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
                          textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

enum _OnboardingKind { welcome, auction, tracking }

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
    required this.pageIndex,
    required this.currentIndex,
    required this.pageCount,
  });

  final _OnboardingData page;
  final int pageIndex;
  final int currentIndex;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    final welcome = page.kind == _OnboardingKind.welcome;
    return LayoutBuilder(
      builder: (context, constraints) {
        final illustrationHeight = welcome
            ? (constraints.maxHeight * .46).clamp(300.0, 430.0)
            : (constraints.maxHeight * .55).clamp(350.0, 500.0);
        return Column(
          children: [
            SizedBox(height: welcome ? 4 : 0),
            AppLogo(size: welcome ? 118 : 72, showName: welcome),
            SizedBox(height: welcome ? 14 : 12),
            if (welcome) ...[
              _TitleBlock(page: page, large: true),
              const SizedBox(height: 12),
            ],
            SizedBox(
              height: illustrationHeight,
              width: double.infinity,
              child: _OnboardingIllustration(kind: page.kind),
            ),
            if (!welcome) ...[
              const SizedBox(height: 8),
              _TitleBlock(page: page),
            ],
            const Spacer(),
            _Dots(count: pageCount, active: currentIndex),
          ],
        );
      },
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.page, this.large = false});

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
              fontSize: large ? 30 : 29,
              height: 1.25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            page.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6F7865),
              fontSize: 14,
              height: 1.65,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          count,
          (dot) => AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 11,
            height: 11,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: dot == active ? AppColors.forest : const Color(0xFFE5D9BC),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
}

class _GradientFilledButton extends StatelessWidget {
  const _GradientFilledButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFF0A4C2B), Color(0xFF206D3F)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: Color(0x140D4328), blurRadius: 18, offset: Offset(0, 7)),
          ],
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              PositionedDirectional(
                start: 8,
                child: Icon(Icons.eco_rounded, size: 30, color: Colors.white.withValues(alpha: .20)),
              ),
              PositionedDirectional(
                end: 8,
                child: Icon(Icons.eco_rounded, size: 28, color: Colors.white.withValues(alpha: .16)),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  if (label == 'ابدأ الآن') ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.eco_rounded, color: Colors.white, size: 19),
                  ],
                ],
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
  Widget build(BuildContext context) => switch (kind) {
        _OnboardingKind.welcome => const _WelcomeScene(),
        _OnboardingKind.auction => const _AuctionScene(),
        _OnboardingKind.tracking => const _TrackingScene(),
      };
}

class _WelcomeScene extends StatelessWidget {
  const _WelcomeScene();

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 16,
            right: 16,
            top: 22,
            bottom: 18,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(48),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const AppDataImage('assets/images/home/date_seedlings.png', fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.ivory.withValues(alpha: .08),
                          AppColors.ivory.withValues(alpha: .03),
                          AppColors.ivory.withValues(alpha: .82),
                        ],
                        stops: const [0, .62, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 31,
            start: 15,
            child: _PhotoBubble(source: 'assets/images/home/najdi_sheep.png', size: 112),
          ),
          PositionedDirectional(
            bottom: 25,
            end: 18,
            child: _PhotoBubble(source: 'assets/images/home/local_calf.png', size: 132),
          ),
          Positioned(
            bottom: 14,
            child: Container(
              width: 132,
              height: 94,
              decoration: BoxDecoration(
                color: const Color(0xFFE4C79D),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: AppColors.terracotta.withValues(alpha: .22)),
                boxShadow: const [BoxShadow(color: Color(0x16000000), blurRadius: 15, offset: Offset(0, 6))],
              ),
              alignment: Alignment.center,
              child: const AppLogo(size: 55),
            ),
          ),
          const PositionedDirectional(top: 0, start: -2, child: _LeafSprig(angle: -.52)),
          const PositionedDirectional(top: 4, end: 0, child: _LeafSprig(angle: .48)),
        ],
      );
}

class _AuctionScene extends StatelessWidget {
  const _AuctionScene();

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 16,
            right: 16,
            top: 20,
            bottom: 10,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFCC6634), Color(0xFFF3D1B7)],
                ),
              ),
            ),
          ),
          Positioned(
            left: 36,
            right: 36,
            top: 64,
            bottom: 38,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(42),
              child: const AppDataImage('assets/images/home/najdi_sheep.png', fit: BoxFit.cover),
            ),
          ),
          PositionedDirectional(
            top: 50,
            start: 28,
            child: Container(
              width: 72,
              height: 105,
              decoration: BoxDecoration(
                color: AppColors.forestDark,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 12)],
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 38),
            ),
          ),
          PositionedDirectional(
            bottom: 28,
            end: 28,
            child: Container(
              width: 118,
              height: 92,
              decoration: BoxDecoration(
                color: const Color(0xFFB86B2B),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 14, offset: Offset(0, 5))],
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.hive_outlined, color: Color(0xFFFFE9B7), size: 50),
            ),
          ),
          PositionedDirectional(
            bottom: 15,
            start: 48,
            child: Transform.rotate(
              angle: -.35,
              child: const Icon(Icons.gavel_rounded, color: Color(0xFF5F371F), size: 96),
            ),
          ),
          const PositionedDirectional(top: 12, end: 2, child: _LeafSprig(angle: .4)),
          const PositionedDirectional(bottom: 0, start: 0, child: _LeafSprig(angle: -.45)),
        ],
      );
}

class _TrackingScene extends StatelessWidget {
  const _TrackingScene();

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 8,
            right: 8,
            top: 6,
            bottom: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(46),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const AppDataImage('assets/images/home/date_seedlings.png', fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.ivory.withValues(alpha: .04),
                          AppColors.ivory.withValues(alpha: .02),
                          AppColors.ivory.withValues(alpha: .56),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 24,
            start: 25,
            child: Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(color: AppColors.forest, shape: BoxShape.circle),
              child: const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 47),
            ),
          ),
          PositionedDirectional(
            bottom: 20,
            end: 20,
            child: Container(
              width: 128,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE5C99C),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.terracotta.withValues(alpha: .28)),
                boxShadow: const [BoxShadow(color: Color(0x17000000), blurRadius: 14, offset: Offset(0, 5))],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppLogo(size: 48),
                  SizedBox(height: 3),
                  Text('طلبك', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
          const PositionedDirectional(top: -4, start: -5, child: _LeafSprig(angle: -.5)),
          const PositionedDirectional(bottom: -4, end: -2, child: _LeafSprig(angle: .42)),
        ],
      );
}

class _PhotoBubble extends StatelessWidget {
  const _PhotoBubble({required this.source, required this.size});

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

class _LeafSprig extends StatelessWidget {
  const _LeafSprig({required this.angle});

  final double angle;

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: angle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco_rounded, size: 52, color: AppColors.forest.withValues(alpha: .46)),
            Icon(Icons.eco_rounded, size: 34, color: AppColors.terracotta.withValues(alpha: .55)),
          ],
        ),
      );
}

class _BotanicalBackdrop extends StatelessWidget {
  const _BotanicalBackdrop();

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          PositionedDirectional(
            top: 24,
            start: -24,
            child: Transform.rotate(
              angle: -.55,
              child: Icon(Icons.eco_rounded, size: 110, color: AppColors.forest.withValues(alpha: .10)),
            ),
          ),
          PositionedDirectional(
            top: 34,
            end: -28,
            child: Transform.rotate(
              angle: .55,
              child: Icon(Icons.eco_rounded, size: 104, color: AppColors.terracotta.withValues(alpha: .08)),
            ),
          ),
          PositionedDirectional(
            bottom: -34,
            start: -35,
            child: Icon(Icons.eco_rounded, size: 150, color: AppColors.forest.withValues(alpha: .13)),
          ),
          PositionedDirectional(
            bottom: -40,
            end: -42,
            child: Icon(Icons.eco_rounded, size: 160, color: AppColors.terracotta.withValues(alpha: .10)),
          ),
        ],
      );
}
