import 'package:flutter/material.dart';

import 'loading_indicator.dart';

class BaseButton extends StatelessWidget {
  const BaseButton({
    required this.text,
    this.onPressed,
    this.borderSide,
    this.color,
    this.textStyle,
    this.loading = false,
    this.height = 50,
    this.radius = 10,
    this.width,
    Key? key,
  }) : super(key: key);

  final String text;
  final TextStyle? textStyle;
  final Color? color;
  final BorderSide? borderSide;
  final VoidCallback? onPressed;
  final bool? loading;
  final double? height;
  final double radius;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          backgroundColor: color,
        ),
        onPressed: !loading! ? onPressed : null,
        child: loading!
            ? const LoadingIndicator()
            : Text(
                text,
                style: textStyle ?? Theme.of(context).textTheme.labelLarge,
                //style: newTextStyle,
              ),
      ),
    );
  }
}
