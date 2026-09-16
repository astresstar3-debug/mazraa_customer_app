import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../data/account_repository.dart';
import '../data/customer_service_repository.dart';

CustomerServiceRepository _serviceRepo(BuildContext context) =>
    CustomerServiceRepository(AppScope.of(context).client);

class ConnectedOrdersScreen extends StatelessWidget {
  const ConnectedOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final orders = app.orders;
    return Scaffold(
      appBar: const MazraaAppBar(title: 'طلباتي'),
      body: orders.isEmpty
          ? const ResultStateView(
              kind: ResultKind.empty,
              title: 'لا توجد طلبات',
              message: 'ستظهر طلباتك هنا بعد إتمام أول عملية شراء.',
            )
          : AppPage(
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
                  ...orders.map((order) => Padding(
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
                                  Text('#${order.id}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge),
                                ],
                              ),
                              const SizedBox(height: 9),
                              if (order.products.isNotEmpty)
                                SizedBox(
                                  height: 86,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: order.products.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(width: 7),
                                    itemBuilder: (_, index) => ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        order.products[index].image,
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
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ConnectedOrderDetailsScreen(
                                          orderId: int.parse(order.id),
                                        ),
                                      ),
                                    ),
                                    child: Text(order.status == 'مكتمل'
                                        ? 'عرض التفاصيل'
                                        : 'تفاصيل الطلب'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
    );
  }
}

class ConnectedOrderDetailsScreen extends StatelessWidget {
  const ConnectedOrderDetailsScreen({super.key, required this.orderId});
  final int orderId;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'تفاصيل الطلب'),
        body: FutureBuilder<List<dynamic>>(
          future: Future.wait<dynamic>([
            _serviceRepo(context).fetchOrder(orderId),
            AccountRepository(AppScope.of(context).client).fetchAddresses(),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || snapshot.data == null) {
              return const ResultStateView(
                kind: ResultKind.error,
                title: 'تعذر تحميل الطلب',
                message: 'تعذر قراءة تفاصيل الطلب من الخادم.',
              );
            }
            final order = snapshot.data![0] as CustomerOrderData;
            final addresses = snapshot.data![1] as List<AccountAddress>;
            AccountAddress? address;
            for (final item in addresses) {
              if (item.id == order.addressId) {
                address = item;
                break;
              }
            }
            return AppPage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text('#${order.id}',
                          style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      StatusPill(
                        label: _statusLabel(order.status),
                        color: _statusColor(order.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const SectionHeader(
                      title: 'المنتجات', icon: Icons.eco_rounded),
                  AppSurfaceCard(
                    child: Column(
                      children: order.items
                          .map((item) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  backgroundColor: AppColors.forestSoft,
                                  child: Icon(Icons.inventory_2_outlined,
                                      color: AppColors.forest),
                                ),
                                title: Text(item.productName.isEmpty
                                    ? 'منتج #${item.variantId}'
                                    : item.productName),
                                subtitle: Text('الكمية ${item.quantity}'),
                                trailing: Text(formatPrice(item.price)),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SettingsTile(
                    icon: Icons.location_on_outlined,
                    title: 'عنوان التوصيل',
                    subtitle: address?.label.isNotEmpty == true
                        ? address!.label
                        : 'العنوان رقم ${order.addressId}',
                  ),
                  const SizedBox(height: 8),
                  AppSurfaceCard(
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long_outlined,
                            color: AppColors.forest),
                        const SizedBox(width: 10),
                        const Text('إجمالي الطلب'),
                        const Spacer(),
                        Text(formatPrice(order.totalPrice),
                            style:
                                Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (!_isFinal(order.status))
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ConnectedTrackOrderScreen(
                                    orderId: order.id),
                              ),
                            ),
                            child: const Text('تتبع الطلب'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ConnectedCancelOrderScreen(
                                    orderId: order.id),
                              ),
                            ),
                            child: const Text('طلب إلغاء'),
                          ),
                        ),
                      ],
                    ),
                  if (_isDelivered(order.status)) ...[
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConnectedReturnRequestScreen(
                              orderId: order.id),
                        ),
                      ),
                      child: const Text('طلب إرجاع'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConnectedRateOrderScreen(
                              orderId: order.id),
                        ),
                      ),
                      child: const Text('تقييم الطلب'),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      );
}

class ConnectedTrackOrderScreen extends StatelessWidget {
  const ConnectedTrackOrderScreen({super.key, required this.orderId});
  final int orderId;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'تتبع الطلب'),
        body: FutureBuilder<OrderTrackingData>(
          future: _serviceRepo(context).fetchTracking(orderId),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || snapshot.data == null) {
              return const ResultStateView(
                kind: ResultKind.empty,
                title: 'لم يبدأ الشحن بعد',
                message: 'سيظهر تتبع السائق والموقع هنا عند إنشاء شحنة للطلب.',
              );
            }
            final data = snapshot.data!;
            return AppPage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSurfaceCard(
                    color: AppColors.forestSoft,
                    child: ListTile(
                      leading: const Icon(Icons.local_shipping_rounded,
                          color: AppColors.forest),
                      title: Text(data.shipmentNumber.isEmpty
                          ? 'شحنة الطلب #$orderId'
                          : data.shipmentNumber),
                      subtitle: Text(_statusLabel(data.status)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (data.driverName.isNotEmpty)
                    SettingsTile(
                      icon: Icons.person_pin_circle_outlined,
                      title: data.driverName,
                      subtitle: data.driverPhone,
                    ),
                  const SizedBox(height: 10),
                  AppSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('آخر موقع مسجل',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 7),
                        Text(data.latitude == null || data.longitude == null
                            ? 'لا يوجد موقع مسجل حتى الآن.'
                            : '${data.latitude}, ${data.longitude}'),
                        if (data.recordedAt != null)
                          Text(_date(data.recordedAt!),
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
}

class ConnectedCancelOrderScreen extends StatefulWidget {
  const ConnectedCancelOrderScreen({super.key, required this.orderId});
  final int orderId;

  @override
  State<ConnectedCancelOrderScreen> createState() =>
      _ConnectedCancelOrderScreenState();
}

class _ConnectedCancelOrderScreenState
    extends State<ConnectedCancelOrderScreen> {
  int reason = 0;
  bool _submitting = false;
  String? _error;

  Future<void> _cancel() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await _serviceRepo(context).cancelOrder(widget.orderId);
      await AppScope.of(context).refreshOrders();
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إلغاء الطلب بنجاح')),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is ApiException
            ? error.message
            : 'تعذر إلغاء الطلب.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'إلغاء الطلب'),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.delete_outline_rounded,
                  color: AppColors.terracotta, size: 72),
              Text('هل تريد إلغاء الطلب؟',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge),
              Text('#${widget.orderId}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 14),
              const SectionHeader(
                  title: 'سبب الإلغاء', icon: Icons.info_outline_rounded),
              ...['تغيير رأيي', 'طلبت بالخطأ', 'تأخر التوصيل', 'سبب آخر']
                  .asMap()
                  .entries
                  .map((entry) => ListTile(
                        onTap: () => setState(() => reason = entry.key),
                        leading: Icon(
                          reason == entry.key
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: reason == entry.key
                              ? AppColors.forest
                              : AppColors.muted,
                        ),
                        title: Text(entry.value),
                      )),
              const AppSurfaceCard(
                color: AppColors.forestSoft,
                child: Text(
                  'سيحدد الخادم إمكانية الإلغاء وحالة أي مبلغ مسترد وفق حالة الطلب والدفع.',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: AppColors.error)),
              ],
              const SizedBox(height: 18),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: _submitting ? null : _cancel,
                child: Text(_submitting ? 'جاري الإلغاء...' : 'تأكيد الإلغاء'),
              ),
            ],
          ),
        ),
      );
}

class ConnectedRateOrderScreen extends StatefulWidget {
  const ConnectedRateOrderScreen({super.key, required this.orderId});
  final int orderId;

  @override
  State<ConnectedRateOrderScreen> createState() => _ConnectedRateOrderScreenState();
}

class _ConnectedRateOrderScreenState extends State<ConnectedRateOrderScreen> {
  int storeRating = 5;
  int deliveryRating = 5;
  final _comment = TextEditingController();
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _serviceRepo(context).rateOrder(
        orderId: widget.orderId,
        deliveryRating: deliveryRating.toDouble(),
        storeRating: storeRating.toDouble(),
        comment: _comment.text,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('شكرًا، تم إرسال تقييمك')),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is ApiException
            ? error.message
            : 'تعذر إرسال التقييم.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'تقييم الطلب'),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StatusPill(label: 'تم التوصيل', color: AppColors.success),
              const SizedBox(height: 12),
              Text('كيف كانت تجربتك؟',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: AppColors.forest)),
              const SizedBox(height: 14),
              _RatingRow(
                label: 'المتجر',
                value: storeRating,
                onChanged: (value) => setState(() => storeRating = value),
              ),
              const SizedBox(height: 9),
              _RatingRow(
                label: 'التوصيل',
                value: deliveryRating,
                onChanged: (value) => setState(() => deliveryRating = value),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _comment,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'شاركنا رأيك'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: AppColors.error)),
              ],
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.send_rounded),
                label: Text(_saving ? 'جاري الإرسال...' : 'إرسال التقييم'),
              ),
            ],
          ),
        ),
      );
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.label, required this.value, required this.onChanged});
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
        child: Row(
          children: [
            Text(label),
            const Spacer(),
            ...List.generate(
              5,
              (index) => IconButton(
                onPressed: () => onChanged(index + 1),
                icon: Icon(
                  index < value ? Icons.star_rounded : Icons.star_border_rounded,
                  color: AppColors.forest,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      );
}

class ConnectedReturnsScreen extends StatelessWidget {
  const ConnectedReturnsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'المرتجعات والاسترداد'),
        body: FutureBuilder<List<CustomerReturnData>>(
          future: _serviceRepo(context).fetchReturns(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const ResultStateView(
                kind: ResultKind.error,
                title: 'تعذر تحميل المرتجعات',
                message: 'تعذر قراءة طلبات الإرجاع من الخادم.',
              );
            }
            final items = snapshot.data ?? const <CustomerReturnData>[];
            return AppPage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (items.isEmpty)
                    const ResultStateView(
                      kind: ResultKind.empty,
                      title: 'لا توجد طلبات إرجاع',
                      message: 'يمكن إنشاء طلب إرجاع من تفاصيل طلب تم تسليمه.',
                    )
                  else
                    ...items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: AppSurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    StatusPill(label: _returnStatus(item.status)),
                                    const Spacer(),
                                    Text('#${item.id}'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('الطلب #${item.orderId}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                if (item.reason.isNotEmpty) Text(item.reason),
                                const Divider(),
                                Row(
                                  children: [
                                    const Text('مبلغ الاسترداد'),
                                    const Spacer(),
                                    Text(formatPrice(item.refundAmount),
                                        style: const TextStyle(
                                            color: AppColors.terracotta,
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                ],
              ),
            );
          },
        ),
      );
}

class ConnectedReturnRequestScreen extends StatefulWidget {
  const ConnectedReturnRequestScreen({super.key, required this.orderId});
  final int orderId;

  @override
  State<ConnectedReturnRequestScreen> createState() =>
      _ConnectedReturnRequestScreenState();
}

class _ConnectedReturnRequestScreenState
    extends State<ConnectedReturnRequestScreen> {
  String reason = 'المنتج غير مطابق';
  bool _saving = false;
  String? _error;

  Future<void> _submit(CustomerOrderData order) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _serviceRepo(context).createReturn(
        orderId: order.id,
        reason: reason,
        items: order.items,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال طلب الإرجاع بنجاح')),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is ApiException
            ? error.message
            : 'تعذر إرسال طلب الإرجاع.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'طلب إرجاع'),
        body: FutureBuilder<CustomerOrderData>(
          future: _serviceRepo(context).fetchOrder(widget.orderId),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || snapshot.data == null) {
              return const ResultStateView(
                kind: ResultKind.error,
                title: 'تعذر تحميل الطلب',
                message: 'تعذر تجهيز بيانات الإرجاع.',
              );
            }
            final order = snapshot.data!;
            return AppPage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSurfaceCard(
                    child: ListTile(
                      leading: const Icon(Icons.receipt_long_outlined),
                      title: Text('رقم الطلب #${order.id}'),
                      subtitle: Text('${order.items.length} عناصر'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...order.items.map((item) => AppSurfaceCard(
                        child: ListTile(
                          title: Text(item.productName),
                          subtitle: Text('الكمية ${item.quantity}'),
                          trailing: Text(formatPrice(item.price * item.quantity)),
                        ),
                      )),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: reason,
                    decoration: const InputDecoration(labelText: 'سبب الإرجاع'),
                    items: const [
                      'المنتج غير مطابق',
                      'تالف عند الاستلام',
                      'المنتج غير مناسب',
                      'سبب آخر',
                    ]
                        .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => reason = value ?? reason),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: AppColors.error)),
                  ],
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _saving ? null : () => _submit(order),
                    icon: const Icon(Icons.send_rounded),
                    label: Text(_saving ? 'جاري الإرسال...' : 'إرسال الطلب'),
                  ),
                ],
              ),
            );
          },
        ),
      );
}

class ConnectedSupportScreen extends StatelessWidget {
  const ConnectedSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = _serviceRepo(context);
    return Scaffold(
      appBar: const MazraaAppBar(title: 'الدعم والمساعدة'),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait<dynamic>([
          repository.fetchFaqs(),
          repository.fetchTickets(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final faqs = snapshot.hasData
              ? snapshot.data![0] as List<SupportFaqData>
              : const <SupportFaqData>[];
          final tickets = snapshot.hasData
              ? snapshot.data![1] as List<SupportTicketData>
              : const <SupportTicketData>[];
          return AppPage(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ConnectedSupportTicketScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.confirmation_number_outlined),
                        label: const Text('فتح تذكرة'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            final id = await repository.startSupportChat();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('تم فتح محادثة الدعم #$id')),
                            );
                          } on Object catch (error) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error is ApiException
                                  ? error.message
                                  : 'تعذر بدء المحادثة.')),
                            );
                          }
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded),
                        label: const Text('محادثة الدعم'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const SectionHeader(
                    title: 'تذاكر الدعم', icon: Icons.history_rounded),
                if (tickets.isEmpty)
                  const AppSurfaceCard(child: Text('لا توجد تذاكر دعم مفتوحة.'))
                else
                  ...tickets.take(5).map((ticket) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppSurfaceCard(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.support_agent_rounded,
                                color: AppColors.forest),
                            title: Text(ticket.subject),
                            subtitle: Text([
                              ticket.number,
                              if (ticket.lastMessage.isNotEmpty)
                                ticket.lastMessage,
                            ].join('\n')),
                            trailing: StatusPill(label: ticket.status),
                          ),
                        ),
                      )),
                const SizedBox(height: 16),
                const SectionHeader(
                    title: 'الأسئلة الشائعة', icon: Icons.help_outline_rounded),
                if (faqs.isEmpty)
                  const AppSurfaceCard(
                      child: Text('لا توجد أسئلة شائعة منشورة حاليًا.'))
                else
                  ...faqs.map((faq) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppSurfaceCard(
                          padding: EdgeInsets.zero,
                          child: ExpansionTile(
                            title: Text(faq.question),
                            subtitle: faq.category.isEmpty
                                ? null
                                : Text(faq.category),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(faq.answer),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ConnectedSupportTicketScreen extends StatefulWidget {
  const ConnectedSupportTicketScreen({super.key});

  @override
  State<ConnectedSupportTicketScreen> createState() =>
      _ConnectedSupportTicketScreenState();
}

class _ConnectedSupportTicketScreenState
    extends State<ConnectedSupportTicketScreen> {
  final _subject = TextEditingController();
  final _message = TextEditingController();
  String priority = 'normal';
  bool _saving = false;
  String? _error;

  Future<void> _submit() async {
    if (_subject.text.trim().isEmpty || _message.text.trim().isEmpty) {
      setState(() => _error = 'أدخل عنوان المشكلة وتفاصيلها.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final result = await _serviceRepo(context).createTicket(
        subject: _subject.text,
        message: _message.text,
        priority: priority,
      );
      if (!mounted) return;
      final number = '${jsonValue(result, 'number') ?? jsonValue(result, 'id') ?? ''}';
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(number.isEmpty
            ? 'تم إرسال تذكرة الدعم'
            : 'تم إرسال التذكرة $number')),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is ApiException
            ? error.message
            : 'تعذر إرسال التذكرة.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'فتح تذكرة دعم'),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: AppColors.forestSoft,
                  child: Icon(Icons.support_agent_rounded,
                      size: 58, color: AppColors.forest),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _subject,
                decoration: const InputDecoration(
                  labelText: 'عنوان المشكلة',
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
              ),
              const SizedBox(height: 11),
              DropdownButtonFormField<String>(
                initialValue: priority,
                decoration: const InputDecoration(labelText: 'الأولوية'),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('منخفضة')),
                  DropdownMenuItem(value: 'normal', child: Text('عادية')),
                  DropdownMenuItem(value: 'high', child: Text('مرتفعة')),
                  DropdownMenuItem(value: 'urgent', child: Text('عاجلة')),
                ],
                onChanged: (value) => setState(() => priority = value ?? priority),
              ),
              const SizedBox(height: 11),
              TextField(
                controller: _message,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'اشرح المشكلة بالتفصيل',
                  prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: AppColors.error)),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: const Icon(Icons.send_rounded),
                label: Text(_saving ? 'جاري الإرسال...' : 'إرسال التذكرة'),
              ),
            ],
          ),
        ),
      );
}

bool _isDelivered(String status) =>
    status.toLowerCase() == 'delivered' || status == 'مكتمل';

bool _isFinal(String status) {
  final value = status.toLowerCase();
  return value == 'cancelled' || value == 'canceled' || value == 'refunded';
}

String _statusLabel(String status) {
  final value = status.toLowerCase();
  if (value.contains('deliver')) return 'تم التسليم';
  if (value.contains('ship') || value.contains('outfordelivery')) {
    return 'قيد التوصيل';
  }
  if (value.contains('cancel')) return 'ملغي';
  if (value.contains('refund')) return 'مسترد';
  if (value.contains('paid')) return 'تم الدفع';
  if (value.contains('process')) return 'قيد التجهيز';
  return status.isEmpty ? 'قيد التجهيز' : status;
}

Color _statusColor(String status) {
  final value = status.toLowerCase();
  if (value.contains('deliver') || value.contains('paid')) {
    return AppColors.success;
  }
  if (value.contains('cancel') || value.contains('refund')) {
    return AppColors.terracotta;
  }
  return AppColors.warning;
}

String _returnStatus(String value) => switch (value.toLowerCase()) {
      'requested' => 'تم الإرسال',
      'approved' => 'تمت الموافقة',
      'received' => 'تم الاستلام',
      'refunded' => 'تم الاسترداد',
      'rejected' => 'مرفوض',
      'cancelled' => 'ملغي',
      _ => value,
    };

String _date(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${local.year}/${two(local.month)}/${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}
