import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A customizable and reusable TextFormField widget with built-in validation,
/// styling, and common functionality.
class CustomTextField extends StatefulWidget {
  /// The controller for the text field
  final TextEditingController? controller;
  /// Label text displayed above the field
  final String? labelText;
  /// Hint text displayed inside the field
  final String? hintText;
  /// Helper text displayed below the field
  final String? helperText;
  /// Prefix icon
  final IconData? prefixIcon;
  /// Suffix icon
  final IconData? suffixIcon;
  /// Callback when suffix icon is pressed
  final VoidCallback? onSuffixIconPressed;
  /// Whether the field is for password input
  final bool isPassword;
  /// Whether the field is enabled
  final bool enabled;
  /// Whether the field is read-only
  final bool readOnly;
  /// Maximum number of lines
  final int? maxLines;
  /// Minimum number of lines
  final int? minLines;
  /// Maximum length of input
  final int? maxLength;
  /// Keyboard type
  final TextInputType keyboardType;
  /// Text input action
  final TextInputAction? textInputAction;
  /// Text capitalization
  final TextCapitalization textCapitalization;
  /// Input formatters
  final List<TextInputFormatter>? inputFormatters;
  /// Validation function
  final String? Function(String?)? validator;
  /// Callback when field value changes
  final void Function(String)? onChanged;
  /// Callback when field is submitted
  final void Function(String)? onFieldSubmitted;
  /// Callback when field is tapped
  final VoidCallback? onTap;
  /// Auto validation mode
  final AutovalidateMode? autovalidateMode;
  /// Focus node
  final FocusNode? focusNode;
  /// Text style
  final TextStyle? textStyle;
  /// Border radius
  final double borderRadius;
  /// Fill color
  final Color? fillColor;
  /// Whether to show character counter
  final bool showCounter;
  /// Content padding
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.isPassword = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.autovalidateMode,
    this.focusNode,
    this.textStyle,
    this.borderRadius = 8.0,
    this.fillColor,
    this.showCounter = false,
    this.contentPadding,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      obscureText: _obscureText,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      onTap: widget.onTap,
      autovalidateMode: widget.autovalidateMode,
      style: widget.textStyle ?? theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        helperText: widget.helperText,

        // Prefix Icon
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon,)
            : null,

        // Suffix Icon (with password toggle if needed)
        suffixIcon: _buildSuffixIcon(colorScheme),

        // Filled style
        filled: true,
        fillColor: widget.fillColor ?? colorScheme.surface,

        // Content Padding
        contentPadding: widget.contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

        // Counter
        counterText: widget.showCounter ? null : '',

        // Borders
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon(ColorScheme colorScheme) {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: colorScheme.onSurfaceVariant,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    } else if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(widget.suffixIcon, color: colorScheme.primary),
        onPressed: widget.onSuffixIconPressed,
      );
    }
    return null;
  }
}

/// Common validators for the CustomTextField
class TextFieldValidators {
  /// Validates that the field is not empty
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validates password strength
  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Validates phone number
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates minimum length
  static String? minLength(String? value, int length, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    if (value.length < length) {
      return '${fieldName ?? 'This field'} must be at least $length characters';
    }
    return null;
  }

  /// Validates maximum length
  static String? maxLength(String? value, int length, {String? fieldName}) {
    if (value != null && value.length > length) {
      return '${fieldName ?? 'This field'} must not exceed $length characters';
    }
    return null;
  }

  /// Validates that value matches another value (for password confirmation)
  static String? match(String? value, String? matchValue, {String? fieldName}) {
    if (value != matchValue) {
      return '${fieldName ?? 'Values'} do not match';
    }
    return null;
  }

  /// Validates numeric input
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }
}