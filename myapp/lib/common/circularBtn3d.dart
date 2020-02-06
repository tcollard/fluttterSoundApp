import 'package:flutter/material.dart';

class CircularBtn3d extends StatelessWidget {
  final Widget child;
  final double size;
  final Color btnColor;
  final Function pressGesture;
  const CircularBtn3d(this.child, this.size, this.btnColor, this.pressGesture);

  @override
  Widget build(BuildContext context) {
    Color _setColorBoxShadow() {
      return (Theme.of(context).brightness == Brightness.dark)
          ? Colors.white.withOpacity(0.1) // black background
          : Colors.white.withOpacity(1); // white background
    }

    return IconButton(
      padding: EdgeInsets.only(top: 50),
      icon: Container(
        height: this.size,
        width: this.size,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset.fromDirection(.8, 20),
                blurRadius: 20.0,
                spreadRadius: 0.0),
            BoxShadow(
                color: _setColorBoxShadow(),
                offset: Offset.fromDirection(3.8, 15),
                blurRadius: 20.0,
                spreadRadius: 0.0),
          ],
          shape: BoxShape.circle,
          color: this.btnColor,
        ),
        child: this.child,
      ),
      splashColor: Colors.transparent,
      iconSize: this.size,
      onPressed: this.pressGesture,
    );
  }
}
