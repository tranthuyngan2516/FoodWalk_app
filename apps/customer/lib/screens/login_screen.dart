import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 600)); // giả lập gọi API
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đăng nhập demo: thành công')),
    );
    setState(() => _submitting = false);
    Navigator.of(context).pop(); // quay lại Home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // global builder đã xử lý tap-outside → unfocus
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, // kéo là ẩn bàn phím
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black.withOpacity(0.85),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailC,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Hãy nhập email' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passC,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Hãy nhập mật khẩu';
                        if (v.length < 6) return 'Tối thiểu 6 ký tự';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
