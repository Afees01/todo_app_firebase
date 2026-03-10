import 'package:flutter/material.dart';
import 'package:todo_app/controllers/auth_controller.dart';
import 'package:todo_app/views/widgets/app_widgets.dart';
import 'login_view.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView>
    with SingleTickerProviderStateMixin {
  final _formKey    = GlobalKey<FormState>();
  final _email      = TextEditingController();
  final _password   = TextEditingController();
  final _confirm    = TextEditingController();
  final _controller = AuthController();

  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim  = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _controller.signup(_email.text.trim(), _password.text);

      if (!mounted) return;
      setState(() => _isLoading = false);

      // ── Success feedback then navigate ──────────────────
      AppSnackBar.show(
        context,
        'Account created! Please sign in.',
        isSuccess: true,
      );

      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginView()));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.show(context, e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      // ── Back button ──────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: AppIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
          bgColor: AppColors.card,
        ),
        leadingWidth: 64,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Headline ───────────────────────────
                    const Text('Create\naccount.', style: AppTextStyles.headline),
                    const SizedBox(height: 8),
                    const Text(
                      'Join us and start managing your tasks.',
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Form card ──────────────────────────
                    AppCard(
                      child: Column(
                        children: [
                          // Email
                          AppTextField(
                            controller: _email,
                            label: 'Email address',
                            hint: 'you@example.com',
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Email is required';
                              if (!RegExp(r'^[\w.-]+@[\w-]+\.[a-zA-Z]{2,}$')
                                  .hasMatch(v.trim()))
                                return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Password
                          AppTextField(
                            controller: _password,
                            label: 'Password',
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Password is required';
                              if (v.length < 6)
                                return 'Minimum 6 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Confirm password
                          AppTextField(
                            controller: _confirm,
                            label: 'Confirm password',
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Please confirm your password';
                              if (v != _password.text)
                                return 'Passwords do not match';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Password strength hint ─────────────
                    _PasswordStrengthRow(password: _password),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Sign Up CTA ────────────────────────
                    AppPrimaryButton(
                      label: 'Create Account',
                      isLoading: _isLoading,
                      onPressed: _handleSignup,
                      icon: Icons.person_add_alt_1_rounded,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Footer ─────────────────────────────
                    AppAuthFooter(
                      question: 'Already have an account?  ',
                      actionLabel: 'Sign in',
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginView())),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Password strength indicator ──────────────────────────────────

class _PasswordStrengthRow extends StatefulWidget {
  const _PasswordStrengthRow({required this.password});
  final TextEditingController password;

  @override
  State<_PasswordStrengthRow> createState() => _PasswordStrengthRowState();
}

class _PasswordStrengthRowState extends State<_PasswordStrengthRow> {
  @override
  void initState() {
    super.initState();
    widget.password.addListener(() => setState(() {}));
  }

  int get _strength {
    final v = widget.password.text;
    if (v.isEmpty) return 0;
    int score = 0;
    if (v.length >= 6) score++;
    if (v.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(v)) score++;
    if (RegExp(r'[0-9]').hasMatch(v)) score++;
    if (RegExp(r'[!@#\$%^&*]').hasMatch(v)) score++;
    return score;
  }

  Color get _color {
    if (_strength <= 1) return AppColors.error;
    if (_strength <= 3) return AppColors.warning;
    return AppColors.success;
  }

  String get _label {
    if (_strength == 0) return '';
    if (_strength <= 1) return 'Weak';
    if (_strength <= 3) return 'Fair';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.password.text.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (i) {
            return Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: i < _strength
                      ? _color
                      : AppColors.inputBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        if (_label.isNotEmpty)
          Text(
            'Password strength: $_label',
            style: TextStyle(
                color: _color, fontSize: 12, fontWeight: FontWeight.w500),
          ),
      ],
    );
  }
}