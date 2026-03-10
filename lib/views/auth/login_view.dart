import 'package:flutter/material.dart';
import 'package:todo_app/views/auth/singup_view.dart';
import 'package:todo_app/controllers/auth_controller.dart';
import 'package:todo_app/views/widgets/app_widgets.dart';
import '../tasks/home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final _formKey        = GlobalKey<FormState>();
  final _email          = TextEditingController();
  final _password       = TextEditingController();
  final _controller     = AuthController();
  bool _isLoading       = false;
  bool _isGoogleLoading = false;

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
    super.dispose();
  }

  // ── Email / Password login ──────────────────────────────
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _controller.login(_email.text.trim(), _password.text);
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.show(context, 'Logged in successfully!', isSuccess: true);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeView()));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.show(context, e.toString(), isError: true);
    }
  }

  // ── Google Sign-In ──────────────────────────────────────
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      await _controller.service.signInWithGoogle();
      if (!mounted) return;
      setState(() => _isGoogleLoading = false);
      AppSnackBar.show(context, 'Signed in with Google!', isSuccess: true);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeView()));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGoogleLoading = false);
      AppSnackBar.show(
          context, 'Google sign-in failed. Try again.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Logo ──────────────────────────────
                    const Center(child: AppLogoMark()),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Headline ──────────────────────────
                    const Text('Welcome\nback.', style: AppTextStyles.headline),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to continue to your workspace.',
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: AppSpacing.xl + 8),

                    // ── Form card ─────────────────────────
                    AppCard(
                      child: Column(
                        children: [
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

                          AppTextField(
                            controller: _password,
                            label: 'Password',
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Password is required';
                              if (v.length < 6) return 'Minimum 6 characters';
                              return null;
                            },
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap),
                              child: const Text('Forgot password?',
                                  style: TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Primary CTA ───────────────────────
                    AppPrimaryButton(
                      label: 'Sign In',
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Divider ───────────────────────────
                    const AppDividerLabel(),
                    const SizedBox(height: AppSpacing.md),

                    // ── Google Button ─────────────────────
                    _GoogleSignInButton(
                      isLoading: _isGoogleLoading,
                      onPressed: _handleGoogleSignIn,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Footer ────────────────────────────
                    AppAuthFooter(
                      question: "Don't have an account?  ",
                      actionLabel: 'Create one',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => SignupView())),
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

// ════════════════════════════════════════════════════════════════
//  Google Sign-In Button  (custom branded)
// ════════════════════════════════════════════════════════════════

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.inputBorder),
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: AppColors.accent, strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google "G" logo built with pure Flutter
                  _GoogleLogo(size: 22),
                  const SizedBox(width: 12),
                  const Text(
                    'Sign in with Google',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Minimal Google "G" logo painted with Canvas ────────────────

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final cx = r;
    final cy = r;

    // Background circle
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = Colors.white,
    );

    // Segment colors
    const blue   = Color(0xFF4285F4);
    const red    = Color(0xFFEA4335);
    const yellow = Color(0xFFFBBC05);
    const green  = Color(0xFF34A853);

    final segPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.2
      ..strokeCap = StrokeCap.butt;

    // Blue  (right arc ~ 120°)
    segPaint.color = blue;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.65),
        -0.3, 2.1, false, segPaint);

    // Red   (top-left arc ~ 120°)
    segPaint.color = red;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.65),
        -0.3 + 2.1, 2.1, false, segPaint);

    // Yellow / Green (bottom arc ~ 120°)
    segPaint.color = yellow;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.65),
        -0.3 + 4.2, 1.05, false, segPaint);

    segPaint.color = green;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.65),
        -0.3 + 4.2 + 1.05, 1.05, false, segPaint);

    // Horizontal bar of the "G"
    final barPaint = Paint()
      ..color = blue
      ..strokeWidth = size.width * 0.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r * 0.65, cy),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}