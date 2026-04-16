import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/modern_theme.dart';

/// Input Field Types
enum AppInputType {
  text,
  email,
  password,
  number,
  phone,
  multiline,
  search,
}

/// Input Field Variants
enum AppInputVariant {
  filled,
  outlined,
  underlined,
}

/// Modern Animated Text Input Field Widget
/// Features:
/// - Smooth focus animations
/// - Floating labels
/// - Character counter
/// - Clear button
/// - Password visibility toggle
/// - Validation states with colors
class AppInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final AppInputType type;
  final IconData? prefixIcon;
  final Widget? prefixIconWidget;
  final Widget? suffixIcon;
  final bool obscureText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function()? onTap;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLength;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final String? errorText;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final EdgeInsets? contentPadding;
  final Color? fillColor;
  final double? borderRadius;
  final AppInputVariant variant;
  final bool showCharCount;
  final String? helperText;
  final Widget? leading;
  final bool isDense;

  const AppInput({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.type = AppInputType.text,
    this.prefixIcon,
    this.prefixIconWidget,
    this.suffixIcon,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines,
    this.minLength,
    this.maxLength,
    this.inputFormatters,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.errorText,
    this.textInputAction,
    this.autofocus = false,
    this.contentPadding,
    this.fillColor,
    this.borderRadius,
    this.variant = AppInputVariant.filled,
    this.showCharCount = false,
    this.helperText,
    this.leading,
    this.isDense = false,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> with SingleTickerProviderStateMixin {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _isFocused = false;
  late TextEditingController _controller;
  int _charCount = 0;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _charCount = _controller.text.length;
    _errorText = widget.errorText;

    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });

    _controller.addListener(() {
      setState(() => _charCount = _controller.text.length);
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final effectiveMaxLines = widget.maxLines ?? (widget.type == AppInputType.multiline ? 5 : 1);
    final borderRadius = widget.borderRadius ?? 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null && !widget.isDense) ...[
          Text(
            widget.label!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _errorText != null
                  ? ModernTheme.error
                  : _isFocused
                      ? ModernTheme.primary
                      : (isDark ? ModernTheme.stone400 : ModernTheme.stone600),
            ),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: _buildDecoration(context, borderRadius, isDark),
          child: TextFormField(
            controller: _controller,
            obscureText: _obscureText,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            maxLines: effectiveMaxLines,
            maxLength: widget.showCharCount || widget.maxLength != null ? widget.maxLength : null,
            inputFormatters: widget.inputFormatters ?? _getInputFormatters(),
            keyboardType: widget.keyboardType ?? _getKeyboardType(),
            textCapitalization: widget.textCapitalization,
            focusNode: _focusNode,
            textInputAction: widget.textInputAction,
            autofocus: widget.autofocus,
            onChanged: (value) {
              if (widget.onChanged != null) widget.onChanged!(value);
              // Clear error on input
              if (_errorText != null) {
                setState(() => _errorText = null);
              }
            },
            onFieldSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            validator: (value) {
              final validationResult = widget.validator?.call(value);
              if (validationResult != null) {
                setState(() => _errorText = validationResult);
              }
              return validationResult;
            },
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                color: ModernTheme.stone400,
                fontSize: 15,
              ),
              errorText: _errorText,
              fillColor: widget.fillColor ?? (isDark ? const Color(0xFF292524) : ModernTheme.stone100.withValues(alpha: 0.5)),
              contentPadding: widget.contentPadding ??
                  EdgeInsets.symmetric(
                    horizontal: widget.leading != null || widget.prefixIcon != null ? 16 : 20,
                    vertical: widget.isDense ? 14 : 20,
                  ),
              border: InputBorder.none,
              prefixIcon: widget.leading ?? widget.prefixIconWidget ??
                  (widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _isFocused ? ModernTheme.primary : ModernTheme.stone500,
                        )
                      : null),
              suffixIcon: _buildSuffixIcon(),
              counterText: widget.showCharCount ? null : '',
            ),
          ),
        ),
        if (widget.helperText != null && _errorText == null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Text(
              widget.helperText!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: ModernTheme.stone500,
              ),
            ),
          ),
        ],
        if (_errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: ModernTheme.error,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _errorText!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: ModernTheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (widget.showCharCount && widget.maxLength != null && _errorText == null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$_charCount / ${widget.maxLength}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: _charCount > widget.maxLength!
                      ? ModernTheme.error
                      : ModernTheme.stone400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  BoxDecoration _buildDecoration(BuildContext context, double radius, bool isDark) {
    Color borderColor;
    double borderWidth;
    Color? fillColor;

    switch (widget.variant) {
      case AppInputVariant.outlined:
        fillColor = Colors.transparent;
        borderColor = _errorText != null
            ? ModernTheme.error
            : _isFocused
                ? ModernTheme.primary
                : ModernTheme.stone300;
        borderWidth = _isFocused ? 2 : 1;
        break;

      case AppInputVariant.underlined:
        fillColor = Colors.transparent;
        borderColor = _errorText != null
            ? ModernTheme.error
            : _isFocused
                ? ModernTheme.primary
                : ModernTheme.stone300;
        borderWidth = _isFocused ? 2 : 1;
        return BoxDecoration(
          color: fillColor,
          border: Border(
            bottom: BorderSide(color: borderColor, width: borderWidth),
          ),
        );

      case AppInputVariant.filled:
        fillColor = widget.fillColor ?? (isDark ? const Color(0xFF292524) : ModernTheme.stone100.withValues(alpha: 0.5));
        borderColor = _errorText != null
            ? ModernTheme.error
            : _isFocused
                ? ModernTheme.primary
                : Colors.transparent;
        borderWidth = _isFocused ? 2 : 0;
    }

    return BoxDecoration(
      color: fillColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: _isFocused
          ? [
              BoxShadow(
                color: ModernTheme.primary.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }

  Widget? _buildSuffixIcon() {
    List<Widget> icons = [];

    // Add custom suffix icon if provided
    if (widget.suffixIcon != null) {
      icons.add(widget.suffixIcon!);
    }

    // Add clear button for non-password fields
    if (widget.type != AppInputType.password &&
        !widget.obscureText &&
        _controller.text.isNotEmpty &&
        _isFocused) {
      icons.add(
        GestureDetector(
          onTap: () {
            _controller.clear();
            if (widget.onChanged != null) widget.onChanged!('');
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: ModernTheme.stone200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.close, size: 16, color: ModernTheme.stone600),
          ),
        ),
      );
    }

    // Add password toggle
    if (widget.type == AppInputType.password || widget.obscureText) {
      icons.add(
        GestureDetector(
          onTap: () => setState(() => _obscureText = !_obscureText),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _obscureText
                  ? ModernTheme.stone200.withValues(alpha: 0.5)
                  : ModernTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20,
              color: _obscureText ? ModernTheme.stone500 : ModernTheme.primary,
            ),
          ),
        ),
      );
    }

    if (icons.isEmpty) return null;
    if (icons.length == 1) return icons.first;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        icons.length,
        (i) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: icons[i],
        ),
      ),
    );
  }

  TextInputType? _getKeyboardType() {
    switch (widget.type) {
      case AppInputType.email:
        return TextInputType.emailAddress;
      case AppInputType.phone:
        return TextInputType.phone;
      case AppInputType.number:
        return TextInputType.number;
      case AppInputType.multiline:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    switch (widget.type) {
      case AppInputType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      case AppInputType.phone:
        return [FilteringTextInputFormatter.digitsOnly];
      default:
        return null;
    }
  }
}

/// Dropdown Input Field
class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? initialValue;
  final List<DropdownMenuItem<T>> items;
  final Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;
  final bool enabled;
  final Widget? icon;
  final double borderRadius;
  final bool isDense;

  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    required this.items,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
    this.icon,
    this.borderRadius = 16,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && !isDense) ...[
          Text(
            label!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? ModernTheme.stone400 : ModernTheme.stone600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF292524) : ModernTheme.stone100.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: ModernTheme.stone300, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButtonFormField<T>(
                initialValue: initialValue,
                items: items,
                onChanged: enabled ? onChanged : null,
                validator: validator,
                icon: icon ??
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: ModernTheme.stone500,
                    ),
                dropdownColor: isDark ? ModernTheme.surfaceDarkElevated : ModernTheme.surface,
                borderRadius: BorderRadius.circular(16),
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Search Input Field with animated clear button
class AppSearchInput extends StatefulWidget {
  final String? hint;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool autoFocus;
  final EdgeInsets? padding;
  final double borderRadius;

  const AppSearchInput({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autoFocus = false,
    this.padding,
    this.borderRadius = 16,
  });

  @override
  State<AppSearchInput> createState() => _AppSearchInputState();
}

class _AppSearchInputState extends State<AppSearchInput> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(() {
      setState(() => _hasText = _controller.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF292524) : ModernTheme.stone100.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: _hasText ? ModernTheme.primary : ModernTheme.stone200,
            width: _hasText ? 2 : 1,
          ),
        ),
        child: TextField(
          controller: _controller,
          autofocus: widget.autoFocus,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
          ),
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Cari...',
            hintStyle: GoogleFonts.plusJakartaSans(
              color: ModernTheme.stone400,
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _hasText ? ModernTheme.primary : ModernTheme.stone400,
            ),
            suffixIcon: _hasText
                ? AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: GestureDetector(
                      onTap: widget.onClear ?? () => _controller.clear(),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ModernTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: ModernTheme.primary,
                        ),
                      ),
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }
}

/// Modern Checkbox with smooth animation
class AppCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;
  final String? subtitle;
  final bool enabled;

  const AppCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return InkWell(
      onTap: enabled ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value
              ? ModernTheme.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value
                ? ModernTheme.primary.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? ModernTheme.primary : ModernTheme.stone200,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? ModernTheme.primary : ModernTheme.stone300,
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: enabled
                          ? (isDark ? ModernTheme.stone100 : ModernTheme.stone800)
                          : ModernTheme.stone400,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: ModernTheme.stone500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern Switch Toggle
class AppSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;
  final String? subtitle;
  final bool enabled;

  const AppSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return InkWell(
      onTap: enabled ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: enabled
                          ? (isDark ? ModernTheme.stone100 : ModernTheme.stone800)
                          : ModernTheme.stone400,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: ModernTheme.stone500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 28,
              decoration: BoxDecoration(
                color: value ? ModernTheme.primary : ModernTheme.stone300,
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
