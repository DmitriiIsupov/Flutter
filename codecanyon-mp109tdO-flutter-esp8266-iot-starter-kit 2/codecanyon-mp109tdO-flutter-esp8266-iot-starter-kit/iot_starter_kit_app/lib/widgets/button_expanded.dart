import 'package:flutter/material.dart';

/// Simple button widget with expanded layout by default
class ButtonExpanded extends StatelessWidget {
  final Icon icon;
  final String text;
  final Color color;
  final bool enabled;
  final int flex;
  final double borderRadius;
  final Function() onPressed;

  ButtonExpanded(
      {this.icon,
      this.text,
      this.color,
      this.enabled,
      this.flex = 1,
      this.borderRadius = 0,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: RaisedButton(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            icon,
            SizedBox(width: 5.0),
            Text(text),
          ],
        ),
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}
