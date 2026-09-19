import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class TkButton extends StatelessWidget {
  const TkButton({super.key, required this.label, required this.onTap,
    this.color, this.outlined = false, this.icon, this.fullWidth = true,
    this.small = false, this.enabled = true});
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final bool outlined, fullWidth, small, enabled;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.chung;
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: fullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(vertical: small ? 12 : 18, horizontal: small ? 16 : 24),
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : c,
            border: outlined ? Border.all(color: c, width: 2) : null,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: small ? 16 : 20, color: outlined ? c : Colors.white), const SizedBox(width: 8)],
              Text(label, style: TextStyle(fontSize: small ? 13 : 16, fontWeight: FontWeight.w700,
                letterSpacing: 1.5, color: outlined ? c : Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class TkTextField extends StatelessWidget {
  const TkTextField({super.key, required this.controller, required this.label,
    this.hint, this.prefixIcon, this.capitalization = TextCapitalization.words,
    this.onChanged, this.autofocus = false});
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final TextCapitalization capitalization;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTextStyles.labelMedium),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        textCapitalization: capitalization,
        autofocus: autofocus,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textDisabled),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20) : null,
          filled: true,
          fillColor: AppColors.surfaceElevated,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd), borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd), borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd), borderSide: const BorderSide(color: AppColors.chung, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    ]);
  }
}

class TkSectionLabel extends StatelessWidget {
  const TkSectionLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text.toUpperCase(), style: AppTextStyles.labelLarge),
  );
}

class TkDivider extends StatelessWidget {
  const TkDivider({super.key, this.vertical = false});
  final bool vertical;
  @override
  Widget build(BuildContext context) => Container(
    width: vertical ? 1 : double.infinity,
    height: vertical ? double.infinity : 1,
    color: AppColors.border,
  );
}

class ConnectionDot extends StatelessWidget {
  const ConnectionDot({super.key, required this.isConnected, this.size = 12});
  final bool isConnected;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: isConnected ? AppColors.success : AppColors.textDisabled,
      boxShadow: isConnected ? [BoxShadow(color: AppColors.success.withOpacity(0.5), blurRadius: 6, spreadRadius: 1)] : null,
    ),
  );
}

class TkCard extends StatelessWidget {
  const TkCard({super.key, required this.child, this.padding, this.color, this.borderColor});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding ?? const EdgeInsets.all(AppDimens.paddingMd),
    decoration: BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      border: Border.all(color: borderColor ?? AppColors.border, width: 1.5),
    ),
    child: child,
  );
}