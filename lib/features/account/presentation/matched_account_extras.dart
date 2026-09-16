import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';

class MatchedEmptyAddressesScreen extends StatelessWidget {
  const MatchedEmptyAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'العناوين',
        child: _CenteredState(
          icon: Icons.home_work_outlined,
          title: 'لم تضف أي عنوان بعد',
          message: 'أضف عنوانك لتسهيل التوصيل وإكمال الطلبات بسرعة.',
          action: 'إضافة عنوان جديد',
          onPressed: () => Navigator.pushNamed(context, '/add-address'),
        ),
      );
}

class MatchedAddAddressScreen extends StatefulWidget {
  const MatchedAddAddressScreen({super.key});

  @override
  State<MatchedAddAddressScreen> createState() => _MatchedAddAddressScreenState();
}

class _MatchedAddAddressScreenState extends State<MatchedAddAddressScreen> {
  bool primary = true;

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'إضافة عنوان جديد',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field('اسم العنوان', Icons.home_outlined, hint: 'المنزل'),
            _field('اسم المستلم', Icons.person_outline_rounded, hint: 'محمد العتيبي'),
            _field('رقم الجوال', Icons.phone_outlined, hint: '+966 50 123 4567'),
            _field('المدينة', Icons.location_city_outlined, hint: 'الرياض'),
            _field('الحي والشارع', Icons.signpost_outlined, hint: 'حي النخيل - شارع الأمير'),
            const SizedBox(height: 4),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFE6EFDD),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(child: CustomPaint(painter: _MapPainter())),
                  const Icon(Icons.location_on_rounded, color: AppColors.forest, size: 54),
                  PositionedDirectional(
                    bottom: 10,
                    end: 10,
                    child: FilledButton.tonalIcon(
                      onPressed: () => Navigator.pushNamed(context, '/location'),
                      icon: const Icon(Icons.my_location_rounded),
                      label: const Text('تحديد الموقع'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: Text('تعيين كعنوان افتراضي', style: TextStyle(fontWeight: FontWeight.w800))),
                Switch(value: primary, onChanged: (value) => setState(() => primary = value)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.save_outlined),
                label: const Text('حفظ العنوان', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      );
}

class MatchedEditProfileScreen extends StatelessWidget {
  const MatchedEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'تعديل البيانات',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(radius: 54, backgroundColor: AppColors.forestSoft, child: Icon(Icons.person_rounded, size: 58, color: AppColors.forest)),
                  PositionedDirectional(end: -2, bottom: 2, child: CircleAvatar(radius: 17, backgroundColor: AppColors.forest, child: Icon(Icons.camera_alt_outlined, size: 17, color: Colors.white))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _field('الاسم الكامل', Icons.person_outline_rounded, hint: 'محمد العتيبي'),
            _field('رقم الجوال', Icons.phone_outlined, hint: '+966 50 123 4567'),
            _field('البريد الإلكتروني', Icons.email_outlined, hint: 'mohammed@example.com'),
            _field('المدينة', Icons.location_on_outlined, hint: 'الرياض'),
            const SizedBox(height: 8),
            SizedBox(height: 54, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('حفظ التغييرات'))),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(color: AppColors.terracotta))),
          ],
        ),
      );
}

class MatchedChangePhoneScreen extends StatelessWidget {
  const MatchedChangePhoneScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'تغيير رقم الهاتف',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HeroIcon(icon: Icons.phone_android_rounded),
            const SizedBox(height: 18),
            _field('رقم الهاتف الحالي', Icons.phone_outlined, hint: '+966 50 123 4567'),
            _field('رقم الهاتف الجديد', Icons.phone_android_outlined, hint: '+966 5X XXX XXXX'),
            const SizedBox(height: 8),
            SizedBox(height: 54, child: FilledButton(onPressed: () => Navigator.pushNamed(context, '/otp'), child: const Text('إرسال رمز التحقق'))),
          ],
        ),
      );
}

class MatchedChangePasswordScreen extends StatelessWidget {
  const MatchedChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'تغيير كلمة المرور',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HeroIcon(icon: Icons.lock_rounded),
            const SizedBox(height: 18),
            _field('كلمة المرور الحالية', Icons.lock_outline_rounded, secure: true),
            _field('كلمة المرور الجديدة', Icons.lock_reset_rounded, secure: true),
            _field('تأكيد كلمة المرور الجديدة', Icons.verified_user_outlined, secure: true),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.forestSoft, borderRadius: BorderRadius.circular(14)),
              child: const Text('استخدم 8 أحرف على الأقل مع رقم وحرف كبير ورمز لزيادة أمان الحساب.', style: TextStyle(color: AppColors.forestDark, fontSize: 12)),
            ),
            const SizedBox(height: 10),
            SizedBox(height: 54, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('حفظ كلمة المرور'))),
          ],
        ),
      );
}

class MatchedNotificationPreferencesScreen extends StatefulWidget {
  const MatchedNotificationPreferencesScreen({super.key});

  @override
  State<MatchedNotificationPreferencesScreen> createState() => _MatchedNotificationPreferencesScreenState();
}

class _MatchedNotificationPreferencesScreenState extends State<MatchedNotificationPreferencesScreen> {
  final values = List<bool>.filled(10, true);
  final items = const [
    ('إشعارات التطبيق', Icons.notifications_active_outlined),
    ('إشعارات الطلبات', Icons.shopping_cart_outlined),
    ('تحديثات التوصيل', Icons.local_shipping_outlined),
    ('إشعارات المزادات', Icons.gavel_rounded),
    ('تجاوز المزايدة', Icons.trending_up_rounded),
    ('تذكير المزاد', Icons.alarm_rounded),
    ('العروض والكوبونات', Icons.local_offer_outlined),
    ('المحفظة والدفع', Icons.account_balance_wallet_outlined),
    ('الرسائل والدعم', Icons.support_agent_rounded),
    ('النشرات والتحديثات', Icons.campaign_outlined),
  ];

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'تفضيلات الإشعارات',
        child: Column(
          children: List.generate(
            items.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(items[index].$2, color: AppColors.forestDark),
                  const SizedBox(width: 10),
                  Expanded(child: Text(items[index].$1, style: const TextStyle(fontWeight: FontWeight.w800))),
                  Switch(value: values[index], onChanged: (value) => setState(() => values[index] = value)),
                ],
              ),
            ),
          ),
        ),
      );
}

class MatchedSupportChatScreen extends StatelessWidget {
  const MatchedSupportChatScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        appBar: const MazraaAppBar(title: 'المحادثة مع الدعم'),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: const [
                  _ChatBubble(text: 'مرحبًا بك، كيف يمكننا مساعدتك اليوم؟', mine: false),
                  _ChatBubble(text: 'لدي استفسار عن حالة طلبي MZ-24581.', mine: true),
                  _ChatBubble(text: 'تم التحقق من الطلب، وهو الآن مع المندوب وسيصل إليك قريبًا.', mine: false),
                  _ChatBubble(text: 'شكرًا لكم.', mine: true),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: [
                    Expanded(child: TextField(decoration: InputDecoration(hintText: 'اكتب رسالتك...', filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)))),
                    const SizedBox(width: 8),
                    CircleAvatar(backgroundColor: AppColors.forest, child: IconButton(onPressed: () {}, icon: const Icon(Icons.send_rounded, color: Colors.white))),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class MatchedLegalScreen extends StatelessWidget {
  const MatchedLegalScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'الشروط والخصوصية',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Center(child: AppLogo(size: 58, showName: true)),
            SizedBox(height: 12),
            Text('الشروط والخصوصية', textAlign: TextAlign.center, style: TextStyle(color: AppColors.forestDark, fontSize: 24, fontWeight: FontWeight.w900)),
            SizedBox(height: 18),
            _LegalSection(title: 'شروط الاستخدام', text: 'باستخدامك تطبيق مزرعتي فإنك توافق على استخدام الخدمات للأغراض المشروعة والمحافظة على بيانات حسابك وتقديم معلومات صحيحة عند الطلب والشراء.'),
            _LegalSection(title: 'الخصوصية وحماية البيانات', text: 'نستخدم بيانات الحساب والطلبات والموقع عند الحاجة لتقديم الخدمة وتحسين تجربة الاستخدام. لا نشارك البيانات إلا بالقدر اللازم لتنفيذ الخدمة أو وفق المتطلبات النظامية.'),
            _LegalSection(title: 'الطلبات والدفع', text: 'تعتمد الأسعار والتوفر وموعد التوصيل على بيانات المتجر والخدمة المتاحة. يمكن أن تختلف حالات الاسترداد والإلغاء بحسب مرحلة الطلب وطريقة الدفع.'),
            _LegalSection(title: 'التواصل والدعم', text: 'يمكنك التواصل مع فريق الدعم من داخل التطبيق لأي استفسار يتعلق بالحساب أو الطلبات أو المزادات.'),
          ],
        ),
      );
}

class MatchedOfflineScreen extends StatelessWidget {
  const MatchedOfflineScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: '',
        child: _CenteredState(
          icon: Icons.signal_wifi_connected_no_internet_4_rounded,
          title: 'لا يوجد اتصال بالإنترنت',
          message: 'تحقق من اتصالك بالشبكة وحاول مرة أخرى.',
          action: 'إعادة المحاولة',
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
        ),
      );
}

class _BaseScreen extends StatelessWidget {
  const _BaseScreen({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        appBar: title.isEmpty ? null : MazraaAppBar(title: title),
        body: BotanicalBackdrop(
          dense: true,
          child: AppPage(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 28),
            child: child,
          ),
        ),
      );
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({required this.icon, required this.title, required this.message, required this.action, required this.onPressed});
  final IconData icon;
  final String title;
  final String message;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: MediaQuery.sizeOf(context).height * .72,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 150, height: 150, decoration: const BoxDecoration(color: AppColors.forestSoft, shape: BoxShape.circle), child: Icon(icon, size: 76, color: AppColors.forest)),
              const SizedBox(height: 22),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.forestDark, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontSize: 14, height: 1.5)),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, height: 54, child: FilledButton(onPressed: onPressed, child: Text(action))),
            ],
          ),
        ),
      );
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon({required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(child: Container(width: 126, height: 126, decoration: const BoxDecoration(color: AppColors.forestSoft, shape: BoxShape.circle), child: Icon(icon, size: 62, color: AppColors.forest)));
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.text, required this.mine});
  final String text;
  final bool mine;

  @override
  Widget build(BuildContext context) => Align(
        alignment: mine ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          constraints: const BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(color: mine ? AppColors.forest : AppColors.surface, borderRadius: BorderRadius.circular(16), border: mine ? null : Border.all(color: AppColors.border)),
          child: Text(text, style: TextStyle(color: mine ? Colors.white : AppColors.forestDark, height: 1.4)),
        ),
      );
}

class _LegalSection extends StatelessWidget {
  const _LegalSection({required this.title, required this.text});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: AppColors.forestDark, fontSize: 16, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(text, style: const TextStyle(color: AppColors.muted, height: 1.6))]),
        ),
      );
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .72)..strokeWidth = 6;
    for (double y = 35; y < size.height; y += 52) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 12), paint);
    }
    for (double x = 28; x < size.width; x += 68) {
      canvas.drawLine(Offset(x, 0), Offset(x + 18, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget _field(String label, IconData icon, {String? hint, bool secure = false}) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        obscureText: secure,
        decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon), filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
      ),
    );
