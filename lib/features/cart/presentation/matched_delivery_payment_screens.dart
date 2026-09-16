import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';

class MatchedDeliverySlotScreen extends StatefulWidget {
  const MatchedDeliverySlotScreen({super.key});

  @override
  State<MatchedDeliverySlotScreen> createState() => _MatchedDeliverySlotScreenState();
}

class _MatchedDeliverySlotScreenState extends State<MatchedDeliverySlotScreen> {
  int day = 0;
  int slot = 1;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        appBar: const _ReferenceTopBar(title: 'موعد التوصيل'),
        body: AppPage(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 14, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'موعد التوصيل',
                  style: TextStyle(color: AppColors.forestDark, fontSize: 28, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(child: _dayCard(0, 'اليوم', Icons.calendar_month_rounded)),
                  const SizedBox(width: 8),
                  Expanded(child: _dayCard(1, 'غدًا', Icons.calendar_month_outlined)),
                  const SizedBox(width: 8),
                  Expanded(flex: 2, child: _dayCard(2, 'الثلاثاء 17 سبتمبر', Icons.calendar_month_outlined)),
                ],
              ),
              const SizedBox(height: 22),
              ...['9 ص - 12 م', '12 م - 3 م', '3 م - 6 م'].asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _slotCard(entry.key, entry.value),
                    ),
                  ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.terracottaSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.local_shipping_rounded, color: AppColors.terracotta, size: 42),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('رسوم التوصيل', style: TextStyle(color: AppColors.forestDark, fontSize: 16, fontWeight: FontWeight.w900)),
                          SizedBox(height: 3),
                          Text('تُضاف عند إتمام الطلب حسب المنطقة', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text('عنوان التوصيل', style: TextStyle(color: AppColors.forestDark, fontSize: 17, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/addresses'),
                borderRadius: BorderRadius.circular(17),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                  decoration: _panel(),
                  child: const Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: AppColors.forest, size: 28),
                      SizedBox(width: 8),
                      Expanded(child: Text('الرياض حي النخيل', style: TextStyle(color: AppColors.forestDark, fontSize: 16, fontWeight: FontWeight.w800))),
                      Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.forest, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/delivery-preferences'),
                  icon: const Icon(Icons.eco_outlined),
                  label: const Text('تأكيد الموعد', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _dayCard(int value, String label, IconData icon) {
    final selected = day == value;
    return InkWell(
      onTap: () => setState(() => day = value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.forest : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.forest : AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : AppColors.forest, size: 20),
            const SizedBox(width: 6),
            Flexible(
              child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: selected ? Colors.white : AppColors.forestDark, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slotCard(int value, String label) {
    final selected = slot == value;
    return InkWell(
      onTap: () => setState(() => slot = value),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 88,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? AppColors.forest : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? AppColors.forest : AppColors.border, width: 1.3),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule_rounded, size: 34, color: selected ? Colors.white : AppColors.forest),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.forestDark, fontSize: 19, fontWeight: FontWeight.w900))),
            if (selected) const CircleAvatar(radius: 20, backgroundColor: AppColors.ivory, child: Icon(Icons.check_rounded, color: AppColors.forest, size: 24)),
          ],
        ),
      ),
    );
  }
}

class MatchedDeliveryPreferencesScreen extends StatefulWidget {
  const MatchedDeliveryPreferencesScreen({super.key});

  @override
  State<MatchedDeliveryPreferencesScreen> createState() => _MatchedDeliveryPreferencesScreenState();
}

class _MatchedDeliveryPreferencesScreenState extends State<MatchedDeliveryPreferencesScreen> {
  int method = 0;
  bool contactless = true;
  bool callFirst = true;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        appBar: const _ReferenceTopBar(title: 'تفضيلات التوصيل'),
        body: AppPage(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 14, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: _deliveryChoice(0, 'توصيل للعنوان', Icons.local_shipping_rounded)),
                  const SizedBox(width: 8),
                  Expanded(child: _deliveryChoice(1, 'استلام من نقطة', Icons.location_on_rounded)),
                  const SizedBox(width: 8),
                  Expanded(child: _deliveryChoice(2, 'استلام من المزرعة', Icons.storefront_rounded)),
                ],
              ),
              const SizedBox(height: 16),
              _switchPanel(
                icon: Icons.back_hand_outlined,
                title: 'توصيل بدون تلامس',
                subtitle: 'سيتم ترك الطلب في مكان آمن دون الحاجة للتواصل المباشر.',
                value: contactless,
                onChanged: (value) => setState(() => contactless = value),
              ),
              const SizedBox(height: 10),
              _switchPanel(
                icon: Icons.phone_in_talk_outlined,
                title: 'الاتصال قبل التوصيل',
                subtitle: 'سيتم الاتصال بك قبل وصول الموصل لتأكيد تفاصيل التوصيل.',
                value: callFirst,
                onChanged: (value) => setState(() => callFirst = value),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: _panel(),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.chat_outlined, color: AppColors.forestDark),
                        SizedBox(width: 7),
                        Text('تعليمات للموصل', style: TextStyle(color: AppColors.forestDark, fontSize: 16, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextField(
                      maxLines: 4,
                      decoration: InputDecoration(hintText: 'مثال: الرجاء ترك الطلب عند البوابة...'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.eco_outlined),
                  label: const Text('حفظ التفضيلات', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _deliveryChoice(int value, String label, IconData icon) {
    final selected = method == value;
    return InkWell(
      onTap: () => setState(() => method = value),
      borderRadius: BorderRadius.circular(17),
      child: Container(
        height: 178,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? AppColors.forestSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: selected ? AppColors.forest : AppColors.border, width: selected ? 1.7 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 35, backgroundColor: AppColors.ivory, child: Icon(icon, size: 35, color: selected ? AppColors.forest : AppColors.terracotta)),
            const SizedBox(height: 12),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.forestDark, fontSize: 12, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: selected ? AppColors.forest : AppColors.muted),
          ],
        ),
      ),
    );
  }

  Widget _switchPanel({required IconData icon, required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) => Container(
        padding: const EdgeInsets.all(13),
        decoration: _panel(),
        child: Row(
          children: [
            CircleAvatar(radius: 29, backgroundColor: AppColors.ivory, child: Icon(icon, color: AppColors.terracotta, size: 30)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.forestDark, fontSize: 15, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 10.5, height: 1.5)),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      );
}

class MatchedPaymentMethodsScreen extends StatefulWidget {
  const MatchedPaymentMethodsScreen({super.key});

  @override
  State<MatchedPaymentMethodsScreen> createState() => _MatchedPaymentMethodsScreenState();
}

class _MatchedPaymentMethodsScreenState extends State<MatchedPaymentMethodsScreen> {
  int selected = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        appBar: const _ReferenceTopBar(title: 'طرق الدفع'),
        body: AppPage(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 14, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('بطاقاتك المحفوظة', style: TextStyle(color: AppColors.forestDark, fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              _savedCard(index: 0, brand: 'VISA', number: '•••• 4821', name: 'بطاقة فيزا', preferred: true),
              const SizedBox(height: 10),
              _savedCard(index: 1, brand: 'مدى', number: '•••• 1098', name: 'بطاقة مدى'),
              const SizedBox(height: 22),
              const Text('خيارات الدفع الأخرى', style: TextStyle(color: AppColors.forestDark, fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              _methodTile(2, 'الدفع عند الاستلام', 'ادفع عند استلام طلبك', Icons.payments_outlined, AppColors.terracotta, '/cash-on-delivery'),
              const SizedBox(height: 9),
              _methodTile(3, 'التحويل البنكي', 'حوّل المبلغ إلى حسابنا البنكي', Icons.account_balance_outlined, AppColors.forest, '/bank-transfer'),
              const SizedBox(height: 9),
              _methodTile(4, 'المحفظة الداخلية', 'استخدم رصيد محفظتك داخل التطبيق', Icons.account_balance_wallet_outlined, AppColors.forestDark, '/wallet'),
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/add-card'),
                  icon: const Icon(Icons.add_card_rounded),
                  label: const Text('إضافة بطاقة جديدة', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(height: 30),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco_outlined, color: AppColors.forest),
                  SizedBox(width: 8),
                  Icon(Icons.verified_user_outlined, color: AppColors.forestDark),
                  SizedBox(width: 8),
                  Text('بياناتك مشفرة وآمنة', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w800)),
                  SizedBox(width: 8),
                  Icon(Icons.eco_outlined, color: AppColors.forest),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _savedCard({required int index, required String brand, required String number, required String name, bool preferred = false}) {
    final active = selected == index;
    return InkWell(
      onTap: () => setState(() => selected = index),
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: _panel(active: active),
        child: Row(
          children: [
            Container(
              width: 94,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.forestDark, borderRadius: BorderRadius.circular(12)),
              child: Text(brand, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(number, style: const TextStyle(color: AppColors.forestDark, fontSize: 18, fontWeight: FontWeight.w900))),
                      if (preferred)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.terracotta, borderRadius: BorderRadius.circular(12)),
                          child: const Text('★ افتراضية', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(name, style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(onPressed: () => Navigator.pushNamed(context, '/edit-payment'), icon: const Icon(Icons.edit_outlined, color: AppColors.forest)),
                      const SizedBox(width: 2),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline_rounded, color: AppColors.terracotta)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(active ? Icons.radio_button_checked : Icons.radio_button_off, color: active ? AppColors.forest : AppColors.muted),
          ],
        ),
      ),
    );
  }

  Widget _methodTile(int index, String title, String subtitle, IconData icon, Color color, String route) {
    final active = selected == index;
    return InkWell(
      onTap: () {
        setState(() => selected = index);
        Navigator.pushNamed(context, route);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: _panel(active: active),
        child: Row(
          children: [
            Container(width: 58, height: 58, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: Colors.white, size: 30)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 10.5))])),
            Icon(active ? Icons.radio_button_checked : Icons.radio_button_off, color: active ? AppColors.forest : AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class MatchedCardFormScreen extends StatefulWidget {
  const MatchedCardFormScreen({super.key, this.editing = false});
  final bool editing;

  @override
  State<MatchedCardFormScreen> createState() => _MatchedCardFormScreenState();
}

class _MatchedCardFormScreenState extends State<MatchedCardFormScreen> {
  bool save = true;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        appBar: _ReferenceTopBar(title: widget.editing ? 'تعديل وسيلة الدفع' : 'إضافة بطاقة جديدة'),
        body: AppPage(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 14, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 202,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF103F29), Color(0xFF185637), Color(0xFFC45C2C)], begin: AlignmentDirectional.topStart, end: AlignmentDirectional.bottomEnd),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [AppLogo(size: 50), SizedBox(width: 8), Text('مزرعتي', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900))]),
                    Spacer(),
                    Icon(Icons.credit_card_rounded, color: Color(0xFFFFC66D), size: 34),
                    SizedBox(height: 6),
                    Text('1234  5678  9012  3456', style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const _LabeledField(label: 'اسم حامل البطاقة', hint: 'أدخل اسم حامل البطاقة', icon: Icons.person_outline_rounded),
              const SizedBox(height: 12),
              const _LabeledField(label: 'رقم البطاقة', hint: 'أدخل رقم البطاقة', icon: Icons.credit_card_outlined),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(child: _LabeledField(label: 'تاريخ الانتهاء', hint: 'شهر / سنة', icon: Icons.calendar_month_outlined)),
                  SizedBox(width: 10),
                  Expanded(child: _LabeledField(label: 'رمز الأمان CVV', hint: '3-4 أرقام', icon: Icons.lock_outline_rounded)),
                ],
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: save,
                onChanged: (value) => setState(() => save = value ?? true),
                title: const Text('حفظ البطاقة للشراء لاحقًا', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w800)),
              ),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(color: AppColors.forestSoft, borderRadius: BorderRadius.circular(14)),
                child: const Row(children: [Icon(Icons.verified_user_outlined, color: AppColors.forestDark), SizedBox(width: 8), Text('بياناتك مشفرة وآمنة', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w800))]),
              ),
              const SizedBox(height: 20),
              SizedBox(height: 56, child: FilledButton(onPressed: () => Navigator.maybePop(context), child: Text(widget.editing ? 'حفظ التعديلات' : 'حفظ البطاقة', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)))),
            ],
          ),
        ),
      );
}

class MatchedCashOnDeliveryScreen extends StatelessWidget {
  const MatchedCashOnDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        appBar: const _ReferenceTopBar(title: 'مزرعتي'),
        body: AppPage(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 14, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 105,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(color: AppColors.forestDark, borderRadius: BorderRadius.circular(20)),
                child: const Row(children: [CircleAvatar(radius: 34, backgroundColor: AppColors.terracotta, child: Icon(Icons.payments_rounded, color: Colors.white, size: 36)), SizedBox(width: 16), Expanded(child: Text('الدفع عند الاستلام', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)))]),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: _panel(),
                child: const Row(
                  children: [
                    Expanded(child: _MoneyMetric('مبلغ الطلب', '485 ر.س')),
                    SizedBox(height: 52, child: VerticalDivider()),
                    Expanded(child: _MoneyMetric('رسوم التوصيل', '25 ر.س')),
                    SizedBox(height: 52, child: VerticalDivider()),
                    Expanded(child: _MoneyMetric('المجموع الكلي', '510 ر.س', terracotta: true)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: _panel(active: true),
                child: const Row(children: [CircleAvatar(radius: 34, backgroundColor: AppColors.terracottaSoft, child: Icon(Icons.payments_outlined, color: AppColors.forestDark, size: 35)), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('الدفع عند الاستلام', style: TextStyle(color: AppColors.forestDark, fontSize: 17, fontWeight: FontWeight.w900)), SizedBox(height: 4), Text('ادفع نقدًا عند وصول الطلب', style: TextStyle(color: AppColors.muted))])), Icon(Icons.radio_button_checked, color: AppColors.forest)]),
              ),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.terracottaSoft, borderRadius: BorderRadius.circular(16)), child: const Row(children: [Icon(Icons.error_outline_rounded, color: AppColors.terracotta), SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('يرجى تجهيز المبلغ عند الاستلام', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900)), Text('الحد الأقصى للمبلغ النقدي هو 5,000 ر.س', style: TextStyle(color: AppColors.muted, fontSize: 10.5))]))])),
              const SizedBox(height: 12),
              InkWell(onTap: () => Navigator.pushNamed(context, '/addresses'), child: Container(padding: const EdgeInsets.all(14), decoration: _panel(), child: const Row(children: [Icon(Icons.location_on_rounded, color: AppColors.forest, size: 30), SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('عنوان التوصيل', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900)), Text('الرياض حي النخيل', style: TextStyle(color: AppColors.forestDark, fontSize: 16))])), Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: AppColors.forest)]))),
              const SizedBox(height: 28),
              TextButton.icon(onPressed: () => Navigator.pushReplacementNamed(context, '/payment-methods'), icon: const Icon(Icons.credit_card_outlined), label: const Text('تغيير طريقة الدفع')),
              const SizedBox(height: 18),
              SizedBox(height: 56, child: FilledButton(onPressed: () => Navigator.pushReplacementNamed(context, '/payment-success'), child: const Text('تأكيد الدفع عند الاستلام', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)))),
            ],
          ),
        ),
      );
}

class MatchedBankTransferScreen extends StatelessWidget {
  const MatchedBankTransferScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        appBar: const _ReferenceTopBar(title: 'التحويل البنكي'),
        body: AppPage(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 14, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.forestDark, borderRadius: BorderRadius.circular(20)),
                child: const Row(children: [CircleAvatar(radius: 32, backgroundColor: AppColors.terracotta, child: Icon(Icons.account_balance_rounded, color: Colors.white, size: 34)), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('التحويل البنكي', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)), SizedBox(height: 3), Text('حوّل المبلغ ثم أرفق إيصال التحويل', style: TextStyle(color: Colors.white70, fontSize: 11))]))]),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: _panel(),
                child: const Column(children: [
                  _BankRow('اسم البنك', 'البنك الأهلي السعودي'),
                  Divider(height: 22),
                  _BankRow('اسم المستفيد', 'مؤسسة مزرعتي للتجارة'),
                  Divider(height: 22),
                  _BankRow('رقم الحساب', '1234567890'),
                  Divider(height: 22),
                  _BankRow('IBAN', 'SA00 0000 0000 0000 0000 0000'),
                ]),
              ),
              const SizedBox(height: 14),
              Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.terracottaSoft, borderRadius: BorderRadius.circular(16)), child: const Row(children: [Icon(Icons.info_outline_rounded, color: AppColors.terracotta), SizedBox(width: 9), Expanded(child: Text('اكتب رقم الطلب في خانة وصف التحويل لتسريع المطابقة.', style: TextStyle(color: AppColors.forestDark, height: 1.5)))])),
              const SizedBox(height: 16),
              Container(
                height: 150,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
                child: const Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.cloud_upload_outlined, color: AppColors.forest, size: 42), SizedBox(height: 7), Text('إرفاق إيصال التحويل', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900)), SizedBox(height: 3), Text('PNG أو JPG أو PDF', style: TextStyle(color: AppColors.muted, fontSize: 10))]),
              ),
              const SizedBox(height: 20),
              SizedBox(height: 56, child: FilledButton.icon(onPressed: () => Navigator.pushReplacementNamed(context, '/wallet-pending'), icon: const Icon(Icons.check_circle_outline_rounded), label: const Text('إرسال للتحقق', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)))),
            ],
          ),
        ),
      );
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.hint, required this.icon});
  final String label;
  final String hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: const TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900)),
          const SizedBox(height: 7),
          TextField(decoration: InputDecoration(hintText: hint, suffixIcon: Icon(icon, color: AppColors.forest))),
        ],
      );
}

class _MoneyMetric extends StatelessWidget {
  const _MoneyMetric(this.label, this.value, {this.terracotta = false});
  final String label;
  final String value;
  final bool terracotta;

  @override
  Widget build(BuildContext context) => Column(children: [Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.forestDark, fontSize: 11, fontWeight: FontWeight.w800)), const SizedBox(height: 8), Text(value, textAlign: TextAlign.center, style: TextStyle(color: terracotta ? AppColors.terracotta : AppColors.forest, fontSize: 17, fontWeight: FontWeight.w900))]);
}

class _BankRow extends StatelessWidget {
  const _BankRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(children: [Text(label, style: const TextStyle(color: AppColors.muted)), const Spacer(), Flexible(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900)))]);
}

class _ReferenceTopBar extends StatelessWidget implements PreferredSizeWidget {
  const _ReferenceTopBar({required this.title});
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) => AppBar(
        toolbarHeight: 72,
        backgroundColor: AppColors.ivory,
        elevation: 0,
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? IconButton(onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.forestDark))
            : null,
        title: Row(mainAxisSize: MainAxisSize.min, children: [const AppLogo(size: 42), const SizedBox(width: 8), Text(title, style: const TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900))]),
      );
}

BoxDecoration _panel({bool active = false}) => BoxDecoration(
      color: active ? AppColors.forestSoft : AppColors.surface,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: active ? AppColors.forest : AppColors.border, width: active ? 1.5 : 1),
      boxShadow: const [BoxShadow(color: Color(0x0A0D4328), blurRadius: 12, offset: Offset(0, 3))],
    );
