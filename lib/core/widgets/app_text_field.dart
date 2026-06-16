import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.autofillHints,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
