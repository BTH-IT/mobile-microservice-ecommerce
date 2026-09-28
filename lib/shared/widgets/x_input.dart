import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecommerce_mobile/config/theme/app_colors.dart';
import 'package:ecommerce_mobile/config/theme/app_decorations.dart';
import 'package:ecommerce_mobile/config/theme/app_typography.dart';

class XInput extends StatefulWidget {
  final String? value;
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  const XInput({
    super.key,
    this.value,
    this.controller,
    this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.prefixIcon,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.inputFormatters,
  });

  @override
  State<XInput> createState() => _XInputState();
}

class _XInputState extends State<XInput> {
  late TextEditingController _controller;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _controller = widget.controller ?? TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(XInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null && _controller.text != widget.value) {
      final cursorPosition = _controller.selection.baseOffset;
      _controller.text = widget.value!;
      if (cursorPosition <= widget.value!.length && cursorPosition >= 0) {
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: cursorPosition),
        );
      }
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  Widget? _buildSuffixActions() {
    final actions = <Widget>[];

    // Clear Button
    if (_controller.text.isNotEmpty && widget.enabled && !widget.readOnly) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.cancel, size: 18, color: AppColors.textMuted),
          tooltip: 'Xóa',
          onPressed: () {
            _controller.clear();
            widget.onChanged?.call('');
            setState(() {});
          },
        ),
      );
    }

    // Password Eye Toggle
    if (widget.obscureText) {
      actions.add(
        IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 20,
            color: AppColors.textSecondary,
          ),
          tooltip: _obscureText ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      );
    }

    if (actions.isEmpty) return null;
    if (actions.length == 1) return actions.first;

    return Row(mainAxisSize: MainAxisSize.min, children: actions);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTypography.label),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: _controller,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          maxLines: widget.maxLines,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          style: AppTypography.bodyMedium,
          onChanged: (val) {
            setState(() {}); // refresh for clear button
            widget.onChanged?.call(val);
          },
          onFieldSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixActions(),
            filled: true,
            fillColor: AppColors.surfaceSecondary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: const OutlineInputBorder(
              borderRadius: AppDecorations.radiusS,
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: AppDecorations.radiusS,
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: AppDecorations.radiusS,
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: AppDecorations.radiusS,
              borderSide: BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}
