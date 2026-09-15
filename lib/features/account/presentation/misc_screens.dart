import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../../marketplace/presentation/marketplace_screens.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, this.empty = false});
  final bool empty;
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final products = app.products.where((p) => app.isFavorite(p.id)).toList();
    if (empty || products.isEmpty) {
      return const Scaffold(
        appBar: MazraaAppBar(title: 'المفضلة'),
        body: ResultStateView(
          kind: ResultKind.empty,
          title: 'لا توجد مفضلة بعد',
          message: 'اضغط على القلب لحفظ المنتجات التي تعجبك',
          primaryLabel: 'تصفح المنتجات',
        ),
      );
    }
    return Scaffold(
      appBar: MazraaAppBar(title: 'المفضلة  ${products.length}'),
      body: AppPage(
        child: Column(
          children: [
            const Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Chip(
                avatar: Icon(Icons.sort_rounded),
                label: Text('الترتيب حسب الأحدث'),
              ),
            ),
            const SizedBox(height: 8),
            ...products.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: ProductCard(
                  product: p,
                  compact: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(product: p),
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
}

class CancelOrderScreen extends StatefulWidget {
  const CancelOrderScreen({super.key});
  @override
  State<CancelOrderScreen> createState() => _CancelOrderScreenState();
}

class _CancelOrderScreenState extends State<CancelOrderScreen> {
  int reason = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'إلغاء الطلب'),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.terracotta,
            size: 72,
          ),
          Text(
            'هل تريد إلغاء الطلب؟',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text(
            '#MZ-24581',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          const SectionHeader(
            title: 'اختر سبب الإلغاء',
            icon: Icons.eco_rounded,
          ),
          ...[
            'تغيير رأيي',
            'طلبت بالخطأ',
            'تأخر التوصيل',
            'سبب آخر',
          ].asMap().entries.map(
            (e) => ListTile(
              onTap: () => setState(() => reason = e.key),
              leading: Icon(
                reason == e.key
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: reason == e.key ? AppColors.forest : AppColors.muted,
              ),
              title: Text(e.value),
            ),
          ),
          const TextField(
            maxLines: 3,
            decoration: InputDecoration(labelText: 'ملاحظات إضافية (اختياري)'),
          ),
          const SizedBox(height: 12),
          const AppSurfaceCard(
            color: AppColors.forestSoft,
            child: ListTile(
              leading: Icon(Icons.account_balance_wallet_outlined),
              title: Text('سيعاد المبلغ إلى محفظتك خلال 3–5 أيام عمل'),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/order-cancelled'),
            child: const Text('تأكيد الإلغاء'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('الاحتفاظ بالطلب'),
          ),
        ],
      ),
    ),
  );
}

class RateOrderScreen extends StatefulWidget {
  const RateOrderScreen({super.key});
  @override
  State<RateOrderScreen> createState() => _RateOrderScreenState();
}

class _RateOrderScreenState extends State<RateOrderScreen> {
  final ratings = [4, 5, 5];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'تقييم الطلب'),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StatusPill(label: 'تم التوصيل', color: AppColors.success),
          const SizedBox(height: 12),
          Text(
            'كيف كانت تجربتك؟',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppColors.forest),
          ),
          const SizedBox(height: 14),
          ...['المنتج', 'البائع', 'التوصيل'].asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: AppSurfaceCard(
                child: Row(
                  children: [
                    Text(e.value),
                    const Spacer(),
                    ...List.generate(
                      5,
                      (i) => IconButton(
                        onPressed: () => setState(() => ratings[e.key] = i + 1),
                        icon: Icon(
                          i < ratings[e.key]
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: AppColors.forest,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const TextField(
            maxLines: 4,
            decoration: InputDecoration(labelText: 'شاركنا رأيك'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('أضف صورة'),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.send_rounded),
            label: const Text('إرسال التقييم'),
          ),
        ],
      ),
    ),
  );
}

class ReturnsScreen extends StatelessWidget {
  const ReturnsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'المرتجعات والاسترداد'),
    body: AppPage(
      child: Column(
        children: [
          const Wrap(
            spacing: 7,
            children: [
              ChoiceChip(label: Text('طلب إرجاع جديد'), selected: true),
              ChoiceChip(label: Text('طلباتي السابقة'), selected: false),
            ],
          ),
          const SizedBox(height: 12),
          AppSurfaceCard(
            child: Column(
              children: [
                const Row(
                  children: [
                    StatusPill(label: 'قابل للإرجاع'),
                    Spacer(),
                    Text('#MZ-24563'),
                  ],
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Image.asset(
                    'assets/images/home/livestock_feed.png',
                    width: 76,
                    height: 66,
                    fit: BoxFit.cover,
                  ),
                  title: const Text('علف مواشي عالي الجودة'),
                  subtitle: const Text('الكمية 1'),
                  trailing: FilledButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/return-request'),
                    child: const Text('طلب إرجاع'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SettingsTile(
            icon: Icons.history_rounded,
            title: 'طلب سابق قيد المراجعة',
            subtitle: 'مبلغ الاسترداد 120 ر.س',
            onTap: () => Navigator.pushNamed(context, '/refund-status'),
          ),
        ],
      ),
    ),
  );
}

class ReturnRequestScreen extends StatefulWidget {
  const ReturnRequestScreen({super.key});
  @override
  State<ReturnRequestScreen> createState() => _ReturnRequestScreenState();
}

class _ReturnRequestScreenState extends State<ReturnRequestScreen> {
  String reason = 'المنتج غير مطابق';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'طلب إرجاع'),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSurfaceCard(
            child: ListTile(
              leading: Icon(Icons.eco_rounded),
              title: Text('رقم الطلب MZ-24563'),
            ),
          ),
          const SizedBox(height: 9),
          AppSurfaceCard(
            child: ListTile(
              leading: Image.asset(
                'assets/images/home/livestock_feed.png',
                width: 70,
                height: 60,
                fit: BoxFit.cover,
              ),
              title: const Text('علف مواشي عالي الجودة'),
              subtitle: const Text('الكمية 1 • 120 ر.س'),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: reason,
            decoration: const InputDecoration(labelText: 'سبب الإرجاع'),
            items: [
              'المنتج غير مطابق',
              'تالف عند الاستلام',
              'طلب بالخطأ',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => reason = v!),
          ),
          const SizedBox(height: 10),
          const TextField(
            maxLines: 5,
            decoration: InputDecoration(labelText: 'تفاصيل إضافية'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('أضف صورًا للمنتج'),
          ),
          const SizedBox(height: 10),
          const AppSurfaceCard(
            color: AppColors.forestSoft,
            child: ListTile(
              leading: Icon(Icons.payments_outlined),
              title: Text('قيمة المنتج'),
              trailing: Text('120 ر.س'),
            ),
          ),
          CheckboxListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('أوافق على سياسة الإرجاع'),
            contentPadding: EdgeInsets.zero,
          ),
          FilledButton.icon(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/return-success'),
            icon: const Icon(Icons.send_rounded),
            label: const Text('إرسال الطلب'),
          ),
        ],
      ),
    ),
  );
}

class RefundStatusScreen extends StatelessWidget {
  const RefundStatusScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'حالة الاسترداد'),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSurfaceCard(
            color: AppColors.forest,
            child: Center(
              child: Text(
                'حالة الاسترداد',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
                  title: Text('تم إرسال الطلب'),
                  subtitle: Text('12 سبتمبر • 10:24'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.forest,
                    child: Icon(Icons.check, color: Colors.white),
                  ),
                  title: Text('قيد المراجعة'),
                  subtitle: Text('12 سبتمبر • 14:17'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.success,
                    child: Icon(Icons.check, color: Colors.white),
                  ),
                  title: Text('تمت الموافقة'),
                  subtitle: Text('13 سبتمبر • 09:42'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.terracotta,
                    child: Icon(Icons.payments_outlined, color: Colors.white),
                  ),
                  title: Text('تم رد المبلغ'),
                  subtitle: Text('15 سبتمبر • 11:30'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const AppSurfaceCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('مبلغ الاسترداد'),
                    Text(
                      '120 ر.س',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.terracotta,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('وجهة الاسترداد'),
                    Text(
                      'المحفظة الداخلية',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/support'),
            icon: const Icon(Icons.support_agent_rounded),
            label: const Text('للتواصل مع الدعم الفني'),
          ),
        ],
      ),
    ),
  );
}

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: MazraaAppBar(
      title: 'الفاتورة الإلكترونية',
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.download_outlined)),
      ],
    ),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSurfaceCard(
            child: Row(
              children: [
                AppLogo(size: 60),
                SizedBox(width: 14),
                VerticalDivider(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('رقم الفاتورة'),
                      Text(
                        'INV-MZ-24581',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text('رقم الطلب #MZ-24581'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const AppSurfaceCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [Text('التاريخ'), Text('2026/09/12')]),
                Column(children: [Text('البائع'), Text('شركة مزرعتي')]),
                Column(children: [Text('المشتري'), Text('محمد العتيبي')]),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const SectionHeader(
            title: 'تفاصيل الطلب',
            icon: Icons.inventory_2_outlined,
          ),
          ...AppScope.of(context).products
              .take(2)
              .map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: AppSurfaceCard(
                    child: ListTile(
                      leading: Image.asset(
                        p.image,
                        width: 60,
                        height: 55,
                        fit: BoxFit.cover,
                      ),
                      title: Text(p.name),
                      subtitle: const Text('الكمية 1'),
                      trailing: Text(formatPrice(p.price)),
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 8),
          const AppSurfaceCard(
            child: Column(
              children: [
                ListTile(
                  title: Text('المجموع الفرعي'),
                  trailing: Text('4,420 ر.س'),
                ),
                ListTile(title: Text('رسوم الشحن'), trailing: Text('200 ر.س')),
                ListTile(title: Text('الضريبة'), trailing: Text('663 ر.س')),
                Divider(),
                ListTile(
                  title: Text(
                    'المبلغ الإجمالي',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  trailing: Text(
                    '5,240 ر.س',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.forest,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_rounded),
            label: const Text('تحميل الفاتورة'),
          ),
        ],
      ),
    ),
  );
}

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'حذف الحساب'),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.delete_forever_rounded,
            color: AppColors.error,
            size: 88,
          ),
          const AppSurfaceCard(
            color: AppColors.terracottaSoft,
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.error),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'سيؤدي حذف الحساب إلى إزالة بياناتك والمفضلة وسجل الطلبات، ولا يمكن التراجع.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const SectionHeader(title: 'سبب حذف الحساب', icon: Icons.eco_rounded),
          ...[
            'استخدم التطبيق بشكل مؤقت',
            'تجربة استخدام غير مرضية',
            'أسعار مرتفعة',
            'مشاكل تقنية',
            'سبب آخر',
          ].map(
            (e) => ListTile(
              leading: Icon(
                e == 'سبب آخر'
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: e == 'سبب آخر' ? AppColors.forest : AppColors.muted,
              ),
              title: Text(e),
            ),
          ),
          const TextField(
            maxLines: 3,
            decoration: InputDecoration(labelText: 'ملاحظاتك'),
          ),
          CheckboxListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('أفهم أن الحذف نهائي'),
            contentPadding: EdgeInsets.zero,
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('تأكيد حذف الحساب'),
                content: const Text(
                  'هل أنت متأكد؟ لا يمكن التراجع عن هذه العملية.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (_) => false,
                    ),
                    child: const Text('حذف نهائي'),
                  ),
                ],
              ),
            ),
            child: const Text('حذف الحساب نهائيًا'),
          ),
        ],
      ),
    ),
  );
}
