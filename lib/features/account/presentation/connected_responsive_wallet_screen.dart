import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../data/account_repository.dart';

class ConnectedResponsiveWalletScreen extends StatelessWidget {
  const ConnectedResponsiveWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AccountRepository(AppScope.of(context).client);
    return Scaffold(
      appBar: const MazraaAppBar(title: 'المحفظة'),
      body: FutureBuilder<_WalletViewData>(
        future: _load(repository),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? _WalletViewData.reference();
          return AppPage(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BalanceCard(data: data),
                const SizedBox(height: 14),
                _MonthlySummary(data: data),
                const SizedBox(height: 18),
                const SectionHeader(
                  title: 'إجراءات سريعة',
                  icon: Icons.bolt_rounded,
                ),
                const SizedBox(height: 8),
                _QuickActions(hasServerData: !data.referenceMode),
                const SizedBox(height: 20),
                const SectionHeader(
                  title: 'أحدث العمليات',
                  icon: Icons.schedule_rounded,
                ),
                const SizedBox(height: 8),
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
                          padding: const EdgeInsets.only(bottom: 9),
                          child: _TransactionCard(
                            item: item,
                            currency: data.wallet.currency,
                          ),
                        ),
                      ),
                const SizedBox(height: 4),
                FilledButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/wallet-transactions'),
                  icon: const Icon(Icons.format_list_bulleted_rounded),
                  label: const Text('عرض كل العمليات'),
                ),
                if (snapshot.hasError) ...[
                  const SizedBox(height: 10),
                  Text(
                    'تُعرض بيانات مرجعية مؤقتة لأن بيانات المحفظة من الخادم غير متاحة حاليًا.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<_WalletViewData> _load(AccountRepository repository) async {
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

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.data});

  final _WalletViewData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.forestDark, AppColors.forest],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: .18),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الرصيد المتاح',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        _money(data.wallet.balance, data.wallet.currency),
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 31,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8EC),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.forestDark,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _WalletPrimaryAction(
                  label: 'شحن المحفظة',
                  icon: Icons.add_card_rounded,
                  backgroundColor: AppColors.forestDark,
                  onTap: () => Navigator.pushNamed(context, '/wallet-topup'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _WalletPrimaryAction(
                  label: 'تحويل أو استخدام',
                  icon: Icons.swap_horiz_rounded,
                  backgroundColor: AppColors.terracotta,
                  onTap: () => Navigator.pushNamed(context, '/payment-methods'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletPrimaryAction extends StatelessWidget {
  const _WalletPrimaryAction({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 21),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
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
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_month_rounded, color: AppColors.forest),
              SizedBox(width: 7),
              Text(
                'ملخص هذا الشهر',
                style: TextStyle(
                  color: AppColors.forestDark,
                  fontWeight: FontWeight.w800,
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
            radius: 20,
            backgroundColor: color.withValues(alpha: .12),
            child: Icon(icon, color: color, size: 21),
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
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.hasServerData});

  final bool hasServerData;

  @override
  Widget build(BuildContext context) {
    final actions = <({IconData icon, String label, VoidCallback onTap})>[
      (
        icon: Icons.add_card_rounded,
        label: 'شحن المحفظة',
        onTap: () => Navigator.pushNamed(context, '/wallet-topup'),
      ),
      (
        icon: Icons.swap_horiz_rounded,
        label: 'تحويل الأموال',
        onTap: () => Navigator.pushNamed(context, '/payment-methods'),
      ),
      (
        icon: Icons.receipt_long_outlined,
        label: 'سجل المعاملات',
        onTap: () => Navigator.pushNamed(context, '/wallet-transactions'),
      ),
      (
        icon: Icons.shield_outlined,
        label: 'إعدادات الأمان',
        onTap: () => Navigator.pushNamed(context, '/settings'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 24) / 4;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              SizedBox(
                width: itemWidth,
                child: _QuickActionCard(
                  icon: actions[i].icon,
                  label: actions[i].label,
                  onTap: actions[i].onTap,
                ),
              ),
            ],
          ],
        );
      },
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
  Widget build(BuildContext context) => AppSurfaceCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 13),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.forestDark, size: 27),
                const SizedBox(height: 7),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
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
    final color = credit ? AppColors.forest : AppColors.terracotta;
    final title = item.description.trim().isEmpty
        ? (credit ? 'إضافة إلى المحفظة' : 'عملية دفع')
        : item.description.trim();
    return AppSurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              credit ? Icons.account_balance_wallet_rounded : Icons.payments_rounded,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                if (item.createdAt != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    _date(item.createdAt!),
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${credit ? '+' : '-'}${_money(item.amount.abs(), currency)}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: credit
                      ? AppColors.forestSoft
                      : AppColors.terracottaSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'مكتمل',
                  style: TextStyle(
                    color: color,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletViewData {
  const _WalletViewData({
    required this.wallet,
    required this.transactions,
    this.referenceMode = false,
  });

  final WalletSummary wallet;
  final List<WalletTransactionData> transactions;
  final bool referenceMode;

  double get credits => transactions
      .where((item) => item.isCredit)
      .fold<double>(0, (sum, item) => sum + item.amount.abs());

  double get debits => transactions
      .where((item) => !item.isCredit)
      .fold<double>(0, (sum, item) => sum + item.amount.abs());

  factory _WalletViewData.reference() => _WalletViewData(
        referenceMode: true,
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
            createdAt: DateTime(2026, 5, 10, 14, 32),
          ),
          WalletTransactionData(
            id: -2,
            amount: 250,
            type: 2,
            description: 'حجز ضمان مزاد',
            referenceId: 'REF-250',
            createdAt: DateTime(2026, 5, 8, 10, 17),
          ),
          WalletTransactionData(
            id: -3,
            amount: 120,
            type: 1,
            description: 'استرداد طلب',
            referenceId: 'REF-120',
            createdAt: DateTime(2026, 5, 6, 9, 45),
          ),
        ],
      );
}

String _money(double value, String currency) {
  final suffix = currency.trim().isEmpty ? 'ر.س' : currency.trim();
  final digits = value % 1 == 0 ? 0 : 2;
  return '${value.toStringAsFixed(digits)} $suffix';
}

String _date(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${local.year}/${two(local.month)}/${two(local.day)}  ${two(local.hour)}:${two(local.minute)}';
}
