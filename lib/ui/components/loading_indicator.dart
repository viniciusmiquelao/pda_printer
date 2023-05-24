import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    Key? key,
    this.size = 20,
    this.color = const Color(0xFFFFFFFF),
  }) : super(key: key);

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) return CupertinoActivityIndicator(radius: size / 2);

    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: color,
      ),
    );
  }
}
