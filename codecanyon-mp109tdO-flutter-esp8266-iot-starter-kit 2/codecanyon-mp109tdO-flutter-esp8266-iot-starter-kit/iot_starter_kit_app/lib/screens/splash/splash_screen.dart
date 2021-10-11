import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final String afterSplashRoute;
  final int secondsDelay;
  final logoPath = 'assets/logo/app_logo.png';

  const SplashScreen({this.afterSplashRoute, this.secondsDelay});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreenAccent[700], // 0xff64dd17
      body: Center(
        child: getSplashLogo(),
      ),
    );
  }

  Widget getSplashLogo() {
    return Image.asset(
      widget.logoPath,
      alignment: Alignment.center,
      height: 100,
    );
  }

  startTimer() {
    Future.delayed(
      Duration(
        seconds: widget.secondsDelay,
      ),
      navigate,
    );
  }

  navigate() async {
    Navigator.pushReplacementNamed(context, widget.afterSplashRoute);
  }
}
