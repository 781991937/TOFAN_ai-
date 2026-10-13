import 'package:flutter/material.dart';

import '../security/tofan_passkey_service.dart';

class PasskeySecurityScreen extends StatefulWidget {
  const PasskeySecurityScreen({super.key});

  @override
  State<PasskeySecurityScreen> createState() => _PasskeySecurityScreenState();
}

class _PasskeySecurityScreenState extends State<PasskeySecurityScreen> {
  final TofanPasskeyService _service = TofanPasskeyService();
  bool _busy = false;
  bool _registeredThisSession = false;

  // Deliberately memory-only. Cleared after the screen closes; never persisted
  // or logged. No privileged app operation consumes this receipt yet.
  String? _ephemeralOwnerReceipt;

  @override
  void dispose() {
    _ephemeralOwnerReceipt = null;
    super.dispose();
  }

  Future<void> _run(Future<void> Function() operation, String success) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await operation();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success)),
      );
    } on Object catch (error) {
      if (!mounted) return;
      final message = error is TofanPasskeyException
          ? error.message
          : 'لم يكتمل الإجراء. تحقق من دعم الجهاز وإعدادات النطاق ثم أعد المحاولة.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _register() async {
    await _run(() async {
      await _service.registerPasskey();
      _registeredThisSession = true;
      if (mounted) setState(() {});
    }, 'تم تسجيل مفتاح المرور والتحقق منه خادميًا.');
  }

  Future<void> _verifyOwner() async {
    await _run(() async {
      final receipt = await _service.verifyOwnerStepUp();
      _ephemeralOwnerReceipt = receipt;
    }, 'نجح تحقق مفتاح المرور للحساب المالك. التصريح مؤقت ومحفوظ في الذاكرة فقط.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('مفتاح المرور والبصمة')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.fingerprint, size: 42, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      'حماية الحساب بمفتاح مرور',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'يستخدم الجهاز قفل الشاشة أو البصمة أو الوجه بحسب ما يدعمه. '
                      'لا يرسل التطبيق صورة البصمة أو قالب الوجه إلى TOFAN؛ '
                      'الخادم يتحقق من توقيع مفتاح المرور العام.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _busy ? null : _register,
              icon: const Icon(Icons.add_moderator_outlined),
              label: const Text('تسجيل مفتاح مرور لهذا الحساب'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _busy ? null : _verifyOwner,
              icon: const Icon(Icons.verified_user_outlined),
              label: const Text('التحقق بمفتاح المرور'),
            ),
            if (_busy) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_registeredThisSession) ...[
              const SizedBox(height: 12),
              const ListTile(
                leading: Icon(Icons.check_circle_outline),
                title: Text('تم التسجيل في هذه الجلسة'),
                subtitle: Text('أُرسل رد المصادقة إلى الخادم للتحقق؛ لا يعني ذلك اعتماد ملكية النظام.'),
              ),
            ],
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'مهم: هذه ميزة تحقق إضافي داخل جلسة مسجّل الدخول، وليست تسجيل دخول مستقلًا بالبصمة. '
                  'لن يحصل الحساب على صلاحية المالك بسبب تسجيل مفتاح المرور. '
                  'يلزم نشر الوظيفة وإعداد نطاق WebAuthn وملفات ربط Android/iOS، '
                  'كما أن إجراءات المالك الفعلية لم تُربط بعد باستهلاك التصريح المؤقت.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
