import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import 'main_navigation.dart';

/// Routes users according to the current Supabase session.
/// A client-side session only establishes identity; it does not grant owner
/// privileges. Privileged actions must still be authorized by the backend.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<AuthState>? _subscription;
  bool _signedIn = false;

  @override
  void initState() {
    super.initState();
    if (SupabaseConfig.isConfigured) {
      final client = Supabase.instance.client;
      _signedIn = client.auth.currentSession != null;
      _subscription = client.auth.onAuthStateChange.listen((state) {
        if (mounted) {
          setState(() => _signedIn = state.session != null);
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.isConfigured) {
      return const _ConfigurationRequiredScreen();
    }
    return _signedIn ? const MainNavigation() : const AuthScreen();
  }
}

class _ConfigurationRequiredScreen extends StatelessWidget {
  const _ConfigurationRequiredScreen();

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 48),
                SizedBox(height: 16),
                Text('يلزم إعداد اتصال Supabase',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  'شغّل التطبيق باستخدام SUPABASE_URL وSUPABASE_ANON_KEY. '
                  'لا تضع مفتاح service_role داخل تطبيق Flutter.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _AuthMode { signIn, signUp, recovery }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  _AuthMode _mode = _AuthMode.signIn;
  bool _busy = false;
  bool _hidePassword = true;
  String? _message;
  bool _messageIsError = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String get _title => switch (_mode) {
        _AuthMode.signIn => 'تسجيل الدخول',
        _AuthMode.signUp => 'إنشاء حساب',
        _AuthMode.recovery => 'استعادة كلمة المرور',
      };

  void _setMode(_AuthMode mode) {
    setState(() {
      _mode = mode;
      _message = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _message = null;
    });

    try {
      final auth = Supabase.instance.client.auth;
      final email = _email.text.trim();
      switch (_mode) {
        case _AuthMode.signIn:
          await auth.signInWithPassword(
            email: email,
            password: _password.text,
          );
          // AuthGate switches to the app when Supabase emits the new session.
          break;
        case _AuthMode.signUp:
          final response = await auth.signUp(
            email: email,
            password: _password.text,
          );
          if (response.session == null && mounted) {
            setState(() {
              _message = 'تم إرسال طلب التسجيل إن كان البريد مقبولًا. '
                  'تحقق من بريدك لتأكيد الحساب قبل تسجيل الدخول.';
              _messageIsError = false;
            });
          }
          break;
        case _AuthMode.recovery:
          await auth.resetPasswordForEmail(email);
          if (mounted) {
            setState(() {
              _message = 'إذا كان البريد مسجلًا، فستصلك رسالة لاستعادة كلمة المرور.';
              _messageIsError = false;
            });
          }
          break;
      }
    } on AuthException catch (error) {
      if (mounted) {
        setState(() {
          _message = error.message;
          _messageIsError = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _message = 'تعذر إكمال العملية. تحقق من الاتصال والإعدادات ثم حاول مجددًا.';
          _messageIsError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recovery = _mode == _AuthMode.recovery;
    final signingUp = _mode == _AuthMode.signUp;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(Icons.auto_awesome, size: 52),
                          const SizedBox(height: 12),
                          Text('TOFAN AI',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(height: 8),
                          Text(_title,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                              labelText: 'البريد الإلكتروني',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty || !email.contains('@')) {
                                return 'أدخل بريدًا إلكترونيًا صحيحًا';
                              }
                              return null;
                            },
                          ),
                          if (!recovery) ...[
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _password,
                              obscureText: _hidePassword,
                              autofillHints: [
                                signingUp
                                    ? AutofillHints.newPassword
                                    : AutofillHints.password,
                              ],
                              decoration: InputDecoration(
                                labelText: 'كلمة المرور',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(
                                      () => _hidePassword = !_hidePassword),
                                  icon: Icon(_hidePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined),
                                ),
                              ),
                              validator: (value) {
                                final password = value ?? '';
                                if (password.isEmpty) return 'أدخل كلمة المرور';
                                if (signingUp && password.length < 8) {
                                  return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                                }
                                return null;
                              },
                            ),
                          ],
                          if (_message != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              _message!,
                              style: TextStyle(
                                color: _messageIsError
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _busy ? null : _submit,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: _busy
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text(_title),
                            ),
                          ),
                          if (_mode == _AuthMode.signIn) ...[
                            TextButton(
                              onPressed: _busy
                                  ? null
                                  : () => _setMode(_AuthMode.recovery),
                              child: const Text('نسيت كلمة المرور؟'),
                            ),
                            TextButton(
                              onPressed: _busy
                                  ? null
                                  : () => _setMode(_AuthMode.signUp),
                              child: const Text('ليس لديك حساب؟ أنشئ حسابًا'),
                            ),
                          ] else
                            TextButton(
                              onPressed: _busy
                                  ? null
                                  : () => _setMode(_AuthMode.signIn),
                              child: const Text('العودة إلى تسجيل الدخول'),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            'إنشاء الحساب لا يمنح صلاحية المالك. '
                            'تُحدد الصلاحيات الحساسة من جهة الخادم فقط.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
