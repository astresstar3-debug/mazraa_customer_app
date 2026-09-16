import 'package:flutter/material.dart';

import '../../../core/network/api_config.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../data/account_repository.dart';

class MatchedAccountScreen extends StatefulWidget {
  const MatchedAccountScreen({super.key});

  @override
  State<MatchedAccountScreen> createState() => _MatchedAccountScreenState();
}

class _MatchedAccountScreenState extends State<MatchedAccountScreen> {
  Future<UserProfileData>? _future;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    if (app.session == null) {
      return Scaffold(
        backgroundColor: AppColors.ivory,
        body: AppPage(
          child: Column(
            children: [
              const SizedBox(height: 60),
              const AppLogo(size: 90, showName: true),
              const SizedBox(height: 24),
              const Text('سجّل الدخول لإدارة حسابك', style: TextStyle(color: AppColors.forestDark, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 18),
              SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.pushNamed(context, '/login'), child: const Text('تسجيل الدخول'))),
            ],
          ),
        ),
      );
    }

    _future ??= AccountRepository(app.client).fetchProfile();
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: AppPage(
                padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 14, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(onPressed: () => Navigator.pushNamed(context, '/notifications'), icon: const Icon(Icons.notifications_none_rounded, color: AppColors.forestDark, size: 29)),
                              Positioned(right: 3, top: 2, child: Container(width: 18, height: 18, alignment: Alignment.center, decoration: const BoxDecoration(color: AppColors.terracotta, shape: BoxShape.circle), child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)))),
                            ],
                          ),
                          IconButton(onPressed: () => Navigator.pushNamed(context, '/settings'), icon: const Icon(Icons.settings_outlined, color: AppColors.forestDark, size: 29)),
                          const Spacer(),
                          const AppLogo(size: 52),
                          const Spacer(),
                          const Row(children: [Text('حسابي', style: TextStyle(color: AppColors.forestDark, fontSize: 25, fontWeight: FontWeight.w900)), SizedBox(width: 7), Icon(Icons.eco_rounded, color: AppColors.forestDark)]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    FutureBuilder<UserProfileData>(
                      future: _future,
                      builder: (context, snapshot) {
                        final p = snapshot.data;
                        final session = app.session!;
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F0E6),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => Navigator.pushNamed(context, '/profile-avatar'),
                                borderRadius: BorderRadius.circular(55),
                                child: _avatar(p),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p?.displayName ?? session.email.split('@').first, style: const TextStyle(color: AppColors.forestDark, fontSize: 22, fontWeight: FontWeight.w900)),
                                    const SizedBox(height: 7),
                                    if ((p?.phone ?? '').trim().isNotEmpty)
                                      Row(children: [const Icon(Icons.phone_rounded, color: AppColors.forestDark, size: 18), const SizedBox(width: 7), Expanded(child: Text(p!.phone, style: const TextStyle(color: AppColors.forestDark)))]),
                                    const SizedBox(height: 5),
                                    Row(children: [const Icon(Icons.email_rounded, color: AppColors.forestDark, size: 18), const SizedBox(width: 7), Expanded(child: Text(p?.email ?? session.email, style: const TextStyle(color: AppColors.forestDark, fontSize: 12)))]),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                                      decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(14)),
                                      child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.verified_rounded, color: Colors.white, size: 18), SizedBox(width: 5), Text('عميل موثق', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900))]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 9,
                      mainAxisSpacing: 9,
                      childAspectRatio: .92,
                      children: const [
                        _AccountShortcut(label: 'طلباتي', icon: Icons.inventory_2_outlined, route: '/orders', tone: _ShortcutTone.orange),
                        _AccountShortcut(label: 'المفضلة', icon: Icons.favorite_border_rounded, route: '/favorites', tone: _ShortcutTone.green),
                        _AccountShortcut(label: 'العناوين', icon: Icons.location_on_outlined, route: '/addresses', tone: _ShortcutTone.sage),
                        _AccountShortcut(label: 'المحفظة', icon: Icons.account_balance_wallet_outlined, route: '/wallet', tone: _ShortcutTone.green),
                        _AccountShortcut(label: 'طرق الدفع', icon: Icons.credit_card_rounded, route: '/payment-methods', tone: _ShortcutTone.orange),
                        _AccountShortcut(label: 'المرتجعات', icon: Icons.assignment_return_outlined, route: '/returns', tone: _ShortcutTone.sage),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _menu(context, Icons.settings_outlined, 'الإعدادات', '/settings'),
                    const SizedBox(height: 8),
                    _menu(context, Icons.support_agent_rounded, 'الدعم والمساعدة', '/support'),
                    const SizedBox(height: 8),
                    _menu(context, Icons.verified_user_outlined, 'الشروط والخصوصية', '/legal'),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        await app.logout();
                        if (!context.mounted) return;
                        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 62,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: _menuDecoration(),
                        child: const Row(children: [Icon(Icons.logout_rounded, color: AppColors.forestDark), SizedBox(width: 11), Expanded(child: Text('تسجيل الخروج', style: TextStyle(color: AppColors.forestDark, fontSize: 16, fontWeight: FontWeight.w800))), Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.forestDark, size: 15)]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const _AccountBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _avatar(UserProfileData? profile) {
    final source = ApiConfig.resolveMediaUrl(profile?.profileImageUrl);
    if (source.isNotEmpty) {
      return Container(
        width: 108,
        height: 108,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.forest, width: 2)),
        child: ClipOval(child: AppDataImage(source, fit: BoxFit.cover)),
      );
    }
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.forestSoft, border: Border.all(color: AppColors.forest, width: 2)),
      child: const Icon(Icons.person_rounded, color: AppColors.forest, size: 58),
    );
  }

  Widget _menu(BuildContext context, IconData icon, String label, String route) => InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: _menuDecoration(),
          child: Row(children: [Icon(icon, color: AppColors.forestDark), const SizedBox(width: 11), Expanded(child: Text(label, style: const TextStyle(color: AppColors.forestDark, fontSize: 16, fontWeight: FontWeight.w800))), const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.forestDark, size: 15)]),
        ),
      );
}

enum _ShortcutTone { green, orange, sage }

class _AccountShortcut extends StatelessWidget {
  const _AccountShortcut({required this.label, required this.icon, required this.route, required this.tone});
  final String label;
  final IconData icon;
  final String route;
  final _ShortcutTone tone;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      _ShortcutTone.green => AppColors.forestDark,
      _ShortcutTone.orange => AppColors.terracotta,
      _ShortcutTone.sage => const Color(0xFF647F55),
    };
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: _menuDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 72, height: 54, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: Colors.white, size: 31)),
            const SizedBox(height: 9),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [Flexible(child: Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.forestDark, fontSize: 12, fontWeight: FontWeight.w900))), const SizedBox(width: 3), const Icon(Icons.arrow_back_ios_new_rounded, size: 10, color: AppColors.forestDark)]),
          ],
        ),
      ),
    );
  }
}

class _AccountBottomNav extends StatelessWidget {
  const _AccountBottomNav();

  @override
  Widget build(BuildContext context) {
    const items = <({String label, IconData icon, String route})>[
      (label: 'الرئيسية', icon: Icons.home_outlined, route: '/'),
      (label: 'المنتجات', icon: Icons.grid_view_outlined, route: '/products'),
      (label: 'المزادات', icon: Icons.gavel_outlined, route: '/auctions'),
      (label: 'سلة التسوق', icon: Icons.shopping_cart_outlined, route: '/cart'),
      (label: 'حسابي', icon: Icons.person_rounded, route: '/account'),
    ];
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Container(
          height: 72,
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final active = index == 4;
              return Expanded(
                child: InkWell(
                  onTap: active ? null : () => Navigator.pushNamedAndRemoveUntil(context, item.route, (route) => item.route != '/' && route.isFirst),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, color: active ? AppColors.forest : AppColors.muted, size: 23),
                      const SizedBox(height: 3),
                      Text(item.label, style: TextStyle(color: active ? AppColors.forest : AppColors.muted, fontSize: 9.5, fontWeight: active ? FontWeight.w900 : FontWeight.w600)),
                      const SizedBox(height: 3),
                      Container(width: active ? 26 : 0, height: 3, decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(3))),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

BoxDecoration _menuDecoration() => BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppColors.border),
      boxShadow: const [BoxShadow(color: Color(0x080D4328), blurRadius: 9, offset: Offset(0, 2))],
    );
