import 'package:flutter/material.dart';

class MainButton extends StatefulWidget {
  const MainButton({super.key, this.onTap, required this.text, this.onLoading});

  final Function()? onTap;
  final String text;
  final bool? onLoading;

  @override
  State<MainButton> createState() => _MainButtonState();
}

class _MainButtonState extends State<MainButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: widget.onTap,
        style: ButtonStyle(
        ),
        child: (widget.onLoading ?? false)
            ? CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
                      strokeAlign: 0.1,
              )
            : Text(widget.text));
  }
}
