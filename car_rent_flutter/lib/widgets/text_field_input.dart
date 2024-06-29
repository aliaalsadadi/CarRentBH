import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final String hintText;
  final IconData? icon; // Make the icon parameter nullable
  final TextEditingController controller;
  final bool obscureText;
  final void Function(String)? onChanged; // Add onChanged callback

  const TextFieldInput({
    Key? key, // Add the Key parameter if needed
    required this.hintText,
    this.icon, // Make the icon parameter optional
    required this.controller,
    this.obscureText = false,
    this.onChanged, // Add onChanged callback
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.black),
        onChanged: onChanged, // Pass the onChanged callback to TextFormField
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.grey)
              : null, // Check if icon is provided
          border: InputBorder.none,
        ),
      ),
    );
  }
}
