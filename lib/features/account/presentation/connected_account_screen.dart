import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';

class ConnectedAccountScreen extends StatelessWidget {
  const ConnectedAccountScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final session = app.session;
    if (session == null) {
      return Scaffold(
        appBar: const MazraaAppBar(),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 42),
              const Center(child: AppLogo(size: 82, showName: true)),
              const SizedBox(height: 24),
              Text(
                'سجّل الدخول لإدارة حسابك',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: AppColors.forest),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('تسجيل الدخول'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('إنشاء حساب جديد'),
              ),
            ],
          ),
        ),
      );
    }

    final role = session.roles.isEmpty ? 'عميل' : session.roles.join('، ');
    return Scaffold(
      appBar: MazraaAppBar(
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSurfaceCard(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.forestSoft,
                    child: Icon(
                      Icons.person_rounded,
                      size: 42,
                      color: AppColors.forest,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.email,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (session.userId != null)
                          Text(
                            'رقم المستخدم: ${session.userId}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        const SizedBox(height: 5),
                        StatusPill(
                          label: role,
                          icon: Icons.verified_user_outlined,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Shortcut(
                    icon: Icons.inventory_2_outlined,
                    label: 'طلباتي',
                    route: '/orders',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Shortcut(
                    icon: Icons.favorite_border_rounded,
                    label: 'المفضلة',
                    route: '/favorites',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Shortcut(
                    icon: Icons.location_on_outlined,
                    label: 'العناوين',
                    route: '/addresses',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _Shortcut(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'المحفظة',
                    route: '/wallet',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Shortcut(
                    icon: Icons.credit_card_rounded,
                    label: 'طرق الدفع',
                    route: '/payment-methods',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Shortcut(
                    icon: Icons.gavel_rounded,
                    label: 'مزاداتي',
                    route: '/my-auctions',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SettingsTile(
              icon: Icons.settings_outlined,
              title: 'الإعدادات',
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            const SizedBox(height: 8),
            SettingsTile(
              icon: Icons.support_agent_rounded,
              title: 'الدعم والمساعدة',
              onTap: () => Navigator.pushNamed(context, '/support'),
            ),
            const SizedBox(height: 8),
            SettingsTile(
              icon: Icons.verified_user_outlined,
              title: 'الشروط والخصوصية',
              onTap: () => Navigator.pushNamed(context, '/legal'),
            ),
            const SizedBox(height: 8),
            SettingsTile(
              icon: Icons.logout_rounded,
              title: 'تسجيل الخروج',
              onTap: () async {
                await app.logout();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.label,
    required this.route,
  });
  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
