import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final Function()? func;
  final String text;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const AuthButton({
    super.key,
    required this.func,
    required this.text,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: TextButton(
        onPressed: func,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          width: 250,
          height: 27,
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
