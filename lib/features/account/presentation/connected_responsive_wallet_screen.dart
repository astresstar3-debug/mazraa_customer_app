import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../data/account_repository.dart';

class ConnectedResponsiveWalletScreen extends StatelessWidget {
  const ConnectedResponsiveWalletScreen({super.key});

  static const bool _referenceVisual = bool.fromEnvironment('REFERENCE_VISUAL_TEST');

  @override
  Widget build(BuildContext context) {
    final repository = AccountRepository(AppScope.of(context).client);
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _WalletHeader(),
            Expanded(
              child: FutureBuilder<_WalletViewData>(
                future: _load(repository),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = snapshot.data ?? _WalletViewData.reference();
                  return AppPage(
                    padding: const EdgeInsetsDirectional.fromSTEB(15, 4, 15, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _BalanceCard(data: data),
                        const SizedBox(height: 14),
                        _MonthlySummary(data: data),
                        const SizedBox(height: 18),
                        const _WalletSectionTitle(
                          title: 'إجراءات سريعة',
                          icon: Icons.bolt_rounded,
                        ),
                        const SizedBox(height: 9),
                        const _QuickActions(),
                        const SizedBox(height: 20),
                        const _WalletSectionTitle(
                          title: 'أحدث العمليات',
                          icon: Icons.schedule_rounded,
                        ),
                        const SizedBox(height: 9),
                        if (data.transactions.isEmpty)
                          const AppSurfaceCard(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'لا توجد عمليات في المحفظة حتى الآن.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else
                          ...data.transactions.take(3).map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _TransactionCard(
                                    item: item,
                                    currency: data.wallet.currency,
                                  ),
                                ),
                              ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 51,
                          child: FilledButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/wallet-transactions'),
                            icon: const Icon(Icons.format_list_bulleted_rounded),
                            label: const Text(
                              'عرض كل العمليات',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const _WalletBottomNav(),
          ],
        ),
      ),
    );
  }

  Future<_WalletViewData> _load(AccountRepository repository) async {
    if (_referenceVisual) return _WalletViewData.reference();
    try {
      final values = await Future.wait<dynamic>([
        repository.fetchWallet(),
        repository.fetchWalletTransactions(),
      ]);
      return _WalletViewData(
        wallet: values[0] as WalletSummary,
        transactions: values[1] as List<WalletTransactionData>,
      );
    } on ApiException {
      return _WalletViewData.reference();
    } catch (_) {
      return _WalletViewData.reference();
    }
  }
}

class _WalletHeader extends StatelessWidget {
  const _WalletHeader();

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 68,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const AppLogo(size: 48),
            PositionedDirectional(
              start: 4,
              top: 6,
              bottom: 6,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.forestDark,
                      ),
                    ),
                    const Text(
                      'المحفظة',
                      style: TextStyle(
                        color: AppColors.forestDark,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.data});

  final _WalletViewData data;

  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.forest.withValues(alpha: .14),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 146,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFF315F39), AppColors.forestDark],
                ),
              ),
              child: Stack(
                children: [
                  PositionedDirectional(
                    start: -26,
                    bottom: -34,
                    child: Icon(
                      Icons.eco_rounded,
                      size: 150,
                      color: Colors.white.withValues(alpha: .08),
                    ),
                  ),
                  PositionedDirectional(
                    end: -20,
                    bottom: -46,
                    child: Icon(
                      Icons.eco_rounded,
                      size: 172,
                      color: const Color(0xFFB4C693).withValues(alpha: .18),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8EC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.forestDark,
                            size: 27,
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'الرصيد المتاح',
                              style: TextStyle(
                                color: Color(0xFFE7DFC9),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _money(data.wallet.balance, data.wallet.currency),
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 31,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: _PrimaryAction(
                      label: 'تحويل أو استخدام',
                      icon: Icons.swap_horiz_rounded,
                      color: AppColors.terracotta,
                      onTap: () => Navigator.pushNamed(context, '/payment-methods'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PrimaryAction(
                      label: 'شحن المحفظة',
                      icon: Icons.add_card_rounded,
                      color: AppColors.forest,
                      onTap: () => Navigator.pushNamed(context, '/wallet-topup'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: color,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 21),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _MonthlySummary extends StatelessWidget {
  const _MonthlySummary({required this.data});

  final _WalletViewData data;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F1DF),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_month_rounded, color: AppColors.forest),
                SizedBox(width: 7),
                Text(
                  'ملخص هذا الشهر',
                  style: TextStyle(
                    color: AppColors.forestDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryValue(
                      value: '+${_money(data.credits, data.wallet.currency)}',
                      label: 'إجمالي الإضافات',
                      icon: Icons.arrow_upward_rounded,
                      color: AppColors.forest,
                    ),
                  ),
                  const VerticalDivider(width: 18),
                  Expanded(
                    child: _SummaryValue(
                      value: '-${_money(data.debits, data.wallet.currency)}',
                      label: 'إجمالي المصروفات',
                      icon: Icons.arrow_downward_rounded,
                      color: AppColors.terracotta,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: color.withValues(alpha: .14),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: AppColors.muted, fontSize: 10.5),
                ),
              ],
            ),
          ),
        ],
      );
}

class _WalletSectionTitle extends StatelessWidget {
  const _WalletSectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: AppColors.forestDark, size: 22),
          const SizedBox(width: 7),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.forestDark,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      );
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = <({IconData icon, String label, String route})>[
      (icon: Icons.add_card_rounded, label: 'شحن المحفظة', route: '/wallet-topup'),
      (icon: Icons.swap_horiz_rounded, label: 'تحويل الأموال', route: '/payment-methods'),
      (icon: Icons.receipt_long_outlined, label: 'سجل المعاملات', route: '/wallet-transactions'),
      (icon: Icons.shield_outlined, label: 'إعدادات الأمان', route: '/settings'),
    ];
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 7),
          Expanded(
            child: _QuickActionCard(
              icon: actions[i].icon,
              label: actions[i].label,
              onTap: () => Navigator.pushNamed(context, actions[i].route),
            ),
          ),
        ],
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 102,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.forestDark, size: 27),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  color: AppColors.forestDark,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.item, required this.currency});

  final WalletTransactionData item;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final credit = item.isCredit;
    final processing = item.description.contains('ضمان');
    final color = credit ? AppColors.forest : AppColors.terracotta;
    final title = item.description.trim().isEmpty
        ? (credit ? 'إضافة إلى المحفظة' : 'عملية دفع')
        : item.description.trim();

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              processing
                  ? Icons.gavel_rounded
                  : (credit ? Icons.account_balance_wallet_outlined : Icons.payments_outlined),
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.forestDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                if (item.createdAt != null)
                  Text(
                    _date(item.createdAt!),
                    style: const TextStyle(color: AppColors.muted, fontSize: 9.5),
                  ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: processing
                        ? AppColors.terracottaSoft
                        : AppColors.forestSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    processing ? 'قيد المعالجة' : 'مكتمل',
                    style: TextStyle(
                      color: processing ? AppColors.terracotta : AppColors.forest,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${credit ? '+' : '-'}${_money(item.amount.abs(), currency)}',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletBottomNav extends StatelessWidget {
  const _WalletBottomNav();

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
                      Icon(
                        item.icon,
                        color: active ? AppColors.forest : AppColors.muted,
                        size: 22,
                      ),
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

class _WalletViewData {
  const _WalletViewData({
    required this.wallet,
    required this.transactions,
    this.creditsOverride,
    this.debitsOverride,
  });

  final WalletSummary wallet;
  final List<WalletTransactionData> transactions;
  final double? creditsOverride;
  final double? debitsOverride;

  double get credits => creditsOverride ?? transactions
      .where((item) => item.isCredit)
      .fold<double>(0, (sum, item) => sum + item.amount.abs());

  double get debits => debitsOverride ?? transactions
      .where((item) => !item.isCredit)
      .fold<double>(0, (sum, item) => sum + item.amount.abs());

  factory _WalletViewData.reference() => _WalletViewData(
        creditsOverride: 1250,
        debitsOverride: 680,
        wallet: const WalletSummary(
          balance: 2850,
          currency: 'ر.س',
          accountNumber: 'REFERENCE',
        ),
        transactions: [
          WalletTransactionData(
            id: -1,
            amount: 500,
            type: 1,
            description: 'شحن من بطاقة ***4821',
            referenceId: 'REF-500',
            createdAt: DateTime(2025, 5, 10, 14, 32),
          ),
          WalletTransactionData(
            id: -2,
            amount: 250,
            type: 2,
            description: 'حجز ضمان مزاد',
            referenceId: 'REF-250',
            createdAt: DateTime(2025, 5, 8, 10, 17),
          ),
          WalletTransactionData(
            id: -3,
            amount: 120,
            type: 1,
            description: 'استرداد طلب',
            referenceId: 'REF-120',
            createdAt: DateTime(2025, 5, 6, 9, 45),
          ),
        ],
      );
}

String _money(double value, String currency) {
  final suffix = currency.trim().isEmpty ? 'ر.س' : currency.trim();
  final digits = value % 1 == 0 ? 0 : 2;
  final raw = value.toStringAsFixed(digits);
  final parts = raw.split('.');
  final digitsOnly = parts.first;
  final buffer = StringBuffer();
  for (var i = 0; i < digitsOnly.length; i++) {
    if (i > 0 && (digitsOnly.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digitsOnly[i]);
  }
  if (parts.length > 1) buffer.write('.${parts[1]}');
  return '${buffer.toString()} $suffix';
}

String _date(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${local.year}/${two(local.month)}/${two(local.day)}  ${two(local.hour)}:${two(local.minute)}';
}
