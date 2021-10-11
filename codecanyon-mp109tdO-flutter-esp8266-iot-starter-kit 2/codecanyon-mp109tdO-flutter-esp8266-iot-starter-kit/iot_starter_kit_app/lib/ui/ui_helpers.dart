import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Contains useful functions to reduce boilerplate code
class UIHelper {
  UIHelper._();

  // Vertical spacing constants. Adjust to your liking.
  static const double VerticalSpaceVerySmall = 12.0;
  static const double VerticalSpaceSmall = 15.0;
  static const double VerticalSpaceMedium = 30.0;
  static const double VerticalSpaceLarge = 45.0;

  // Horizontal spacing constants. Adjust to your liking.
  static const double HorizontalSpaceVerySmall = 12.0;
  static const double HorizontalSpaceSmall = 15.0;
  static const double HorizontalSpaceMedium = 30.0;
  static const double HorizontalSpaceLarge = 45.0;

  /// Returns a vertical space with height set to [VerticalSpaceVerySmall]
  static Widget verticalSpaceVerySmall() {
    return verticalSpace(VerticalSpaceVerySmall);
  }

  /// Returns a vertical space with height set to [VerticalSpaceSmall]
  static Widget verticalSpaceSmall() {
    return verticalSpace(VerticalSpaceSmall);
  }

  /// Returns a vertical space with height set to [VerticalSpaceMedium]
  static Widget verticalSpaceMedium() {
    return verticalSpace(VerticalSpaceMedium);
  }

  /// Returns a vertical space with height set to [VerticalSpaceLarge]
  static Widget verticalSpaceLarge() {
    return verticalSpace(VerticalSpaceLarge);
  }

  /// Returns a vertical space equal to the [height] supplied
  static Widget verticalSpace(double height) {
    return SizedBox(height: height);
  }

  /// Returns a vertical space with height set to [HorizontalSpaceVerySmall]
  static Widget horizontalSpaceVerySmall() {
    return horizontalSpace(HorizontalSpaceVerySmall);
  }

  /// Returns a vertical space with height set to [HorizontalSpaceSmall]
  static Widget horizontalSpaceSmall() {
    return horizontalSpace(HorizontalSpaceSmall);
  }

  /// Returns a vertical space with height set to [HorizontalSpaceMedium]
  static Widget horizontalSpaceMedium() {
    return horizontalSpace(HorizontalSpaceMedium);
  }

  /// Returns a vertical space with height set to [HorizontalSpaceLarge]
  static Widget horizontalSpaceLarge() {
    return horizontalSpace(HorizontalSpaceLarge);
  }

  /// Returns a vertical space equal to the [width] supplied
  static Widget horizontalSpace(double width) {
    return SizedBox(width: width);
  }

  /// Provides an input field with a title that stretches the full width of the screen
  static Widget inputField(
      {String title,
      String placeholder,
      @required TextEditingController controller,
      String validationMessage,
      bool isPassword = false,
      double spaceBetweenTitle = 15.0,
      double padding = 10.0}) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.0)),
          validationMessage != null
              ? Text(validationMessage,
                  style: TextStyle(color: Colors.red[400], fontSize: 12.0))
              : Container(),
          Container(
            alignment: Alignment(0.0, 0.0),
            padding: EdgeInsets.only(left: padding),
            margin: EdgeInsets.only(top: spaceBetweenTitle),
            width: double.infinity,
            height: 40.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.grey[100]),
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              style: TextStyle(fontSize: 12.0),
              decoration: InputDecoration.collapsed(
                  hintText: placeholder,
                  hintStyle:
                      TextStyle(color: Colors.grey[600], fontSize: 12.0)),
            ),
          )
        ]);
  }

  static Widget fullScreenButton({String title, Function onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 40.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Color.fromARGB(255, 9, 202, 172)),
        child: Center(
            child: Text(title, style: TextStyle(fontWeight: FontWeight.w800))),
      ),
    );
  }

  static Widget getDummyColumn({bool colorful = true}) {
    const noColor = Color(0x00FFFFFF);
    final horizontalBar = Container(
      height: 1,
      color: Color(0x40FFFFFF),
    );
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
      shadows: [
        Shadow(
          color: Colors.black87,
          blurRadius: 1.8,
          offset: Offset(0.5, 0.5),
        )
      ],
    );

    var colors = [
      Colors.limeAccent,
      Colors.amberAccent,
      Colors.pinkAccent,
      Colors.purpleAccent,
      Colors.deepPurpleAccent,
      Colors.indigoAccent,
      Colors.blueAccent,
      Colors.lightBlueAccent,
      Colors.tealAccent,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (!colorful) horizontalBar,
        ...colors.map((color) {
          return Container(
            padding: const EdgeInsets.all(36),
            alignment: Alignment.center,
            child: Text(
              'Content ${colors.indexOf(color) + 1}',
              style: textStyle,
            ),
            decoration: BoxDecoration(
                color: colorful ? color : noColor,
                border: Border(
                  bottom: BorderSide(
                    width: 1.0,
                    color: Color(0x40FFFFFF),
                  ),
                )),
          );
        }).toList(),
      ],
    );
  }

  static void showToast({String message, Color bgColor, Color textColor}) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: bgColor,
      timeInSecForIosWeb: 2,
      textColor: textColor,
      fontSize: 14,
    );
  }

  static SnackBar getSnackBar({Text message, Color bgColor}) {
    return SnackBar(
      content: message,
      backgroundColor: bgColor,
      duration: Duration(milliseconds: 1500),
    );
  }
}
