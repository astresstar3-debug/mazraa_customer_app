import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';

class ConnectedPhoneVerificationScreen extends StatefulWidget {
  const ConnectedPhoneVerificationScreen({super.key, this.initialPhone});
  final String? initialPhone;

  @override
  State<ConnectedPhoneVerificationScreen> createState() =>
      _ConnectedPhoneVerificationScreenState();
}

class _ConnectedPhoneVerificationScreenState
    extends State<ConnectedPhoneVerificationScreen> {
  late final TextEditingController _phone;
  final _code = TextEditingController();
  bool _sending = false;
  bool _verifying = false;
  bool _sent = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController(text: widget.initialPhone ?? '');
  }

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_phone.text.trim().isEmpty) {
      setState(() => _error = 'أدخل رقم الهاتف أولًا.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await AppScope.of(context).authRepository.requestPhoneOtp(_phone.text);
      if (mounted) setState(() => _sent = true);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is ApiException
            ? error.message
            : 'تعذر إرسال رمز التحقق.');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _verify() async {
    if (_code.text.trim().isEmpty) {
      setState(() => _error = 'أدخل رمز التحقق.');
      return;
    }
    setState(() {
      _verifying = true;
      _error = null;
    });
    final app = AppScope.of(context);
    try {
      app.session = await app.authRepository.verifyPhoneOtp(
        phone: _phone.text,
        code: _code.text,
      );
      await Future.wait<void>([
        app.refreshCart(),
        app.refreshWishlist(),
        app.refreshOrders(),
      ]);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/location-permission',
        (_) => false,
      );
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is ApiException
            ? error.message
            : 'رمز التحقق غير صالح أو تعذر التحقق.');
      }
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'التحقق من الهاتف'),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.phonelink_lock_rounded,
                  size: 100, color: AppColors.forest),
              const SizedBox(height: 16),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _sending ? null : _send,
                icon: const Icon(Icons.sms_outlined),
                label: Text(_sending
                    ? 'جاري الإرسال...'
                    : (_sent ? 'إعادة إرسال الرمز' : 'إرسال رمز التحقق')),
              ),
              if (_sent) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _code,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'رمز التحقق',
                    prefixIcon: Icon(Icons.password_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _verifying ? null : _verify,
                  icon: const Icon(Icons.verified_outlined),
                  label: Text(_verifying ? 'جاري التحقق...' : 'تحقق ومتابعة'),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: AppColors.error)),
              ],
            ],
          ),
        ),
      );
}

class ConnectedCouponScreen extends StatefulWidget {
  const ConnectedCouponScreen({super.key});

  @override
  State<ConnectedCouponScreen> createState() => _ConnectedCouponScreenState();
}

class _ConnectedCouponScreenState extends State<ConnectedCouponScreen> {
  final _code = TextEditingController();
  bool _loading = true;
  bool _applying = false;
  String? _error;
  List<Map<String, dynamic>> _coupons = const [];
  Map<String, dynamic>? _preview;
  int? _addressId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) _load();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final app = AppScope.of(context);
    try {
      final responses = await Future.wait<dynamic>([
        app.client.get('/api/Coupons'),
        if (app.isAuthenticated) app.client.get('/api/Addresses/my'),
      ]);
      final rawCoupons = responses[0];
      final coupons = rawCoupons is List
          ? rawCoupons.map((e) => jsonMap(e)).toList()
          : <Map<String, dynamic>>[];
      int? addressId;
      if (responses.length > 1 && responses[1] is List) {
        final addresses = responses[1] as List;
        if (addresses.isNotEmpty) {
          final first = jsonMap(addresses.first);
          addressId = _int(jsonValue(first, 'id'));
        }
      }
      if (mounted) {
        setState(() {
          _coupons = coupons;
          _addressId = addressId;
          _loading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = error is ApiException
              ? error.message
              : 'تعذر تحميل الكوبونات.';
        });
      }
    }
  }

  Future<void> _apply([String? value]) async {
    final app = AppScope.of(context);
    if (!app.isAuthenticated) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    final code = (value ?? _code.text).trim();
    if (code.isEmpty) {
      setState(() => _error = 'أدخل رمز الكوبون.');
      return;
    }
    if (_addressId == null) {
      setState(() => _error = 'أضف عنوان توصيل أولًا لتطبيق الكوبون.');
      return;
    }
    setState(() {
      _applying = true;
      _error = null;
      _preview = null;
      _code.text = code;
    });
    try {
      final response = jsonMap(await app.client.post(
        '/api/cart/apply-coupon',
        body: {
          'couponCode': code,
          'addressId': _addressId,
          'deliveryZoneId': null,
        },
      ));
      if (mounted) setState(() => _preview = response);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is ApiException
            ? error.message
            : 'تعذر تطبيق الكوبون.');
      }
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'الكوبونات'),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _code,
                decoration: const InputDecoration(
                  labelText: 'رمز الكوبون',
                  prefixIcon: Icon(Icons.discount_outlined),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _applying ? null : _apply,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text(_applying ? 'جاري التحقق...' : 'تطبيق والتحقق من الكوبون'),
              ),
              if (_loading) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ],
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: AppColors.error)),
              ],
              if (_preview != null) ...[
                const SizedBox(height: 12),
                AppSurfaceCard(
                  color: AppColors.forestSoft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('تم قبول الكوبون من الخادم',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      ..._preview!.entries
                          .where((e) => e.value is num || e.value is String)
                          .take(8)
                          .map((e) => Text('${e.key}: ${e.value}')),
                    ],
                  ),
                ),
              ],
              if (_coupons.isNotEmpty) ...[
                const SizedBox(height: 16),
                const SectionHeader(
                    title: 'الكوبونات المتاحة', icon: Icons.local_offer_outlined),
                ..._coupons.map((coupon) {
                  final code = '${jsonValue(coupon, 'code') ?? ''}';
                  final name = '${jsonValue(coupon, 'name') ?? code}';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppSurfaceCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.confirmation_number_outlined),
                        title: Text(name.isEmpty ? 'كوبون' : name),
                        subtitle: code.isEmpty ? null : Text(code),
                        trailing: TextButton(
                          onPressed: code.isEmpty ? null : () => _apply(code),
                          child: const Text('تطبيق'),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      );

  static int? _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }
}

class ConnectedInvoiceScreen extends StatefulWidget {
  const ConnectedInvoiceScreen({super.key, required this.orderId});
  final int orderId;

  @override
  State<ConnectedInvoiceScreen> createState() => _ConnectedInvoiceScreenState();
}

class _ConnectedInvoiceScreenState extends State<ConnectedInvoiceScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _invoice;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading && _invoice == null && _error == null) _load();
  }

  Future<void> _load() async {
    try {
      final value = jsonMap(await AppScope.of(context)
          .client
          .get('/api/checkout/orders/${widget.orderId}/invoice'));
      if (mounted) setState(() => _invoice = value);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is ApiException
            ? error.message
            : 'تعذر تحميل الفاتورة.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'الفاتورة'),
        body: AppPage(
          child: _loading
              ? const LinearProgressIndicator()
              : _error != null
                  ? ResultStateView(
                      kind: ResultKind.error,
                      title: 'الفاتورة غير متاحة',
                      message: _error!,
                      primaryLabel: 'إعادة المحاولة',
                      onPrimary: () {
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                        _load();
                      },
                    )
                  : AppSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _invoice!.entries
                            .where((e) => e.value == null ||
                                e.value is String ||
                                e.value is num ||
                                e.value is bool)
                            .map((e) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(_label(e.key))),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Text('${e.value ?? '-'}',
                                            textAlign: TextAlign.end,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700)),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
        ),
      );

  static String _label(String key) {
    const labels = {
      'id': 'رقم الفاتورة',
      'documentNumber': 'رقم المستند',
      'orderId': 'رقم الطلب',
      'totalAmount': 'الإجمالي',
      'currency': 'العملة',
      'isPosted': 'مرحّلة',
      'postedAt': 'تاريخ الترحيل',
      'paymentMethod': 'طريقة الدفع',
      'paidAmount': 'المدفوع',
      'remainingAmount': 'المتبقي',
    };
    return labels[key] ?? key;
  }
}

class ConnectedLegalScreen extends StatefulWidget {
  const ConnectedLegalScreen({super.key});

  @override
  State<ConnectedLegalScreen> createState() => _ConnectedLegalScreenState();
}

class _ConnectedLegalScreenState extends State<ConnectedLegalScreen> {
  bool _loading = true;
  String? _error;
  String _terms = '';
  String _privacy = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading && _terms.isEmpty && _privacy.isEmpty && _error == null) _load();
  }

  Future<void> _load() async {
    try {
      final values = await Future.wait<dynamic>([
        AppScope.of(context).client.get('/api/content/terms'),
        AppScope.of(context).client.get('/api/content/privacy'),
      ]);
      if (mounted) {
        setState(() {
          _terms = '${jsonValue(jsonMap(values[0]), 'content') ?? ''}';
          _privacy = '${jsonValue(jsonMap(values[1]), 'content') ?? ''}';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is ApiException
            ? error.message
            : 'تعذر تحميل المحتوى القانوني.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: const MazraaAppBar(
            title: 'الشروط والخصوصية',
            bottom: TabBar(
              tabs: [
                Tab(text: 'الشروط'),
                Tab(text: 'الخصوصية'),
              ],
            ),
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? ResultStateView(
                      kind: ResultKind.error,
                      title: 'تعذر تحميل المحتوى',
                      message: _error!,
                    )
                  : TabBarView(
                      children: [
                        _LegalBody(content: _terms),
                        _LegalBody(content: _privacy),
                      ],
                    ),
        ),
      );
}

class _LegalBody extends StatelessWidget {
  const _LegalBody({required this.content});
  final String content;

  @override
  Widget build(BuildContext context) => AppPage(
        child: AppSurfaceCard(
          child: SelectableText(
            content.trim().isEmpty
                ? 'لم يضف الخادم محتوى لهذه الصفحة بعد.'
                : content,
          ),
        ),
      );
}
