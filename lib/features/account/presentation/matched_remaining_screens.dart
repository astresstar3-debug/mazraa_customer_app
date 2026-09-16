import 'package:flutter/material.dart';

import '../../../core/reference/reference_demo_data.dart';
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
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: primary,
              onChanged: (value) => setState(() => primary = value),
              title: const Text('تعيين كعنوان افتراضي', style: TextStyle(fontWeight: FontWeight.w800)),
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
            const _PasswordHint(),
            const SizedBox(height: 10),
            SizedBox(height: 54, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('حفظ كلمة المرور'))),
          ],
        ),
      );
}

class MatchedOrderDetailsScreen extends StatelessWidget {
  const MatchedOrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = ReferenceDemoData.products.take(2).toList();
    return _BaseScreen(
      title: 'تفاصيل الطلب',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _orderHeader('MZ-24581', 'قيد التوصيل', AppColors.terracotta),
          const SizedBox(height: 12),
          _stepper(const ['تم الطلب', 'تم التأكيد', 'قيد التجهيز', 'خرج للتوصيل'], 3),
          const SizedBox(height: 14),
          _sectionCard('المنتجات', Icons.shopping_bag_outlined, Column(children: products.map(_orderProduct).toList())),
          const SizedBox(height: 12),
          _sectionCard('عنوان التوصيل', Icons.location_on_outlined, const Text('الرياض، حي النخيل، شارع الأمير محمد بن سلمان')),
          const SizedBox(height: 12),
          _sectionCard('ملخص الدفع', Icons.receipt_long_outlined, const Column(children: [
            _StaticRow('المجموع الفرعي', '520 ر.س'),
            _StaticRow('التوصيل', '25 ر.س'),
            _StaticRow('الخصم', '-20 ر.س'),
            Divider(),
            _StaticRow('الإجمالي', '525 ر.س', bold: true),
          ])),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pushNamed(context, '/invoice'), child: const Text('عرض الفاتورة'))),
            const SizedBox(width: 8),
            Expanded(child: FilledButton(onPressed: () => Navigator.pushNamed(context, '/track-order'), child: const Text('تتبع الطلب'))),
          ]),
        ],
      ),
    );
  }
}

class MatchedTrackOrderScreen extends StatelessWidget {
  const MatchedTrackOrderScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'تتبع الطلب',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 290,
              decoration: BoxDecoration(color: const Color(0xFFE6EFDD), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
              child: Stack(children: [
                Positioned.fill(child: CustomPaint(painter: _MapPainter())),
                const Positioned(top: 52, right: 86, child: Icon(Icons.location_on_rounded, size: 42, color: AppColors.terracotta)),
                const Positioned(bottom: 55, left: 82, child: Icon(Icons.home_rounded, size: 36, color: AppColors.forestDark)),
                Positioned(top: 135, left: 150, child: Container(width: 54, height: 54, decoration: const BoxDecoration(color: AppColors.forest, shape: BoxShape.circle), child: const Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 30))),
              ]),
            ),
            const SizedBox(height: 12),
            _sectionCard('الموصل في الطريق إليك', Icons.delivery_dining_rounded, Row(children: [
              const CircleAvatar(radius: 28, backgroundColor: AppColors.forestSoft, child: Icon(Icons.person_rounded, color: AppColors.forestDark)),
              const SizedBox(width: 10),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('أحمد محمد', style: TextStyle(fontWeight: FontWeight.w900)), Text('يصل خلال 15 - 20 دقيقة', style: TextStyle(color: AppColors.muted))])),
              IconButton(onPressed: () {}, icon: const Icon(Icons.phone_rounded, color: AppColors.forest)),
            ])),
            const SizedBox(height: 12),
            _sectionCard('حالة الطلب', Icons.route_rounded, _stepper(const ['تم الطلب', 'تم التجهيز', 'استلمه الموصل', 'قريب منك'], 2)),
          ],
        ),
      );
}

class MatchedCancelOrderScreen extends StatefulWidget {
  const MatchedCancelOrderScreen({super.key});

  @override
  State<MatchedCancelOrderScreen> createState() => _MatchedCancelOrderScreenState();
}

class _MatchedCancelOrderScreenState extends State<MatchedCancelOrderScreen> {
  int reason = 0;

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'إلغاء الطلب',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: Icon(Icons.delete_outline_rounded, size: 68, color: AppColors.terracotta)),
            const SizedBox(height: 8),
            const Text('هل تريد إلغاء هذا الطلب؟', textAlign: TextAlign.center, style: TextStyle(color: AppColors.forestDark, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            _sectionCard('الطلب MZ-24581', Icons.shopping_bag_outlined, Row(children: ReferenceDemoData.products.take(3).map((p) => Expanded(child: Padding(padding: const EdgeInsets.all(4), child: ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(height: 76, child: AppDataImage(p.image, fit: BoxFit.cover)))))).toList())),
            const SizedBox(height: 12),
            const Text('اختر سبب الإلغاء', style: TextStyle(fontWeight: FontWeight.w900)),
            ...['غيرت رأيي', 'وجدت سعرًا أفضل', 'تأخر موعد التوصيل', 'أريد تعديل الطلب'].asMap().entries.map((entry) => RadioListTile<int>(value: entry.key, groupValue: reason, onChanged: (value) => setState(() => reason = value ?? 0), title: Text(entry.value))),
            TextField(maxLines: 3, decoration: InputDecoration(hintText: 'ملاحظات إضافية', filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
            const SizedBox(height: 12),
            SizedBox(height: 54, child: FilledButton.styleFrom(backgroundColor: AppColors.terracotta).copyWith(),),
          ],
        ),
      );
}

class MatchedOrderCancelledScreen extends StatelessWidget {
  const MatchedOrderCancelledScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'تم إلغاء الطلب',
        child: _CenteredState(
          icon: Icons.check_circle_rounded,
          title: 'تم إلغاء الطلب بنجاح',
          message: 'الطلب رقم MZ-24581 تم إلغاؤه. سيتم إعادة المبلغ إلى وسيلة الدفع المستخدمة.',
          action: 'العودة إلى طلباتي',
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/orders', (r) => r.isFirst),
        ),
      );
}

class MatchedRateOrderScreen extends StatefulWidget {
  const MatchedRateOrderScreen({super.key});

  @override
  State<MatchedRateOrderScreen> createState() => _MatchedRateOrderScreenState();
}

class _MatchedRateOrderScreenState extends State<MatchedRateOrderScreen> {
  int orderRating = 5;
  int deliveryRating = 5;

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'تقييم الطلب',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionCard('كيف كانت تجربتك؟', Icons.star_rounded, Column(children: [
              _ratingRow('الطلب', orderRating, (v) => setState(() => orderRating = v)),
              const SizedBox(height: 12),
              _ratingRow('التوصيل', deliveryRating, (v) => setState(() => deliveryRating = v)),
            ])),
            const SizedBox(height: 12),
            ...ReferenceDemoData.products.take(2).map((p) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _sectionCard(p.name, Icons.shopping_bag_outlined, _ratingRow('تقييم المنتج', 5, (_) {})))),
            TextField(maxLines: 4, decoration: InputDecoration(hintText: 'شاركنا ملاحظاتك', filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
            const SizedBox(height: 12),
            SizedBox(height: 54, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('إرسال التقييم'))),
          ],
        ),
      );
}

class MatchedInvoiceScreen extends StatelessWidget {
  const MatchedInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'الفاتورة الإلكترونية',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(padding: const EdgeInsets.all(18), decoration: _cardDecoration(), child: const Column(children: [AppLogo(size: 62, showName: true), SizedBox(height: 10), Text('فاتورة ضريبية', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.forestDark)), Text('رقم الطلب: MZ-24581'), Text('16 سبتمبر 2026')])),
            const SizedBox(height: 12),
            _sectionCard('تفاصيل المنتجات', Icons.receipt_long_outlined, Column(children: ReferenceDemoData.products.take(2).map(_orderProduct).toList())),
            const SizedBox(height: 12),
            _sectionCard('الإجمالي', Icons.account_balance_wallet_outlined, const Column(children: [
              _StaticRow('قيمة المنتجات', '520 ر.س'),
              _StaticRow('الضريبة', '78 ر.س'),
              _StaticRow('الشحن', '25 ر.س'),
              Divider(),
              _StaticRow('الإجمالي شامل الضريبة', '623 ر.س', bold: true),
            ])),
            const SizedBox(height: 12),
            SizedBox(height: 52, child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.download_outlined), label: const Text('تنزيل الفاتورة'))),
          ],
        ),
      );
}

class MatchedReturnsScreen extends StatelessWidget {
  const MatchedReturnsScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'المرتجعات والاسترداد',
        child: Column(
          children: [
            _returnCard(context, ReferenceDemoData.products.first, 'طلب إرجاع قيد المراجعة', 'RT-10342', AppColors.terracotta),
            const SizedBox(height: 10),
            _returnCard(context, ReferenceDemoData.products[1], 'تم الاسترداد', 'RT-10296', AppColors.forest),
          ],
        ),
      );
}

class MatchedReturnRequestScreen extends StatelessWidget {
  const MatchedReturnRequestScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'طلب إرجاع',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionCard('المنتج', Icons.shopping_bag_outlined, _orderProduct(ReferenceDemoData.products.first)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(value: 'المنتج غير مطابق', items: const [DropdownMenuItem(value: 'المنتج غير مطابق', child: Text('المنتج غير مطابق')), DropdownMenuItem(value: 'تالف', child: Text('المنتج تالف'))], onChanged: (_) {}, decoration: const InputDecoration(labelText: 'سبب الإرجاع')),
            const SizedBox(height: 10),
            TextField(maxLines: 4, decoration: InputDecoration(labelText: 'تفاصيل إضافية', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
            const SizedBox(height: 10),
            _sectionCard('طريقة الاسترداد', Icons.account_balance_wallet_outlined, const Column(children: [RadioListTile<int>(value: 0, groupValue: 0, onChanged: null, title: Text('المحفظة')), RadioListTile<int>(value: 1, groupValue: 0, onChanged: null, title: Text('وسيلة الدفع الأصلية'))])),
            const SizedBox(height: 12),
            SizedBox(height: 54, child: FilledButton(onPressed: () => Navigator.pushReplacementNamed(context, '/return-success'), child: const Text('إرسال طلب الإرجاع'))),
          ],
        ),
      );
}

class MatchedReturnSuccessScreen extends StatelessWidget {
  const MatchedReturnSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'المرتجعات والاسترداد',
        child: _CenteredState(
          icon: Icons.check_circle_rounded,
          title: 'تم إرسال طلب الإرجاع',
          message: 'رقم الطلب RT-10342. سنراجع الطلب ونرسل لك تحديثًا عند تغيير حالته.',
          action: 'عرض حالة الإرجاع',
          onPressed: () => Navigator.pushReplacementNamed(context, '/refund-status'),
        ),
      );
}

class MatchedRefundStatusScreen extends StatelessWidget {
  const MatchedRefundStatusScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'حالة الاسترداد',
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _orderHeader('RT-10342', 'قيد المعالجة', AppColors.terracotta),
          const SizedBox(height: 14),
          _sectionCard('تقدم الطلب', Icons.timeline_rounded, _stepper(const ['تم استلام الطلب', 'تمت الموافقة', 'استلام المنتج', 'إعادة المبلغ'], 1)),
          const SizedBox(height: 12),
          _sectionCard('بيانات الاسترداد', Icons.account_balance_wallet_outlined, const Column(children: [_StaticRow('قيمة الاسترداد', '120 ر.س'), _StaticRow('الطريقة', 'المحفظة'), _StaticRow('المدة المتوقعة', '2 - 5 أيام عمل')])),
        ]),
      );
}

class MatchedSupportChatScreen extends StatelessWidget {
  const MatchedSupportChatScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        appBar: const MazraaAppBar(title: 'المحادثة مع الدعم'),
        body: Column(children: [
          Expanded(child: ListView(padding: const EdgeInsets.all(14), children: const [
            _ChatBubble(text: 'مرحبًا بك، كيف يمكننا مساعدتك اليوم؟', mine: false),
            _ChatBubble(text: 'لدي استفسار عن حالة طلبي MZ-24581.', mine: true),
            _ChatBubble(text: 'تم التحقق من الطلب، وهو الآن مع المندوب وسيصل إليك قريبًا.', mine: false),
            _ChatBubble(text: 'شكرًا لكم.', mine: true),
          ])),
          SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 12), child: Row(children: [Expanded(child: TextField(decoration: InputDecoration(hintText: 'اكتب رسالتك...', filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)))), const SizedBox(width: 8), CircleAvatar(backgroundColor: AppColors.forest, child: IconButton(onPressed: () {}, icon: const Icon(Icons.send_rounded, color: Colors.white))) ]))),
        ]),
      );
}

class MatchedLegalScreen extends StatelessWidget {
  const MatchedLegalScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'الشروط والخصوصية',
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: const [
          AppLogo(size: 58, showName: true),
          SizedBox(height: 12),
          Text('الشروط والخصوصية', textAlign: TextAlign.center, style: TextStyle(color: AppColors.forestDark, fontSize: 24, fontWeight: FontWeight.w900)),
          SizedBox(height: 18),
          _LegalSection(title: 'شروط الاستخدام', text: 'باستخدامك تطبيق مزرعتي فإنك توافق على استخدام الخدمات للأغراض المشروعة، والمحافظة على بيانات حسابك، وتقديم معلومات صحيحة عند الطلب والشراء.'),
          _LegalSection(title: 'الخصوصية وحماية البيانات', text: 'نستخدم بيانات الحساب والطلبات والموقع عند الحاجة لتقديم الخدمة وتحسين تجربة الاستخدام. لا نشارك البيانات إلا بالقدر اللازم لتنفيذ الخدمة أو وفق المتطلبات النظامية.'),
          _LegalSection(title: 'الطلبات والدفع', text: 'تعتمد الأسعار والتوفر وموعد التوصيل على بيانات المتجر والخدمة المتاحة. يمكن أن تختلف حالات الاسترداد والإلغاء بحسب مرحلة الطلب وطريقة الدفع.'),
          _LegalSection(title: 'التواصل والدعم', text: 'يمكنك التواصل مع فريق الدعم من داخل التطبيق لأي استفسار يتعلق بالحساب أو الطلبات أو المزادات.'),
        ]),
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
        child: Column(children: List.generate(items.length, (index) => SwitchListTile(value: values[index], onChanged: (value) => setState(() => values[index] = value), secondary: Icon(items[index].$2, color: AppColors.forestDark), title: Text(items[index].$1, style: const TextStyle(fontWeight: FontWeight.w800))))),
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

class MatchedPhoneVerificationScreen extends StatelessWidget {
  const MatchedPhoneVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'التحقق من رقم الهاتف',
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const _HeroIcon(icon: Icons.phonelink_lock_rounded),
          const SizedBox(height: 18),
          const Text('أدخل رمز التحقق', textAlign: TextAlign.center, style: TextStyle(color: AppColors.forestDark, fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('أرسلنا رمزًا مكونًا من 4 أرقام إلى +966 50 123 4567', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) => Container(width: 56, height: 62, margin: const EdgeInsets.symmetric(horizontal: 5), alignment: Alignment.center, decoration: _cardDecoration(), child: Text(['2','8','4','1'][i], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.forestDark))))),
          const SizedBox(height: 18),
          const Text('إعادة الإرسال خلال 00:42', textAlign: TextAlign.center, style: TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          SizedBox(height: 54, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('متابعة'))),
        ]),
      );
}

class MatchedLocationPermissionScreen extends StatelessWidget {
  const MatchedLocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: '',
        child: _CenteredState(
          icon: Icons.map_rounded,
          title: 'فعّل موقعك',
          message: 'نستخدم موقعك لعرض المتاجر والمنتجات القريبة وتحديد عنوان التوصيل بدقة.',
          action: 'السماح بالموقع',
          onPressed: () => Navigator.pushReplacementNamed(context, '/location'),
          secondaryAction: 'إدخال يدويًا',
        ),
      );
}

class MatchedLocationPickerScreen extends StatelessWidget {
  const MatchedLocationPickerScreen({super.key});

  @override
  Widget build(BuildContext context) => _BaseScreen(
        title: 'تحديد الموقع',
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(decoration: InputDecoration(hintText: 'ابحث عن موقع', prefixIcon: const Icon(Icons.search_rounded), filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
          const SizedBox(height: 12),
          Container(height: 430, decoration: BoxDecoration(color: const Color(0xFFE5EEDC), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)), child: Stack(alignment: Alignment.center, children: [Positioned.fill(child: CustomPaint(painter: _MapPainter())), const Icon(Icons.location_on_rounded, color: AppColors.forestDark, size: 58), PositionedDirectional(bottom: 12, end: 12, child: FloatingActionButton.small(onPressed: null, child: Icon(Icons.my_location_rounded))) ])),
          const SizedBox(height: 12),
          _sectionCard('الموقع المحدد', Icons.location_on_outlined, const Text('الرياض - حي النخيل')),
          const SizedBox(height: 12),
          SizedBox(height: 54, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('تأكيد الموقع'))),
        ]),
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
        body: BotanicalBackdrop(dense: true, child: AppPage(padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 28), child: child)),
      );
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({required this.icon, required this.title, required this.message, required this.action, required this.onPressed, this.secondaryAction});
  final IconData icon;
  final String title;
  final String message;
  final String action;
  final VoidCallback onPressed;
  final String? secondaryAction;

  @override
  Widget build(BuildContext context) => SizedBox(height: MediaQuery.sizeOf(context).height * .72, child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 150, height: 150, decoration: const BoxDecoration(color: AppColors.forestSoft, shape: BoxShape.circle), child: Icon(icon, size: 76, color: AppColors.forest)),
    const SizedBox(height: 22),
    Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.forestDark, fontSize: 24, fontWeight: FontWeight.w900)),
    const SizedBox(height: 8),
    Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontSize: 14, height: 1.5)),
    const SizedBox(height: 24),
    SizedBox(width: double.infinity, height: 54, child: FilledButton(onPressed: onPressed, child: Text(action))),
    if (secondaryAction != null) ...[const SizedBox(height: 8), SizedBox(width: double.infinity, height: 52, child: OutlinedButton(onPressed: () {}, child: Text(secondaryAction!)))],
  ])));
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon({required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(child: Container(width: 126, height: 126, decoration: const BoxDecoration(color: AppColors.forestSoft, shape: BoxShape.circle), child: Icon(icon, size: 62, color: AppColors.forest)));
}

class _PasswordHint extends StatelessWidget {
  const _PasswordHint();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.forestSoft, borderRadius: BorderRadius.circular(14)), child: const Text('استخدم 8 أحرف على الأقل، مع رقم وحرف كبير ورمز لزيادة أمان الحساب.', style: TextStyle(color: AppColors.forestDark, fontSize: 12)));
}

class _StaticRow extends StatelessWidget {
  const _StaticRow(this.label, this.value, {this.bold = false});
  final String label;
  final String value;
  final bool bold;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w500)), const Spacer(), Text(value, style: TextStyle(color: bold ? AppColors.forest : AppColors.forestDark, fontWeight: bold ? FontWeight.w900 : FontWeight.w700))]));
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.text, required this.mine});
  final String text;
  final bool mine;
  @override
  Widget build(BuildContext context) => Align(alignment: mine ? Alignment.centerLeft : Alignment.centerRight, child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), constraints: const BoxConstraints(maxWidth: 300), decoration: BoxDecoration(color: mine ? AppColors.forest : AppColors.surface, borderRadius: BorderRadius.circular(16), border: mine ? null : Border.all(color: AppColors.border)), child: Text(text, style: TextStyle(color: mine ? Colors.white : AppColors.forestDark, height: 1.4))));
}

class _LegalSection extends StatelessWidget {
  const _LegalSection({required this.title, required this.text});
  final String title;
  final String text;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Container(padding: const EdgeInsets.all(14), decoration: _cardDecoration(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: AppColors.forestDark, fontSize: 16, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(text, style: const TextStyle(color: AppColors.muted, height: 1.6))])));
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .72)..strokeWidth = 6;
    for (double y = 35; y < size.height; y += 52) canvas.drawLine(Offset(0, y), Offset(size.width, y + 12), paint);
    for (double x = 28; x < size.width; x += 68) canvas.drawLine(Offset(x, 0), Offset(x + 18, size.height), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget _field(String label, IconData icon, {String? hint, bool secure = false}) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(obscureText: secure, decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon), filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
    );

Widget _sectionCard(String title, IconData icon, Widget child) => Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Row(children: [Icon(icon, color: AppColors.forestDark), const SizedBox(width: 7), Text(title, style: const TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900, fontSize: 15))]), const SizedBox(height: 11), child]),
    );

Widget _orderHeader(String id, String status, Color statusColor) => Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(children: [const Icon(Icons.shopping_bag_outlined, color: AppColors.forestDark), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('الطلب $id', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.forestDark)), const Text('16 سبتمبر 2026', style: TextStyle(color: AppColors.muted, fontSize: 11))])), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: statusColor.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)), child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 11)))]),
    );

Widget _stepper(List<String> steps, int active) => Column(children: List.generate(steps.length, (index) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Column(children: [CircleAvatar(radius: 13, backgroundColor: index <= active ? AppColors.forest : AppColors.border, child: Icon(index < active ? Icons.check_rounded : Icons.circle, color: Colors.white, size: 13)), if (index < steps.length - 1) Container(width: 2, height: 34, color: index < active ? AppColors.forest : AppColors.border)]), const SizedBox(width: 9), Padding(padding: const EdgeInsets.only(top: 4), child: Text(steps[index], style: TextStyle(fontWeight: index == active ? FontWeight.w900 : FontWeight.w600, color: AppColors.forestDark))) ])));

Widget _orderProduct(dynamic product) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(width: 72, height: 62, child: AppDataImage(product.image, fit: BoxFit.cover))), const SizedBox(width: 9), Expanded(child: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w800))), Text(formatPrice(product.price), style: const TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.w900))]));

Widget _ratingRow(String label, int value, ValueChanged<int> onChanged) => Row(children: [Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))), ...List.generate(5, (index) => IconButton(onPressed: () => onChanged(index + 1), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 35, minHeight: 35), icon: Icon(index < value ? Icons.star_rounded : Icons.star_border_rounded, color: AppColors.warning))) ]);

Widget _returnCard(BuildContext context, dynamic product, String status, String id, Color color) => Container(padding: const EdgeInsets.all(12), decoration: _cardDecoration(), child: Column(children: [Row(children: [ClipRRect(borderRadius: BorderRadius.circular(11), child: SizedBox(width: 92, height: 78, child: AppDataImage(product.image, fit: BoxFit.cover))), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(product.name, style: const TextStyle(fontWeight: FontWeight.w900)), Text(id, style: const TextStyle(color: AppColors.muted, fontSize: 11)), const SizedBox(height: 5), Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w900))]))]), const SizedBox(height: 10), SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => Navigator.pushNamed(context, '/refund-status'), child: const Text('عرض التفاصيل')))]));

BoxDecoration _cardDecoration() => BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border), boxShadow: const [BoxShadow(color: Color(0x090D4328), blurRadius: 10, offset: Offset(0, 3))]);
