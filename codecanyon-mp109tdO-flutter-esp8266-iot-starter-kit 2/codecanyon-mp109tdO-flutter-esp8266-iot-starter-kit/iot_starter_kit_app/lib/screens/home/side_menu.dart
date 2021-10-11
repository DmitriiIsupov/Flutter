import 'package:flutter/material.dart';
import 'package:iot_starter_kit_app/core/constants.dart';
import 'package:iot_starter_kit_app/generated/locale_base.dart';
import 'package:iot_starter_kit_app/screen_router.dart';
import 'package:preferences/preference_service.dart';

/// build side menu for Drawer
class SideMenu extends StatelessWidget {
  final String deviceUptime;

  const SideMenu({Key key, this.deviceUptime});

  final double iconSize = 30;
  final double fontSize = 16;

  @override
  Widget build(BuildContext context) {
    LocaleBase lang = Localizations.of<LocaleBase>(context, LocaleBase);

    var versionString = PrefService.getString('app_version_string');

    var menuItems = [
      DrawerHeader(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              'assets/logo/app_logo.png',
              alignment: Alignment.center,
              height: 60,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  Constants.appName,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  '${lang.Common.deviceUptime}: $deviceUptime',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ListTile(
        leading: Icon(
          Icons.settings,
          size: iconSize,
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: iconSize,
        ),
        title: Text(
          lang.Common.menuSettings,
          style: TextStyle(fontSize: fontSize),
        ),
        onTap: () {
          Navigator.pushNamed(context, ScreenRouter.settings);
        },
      ),
      ListTile(
        leading: Icon(
          Icons.help_outline,
          size: iconSize,
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: iconSize,
        ),
        title: Text(
          lang.Common.menuHelp,
          style: TextStyle(fontSize: fontSize),
        ),
        onTap: () {
          Navigator.pushNamed(context, ScreenRouter.help);
        },
      ),
      ListTile(
        leading: Icon(
          Icons.info_outline,
          size: iconSize,
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: iconSize,
        ),
        title: Text(
          lang.Common.menuAbout,
          style: TextStyle(fontSize: fontSize),
        ),
        onTap: () {
          Navigator.pushNamed(context, ScreenRouter.about);
        },
      ),
      // Menu Item for Demo Screen
      // ListTile(
      //   leading: Icon(
      //     Icons.accessibility,
      //     size: iconSize,
      //   ),
      //   trailing: Icon(
      //     Icons.chevron_right,
      //     size: iconSize,
      //   ),
      //   title: Text(
      //     'Demo / Test',
      //     style: TextStyle(fontSize: fontSize),
      //   ),
      //   onTap: () {
      //     Navigator.pushNamed(context, ScreenRouter.demo);
      //   },
      // ),
      ListTile(
        title: Text(
          versionString,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: fontSize - 1,
            color: Theme.of(context).accentColor,
          ),
          textAlign: TextAlign.center,
        ),
      )
    ];

    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView.separated(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        itemCount: menuItems.length,
        itemBuilder: (context, i) {
          return menuItems[i];
        },
        separatorBuilder: (context, i) {
          // hide the divider for first entry
          if (i > 0)
            return Divider();
          else
            return Divider(
              thickness: 0,
              height: 4,
              color: Colors.transparent,
            );
        },
      ),
    );
  }
}
