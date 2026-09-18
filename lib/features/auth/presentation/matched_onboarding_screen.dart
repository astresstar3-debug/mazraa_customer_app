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
      message: 'زاود على الحيوانات والمنتجات الزراعية\nوالمعدات ومستلزمات النحل.',
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
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void previous() {
    if (index == 0) return;
    controller.animateToPage(
      index - 1,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        body: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(child: _BotanicalBackdrop()),
              PageView.builder(
                controller: controller,
                itemCount: pages.length,
                onPageChanged: (value) => setState(() => index = value),
                itemBuilder: (context, pageIndex) => _OnboardingPage(
                  page: pages[pageIndex],
                  currentIndex: index,
                  pageCount: pages.length,
                  onNext: next,
                  onPrevious: previous,
                  onSkip: () => Navigator.pushReplacementNamed(context, '/login'),
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
    required this.currentIndex,
    required this.pageCount,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
  });

  final _OnboardingData page;
  final int currentIndex;
  final int pageCount;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final isAuction = page.kind == _OnboardingKind.auction;
    final isTracking = page.kind == _OnboardingKind.tracking;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 720;
        final horizontal = compact ? 18.0 : 24.0;
        final sceneHeight = isTracking
            ? (constraints.maxHeight * .49).clamp(320.0, 520.0)
            : (constraints.maxHeight * .46).clamp(300.0, 500.0);

        return Padding(
          padding: EdgeInsetsDirectional.fromSTEB(horizontal, 12, horizontal, 18),
          child: Column(
            children: [
              AppLogo(
                size: page.kind == _OnboardingKind.welcome ? 104 : 74,
                showName: page.kind == _OnboardingKind.welcome,
              ),
              SizedBox(height: compact ? 8 : 14),
              if (page.kind == _OnboardingKind.welcome) ...[
                _TitleBlock(page: page, titleSize: compact ? 27 : 31),
                SizedBox(height: compact ? 8 : 16),
              ],
              SizedBox(
                height: sceneHeight,
                width: double.infinity,
                child: _OnboardingIllustration(kind: page.kind),
              ),
              if (page.kind != _OnboardingKind.welcome) ...[
                SizedBox(height: compact ? 8 : 14),
                _TitleBlock(page: page, titleSize: compact ? 27 : 31),
              ],
              const Spacer(),
              _Dots(count: pageCount, active: currentIndex),
              SizedBox(height: compact ? 14 : 26),
              if (isAuction)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextButton(
                        onPressed: onSkip,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF62745D),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        child: const Text('تخطي'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: _GradientFilledButton(label: 'التالي', onPressed: onNext),
                    ),
                  ],
                )
              else
                _GradientFilledButton(
                  label: isTracking ? 'ابدأ الآن' : 'التالي',
                  onPressed: onNext,
                ),
              if (isTracking) ...[
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: onPrevious,
                  icon: const Icon(Icons.arrow_back_rounded, size: 19),
                  label: const Text('السابق'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.forestDark,
                    textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.page, required this.titleSize});

  final _OnboardingData page;
  final double titleSize;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.forestDark,
              fontSize: titleSize,
              height: 1.22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            page.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF687462),
              fontSize: 15,
              height: 1.75,
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
            width: dot == active ? 14 : 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: dot == active ? AppColors.forest : const Color(0xFFE5D8B9),
              borderRadius: BorderRadius.circular(20),
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
        height: 62,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFF0A4728), Color(0xFF246B3D)],
          ),
          borderRadius: BorderRadius.circular(31),
          boxShadow: const [
            BoxShadow(color: Color(0x160D4328), blurRadius: 18, offset: Offset(0, 8)),
          ],
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(31)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              PositionedDirectional(
                start: 16,
                child: Icon(Icons.eco_rounded, size: 34, color: Colors.white.withValues(alpha: .14)),
              ),
              PositionedDirectional(
                end: 16,
                child: Icon(Icons.eco_rounded, size: 30, color: Colors.white.withValues(alpha: .12)),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 19),
                  ),
                  if (label == 'ابدأ الآن') ...[
                    const SizedBox(width: 9),
                    const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
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
            left: 34,
            right: 34,
            top: 24,
            bottom: 32,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF1D7), Color(0xFFFFFBF3)],
                ),
              ),
            ),
          ),
          Positioned(
            left: 40,
            right: 40,
            top: 58,
            bottom: 34,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(150),
              child: const AppDataImage('assets/images/home/date_seedlings.png', fit: BoxFit.cover),
            ),
          ),
          PositionedDirectional(
            bottom: 35,
            start: 18,
            child: _PhotoBubble(source: 'assets/images/home/najdi_sheep.png', size: 118),
          ),
          PositionedDirectional(
            bottom: 30,
            end: 22,
            child: _PhotoBubble(source: 'assets/images/home/local_calf.png', size: 130),
          ),
          Positioned(
            bottom: 16,
            child: Container(
              width: 132,
              height: 92,
              decoration: BoxDecoration(
                color: const Color(0xFFE5C89C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCB8356).withValues(alpha: .45)),
                boxShadow: const [BoxShadow(color: Color(0x16000000), blurRadius: 14, offset: Offset(0, 6))],
              ),
              alignment: Alignment.center,
              child: const AppLogo(size: 56),
            ),
          ),
          const PositionedDirectional(top: 8, start: 0, child: _LeafSprig(angle: -.52)),
          const PositionedDirectional(top: 4, end: 0, child: _LeafSprig(angle: .48)),
          const PositionedDirectional(bottom: 0, start: 30, child: _SmallProduceCluster()),
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
            left: 32,
            right: 32,
            top: 18,
            bottom: 24,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFCD6B3B), Color(0xFFF2C9A8)],
                ),
              ),
            ),
          ),
          Positioned(
            left: 56,
            right: 110,
            top: 92,
            bottom: 42,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(70),
              child: const AppDataImage('assets/images/home/najdi_sheep.png', fit: BoxFit.cover),
            ),
          ),
          PositionedDirectional(
            end: 22,
            top: 112,
            child: Container(
              width: 126,
              height: 126,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                boxShadow: const [BoxShadow(color: Color(0x19000000), blurRadius: 16, offset: Offset(0, 7))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: const AppDataImage('assets/images/home/sidr_honey.png', fit: BoxFit.cover),
              ),
            ),
          ),
          PositionedDirectional(
            top: 58,
            start: 36,
            child: Container(
              width: 74,
              height: 118,
              decoration: BoxDecoration(
                color: AppColors.forestDark,
                borderRadius: BorderRadius.circular(9),
                boxShadow: const [BoxShadow(color: Color(0x1B000000), blurRadius: 12)],
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.gavel_rounded, color: Color(0xFFF7E8CA), size: 40),
            ),
          ),
          Positioned(
            bottom: 24,
            child: Transform.rotate(
              angle: -.28,
              child: const Icon(Icons.gavel_rounded, color: Color(0xFF6C351C), size: 112),
            ),
          ),
          const PositionedDirectional(top: 0, end: -5, child: _LeafSprig(angle: .44)),
          const PositionedDirectional(bottom: 4, start: -5, child: _LeafSprig(angle: -.48)),
          const PositionedDirectional(top: 130, end: 98, child: Icon(Icons.hive_rounded, color: Color(0xFF8B5B1F), size: 42)),
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
            left: 10,
            right: 10,
            top: 4,
            bottom: 8,
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
                          Colors.transparent,
                          AppColors.ivory.withValues(alpha: .06),
                          AppColors.ivory.withValues(alpha: .78),
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
            bottom: 42,
            start: 26,
            child: _PhotoBubble(source: 'assets/images/home/najdi_sheep.png', size: 96),
          ),
          PositionedDirectional(
            bottom: 38,
            end: 30,
            child: _PhotoBubble(source: 'assets/images/home/local_calf.png', size: 112),
          ),
          Positioned(
            bottom: 18,
            child: Container(
              width: 152,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFE2C493),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFC37A4C).withValues(alpha: .48)),
                boxShadow: const [BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 6))],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppLogo(size: 54),
                  SizedBox(height: 5),
                  Text('طلبك', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 40,
            start: 114,
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: AppColors.forest, shape: BoxShape.circle),
              child: const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 38),
            ),
          ),
          const PositionedDirectional(top: -2, start: -4, child: _LeafSprig(angle: -.5)),
          const PositionedDirectional(bottom: -3, end: -4, child: _LeafSprig(angle: .44)),
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

class _SmallProduceCluster extends StatelessWidget {
  const _SmallProduceCluster();

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: const AppDataImage('assets/images/home/fresh_herbs.png', fit: BoxFit.cover),
          ),
          Transform.translate(
            offset: const Offset(-12, 5),
            child: Container(
              width: 55,
              height: 55,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              clipBehavior: Clip.antiAlias,
              child: const AppDataImage('assets/images/home/livestock_feed.png', fit: BoxFit.cover),
            ),
          ),
        ],
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
            Icon(Icons.eco_rounded, size: 52, color: AppColors.forest.withValues(alpha: .42)),
            Icon(Icons.eco_rounded, size: 34, color: AppColors.terracotta.withValues(alpha: .52)),
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
            top: 12,
            start: -20,
            child: Transform.rotate(
              angle: -.55,
              child: Icon(Icons.eco_rounded, size: 104, color: AppColors.forest.withValues(alpha: .08)),
            ),
          ),
          PositionedDirectional(
            top: 16,
            end: -22,
            child: Transform.rotate(
              angle: .55,
              child: Icon(Icons.eco_rounded, size: 98, color: AppColors.terracotta.withValues(alpha: .07)),
            ),
          ),
          PositionedDirectional(
            bottom: -28,
            start: -34,
            child: Icon(Icons.eco_rounded, size: 150, color: AppColors.forest.withValues(alpha: .11)),
          ),
          PositionedDirectional(
            bottom: -34,
            end: -38,
            child: Icon(Icons.eco_rounded, size: 158, color: AppColors.terracotta.withValues(alpha: .09)),
          ),
        ],
      );
}
