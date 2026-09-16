// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../data/account_repository.dart';

class ConnectedInvoiceScreen extends StatefulWidget {
  const ConnectedInvoiceScreen({super.key, required this.orderId});
  final int orderId;

  @override
  State<ConnectedInvoiceScreen> createState() => _ConnectedInvoiceScreenState();
}

class _ConnectedInvoiceScreenState extends State<ConnectedInvoiceScreen> {
  bool loading = true;
  String? error;
  Map<String, dynamic>? invoice;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loading && invoice == null && error == null) _load();
  }

  Future<void> _load() async {
    try {
      final data = jsonMap(await AppScope.of(context)
          .client
          .get('/api/checkout/orders/${widget.orderId}/invoice'));
      if (mounted) setState(() => invoice = data);
    } catch (e) {
      if (mounted) {
        setState(() => error = e is ApiException ? e.message : 'تعذر تحميل الفاتورة.');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'الفاتورة'),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? ResultStateView(
                    kind: ResultKind.error,
                    title: 'الفاتورة غير متاحة',
                    message: error!,
                    primaryLabel: 'إعادة المحاولة',
                    onPrimary: () {
                      setState(() {
                        loading = true;
                        error = null;
                      });
                      _load();
                    },
                  )
                : AppPage(
                    child: AppSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: invoice!.entries
                            .where((e) => e.value == null ||
                                e.value is String ||
                                e.value is num ||
                                e.value is bool)
                            .map((e) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 7),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(_label(e.key))),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Text(
                                          '${e.value ?? '-'}',
                                          textAlign: TextAlign.end,
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
      );

  String _label(String key) {
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
  bool loading = true;
  String? error;
  String terms = '';
  String privacy = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loading && terms.isEmpty && privacy.isEmpty && error == null) _load();
  }

  Future<void> _load() async {
    try {
      final client = AppScope.of(context).client;
      final values = await Future.wait<dynamic>([
        client.get('/api/content/terms'),
        client.get('/api/content/privacy'),
      ]);
      if (!mounted) return;
      setState(() {
        terms = '${jsonValue(jsonMap(values[0]), 'content') ?? ''}';
        privacy = '${jsonValue(jsonMap(values[1]), 'content') ?? ''}';
      });
    } catch (e) {
      if (mounted) {
        setState(() => error = e is ApiException ? e.message : 'تعذر تحميل المحتوى القانوني.');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'الشروط والخصوصية'),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? ResultStateView(
                    kind: ResultKind.error,
                    title: 'تعذر تحميل المحتوى',
                    message: error!,
                  )
                : AppPage(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SectionHeader(
                          title: 'الشروط والأحكام',
                          icon: Icons.gavel_outlined,
                        ),
                        AppSurfaceCard(
                          child: SelectableText(
                            terms.trim().isEmpty
                                ? 'لم يضف الخادم محتوى الشروط بعد.'
                                : terms,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const SectionHeader(
                          title: 'سياسة الخصوصية',
                          icon: Icons.privacy_tip_outlined,
                        ),
                        AppSurfaceCard(
                          child: SelectableText(
                            privacy.trim().isEmpty
                                ? 'لم يضف الخادم محتوى الخصوصية بعد.'
                                : privacy,
                          ),
                        ),
                      ],
                    ),
                  ),
      );
}

class ConnectedAvatarScreen extends StatefulWidget {
  const ConnectedAvatarScreen({super.key});

  @override
  State<ConnectedAvatarScreen> createState() => _ConnectedAvatarScreenState();
}

class _ConnectedAvatarScreenState extends State<ConnectedAvatarScreen> {
  final picker = ImagePicker();
  bool loading = true;
  bool uploading = false;
  String? error;
  UserProfileData? profile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loading && profile == null && error == null) _load();
  }

  Future<void> _load() async {
    try {
      final data = await AccountRepository(AppScope.of(context).client).fetchProfile();
      if (mounted) setState(() => profile = data);
    } catch (e) {
      if (mounted) {
        setState(() => error = e is ApiException ? e.message : 'تعذر تحميل صورة الحساب.');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _pickAndUpload() async {
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1600,
    );
    if (file == null) return;
    setState(() {
      uploading = true;
      error = null;
    });
    try {
      await AppScope.of(context).client.postMultipart(
        '/api/users/me/avatar',
        files: {'file': file.path},
      );
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث صورة الحساب بنجاح')),
      );
    } catch (e) {
      if (mounted) {
        setState(() => error = e is ApiException ? e.message : 'تعذر رفع الصورة.');
      }
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = ApiConfig.resolveMediaUrl(profile?.profileImageUrl);
    return Scaffold(
      appBar: const MazraaAppBar(title: 'صورة الحساب'),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : AppPage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: ClipOval(
                      child: image.isEmpty
                          ? const CircleAvatar(
                              radius: 72,
                              backgroundColor: AppColors.forestSoft,
                              child: Icon(Icons.person_rounded,
                                  size: 82, color: AppColors.forest),
                            )
                          : AppDataImage(
                              image,
                              width: 144,
                              height: 144,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: uploading ? null : _pickAndUpload,
                    icon: uploading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.photo_library_outlined),
                    label: Text(uploading ? 'جاري الرفع...' : 'اختيار صورة ورفعها'),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Text(error!, style: const TextStyle(color: AppColors.error)),
                  ],
                  const SizedBox(height: 12),
                  const Text(
                    'الحد الأقصى الذي يقبله الخادم للصورة هو 5 ميجابايت.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
    );
  }
}
