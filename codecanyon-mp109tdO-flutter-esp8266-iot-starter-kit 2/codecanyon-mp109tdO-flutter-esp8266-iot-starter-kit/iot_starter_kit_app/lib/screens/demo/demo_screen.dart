import 'package:flutter/material.dart';

class DemoScreen extends StatefulWidget {
  DemoScreen({Key key}) : super(key: key);

  @override
  _DemoScreenState createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demo Screen'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            child: Text('This screen is used to play with widgets'),
          ),
        ],
      ),
    );
  }
}
