import 'package:flutter/material.dart';

import '../../../core/reference/reference_demo_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import 'connected_customer_service_screens.dart';

class PixelAwareOrdersScreen extends StatelessWidget {
  const PixelAwareOrdersScreen({super.key});

  static const bool _referenceVisual = bool.fromEnvironment('REFERENCE_VISUAL_TEST');

  @override
  Widget build(BuildContext context) => _referenceVisual
      ? const PixelOrdersScreen()
      : const ConnectedOrdersScreen();
}

class PixelOrdersScreen extends StatefulWidget {
  const PixelOrdersScreen({super.key});

  @override
  State<PixelOrdersScreen> createState() => _PixelOrdersScreenState();
}

class _PixelOrdersScreenState extends State<PixelOrdersScreen> {
  int filter = 0;

  static const filters = ['الكل', 'قيد التجهيز', 'قيد التوصيل', 'مكتمل', 'ملغي'];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ivory,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _OrdersHeader(),
              Expanded(
                child: AppPage(
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 2, 14, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 50,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: filters.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 6),
                          itemBuilder: (context, index) {
                            final active = filter == index;
                            return ChoiceChip(
                              selected: active,
                              showCheckmark: false,
                              label: Text(filters[index]),
                              onSelected: (_) => setState(() => filter = index),
                              selectedColor: AppColors.forest,
                              backgroundColor: const Color(0xFFF3EFE5),
                              labelStyle: TextStyle(
                                color: active ? Colors.white : AppColors.forestDark,
                                fontWeight: FontWeight.w800,
                              ),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _OrderCard(
                        orderId: 'MZ-24581',
                        date: '12 أبريل 2025',
                        status: 'قيد التوصيل',
                        statusIcon: Icons.local_shipping_outlined,
                        statusColor: AppColors.forest,
                        total: '5,938 ر.س',
                        products: [
                          _OrderProduct(
                            image: ReferenceDemoData.products[0].image,
                            name: 'عسل سدر طبيعي',
                            price: '4,500 ر.س',
                            quantity: 1,
                          ),
                          _OrderProduct(
                            image: ReferenceDemoData.products[2].image,
                            name: 'بذور زراعية متنوعة',
                            price: '238 ر.س',
                            quantity: 2,
                          ),
                          _OrderProduct(
                            image: ReferenceDemoData.products[1].image,
                            name: 'بدلة تربية النحل',
                            price: '1,200 ر.س',
                            quantity: 1,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _OrderCard(
                        orderId: 'MZ-24563',
                        date: '8 أبريل 2025',
                        status: 'مكتمل',
                        statusIcon: Icons.check_circle_outline_rounded,
                        statusColor: const Color(0xFF6D8C55),
                        total: '4,520 ر.س',
                        products: [
                          _OrderProduct(
                            image: ReferenceDemoData.products[0].image,
                            name: 'عسل طبيعي فاخر',
                            price: '3,200 ر.س',
                            quantity: 1,
                          ),
                          _OrderProduct(
                            image: ReferenceDemoData.products[2].image,
                            name: 'بذور الكتان',
                            price: '120 ر.س',
                            quantity: 3,
                          ),
                          _OrderProduct(
                            image: ReferenceDemoData.products[1].image,
                            name: 'بدلة تربية النحل',
                            price: '1,200 ر.س',
                            quantity: 1,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const _OrdersBottomNav(),
            ],
          ),
        ),
      );
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader();

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 70,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const AppLogo(size: 48),
            const PositionedDirectional(
              end: 14,
              child: Row(
                children: [
                  Text(
                    'طلباتي',
                    style: TextStyle(
                      color: AppColors.forestDark,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.eco_rounded, color: AppColors.forestDark),
                ],
              ),
            ),
            PositionedDirectional(
              start: 4,
              child: IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.forestDark),
              ),
            ),
          ],
        ),
      );
}

class _OrderProduct {
  const _OrderProduct({
    required this.image,
    required this.name,
    required this.price,
    required this.quantity,
  });

  final String image;
  final String name;
  final String price;
  final int quantity;
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.orderId,
    required this.date,
    required this.status,
    required this.statusIcon,
    required this.statusColor,
    required this.total,
    required this.products,
  });

  final String orderId;
  final String date;
  final String status;
  final IconData statusIcon;
  final Color statusColor;
  final String total;
  final List<_OrderProduct> products;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(color: Color(0x080D4328), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 17),
                      const SizedBox(width: 5),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '#$orderId',
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        color: AppColors.forestDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(date, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
                        const SizedBox(width: 5),
                        const Icon(Icons.calendar_month_outlined, color: AppColors.forest, size: 15),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 13),
            Row(
              children: products
                  .map(
                    (product) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _ProductMiniCard(product: product),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4E8),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, color: AppColors.forestDark),
                  const SizedBox(width: 8),
                  const Text('المجموع الكلي', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                  const Spacer(),
                  Text(
                    total,
                    style: const TextStyle(
                      color: AppColors.forestDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/order-details'),
                      icon: const Icon(Icons.receipt_long_outlined, size: 18),
                      label: const Text('عرض التفاصيل'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/track-order'),
                      icon: const Icon(Icons.local_shipping_outlined, size: 19),
                      label: const Text('تتبع الطلب'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _ProductMiniCard extends StatelessWidget {
  const _ProductMiniCard({required this.product});

  final _OrderProduct product;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: AppDataImage(product.image, fit: BoxFit.cover),
                ),
              ),
              PositionedDirectional(
                top: 5,
                start: 5,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFFF8F1DF),
                  child: Text(
                    '×${product.quantity}',
                    style: const TextStyle(
                      color: AppColors.forestDark,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.forestDark,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            product.price,
            style: const TextStyle(
              color: AppColors.forest,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      );
}

class _OrdersBottomNav extends StatelessWidget {
  const _OrdersBottomNav();

  @override
  Widget build(BuildContext context) {
    const items = <({String label, IconData icon, String route})>[
      (label: 'الرئيسية', icon: Icons.home_rounded, route: '/'),
      (label: 'المنتجات', icon: Icons.grid_view_outlined, route: '/products'),
      (label: 'المزادات', icon: Icons.gavel_outlined, route: '/auctions'),
      (label: 'سلة التسوق', icon: Icons.shopping_cart_outlined, route: '/cart'),
      (label: 'حسابي', icon: Icons.person_outline_rounded, route: '/account'),
    ];
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Container(
          height: 70,
          decoration: const BoxDecoration(
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
      ),
    );
  }
}
