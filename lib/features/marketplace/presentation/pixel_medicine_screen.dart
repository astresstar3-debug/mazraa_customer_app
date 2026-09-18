import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../domain/marketplace_models.dart';

class PixelMedicineProductScreen extends StatefulWidget {
  const PixelMedicineProductScreen({super.key});

  @override
  State<PixelMedicineProductScreen> createState() => _PixelMedicineProductScreenState();
}

class _PixelMedicineProductScreenState extends State<PixelMedicineProductScreen> {
  int quantity = 1;
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    Product? product;
    for (final item in app.products) {
      if (item.kind == ProductKind.medicine) {
        product = item;
        break;
      }
    }
    product ??= app.products.isNotEmpty ? app.products.first : null;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 68,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.forestDark),
                  ),
                  const Spacer(),
                  const AppLogo(size: 48),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.ios_share_rounded, color: AppColors.forestDark),
                  ),
                  IconButton(
                    onPressed: product == null ? null : () => app.toggleFavorite(product!.id),
                    icon: Icon(
                      product != null && app.isFavorite(product.id)
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: AppColors.forestDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: AppPage(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 2, 14, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.location_on_outlined, color: AppColors.forest, size: 16),
                SizedBox(width: 4),
                Text(
                  'مزرعتي',
                  style: TextStyle(
                    color: AppColors.forestDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            const _MedicineHero(),
            const SizedBox(height: 14),
            Text(
              product?.name ?? 'دواء بيطري متعدد الاستخدام',
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: AppColors.forestDark,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
                const SizedBox(width: 3),
                Text(
                  '${product?.rating == 0 || product?.rating == null ? 4.7 : product!.rating}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${product?.reviews == 0 || product?.reviews == null ? 38 : product!.reviews} تقييم)',
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatPrice(product?.price ?? 96),
                  style: const TextStyle(
                    color: AppColors.forest,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatPrice(product?.oldPrice ?? 120),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.forestSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 15, color: AppColors.forest),
                      SizedBox(width: 4),
                      Text('متوفر', style: TextStyle(color: AppColors.forest, fontSize: 10, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border),
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(child: _InfoCell(label: 'الماركة', value: 'VetCare', icon: Icons.verified_outlined)),
                  SizedBox(width: 1, height: 58, child: ColoredBox(color: AppColors.border)),
                  Expanded(child: _InfoCell(label: 'التصنيف', value: 'الأدوية البيطرية', icon: Icons.medical_services_outlined)),
                ],
              ),
            ),
            const SizedBox(height: 11),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5EA),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.terracotta.withValues(alpha: .35)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.terracotta),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'استخدم المنتج حسب إرشادات المختص البيطري وتعليمات الجرعة الموضحة.',
                      style: TextStyle(color: AppColors.forestDark, fontSize: 10.5, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Expanded(
                  child: _UsageCard(
                    icon: Icons.science_outlined,
                    title: 'طريقة الاستخدام',
                    message: 'رج العبوة جيدًا واتبع الجرعة الموصى بها.',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _UsageCard(
                    icon: Icons.ac_unit_rounded,
                    title: 'طريقة التخزين',
                    message: 'يحفظ في مكان بارد وجاف بعيدًا عن الشمس.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'الكمية',
                  style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() => quantity = quantity > 1 ? quantity - 1 : 1),
                        icon: const Icon(Icons.remove_rounded, size: 18),
                      ),
                      Text('$quantity', style: const TextStyle(fontWeight: FontWeight.w900)),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() => quantity++),
                        icon: const Icon(Icons.add_rounded, size: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/cart'),
                      icon: const Icon(Icons.bolt_rounded),
                      label: const Text('اشترِ الآن', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.terracotta),
                      onPressed: product == null
                          ? null
                          : () async {
                              try {
                                await app.addToCart(product!, quantity: quantity);
                              } catch (_) {}
                            },
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text('أضف إلى السلة', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _Tabs(value: tab, onChanged: (value) => setState(() => tab = value)),
            const SizedBox(height: 10),
            _TabPanel(tab: tab),
          ],
        ),
      ),
      bottomNavigationBar: const _MedicineBottomNav(),
    );
  }
}

class _MedicineHero extends StatelessWidget {
  const _MedicineHero();

  @override
  Widget build(BuildContext context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: const Color(0xFFE6E0D2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            PositionedDirectional(
              start: -20,
              bottom: -22,
              child: Icon(
                Icons.eco_rounded,
                size: 150,
                color: AppColors.forest.withValues(alpha: .10),
              ),
            ),
            PositionedDirectional(
              end: -22,
              top: -18,
              child: Icon(
                Icons.eco_rounded,
                size: 135,
                color: AppColors.terracotta.withValues(alpha: .08),
              ),
            ),
            PositionedDirectional(
              start: 34,
              bottom: 42,
              child: Transform.rotate(
                angle: -.06,
                child: Container(
                  width: 112,
                  height: 165,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F3E8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC7BDA8)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 7)),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppLogo(size: 36),
                      SizedBox(height: 10),
                      Text('VET CARE', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900, fontSize: 13)),
                      SizedBox(height: 6),
                      Text('دواء بيطري\nمتعدد الاستخدام', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 10, height: 1.4)),
                    ],
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              end: 55,
              bottom: 34,
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.forestDark,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                  ),
                  Container(
                    width: 105,
                    height: 175,
                    decoration: BoxDecoration(
                      color: const Color(0xFF452B1D),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0xFF2B1A12), width: 2),
                      boxShadow: const [
                        BoxShadow(color: Color(0x33000000), blurRadius: 15, offset: Offset(0, 9)),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 88,
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F0E5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppLogo(size: 28),
                          SizedBox(height: 7),
                          Text('VetCare', style: TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900, fontSize: 12)),
                          SizedBox(height: 3),
                          Text('لقاح بيطري', style: TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.w800, fontSize: 10)),
                          SizedBox(height: 6),
                          Text('500 ml', style: TextStyle(color: AppColors.muted, fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              top: 12,
              start: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.forest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('خصم 20%', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ),
            const PositionedDirectional(
              top: 12,
              end: 12,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(Icons.favorite_border_rounded, color: AppColors.forestDark, size: 20),
              ),
            ),
          ],
        ),
      );
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 17, color: AppColors.forest),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.forestDark, fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _UsageCard extends StatelessWidget {
  const _UsageCard({required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.forest, size: 18),
                const SizedBox(width: 5),
                Text(title, style: const TextStyle(color: AppColors.forestDark, fontWeight: FontWeight.w900, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 6),
            Text(message, style: const TextStyle(color: AppColors.muted, fontSize: 9.5, height: 1.45)),
          ],
        ),
      );
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  static const labels = ['الوصف', 'الاستخدام', 'التحذيرات', 'التقييمات'];

  @override
  Widget build(BuildContext context) => Row(
        children: List.generate(labels.length, (index) {
          final active = index == value;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: active ? AppColors.forest : AppColors.border,
                      width: active ? 3 : 1,
                    ),
                  ),
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: active ? AppColors.forestDark : AppColors.muted,
                    fontSize: 10.5,
                    fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      );
}

class _TabPanel extends StatelessWidget {
  const _TabPanel({required this.tab});

  final int tab;

  @override
  Widget build(BuildContext context) {
    const texts = [
      'دواء بيطري مخصص للعناية بالحيوانات، بتركيبة موثوقة ومعلومات استخدام واضحة.',
      'يستخدم وفق الجرعة الموضحة على العبوة وتحت إشراف المختص البيطري.',
      'يحفظ بعيدًا عن متناول الأطفال وفي درجة الحرارة الموصى بها.',
      '4.7 من 5 بناءً على تقييمات العملاء والمستخدمين.',
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        texts[tab.clamp(0, texts.length - 1)],
        style: const TextStyle(color: AppColors.muted, fontSize: 10.5, height: 1.65),
      ),
    );
  }
}

class _MedicineBottomNav extends StatelessWidget {
  const _MedicineBottomNav();

  @override
  Widget build(BuildContext context) {
    const items = <({String label, IconData icon, String route})>[
      (label: 'الرئيسية', icon: Icons.home_rounded, route: '/'),
      (label: 'المنتجات', icon: Icons.grid_view_rounded, route: '/products'),
      (label: 'المزادات', icon: Icons.gavel_outlined, route: '/auctions'),
      (label: 'سلة التسوق', icon: Icons.shopping_cart_outlined, route: '/cart'),
      (label: 'حسابي', icon: Icons.person_outline_rounded, route: '/account'),
    ];
    return SafeArea(
      top: false,
      child: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final active = index == 0;
            return Expanded(
              child: InkWell(
                onTap: active
                    ? null
                    : () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          item.route,
                          (route) => item.route != '/' && route.isFirst,
                        ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, color: active ? AppColors.forest : AppColors.muted, size: 22),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: active ? AppColors.forest : AppColors.muted,
                        fontSize: 9,
                        fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
