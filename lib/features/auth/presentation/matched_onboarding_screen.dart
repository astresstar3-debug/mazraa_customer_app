import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';

class MatchedOnboardingScreen extends StatefulWidget {
  const MatchedOnboardingScreen({super.key});

  @override
  State<MatchedOnboardingScreen> createState() => _MatchedOnboardingScreenState();
}

class _MatchedOnboardingScreenState extends State<MatchedOnboardingScreen> {
  final controller = PageController();
  int index = 0;

  static const pages = [
    _OnboardingData(
      image: 'assets/images/home/fresh_herbs.png',
      title: 'تابع طلبك حتى يصل إليك',
      message: 'تسوّق من المنتجات الزراعية والبيطرية وتابع حالة طلبك خطوة بخطوة.',
      icon: Icons.local_shipping_outlined,
    ),
    _OnboardingData(
      image: 'assets/images/home/sidr_honey.png',
      title: 'كل احتياجات مزرعتك في مكان واحد',
      message: 'منتجات موثوقة، أعلاف، مستلزمات، أدوية بيطرية وعروض مختارة بعناية.',
      icon: Icons.eco_outlined,
    ),
    _OnboardingData(
      image: 'assets/images/home/local_calf.png',
      title: 'مزادات وفرص أقرب إليك',
      message: 'شارك في المزادات وتابع عروض الحيوانات والمعدات والمنتجات الزراعية بسهولة.',
      icon: Icons.gavel_rounded,
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void next() {
    if (index < pages.length - 1) {
      controller.animateToPage(index + 1, duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
            child: Column(
              children: [
                Row(
                  children: [
                    TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/login'), child: const Text('تخطي')),
                    const Spacer(),
                    const AppLogo(size: 48),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: PageView.builder(
                    controller: controller,
                    itemCount: pages.length,
                    onPageChanged: (value) => setState(() => index = value),
                    itemBuilder: (context, pageIndex) {
                      final page = pages[pageIndex];
                      return Column(
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.forestSoft,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(27),
                                    child: AppDataImage(page.image, fit: BoxFit.cover),
                                  ),
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(27),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [Color(0x05000000), Color(0x550D4328)],
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 18),
                                      child: CircleAvatar(
                                        radius: 34,
                                        backgroundColor: AppColors.surface,
                                        child: Icon(page.icon, size: 34, color: AppColors.forestDark),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(page.title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.forestDark, fontSize: 24, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 8),
                          Text(page.message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontSize: 14, height: 1.55)),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (dot) => AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: dot == index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(color: dot == index ? AppColors.forest : AppColors.border, borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: next,
                    child: Text(index == pages.length - 1 ? 'ابدأ الآن' : 'التالي', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _OnboardingData {
  const _OnboardingData({required this.image, required this.title, required this.message, required this.icon});
  final String image;
  final String title;
  final String message;
  final IconData icon;
}
