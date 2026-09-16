import 'package:flutter/material.dart';

import '../../../core/network/api_config.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../data/account_repository.dart';

class ConnectedAccountScreen extends StatefulWidget {
  const ConnectedAccountScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<ConnectedAccountScreen> createState() => _ConnectedAccountScreenState();
}

class _ConnectedAccountScreenState extends State<ConnectedAccountScreen> {
  Future<UserProfileData>? _profileFuture;

  Future<UserProfileData> _loadProfile() {
    final app = AppScope.of(context);
    return AccountRepository(app.client).fetchProfile();
  }

  Future<void> _openAndRefresh(String route) async {
    await Navigator.pushNamed(context, route);
    if (!mounted) return;
    setState(() => _profileFuture = _loadProfile());
  }

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

    _profileFuture ??= _loadProfile();
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
            FutureBuilder<UserProfileData>(
              future: _profileFuture,
              builder: (context, snapshot) {
                final profile = snapshot.data;
                final roles = profile?.roles.isNotEmpty == true
                    ? profile!.roles.join('، ')
                    : (session.roles.isEmpty ? 'عميل' : session.roles.join('، '));
                return AppSurfaceCard(
                  child: Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(40),
                        onTap: () => _openAndRefresh('/profile-avatar'),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _ProfileAvatar(profile: profile),
                            const PositionedDirectional(
                              end: -4,
                              bottom: -4,
                              child: CircleAvatar(
                                radius: 13,
                                backgroundColor: AppColors.forest,
                                child: Icon(Icons.camera_alt_outlined,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.displayName ?? 'جاري تحميل البيانات...',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if ((profile?.phone ?? '').trim().isNotEmpty)
                              Text(profile!.phone),
                            Text(
                              profile?.email ?? session.email,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 5),
                            StatusPill(
                              label: roles,
                              icon: profile?.emailVerified == true ||
                                      profile?.phoneVerified == true
                                  ? Icons.verified_rounded
                                  : Icons.verified_user_outlined,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _Shortcut(icon: Icons.inventory_2_outlined, label: 'طلباتي', route: '/orders')),
                const SizedBox(width: 8),
                Expanded(child: _Shortcut(icon: Icons.favorite_border_rounded, label: 'المفضلة', route: '/favorites')),
                const SizedBox(width: 8),
                Expanded(child: _Shortcut(icon: Icons.location_on_outlined, label: 'العناوين', route: '/addresses')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _Shortcut(icon: Icons.account_balance_wallet_outlined, label: 'المحفظة', route: '/wallet')),
                const SizedBox(width: 8),
                Expanded(child: _Shortcut(icon: Icons.credit_card_rounded, label: 'طرق الدفع', route: '/payment-methods')),
                const SizedBox(width: 8),
                Expanded(child: _Shortcut(icon: Icons.gavel_rounded, label: 'مزاداتي', route: '/my-auctions')),
              ],
            ),
            const SizedBox(height: 14),
            SettingsTile(
              icon: Icons.edit_outlined,
              title: 'تعديل البيانات',
              onTap: () => _openAndRefresh('/edit-profile'),
            ),
            const SizedBox(height: 8),
            SettingsTile(
              icon: Icons.photo_camera_back_outlined,
              title: 'صورة الحساب',
              subtitle: 'اختيار صورة ورفعها إلى الخادم',
              onTap: () => _openAndRefresh('/profile-avatar'),
            ),
            const SizedBox(height: 8),
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile});
  final UserProfileData? profile;

  @override
  Widget build(BuildContext context) {
    final image = ApiConfig.resolveMediaUrl(profile?.profileImageUrl);
    if (image.isNotEmpty) {
      return ClipOval(
        child: AppDataImage(
          image,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
        ),
      );
    }
    return const _FallbackAvatar();
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar();

  @override
  Widget build(BuildContext context) => const CircleAvatar(
        radius: 36,
        backgroundColor: AppColors.forestSoft,
        child: Icon(Icons.person_rounded, size: 42, color: AppColors.forest),
      );
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({required this.icon, required this.label, required this.route});
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
                Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
                const SizedBox(height: 6),
                Text(label,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      );
}
