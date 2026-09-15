import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, this.embedded = false});
  final bool embedded;
  @override
  Widget build(BuildContext context) => Scaffold(
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
                        'محمد العتيبي',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Text('+966 50 123 4567'),
                      const Text(
                        'mohammed@example.com',
                        style: TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                      const SizedBox(height: 5),
                      const StatusPill(
                        label: 'عميل موثّق',
                        icon: Icons.verified_rounded,
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
                child: _AccountShortcut(
                  icon: Icons.inventory_2_outlined,
                  label: 'طلباتي',
                  route: '/orders',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AccountShortcut(
                  icon: Icons.favorite_border_rounded,
                  label: 'المفضلة',
                  route: '/favorites',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AccountShortcut(
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
                child: _AccountShortcut(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'المحفظة',
                  route: '/wallet',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AccountShortcut(
                  icon: Icons.credit_card_rounded,
                  label: 'طرق الدفع',
                  route: '/payment-methods',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AccountShortcut(
                  icon: Icons.gavel_rounded,
                  label: 'مزاداتي',
                  route: '/my-auctions',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SettingsTile(
            icon: Icons.edit_outlined,
            title: 'تعديل البيانات',
            onTap: () => Navigator.pushNamed(context, '/edit-profile'),
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
          const SettingsTile(icon: Icons.logout_rounded, title: 'تسجيل الخروج'),
        ],
      ),
    ),
  );
}

class _AccountShortcut extends StatelessWidget {
  const _AccountShortcut({
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
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}

class SimpleFormScreen extends StatelessWidget {
  const SimpleFormScreen({
    super.key,
    required this.title,
    required this.fields,
    this.icon = Icons.eco_rounded,
    this.button = 'حفظ التغييرات',
    this.danger = false,
  });
  final String title;
  final List<FormFieldSpec> fields;
  final IconData icon;
  final String button;
  final bool danger;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: MazraaAppBar(title: title),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: danger ? AppColors.terracottaSoft : AppColors.forestSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 58,
                color: danger ? AppColors.error : AppColors.forest,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...fields.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: f.multiline
                  ? TextField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: f.label,
                        hintText: f.hint,
                        prefixIcon: Icon(f.icon),
                      ),
                    )
                  : TextField(
                      obscureText: f.secure,
                      keyboardType: f.phone
                          ? TextInputType.phone
                          : TextInputType.text,
                      decoration: InputDecoration(
                        labelText: f.label,
                        hintText: f.hint,
                        prefixIcon: Icon(f.icon),
                        suffixIcon: f.secure
                            ? const Icon(Icons.visibility_off_outlined)
                            : null,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            style: danger
                ? FilledButton.styleFrom(backgroundColor: AppColors.error)
                : null,
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('تم $button بنجاح')));
              Navigator.pop(context);
            },
            child: Text(button),
          ),
        ],
      ),
    ),
  );
}

class FormFieldSpec {
  const FormFieldSpec(
    this.label,
    this.icon, {
    this.hint,
    this.secure = false,
    this.multiline = false,
    this.phone = false,
  });
  final String label;
  final IconData icon;
  final String? hint;
  final bool secure;
  final bool multiline;
  final bool phone;
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool appNotifications = true;
  bool auctionNotifications = true;
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      appBar: const MazraaAppBar(title: 'الإعدادات'),
      body: AppPage(
        child: Column(
          children: [
            SwitchListTile(
              value: appNotifications,
              onChanged: (v) => setState(() => appNotifications = v),
              title: const Text('إشعارات التطبيق'),
              secondary: const Icon(Icons.notifications_none_rounded),
            ),
            SwitchListTile(
              value: auctionNotifications,
              onChanged: (v) => setState(() => auctionNotifications = v),
              title: const Text('إشعارات المزادات'),
              secondary: const Icon(Icons.gavel_rounded),
            ),
            const SizedBox(height: 8),
            const SettingsTile(
              icon: Icons.translate_rounded,
              title: 'اللغة',
              subtitle: 'العربية',
            ),
            const SizedBox(height: 8),
            const SettingsTile(
              icon: Icons.location_on_outlined,
              title: 'الموقع الجغرافي',
              subtitle: 'الرياض',
            ),
            const SizedBox(height: 8),
            SettingsTile(
              icon: Icons.credit_card_rounded,
              title: 'طرق الدفع',
              onTap: () => Navigator.pushNamed(context, '/payment-methods'),
            ),
            const SizedBox(height: 8),
            SettingsTile(
              icon: Icons.security_rounded,
              title: 'الأمان وتسجيل الدخول',
              onTap: () => Navigator.pushNamed(context, '/change-password'),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: app.themeMode == ThemeMode.dark,
              onChanged: app.toggleTheme,
              title: const Text('الوضع الليلي'),
              secondary: const Icon(Icons.dark_mode_outlined),
            ),
            const SizedBox(height: 8),
            const SettingsTile(
              icon: Icons.delete_sweep_outlined,
              title: 'مسح ذاكرة التخزين',
            ),
            const SizedBox(height: 12),
            const AppSurfaceCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco_rounded, color: AppColors.forest),
                  SizedBox(width: 7),
                  Text('الإصدار 1.0.0'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout_rounded),
                label: const Text('تسجيل الخروج'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/delete-account'),
              child: const Text(
                'حذف الحساب',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int tab = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: MazraaAppBar(
      title: 'الإشعارات',
      actions: [
        IconButton(
          onPressed: () =>
              Navigator.pushNamed(context, '/notification-preferences'),
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
    ),
    body: AppPage(
      child: Column(
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('الكل')),
              ButtonSegment(value: 1, label: Text('الطلبات')),
              ButtonSegment(value: 2, label: Text('المزادات')),
              ButtonSegment(value: 3, label: Text('العروض')),
            ],
            selected: {tab},
            showSelectedIcon: false,
            onSelectionChanged: (v) => setState(() => tab = v.first),
          ),
          const SizedBox(height: 12),
          ...const [
            (
              'تم شحن طلبك #MZ-24581',
              'منذ 5 دقائق',
              Icons.local_shipping_outlined,
              AppColors.forest,
            ),
            (
              'تم تجاوز مزايدتك على عسل سدر',
              'منذ 27 دقيقة',
              Icons.gavel_rounded,
              AppColors.terracotta,
            ),
            (
              'اقترب موعد انتهاء مزاد النخيل',
              'منذ ساعة',
              Icons.notifications_active_outlined,
              AppColors.warning,
            ),
            (
              'كوبون خصم 20% متاح لك',
              'منذ 3 ساعات',
              Icons.local_offer_outlined,
              AppColors.terracotta,
            ),
            (
              'تمت إضافة مبلغ إلى محفظتك',
              'منذ 5 ساعات',
              Icons.account_balance_wallet_outlined,
              AppColors.forest,
            ),
          ].map(
            (n) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppSurfaceCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: n.$4.withValues(alpha: .12),
                    child: Icon(n.$3, color: n.$4),
                  ),
                  title: Text(n.$1),
                  subtitle: Text(n.$2),
                  trailing: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});
  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  final values = List.filled(8, true);
  @override
  Widget build(BuildContext context) {
    const items = [
      ('كل الإشعارات', Icons.notifications_active_outlined),
      ('إشعارات الطلبات', Icons.shopping_cart_outlined),
      ('تحديثات التوصيل', Icons.local_shipping_outlined),
      ('المزايدات الفورية', Icons.gavel_rounded),
      ('تجاوز المزايدة', Icons.trending_up_rounded),
      ('تذكير المزادات', Icons.alarm_rounded),
      ('العروض والكوبونات', Icons.local_offer_outlined),
      ('عمليات المحفظة', Icons.account_balance_wallet_outlined),
    ];
    return Scaffold(
      appBar: const MazraaAppBar(title: 'تفضيلات الإشعارات'),
      body: AppPage(
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppSurfaceCard(
                  padding: EdgeInsets.zero,
                  child: SwitchListTile(
                    value: values[i],
                    onChanged: (v) => setState(() => values[i] = v),
                    title: Text(items[i].$1),
                    secondary: Icon(items[i].$2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key, this.empty = false});
  final bool empty;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'العناوين'),
    body: empty
        ? ResultStateView(
            kind: ResultKind.empty,
            title: 'لم تضف أي عنوان بعد',
            message: 'أضف عنوانك لتسهيل إتمام الطلب والتوصيل',
            primaryLabel: 'إضافة عنوان جديد',
            onPrimary: () => Navigator.pushNamed(context, '/add-address'),
          )
        : AppPage(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppSurfaceCard(
                  color: AppColors.forestSoft,
                  child: ListTile(
                    leading: Icon(Icons.home_rounded, color: AppColors.forest),
                    title: Text('المنزل'),
                    subtitle: Text('الرياض، حي النخيل، شارع الملك فهد'),
                    trailing: Icon(
                      Icons.radio_button_checked,
                      color: AppColors.forest,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                const AppSurfaceCard(
                  child: ListTile(
                    leading: Icon(Icons.eco_rounded, color: AppColors.forest),
                    title: Text('المزرعة'),
                    subtitle: Text('الخرج، طريق المزرعة'),
                    trailing: Icon(
                      Icons.radio_button_off,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/add-address'),
                  icon: const Icon(Icons.add_circle_rounded),
                  label: const Text('إضافة عنوان جديد'),
                ),
              ],
            ),
          ),
  );
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'المحفظة'),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 142,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.forestDark, AppColors.forest],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الرصيد المتاح',
                  style: TextStyle(color: Colors.white70),
                ),
                const Text(
                  '2,850 ر.س',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white24,
                        ),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/wallet-topup'),
                        icon: const Icon(Icons.add_card_rounded),
                        label: const Text('شحن المحفظة'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.terracotta,
                        ),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/wallet-transactions',
                        ),
                        icon: const Icon(Icons.swap_horiz_rounded),
                        label: const Text('تحويل أو استخدام'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: AppSurfaceCard(
                  child: Column(
                    children: [
                      Text('إجمالي المدفوعات'),
                      Text(
                        '680- ر.س',
                        style: TextStyle(
                          color: AppColors.terracotta,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: AppSurfaceCard(
                  child: Column(
                    children: [
                      Text('إجمالي الإضافات'),
                      Text(
                        '1,250+ ر.س',
                        style: TextStyle(
                          color: AppColors.forest,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const SectionHeader(title: 'إجراءات سريعة', icon: Icons.bolt_rounded),
          Row(
            children: [
              Expanded(
                child: _AccountShortcut(
                  icon: Icons.add_card_rounded,
                  label: 'شحن المحفظة',
                  route: '/wallet-topup',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AccountShortcut(
                  icon: Icons.swap_horiz_rounded,
                  label: 'تحويل الأموال',
                  route: '/wallet-transactions',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AccountShortcut(
                  icon: Icons.receipt_long_outlined,
                  label: 'سجل العمليات',
                  route: '/wallet-transactions',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const SectionHeader(
            title: 'أحدث العمليات',
            icon: Icons.history_rounded,
          ),
          ..._transactions
              .take(3)
              .map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _TransactionTile(data: t),
                ),
              ),
          FilledButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/wallet-transactions'),
            child: const Text('عرض كل العمليات'),
          ),
        ],
      ),
    ),
  );
}

const _transactions = [
  (
    'شحن من بطاقة ••••4821',
    '+500 ر.س',
    Icons.add_card_rounded,
    AppColors.forest,
  ),
  ('حجز ضمان مزاد', '-250 ر.س', Icons.gavel_rounded, AppColors.terracotta),
  ('استرداد طلب', '+120 ر.س', Icons.replay_rounded, AppColors.forest),
  (
    'شراء من المحفظة',
    '-85 ر.س',
    Icons.shopping_cart_outlined,
    AppColors.terracotta,
  ),
];

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.data});
  final (String, String, IconData, Color) data;
  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: data.$4.withValues(alpha: .12),
        child: Icon(data.$3, color: data.$4),
      ),
      title: Text(data.$1),
      subtitle: const Text('12 سبتمبر 2026 • 14:32'),
      trailing: Text(
        data.$2,
        style: TextStyle(color: data.$4, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

class WalletTransactionsScreen extends StatelessWidget {
  const WalletTransactionsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'عمليات المحفظة'),
    body: AppPage(
      child: Column(
        children: [
          const AppSurfaceCard(
            color: AppColors.forest,
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet_rounded, color: Colors.white),
                SizedBox(width: 9),
                Text('الرصيد الحالي', style: TextStyle(color: Colors.white)),
                Spacer(),
                Text(
                  '2,850 ر.س',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 7,
            children: [
              ChoiceChip(label: Text('الكل'), selected: true),
              ChoiceChip(label: Text('شحن'), selected: false),
              ChoiceChip(label: Text('خصم'), selected: false),
              ChoiceChip(label: Text('استرداد'), selected: false),
            ],
          ),
          const SizedBox(height: 12),
          ..._transactions.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TransactionTile(data: t),
            ),
          ),
        ],
      ),
    ),
  );
}

class WalletTopUpScreen extends StatefulWidget {
  const WalletTopUpScreen({super.key});
  @override
  State<WalletTopUpScreen> createState() => _WalletTopUpScreenState();
}

class _WalletTopUpScreenState extends State<WalletTopUpScreen> {
  int amount = 1000;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'شحن المحفظة'),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSurfaceCard(
            color: AppColors.forestSoft,
            child: Column(
              children: [
                Text('رصيد المحفظة الحالي'),
                Text(
                  '2,850 ر.س',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forest,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const SectionHeader(
            title: 'اختر مبلغ الشحن',
            icon: Icons.payments_outlined,
          ),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [100, 250, 500, 1000]
                .map(
                  (e) => ChoiceChip(
                    label: Text('$e ر.س'),
                    selected: amount == e,
                    onSelected: (_) => setState(() => amount = e),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'مبلغ آخر',
              prefixIcon: Icon(Icons.calculate_outlined),
            ),
          ),
          const SizedBox(height: 14),
          const SectionHeader(
            title: 'طريقة الدفع',
            icon: Icons.credit_card_rounded,
          ),
          const SettingsTile(
            icon: Icons.credit_card_rounded,
            title: 'بطاقة مدى •••• 4821',
            subtitle: 'تغيير',
          ),
          const SizedBox(height: 14),
          AppSurfaceCard(
            child: Row(
              children: [
                const Text('المبلغ الإجمالي للدفع'),
                const Spacer(),
                Text(
                  formatPrice(amount),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => WalletTopUpSuccessScreen(amount: amount),
              ),
            ),
            icon: const Icon(Icons.account_balance_wallet_rounded),
            label: const Text('شحن الآن'),
          ),
        ],
      ),
    ),
  );
}

class WalletTopUpSuccessScreen extends StatelessWidget {
  const WalletTopUpSuccessScreen({super.key, required this.amount});
  final int amount;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(),
    body: ResultStateView(
      kind: ResultKind.success,
      title: 'تمت إضافة الرصيد بنجاح',
      message: 'تمت إضافة المبلغ إلى محفظتك',
      primaryLabel: 'العودة للمحفظة',
      onPrimary: () => Navigator.pop(context),
      secondaryLabel: 'عرض العمليات',
      onSecondary: () => Navigator.pushNamed(context, '/wallet-transactions'),
      details: AppSurfaceCard(
        child: Column(
          children: [
            ListTile(
              title: const Text('المبلغ المضاف'),
              trailing: Text('+${formatPrice(amount)}'),
            ),
            const Divider(),
            const ListTile(
              title: Text('الرصيد الجديد'),
              trailing: Text('3,850 ر.س'),
            ),
            const Divider(),
            const ListTile(
              title: Text('رقم العملية'),
              trailing: Text('#WLT-77821'),
            ),
          ],
        ),
      ),
    ),
  );
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final orders = AppScope.of(context).repository.orders;
    return Scaffold(
      appBar: const MazraaAppBar(title: 'طلباتي'),
      body: AppPage(
        child: Column(
          children: [
            const Wrap(
              spacing: 7,
              children: [
                ChoiceChip(label: Text('الكل'), selected: true),
                ChoiceChip(label: Text('قيد التجهيز'), selected: false),
                ChoiceChip(label: Text('قيد التوصيل'), selected: false),
                ChoiceChip(label: Text('مكتمل'), selected: false),
              ],
            ),
            const SizedBox(height: 12),
            ...orders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppSurfaceCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          StatusPill(
                            label: order.status,
                            color: order.status == 'مكتمل'
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          const Spacer(),
                          Text(
                            '#${order.id}',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      SizedBox(
                        height: 86,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: order.products.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 7),
                          itemBuilder: (_, i) => ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              order.products[i].image,
                              width: 92,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Text('الإجمالي ${formatPrice(order.total)}'),
                          const Spacer(),
                          FilledButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/order-details'),
                            child: Text(
                              order.status == 'مكتمل'
                                  ? 'عرض التفاصيل'
                                  : 'تتبع الطلب',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final order = AppScope.of(context).repository.orders.first;
    return Scaffold(
      appBar: const MazraaAppBar(title: 'تفاصيل الطلب'),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  '#${order.id}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                const StatusPill(
                  label: 'قيد التوصيل',
                  color: AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const AppSurfaceCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.forest,
                        child: Icon(Icons.check, color: Colors.white),
                      ),
                      Text('تم الطلب', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                  Expanded(child: Divider()),
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.forest,
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.white,
                        ),
                      ),
                      Text('قيد التجهيز', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                  Expanded(child: Divider()),
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.warning,
                        child: Icon(
                          Icons.local_shipping_outlined,
                          color: Colors.white,
                        ),
                      ),
                      Text('قيد التوصيل', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                  Expanded(child: Divider()),
                  Column(
                    children: [
                      CircleAvatar(child: Icon(Icons.home_outlined)),
                      Text('تم التسليم', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const SectionHeader(title: 'المنتجات', icon: Icons.eco_rounded),
            AppSurfaceCard(
              child: Column(
                children: order.products
                    .map(
                      (p) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Image.asset(
                          p.image,
                          width: 58,
                          height: 54,
                          fit: BoxFit.cover,
                        ),
                        title: Text(p.name),
                        subtitle: const Text('الكمية 1'),
                        trailing: Text(formatPrice(p.price)),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),
            const SettingsTile(
              icon: Icons.location_on_outlined,
              title: 'عنوان التوصيل',
              subtitle: 'الرياض، حي النخيل',
            ),
            const SizedBox(height: 8),
            const SettingsTile(
              icon: Icons.credit_card_rounded,
              title: 'طريقة الدفع',
              subtitle: 'بطاقة مدى •••• 4821',
            ),
            const SizedBox(height: 8),
            const SettingsTile(
              icon: Icons.receipt_long_outlined,
              title: 'الفاتورة الإلكترونية',
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/track-order'),
                    child: const Text('تتبع الطلب'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/cancel-order'),
                    child: const Text('طلب إلغاء'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/return-request'),
              child: const Text('طلب إرجاع'),
            ),
          ],
        ),
      ),
    );
  }
}

class TrackOrderScreen extends StatelessWidget {
  const TrackOrderScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'تتبع الطلب'),
    body: AppPage(
      child: Column(
        children: [
          Container(
            height: 265,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFDDE6CF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(double.infinity, 265),
                  painter: _RoutePainter(),
                ),
                const Positioned(
                  right: 56,
                  bottom: 60,
                  child: CircleAvatar(
                    backgroundColor: AppColors.forest,
                    child: Icon(Icons.location_on_rounded, color: Colors.white),
                  ),
                ),
                const Positioned(
                  left: 70,
                  top: 54,
                  child: CircleAvatar(
                    backgroundColor: AppColors.terracotta,
                    child: Icon(Icons.home_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const AppSurfaceCard(
            child: ListTile(
              leading: CircleAvatar(
                radius: 28,
                child: Icon(Icons.person_rounded),
              ),
              title: Text('الموصل عبدالله السالم'),
              subtitle: Text('يصل خلال 35 دقيقة • تقييم 4.9'),
              trailing: Icon(Icons.phone_rounded, color: AppColors.forest),
            ),
          ),
          const SizedBox(height: 10),
          const AppSurfaceCard(
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.forest,
                    child: Icon(Icons.check, color: Colors.white),
                  ),
                  title: Text('قيد التوصيل'),
                  subtitle: Text('الآن • في الطريق إليك'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.forestSoft,
                    child: Icon(Icons.location_on_outlined),
                  ),
                  title: Text('وصل إلى منطقتك'),
                  subtitle: Text('منذ 15 دقيقة'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.forestSoft,
                    child: Icon(Icons.inventory_2_outlined),
                  ),
                  title: Text('تم تجهيز الطلب'),
                  subtitle: Text('منذ 45 دقيقة'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: const Text('مراسلة'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone_rounded),
                  label: const Text('اتصال'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: .65)
      ..strokeWidth = 2;
    for (double y = 20; y < size.height; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 20), grid);
    }
    for (double x = 20; x < size.width; x += 54) {
      canvas.drawLine(Offset(x, 0), Offset(x - 20, size.height), grid);
    }
    final route = Paint()
      ..color = AppColors.forest
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width - 55, size.height - 55)
      ..cubicTo(
        size.width * .7,
        size.height * .65,
        size.width * .35,
        size.height * .52,
        75,
        70,
      );
    canvas.drawPath(path, route);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'الدعم والمساعدة'),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSearchField(hint: 'ابحث في الأسئلة الشائعة...'),
          const SizedBox(height: 14),
          const SectionHeader(
            title: 'الأسئلة الشائعة',
            icon: Icons.quiz_outlined,
          ),
          ...[
            'كيف أتابع طلبي؟',
            'كيف أشارك في مزاد؟',
            'كيف أشحن المحفظة؟',
            'ما سياسة الإرجاع؟',
          ].map(
            (q) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
                ),
                title: Text(q),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(14),
                    child: Text(
                      'ستجد كل التفاصيل والخطوات داخل القسم المرتبط من حسابك، ويمكن لفريق الدعم مساعدتك في أي وقت.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const SectionHeader(
            title: 'تواصل معنا',
            icon: Icons.support_agent_rounded,
          ),
          Row(
            children: [
              Expanded(
                child: _AccountShortcut(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'محادثة مباشرة',
                  route: '/support-chat',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AccountShortcut(
                  icon: Icons.phone_outlined,
                  label: 'اتصال هاتفي',
                  route: '/support-chat',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AccountShortcut(
                  icon: Icons.email_outlined,
                  label: 'تواصل معنا',
                  route: '/support-ticket',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/support-ticket'),
            icon: const Icon(Icons.confirmation_number_outlined),
            label: const Text('فتح تذكرة دعم'),
          ),
        ],
      ),
    ),
  );
}

class SupportChatScreen extends StatelessWidget {
  const SupportChatScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'المحادثة مع الدعم'),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            IconButton.filledTonal(
              onPressed: () {},
              icon: const Icon(Icons.attach_file_rounded),
            ),
            const SizedBox(width: 7),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(hintText: 'اكتب رسالتك...'),
              ),
            ),
            const SizedBox(width: 7),
            IconButton.filled(
              onPressed: () {},
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    ),
    body: AppPage(
      child: Column(
        children: [
          const ListTile(
            leading: CircleAvatar(child: Icon(Icons.support_agent_rounded)),
            title: Text('سارة من فريق مزرعتي'),
            subtitle: Text(
              'متصلة الآن',
              style: TextStyle(color: AppColors.success),
            ),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppSurfaceCard(
              child: Text('مرحبًا بك، كيف يمكننا مساعدتك؟'),
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: AlignmentDirectional.centerEnd,
            child: AppSurfaceCard(
              color: AppColors.forest,
              child: Text(
                'أريد الاستفسار عن طلبي #MZ-24581',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
          AppSurfaceCard(
            child: Row(
              children: [
                Image.asset(
                  'assets/images/home/najdi_sheep.png',
                  width: 72,
                  height: 62,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#MZ-24581',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text('قيد التوصيل'),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppSurfaceCard(
              child: Text(
                'سأتحقق من حالة الطلب الآن. سيصل خلال 35 دقيقة تقريبًا.',
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});
  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  int tab = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'الشروط والخصوصية'),
    body: AppPage(
      child: Column(
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('شروط الاستخدام')),
              ButtonSegment(value: 1, label: Text('سياسة الخصوصية')),
              ButtonSegment(value: 2, label: Text('سياسة الإرجاع')),
            ],
            selected: {tab},
            showSelectedIcon: false,
            onSelectionChanged: (v) => setState(() => tab = v.first),
          ),
          const SizedBox(height: 14),
          ...[
            'شروط الاستخدام',
            'سياسة الخصوصية',
            'سياسة الإرجاع',
          ].asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          [
                            Icons.description_outlined,
                            Icons.lock_outline_rounded,
                            Icons.replay_rounded,
                          ][e.key],
                          color: AppColors.forest,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          e.value,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'توضح هذه السياسة حقوقك والتزاماتك عند استخدام منصة مزرعتي. نحافظ على بياناتك ونوفر تجربة شراء ومزايدة آمنة وشفافة، مع الالتزام بأحكام البيع والدفع والتوصيل والإرجاع المعروضة داخل التطبيق.',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const AppSurfaceCard(
            color: AppColors.forestSoft,
            child: ListTile(
              leading: Icon(Icons.calendar_month_outlined),
              title: Text('آخر تحديث'),
              trailing: Text('15 سبتمبر 2026'),
            ),
          ),
        ],
      ),
    ),
  );
}

class GenericActionResultScreen extends StatelessWidget {
  const GenericActionResultScreen({
    super.key,
    required this.title,
    required this.message,
    this.kind = ResultKind.success,
  });
  final String title;
  final String message;
  final ResultKind kind;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(),
    body: ResultStateView(kind: kind, title: title, message: message),
  );
}
