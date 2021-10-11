import 'package:about/about.dart';
import 'package:flutter/material.dart';
import 'package:iot_starter_kit_app/generated/locale_base.dart';

class HelpScreen extends StatefulWidget {
  HelpScreen({Key key}) : super(key: key);

  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  LocaleBase lang;

  @override
  Widget build(BuildContext context) {
    lang = Localizations.of<LocaleBase>(context, LocaleBase);

    return MarkdownPage(
      title: Text(lang.ScreenHelp.helpTitle),
      filename: 'assets/docs/help_screen.md',
      selectable: true,
    );
  }
}
