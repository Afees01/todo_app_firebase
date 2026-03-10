import 'package:flutter/material.dart';


class AppColors {
  AppColors._();

  static const bg         = Color(0xFF0D0D0F);
  static const surface    = Color(0xFF17171A);
  static const card       = Color(0xFF1E1E23);
  static const inputBorder= Color(0xFF2C2C32);
  static const accent     = Color(0xFFD4AF37);   // gold
  static const accentSoft = Color(0x33D4AF37);
  static const primary    = Color(0xFFF5F5F0);
  static const secondary  = Color(0xFF8A8A8E);
  static const error      = Color(0xFFE05555);
  static const success    = Color(0xFF4CAF50);
  static const warning    = Color(0xFFFFA726);
}

class AppRadius {
  AppRadius._();

  static const sm  = 8.0;
  static const md  = 12.0;
  static const lg  = 16.0;
  static const xl  = 20.0;
  static const xxl = 28.0;
}

class AppSpacing {
  AppSpacing._();

  static const xs  = 4.0;
  static const sm  = 8.0;
  static const md  = 16.0;
  static const lg  = 24.0;
  static const xl  = 32.0;
  static const xxl = 48.0;
}

class AppTextStyles {
  AppTextStyles._();

  static const headline = TextStyle(
    color: AppColors.primary,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.5,
  );

  static const title = TextStyle(
    color: AppColors.primary,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static const subtitle = TextStyle(
    color: AppColors.secondary,
    fontSize: 14.5,
    letterSpacing: 0.1,
  );

  static const body = TextStyle(
    color: AppColors.primary,
    fontSize: 15,
  );

  static const caption = TextStyle(
    color: AppColors.secondary,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
  );

  static const label = TextStyle(
    color: AppColors.accent,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: AppColors.bg,
  );
}

// ════════════════════════════════════════════════════════════════
//  1. APP TEXT FIELD
// ════════════════════════════════════════════════════════════════

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.maxLines = 1,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final bool isPassword;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final int maxLines;
  final Widget? suffixIcon;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.caption),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          readOnly: widget.readOnly,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          onChanged: widget.onChanged,
          validator: widget.validator,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
                color: Color(0xFF4A4A52), fontSize: 14),
            prefixIcon:
                Icon(widget.icon, color: AppColors.secondary, size: 20),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscure = !_obscure),
                  )
                : widget.suffixIcon,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
                vertical: 16, horizontal: 16),
            border: _border(AppColors.inputBorder),
            enabledBorder: _border(AppColors.inputBorder),
            focusedBorder: _border(AppColors.accent, width: 1.5),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error, width: 1.5),
            errorStyle:
                const TextStyle(color: AppColors.error, fontSize: 12),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: color, width: width),
      );
}

// ════════════════════════════════════════════════════════════════
//  2. PRIMARY BUTTON  (gold filled)
// ════════════════════════════════════════════════════════════════

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.width = double.infinity,
    this.height = 54,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double width;
  final double height;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.bg,
          disabledBackgroundColor: AppColors.accent.withOpacity(0.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: AppColors.bg, strokeWidth: 2.5),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(label, style: AppTextStyles.button),
                ],
              ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  3. OUTLINED / SECONDARY BUTTON
// ════════════════════════════════════════════════════════════════

class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.width = double.infinity,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.inputBorder),
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
            ],
            Text(label,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  4. APP CARD
// ════════════════════════════════════════════════════════════════

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderColor = AppColors.inputBorder,
    this.color = AppColors.card,
    this.borderRadius = AppRadius.xl,
    this.glowColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color borderColor;
  final Color color;
  final double borderRadius;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
        boxShadow: glowColor != null
            ? [
                BoxShadow(
                  color: glowColor!.withOpacity(0.18),
                  blurRadius: 24,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: child,
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  5. APP LOGO MARK
// ════════════════════════════════════════════════════════════════

class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 64});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: AppColors.accent, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.25),
            blurRadius: 24,
            spreadRadius: 2,
          )
        ],
      ),
      child: Icon(Icons.check_rounded,
          color: AppColors.accent, size: size * 0.5),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  6. DIVIDER WITH LABEL
// ════════════════════════════════════════════════════════════════

class AppDividerLabel extends StatelessWidget {
  const AppDividerLabel({super.key, this.label = 'or'});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
            child: Divider(color: AppColors.inputBorder, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.secondary, fontSize: 13)),
        ),
        const Expanded(
            child: Divider(color: AppColors.inputBorder, thickness: 1)),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  7. SIGN-UP / SIGN-IN FOOTER LINK
// ════════════════════════════════════════════════════════════════

class AppAuthFooter extends StatelessWidget {
  const AppAuthFooter({
    super.key,
    required this.question,
    required this.actionLabel,
    required this.onTap,
  });

  final String question;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(question,
            style: const TextStyle(
                color: AppColors.secondary, fontSize: 14)),
        GestureDetector(
          onTap: onTap,
          child: Text(actionLabel, style: AppTextStyles.label),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  8. SNACKBAR HELPERS
// ════════════════════════════════════════════════════════════════

class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    final color = isError
        ? AppColors.error
        : isSuccess
            ? AppColors.success
            : AppColors.accent;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(color: AppColors.primary)),
        backgroundColor: AppColors.card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(color: color, width: 1)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  9. LOADING OVERLAY
// ════════════════════════════════════════════════════════════════

class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({super.key, required this.isLoading, required this.child});
  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.55),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 2.5,
              ),
            ),
          ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  10. SECTION HEADER
// ════════════════════════════════════════════════════════════════

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.title),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  11. BADGE / CHIP
// ════════════════════════════════════════════════════════════════

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.color = AppColors.accent,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  12. ICON BUTTON (circular)
// ════════════════════════════════════════════════════════════════

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 44,
    this.iconColor = AppColors.primary,
    this.bgColor = AppColors.card,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color iconColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border:
              Border.all(color: AppColors.inputBorder),
        ),
        child: Icon(icon, color: iconColor, size: size * 0.45),
      ),
    );
  }
}