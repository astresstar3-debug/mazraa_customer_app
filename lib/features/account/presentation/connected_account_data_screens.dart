import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_client.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../data/account_repository.dart';

AccountRepository _repo(BuildContext context) =>
    AccountRepository(AppScope.of(context).client);

class ConnectedEditProfileScreen extends StatefulWidget {
  const ConnectedEditProfileScreen({super.key});

  @override
  State<ConnectedEditProfileScreen> createState() =>
      _ConnectedEditProfileScreenState();
}

class _ConnectedEditProfileScreenState extends State<ConnectedEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _error;
  UserProfileData? _profile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_profile == null && _loading) _load();
  }

  Future<void> _load() async {
    try {
      final profile = await _repo(context).fetchProfile();
      if (!mounted) return;
      _profile = profile;
      _name.text = profile.displayName;
      _phone.text = profile.phone;
      _email.text = profile.email;
    } catch (error) {
      _error = error is ApiException ? error.message : 'تعذر تحميل بيانات الحساب.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final profile = _profile;
      await _repo(context).updateProfile(
        name: _name.text,
        phone: _phone.text,
        email: _email.text,
        firstName: profile?.firstName ?? '',
        lastName: profile?.lastName ?? '',
        gender: profile?.gender,
        dateOfBirth: profile?.dateOfBirth,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث بيانات الحساب بنجاح')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error is ApiException
          ? error.message
          : 'تعذر حفظ بيانات الحساب.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'تعديل البيانات'),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : AppPage(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: CircleAvatar(
                          radius: 56,
                          backgroundColor: AppColors.forestSoft,
                          child: Icon(Icons.person_rounded,
                              size: 58, color: AppColors.forest),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _name,
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'أدخل الاسم الكامل'
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'الاسم الكامل',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 11),
                      TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'رقم الجوال',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 11),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value == null || !value.contains('@')
                            ? 'أدخل بريدًا إلكترونيًا صحيحًا'
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(_error!, style: const TextStyle(color: AppColors.error)),
                      ],
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        child: Text(_saving ? 'جاري الحفظ...' : 'حفظ التغييرات'),
                      ),
                    ],
                  ),
                ),
              ),
      );
}

class ConnectedChangePasswordScreen extends StatefulWidget {
  const ConnectedChangePasswordScreen({super.key});

  @override
  State<ConnectedChangePasswordScreen> createState() =>
      _ConnectedChangePasswordScreenState();
}

class _ConnectedChangePasswordScreenState
    extends State<ConnectedChangePasswordScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    if (_next.text.length < 8) {
      setState(() => _error = 'كلمة المرور الجديدة يجب ألا تقل عن 8 أحرف.');
      return;
    }
    if (_next.text != _confirm.text) {
      setState(() => _error = 'تأكيد كلمة المرور غير مطابق.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _repo(context).changePassword(
        currentPassword: _current.text,
        newPassword: _next.text,
      );
      if (!mounted) return;
      await AppScope.of(context).logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error is ApiException
          ? error.message
          : 'تعذر تغيير كلمة المرور.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'تغيير كلمة المرور'),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: AppColors.forestSoft,
                  child: Icon(Icons.lock_rounded,
                      size: 58, color: AppColors.forest),
                ),
              ),
              const SizedBox(height: 20),
              _PasswordField(controller: _current, label: 'كلمة المرور الحالية'),
              const SizedBox(height: 11),
              _PasswordField(controller: _next, label: 'كلمة المرور الجديدة'),
              const SizedBox(height: 11),
              _PasswordField(controller: _confirm, label: 'تأكيد كلمة المرور'),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: AppColors.error)),
              ],
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'جاري التحديث...' : 'تحديث كلمة المرور'),
              ),
            ],
          ),
        ),
      );
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          suffixIcon: const Icon(Icons.visibility_off_outlined),
        ),
      );
}

class ConnectedSettingsScreen extends StatefulWidget {
  const ConnectedSettingsScreen({super.key});

  @override
  State<ConnectedSettingsScreen> createState() => _ConnectedSettingsScreenState();
}

class _ConnectedSettingsScreenState extends State<ConnectedSettingsScreen> {
  UserPreferenceData? _settings;
  bool _loading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_settings == null && _loading) _load();
  }

  Future<void> _load() async {
    try {
      final value = await _repo(context).fetchSettings();
      if (mounted) setState(() => _settings = value);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is ApiException
            ? error.message
            : 'تعذر تحميل الإعدادات.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveNotifications({bool? push, bool? marketing}) async {
    final current = _settings;
    if (current == null) return;
    final next = UserPreferenceData(
      push: push ?? current.push,
      email: current.email,
      sms: current.sms,
      marketing: marketing ?? current.marketing,
      language: current.language,
      shareAnalytics: current.shareAnalytics,
      profileVisible: current.profileVisible,
    );
    setState(() => _settings = next);
    try {
      await _repo(context).updateNotificationPreferences(
        push: next.push,
        email: next.email,
        sms: next.sms,
        marketing: next.marketing,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _settings = current;
        _error = error is ApiException ? error.message : 'تعذر حفظ الإعدادات.';
      });
    }
  }

  Future<void> _toggleLanguage() async {
    final current = _settings;
    if (current == null) return;
    final language = current.language.toLowerCase() == 'ar' ? 'en' : 'ar';
    try {
      await _repo(context).updateLanguage(language);
      if (!mounted) return;
      setState(() => _settings = UserPreferenceData(
            push: current.push,
            email: current.email,
            sms: current.sms,
            marketing: current.marketing,
            language: language,
            shareAnalytics: current.shareAnalytics,
            profileVisible: current.profileVisible,
          ));
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is ApiException
            ? error.message
            : 'تعذر تغيير اللغة.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final settings = _settings;
    return Scaffold(
      appBar: const MazraaAppBar(title: 'الإعدادات'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : AppPage(
              child: Column(
                children: [
                  SwitchListTile(
                    value: settings?.push ?? false,
                    onChanged: settings == null
                        ? null
                        : (value) => _saveNotifications(push: value),
                    title: const Text('إشعارات التطبيق'),
                    secondary: const Icon(Icons.notifications_none_rounded),
                  ),
                  SwitchListTile(
                    value: settings?.marketing ?? false,
                    onChanged: settings == null
                        ? null
                        : (value) => _saveNotifications(marketing: value),
                    title: const Text('العروض والتنبيهات التسويقية'),
                    secondary: const Icon(Icons.local_offer_outlined),
                  ),
                  const SizedBox(height: 8),
                  SettingsTile(
                    icon: Icons.translate_rounded,
                    title: 'اللغة',
                    subtitle: settings?.language.toLowerCase() == 'en'
                        ? 'English'
                        : 'العربية',
                    onTap: _toggleLanguage,
                  ),
                  const SizedBox(height: 8),
                  SettingsTile(
                    icon: Icons.location_on_outlined,
                    title: 'العناوين والموقع',
                    subtitle: 'إدارة عناوين التوصيل',
                    onTap: () => Navigator.pushNamed(context, '/addresses'),
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
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: AppColors.error)),
                  ],
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
                      onPressed: () async {
                        await app.logout();
                        if (!context.mounted) return;
                        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('تسجيل الخروج'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/delete-account'),
                    child: const Text('حذف الحساب',
                        style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            ),
    );
  }
}

class ConnectedNotificationsScreen extends StatefulWidget {
  const ConnectedNotificationsScreen({super.key});

  @override
  State<ConnectedNotificationsScreen> createState() =>
      _ConnectedNotificationsScreenState();
}

class _ConnectedNotificationsScreenState
    extends State<ConnectedNotificationsScreen> {
  int tab = 0;
  bool _loading = true;
  String? _error;
  List<AccountNotificationData> _items = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading && _items.isEmpty) _load();
  }

  Future<void> _load() async {
    try {
      final items = await _repo(context).fetchNotifications();
      if (mounted) setState(() => _items = items);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is ApiException
            ? error.message
            : 'تعذر تحميل الإشعارات.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _matches(AccountNotificationData item) {
    final type = item.eventType.toLowerCase();
    return switch (tab) {
      1 => type.contains('order') || type.contains('shipment'),
      2 => type.contains('auction') || type.contains('bid'),
      3 => type.contains('offer') || type.contains('coupon') || type.contains('promotion'),
      _ => true,
    };
  }

  Future<void> _markAll() async {
    await _repo(context).markAllNotificationsRead();
    if (!mounted) return;
    setState(() {
      _items = _items
          .map((item) => AccountNotificationData(
                id: item.id,
                title: item.title,
                message: item.message,
                eventType: item.eventType,
                isRead: true,
                createdAt: item.createdAt,
                deepLink: item.deepLink,
              ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _items.where(_matches).toList();
    return Scaffold(
      appBar: MazraaAppBar(
        title: 'الإشعارات',
        actions: [
          IconButton(onPressed: _markAll, icon: const Icon(Icons.done_all_rounded)),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/notification-preferences'),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : AppPage(
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
                    onSelectionChanged: (value) => setState(() => tab = value.first),
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    ResultStateView(
                      kind: ResultKind.error,
                      title: 'تعذر تحميل الإشعارات',
                      message: _error!,
                      primaryLabel: 'إعادة المحاولة',
                      onPrimary: () {
                        setState(() => _loading = true);
                        _load();
                      },
                    )
                  else if (visible.isEmpty)
                    const ResultStateView(
                      kind: ResultKind.empty,
                      title: 'لا توجد إشعارات',
                      message: 'ستظهر تحديثات حسابك وطلباتك ومزاداتك هنا.',
                    )
                  else
                    ...visible.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _NotificationTile(item: item),
                        )),
                ],
              ),
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});
  final AccountNotificationData item;

  @override
  Widget build(BuildContext context) {
    final type = item.eventType.toLowerCase();
    final (icon, color) = type.contains('auction') || type.contains('bid')
        ? (Icons.gavel_rounded, AppColors.terracotta)
        : type.contains('wallet') || type.contains('payment')
            ? (Icons.account_balance_wallet_outlined, AppColors.forest)
            : type.contains('offer') || type.contains('coupon')
                ? (Icons.local_offer_outlined, AppColors.terracotta)
                : (Icons.notifications_none_rounded, AppColors.forest);
    return AppSurfaceCard(
      color: item.isRead ? null : AppColors.forestSoft,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .12),
          child: Icon(icon, color: color),
        ),
        title: Text(item.title.isEmpty ? 'إشعار' : item.title),
        subtitle: Text([
          if (item.message.isNotEmpty) item.message,
          if (item.createdAt != null) _formatDate(item.createdAt!),
        ].join('\n')),
        isThreeLine: item.message.isNotEmpty && item.createdAt != null,
      ),
    );
  }
}

class ConnectedNotificationPreferencesScreen extends StatefulWidget {
  const ConnectedNotificationPreferencesScreen({super.key});

  @override
  State<ConnectedNotificationPreferencesScreen> createState() =>
      _ConnectedNotificationPreferencesScreenState();
}

class _ConnectedNotificationPreferencesScreenState
    extends State<ConnectedNotificationPreferencesScreen> {
  UserPreferenceData? _settings;
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading && _settings == null) _load();
  }

  Future<void> _load() async {
    try {
      final data = await _repo(context).fetchSettings();
      if (mounted) setState(() => _settings = data);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save({bool? push, bool? email, bool? sms, bool? marketing}) async {
    final old = _settings;
    if (old == null) return;
    final next = UserPreferenceData(
      push: push ?? old.push,
      email: email ?? old.email,
      sms: sms ?? old.sms,
      marketing: marketing ?? old.marketing,
      language: old.language,
      shareAnalytics: old.shareAnalytics,
      profileVisible: old.profileVisible,
    );
    setState(() => _settings = next);
    try {
      await _repo(context).updateNotificationPreferences(
        push: next.push,
        email: next.email,
        sms: next.sms,
        marketing: next.marketing,
      );
    } catch (_) {
      if (mounted) setState(() => _settings = old);
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = _settings;
    return Scaffold(
      appBar: const MazraaAppBar(title: 'تفضيلات الإشعارات'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : AppPage(
              child: Column(
                children: [
                  _PreferenceTile(
                    icon: Icons.notifications_active_outlined,
                    title: 'إشعارات التطبيق',
                    value: value?.push ?? false,
                    onChanged: (v) => _save(push: v),
                  ),
                  _PreferenceTile(
                    icon: Icons.email_outlined,
                    title: 'إشعارات البريد الإلكتروني',
                    value: value?.email ?? false,
                    onChanged: (v) => _save(email: v),
                  ),
                  _PreferenceTile(
                    icon: Icons.sms_outlined,
                    title: 'إشعارات الرسائل النصية',
                    value: value?.sms ?? false,
                    onChanged: (v) => _save(sms: v),
                  ),
                  _PreferenceTile(
                    icon: Icons.local_offer_outlined,
                    title: 'العروض والتنبيهات التسويقية',
                    value: value?.marketing ?? false,
                    onChanged: (v) => _save(marketing: v),
                  ),
                ],
              ),
            ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AppSurfaceCard(
          padding: EdgeInsets.zero,
          child: SwitchListTile(
            value: value,
            onChanged: onChanged,
            title: Text(title),
            secondary: Icon(icon),
          ),
        ),
      );
}

class ConnectedAddressesScreen extends StatefulWidget {
  const ConnectedAddressesScreen({super.key});

  @override
  State<ConnectedAddressesScreen> createState() => _ConnectedAddressesScreenState();
}

class _ConnectedAddressesScreenState extends State<ConnectedAddressesScreen> {
  bool _loading = true;
  List<AccountAddress> _addresses = const [];
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading && _addresses.isEmpty) _load();
  }

  Future<void> _load() async {
    try {
      final data = await _repo(context).fetchAddresses();
      if (mounted) setState(() => _addresses = data);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is ApiException
            ? error.message
            : 'تعذر تحميل العناوين.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setDefault(AccountAddress address) async {
    await _repo(context).setDefaultAddress(address.id);
    await _load();
  }

  Future<void> _delete(AccountAddress address) async {
    await _repo(context).deleteAddress(address.id);
    await _load();
  }

  Future<void> _add() async {
    await Navigator.pushNamed(context, '/add-address');
    if (!mounted) return;
    setState(() => _loading = true);
    await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'العناوين'),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ResultStateView(
                    kind: ResultKind.error,
                    title: 'تعذر تحميل العناوين',
                    message: _error!,
                    primaryLabel: 'إعادة المحاولة',
                    onPrimary: () {
                      setState(() {
                        _error = null;
                        _loading = true;
                      });
                      _load();
                    },
                  )
                : _addresses.isEmpty
                    ? ResultStateView(
                        kind: ResultKind.empty,
                        title: 'لم تضف أي عنوان بعد',
                        message: 'أضف عنوانك لتسهيل إتمام الطلب والتوصيل',
                        primaryLabel: 'إضافة عنوان جديد',
                        onPrimary: _add,
                      )
                    : AppPage(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ..._addresses.map((address) => Padding(
                                  padding: const EdgeInsets.only(bottom: 9),
                                  child: AppSurfaceCard(
                                    color: address.isDefault
                                        ? AppColors.forestSoft
                                        : null,
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      onTap: () => _setDefault(address),
                                      leading: Icon(
                                        address.isDefault
                                            ? Icons.home_rounded
                                            : Icons.location_on_outlined,
                                        color: AppColors.forest,
                                      ),
                                      title: Text(address.isDefault
                                          ? 'العنوان الافتراضي'
                                          : address.city),
                                      subtitle: Text(address.label),
                                      trailing: PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'default') {
                                            _setDefault(address);
                                          } else if (value == 'delete') {
                                            _delete(address);
                                          }
                                        },
                                        itemBuilder: (_) => const [
                                          PopupMenuItem(
                                              value: 'default',
                                              child: Text('تعيين كافتراضي')),
                                          PopupMenuItem(
                                              value: 'delete',
                                              child: Text('حذف')),
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                            const SizedBox(height: 5),
                            OutlinedButton.icon(
                              onPressed: _add,
                              icon: const Icon(Icons.add_circle_rounded),
                              label: const Text('إضافة عنوان جديد'),
                            ),
                          ],
                        ),
                      ),
      );
}

class ConnectedWalletScreen extends StatelessWidget {
  const ConnectedWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = _repo(context);
    return Scaffold(
      appBar: const MazraaAppBar(title: 'المحفظة'),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait<dynamic>([
          repository.fetchWallet(),
          repository.fetchWalletTransactions(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return ResultStateView(
              kind: ResultKind.error,
              title: 'تعذر تحميل المحفظة',
              message: snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'تعذر تحميل بيانات المحفظة من الخادم.',
            );
          }
          final wallet = snapshot.data![0] as WalletSummary;
          final transactions = snapshot.data![1] as List<WalletTransactionData>;
          final credits = transactions
              .where((item) => item.isCredit)
              .fold<double>(0, (sum, item) => sum + item.amount.abs());
          final debits = transactions
              .where((item) => !item.isCredit)
              .fold<double>(0, (sum, item) => sum + item.amount.abs());
          return AppPage(
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
                      const Text('الرصيد المتاح',
                          style: TextStyle(color: Colors.white70)),
                      Text(
                        _money(wallet.balance, wallet.currency),
                        style: const TextStyle(
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
                                  backgroundColor: Colors.white24),
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
                                  backgroundColor: AppColors.terracotta),
                              onPressed: () => Navigator.pushNamed(
                                  context, '/wallet-transactions'),
                              icon: const Icon(Icons.history_rounded),
                              label: const Text('سجل العمليات'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppSurfaceCard(
                        child: Column(
                          children: [
                            const Text('إجمالي المدفوعات'),
                            Text(
                              '-${_money(debits, wallet.currency)}',
                              style: const TextStyle(
                                color: AppColors.terracotta,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppSurfaceCard(
                        child: Column(
                          children: [
                            const Text('إجمالي الإضافات'),
                            Text(
                              '+${_money(credits, wallet.currency)}',
                              style: const TextStyle(
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
                const SectionHeader(
                    title: 'أحدث العمليات', icon: Icons.history_rounded),
                if (transactions.isEmpty)
                  const AppSurfaceCard(
                    child: Text('لا توجد عمليات في المحفظة حتى الآن.'),
                  )
                else
                  ...transactions.take(3).map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _WalletTransactionTile(
                            item: item, currency: wallet.currency),
                      )),
                const SizedBox(height: 4),
                FilledButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/wallet-transactions'),
                  child: const Text('عرض كل العمليات'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ConnectedWalletTransactionsScreen extends StatelessWidget {
  const ConnectedWalletTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = _repo(context);
    return Scaffold(
      appBar: const MazraaAppBar(title: 'عمليات المحفظة'),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait<dynamic>([
          repository.fetchWallet(),
          repository.fetchWalletTransactions(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const ResultStateView(
              kind: ResultKind.error,
              title: 'تعذر تحميل العمليات',
              message: 'تعذر قراءة سجل المحفظة من الخادم.',
            );
          }
          final wallet = snapshot.data![0] as WalletSummary;
          final items = snapshot.data![1] as List<WalletTransactionData>;
          return AppPage(
            child: Column(
              children: [
                AppSurfaceCard(
                  color: AppColors.forest,
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded,
                          color: Colors.white),
                      const SizedBox(width: 9),
                      const Text('الرصيد الحالي',
                          style: TextStyle(color: Colors.white)),
                      const Spacer(),
                      Text(
                        _money(wallet.balance, wallet.currency),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  const ResultStateView(
                    kind: ResultKind.empty,
                    title: 'لا توجد عمليات',
                    message: 'ستظهر عمليات الشحن والدفع والاسترداد هنا.',
                  )
                else
                  ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _WalletTransactionTile(
                            item: item, currency: wallet.currency),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WalletTransactionTile extends StatelessWidget {
  const _WalletTransactionTile({required this.item, required this.currency});
  final WalletTransactionData item;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final credit = item.isCredit;
    final title = item.description.trim().isNotEmpty
        ? item.description
        : _transactionType(item.type);
    final color = credit ? AppColors.forest : AppColors.terracotta;
    return AppSurfaceCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .12),
          child: Icon(
            credit ? Icons.add_card_rounded : Icons.payments_outlined,
            color: color,
          ),
        ),
        title: Text(title),
        subtitle: Text([
          if (item.createdAt != null) _formatDate(item.createdAt!),
          if (item.referenceId.isNotEmpty) item.referenceId,
        ].join(' • ')),
        trailing: Text(
          '${credit ? '+' : '-'}${_money(item.amount.abs(), currency)}',
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class ConnectedWalletTopUpScreen extends StatefulWidget {
  const ConnectedWalletTopUpScreen({super.key});

  @override
  State<ConnectedWalletTopUpScreen> createState() =>
      _ConnectedWalletTopUpScreenState();
}

class _ConnectedWalletTopUpScreenState extends State<ConnectedWalletTopUpScreen> {
  int amount = 1000;
  bool _submitting = false;
  String? _error;

  Future<void> _topUp() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await _repo(context).createWalletTopUp(amount.toDouble());
      final url = '${jsonValue(result, 'sessionUrl') ?? ''}';
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme) {
        throw const ApiException('لم يُرجع الخادم رابط دفع صالحًا.');
      }
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) throw const ApiException('تعذر فتح صفحة الدفع.');
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is ApiException
            ? error.message
            : 'تعذر بدء عملية الشحن.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'شحن المحفظة'),
        body: FutureBuilder<WalletSummary>(
          future: _repo(context).fetchWallet(),
          builder: (context, snapshot) {
            final wallet = snapshot.data;
            return AppPage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSurfaceCard(
                    color: AppColors.forestSoft,
                    child: Column(
                      children: [
                        const Text('رصيد المحفظة الحالي'),
                        Text(
                          wallet == null
                              ? '...'
                              : _money(wallet.balance, wallet.currency),
                          style: const TextStyle(
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
                        .map((value) => ChoiceChip(
                              label: Text('$value'),
                              selected: amount == value,
                              onSelected: (_) => setState(() => amount = value),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  const SettingsTile(
                    icon: Icons.credit_card_rounded,
                    title: 'الدفع الإلكتروني الآمن',
                    subtitle: 'سيتم فتح صفحة Stripe التي أنشأها الخادم',
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!, style: const TextStyle(color: AppColors.error)),
                  ],
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: _submitting ? null : _topUp,
                    icon: const Icon(Icons.account_balance_wallet_rounded),
                    label: Text(_submitting ? 'جاري التحضير...' : 'شحن الآن'),
                  ),
                ],
              ),
            );
          },
        ),
      );
}

class ConnectedPaymentMethodsScreen extends StatelessWidget {
  const ConnectedPaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'طرق الدفع'),
        body: FutureBuilder<PaymentMethodsData>(
          future: _repo(context).fetchPaymentMethods(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || snapshot.data == null) {
              return const ResultStateView(
                kind: ResultKind.error,
                title: 'تعذر تحميل طرق الدفع',
                message: 'تعذر قراءة طرق الدفع المتاحة من الخادم.',
              );
            }
            final data = snapshot.data!;
            return AppPage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                      title: 'طرق الدفع المتاحة',
                      icon: Icons.credit_card_rounded),
                  ...data.available.map((method) {
                    final code = '${jsonValue(method, 'code') ?? ''}';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SettingsTile(
                        icon: _paymentIcon(code),
                        title: _paymentName(code),
                        subtitle: 'متاح لهذا الحساب',
                      ),
                    );
                  }),
                  if (data.available.isEmpty)
                    const AppSurfaceCard(
                      child: Text('لا توجد طرق دفع متاحة حاليًا.'),
                    ),
                  const SizedBox(height: 10),
                  const SectionHeader(
                      title: 'البطاقات المحفوظة', icon: Icons.wallet_outlined),
                  if (data.saved.isEmpty)
                    const AppSurfaceCard(
                      child: Text('لا توجد بطاقات محفوظة على الحساب.'),
                    )
                  else
                    ...data.saved.map((method) => AppSurfaceCard(
                          child: Text('${jsonValue(method, 'name') ?? 'طريقة دفع'}'),
                        )),
                ],
              ),
            );
          },
        ),
      );
}

String _money(double value, String currency) {
  final amount = value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
  final code = currency.trim().isEmpty ? '' : ' ${currency.trim()}';
  return '$amount$code';
}

String _transactionType(int type) => switch (type) {
      1 => 'إضافة رصيد',
      2 => 'سحب من المحفظة',
      3 => 'دفع طلب',
      4 => 'دفع خارجي',
      _ => 'عملية محفظة',
    };

String _formatDate(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${local.year}/${two(local.month)}/${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}

IconData _paymentIcon(String code) {
  final value = code.toLowerCase();
  if (value.contains('wallet')) return Icons.account_balance_wallet_outlined;
  if (value.contains('cash')) return Icons.payments_outlined;
  if (value.contains('bank')) return Icons.account_balance_outlined;
  return Icons.credit_card_rounded;
}

String _paymentName(String code) {
  final value = code.toLowerCase();
  if (value.contains('stripe')) return 'الدفع الإلكتروني';
  if (value.contains('wallet')) return 'المحفظة';
  if (value.contains('cash')) return 'الدفع عند الاستلام';
  if (value.contains('bank')) return 'تحويل بنكي';
  return code.isEmpty ? 'طريقة دفع' : code;
}
