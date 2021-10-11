import 'package:flutter/material.dart';
import 'package:iot_starter_kit_app/core/constants.dart';
import 'package:iot_starter_kit_app/core/services/settings_service.dart';
import 'package:iot_starter_kit_app/generated/locale_base.dart';
import 'package:iot_starter_kit_app/locator.dart';
import 'package:iot_starter_kit_app/utils/locale_delegate.dart';
import 'package:iot_starter_kit_app/utils/settings_helper.dart';
import 'package:preferences/preference_service.dart';
import 'package:preferences/preferences.dart';
import 'package:theme_provider/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  LocaleBase lang;

  @override
  Widget build(BuildContext context) {
    lang = Localizations.of<LocaleBase>(context, LocaleBase);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.ScreenSettings.settingsTitle),
      ),
      body: buildSettingsBody(context),
    );
  }

  /// construct the setting elements
  buildSettingsBody(BuildContext context) {
    final settingsService = locator.get<SettingsService>();

    // list of languages for Display
    final languageLocalNames = LocaleDelegate.getLanguagesList()
        .map((language) => language.localName)
        .toList();

    final languageKeys =
        LocaleDelegate.getLanguagesMap().keys.toList(growable: false);

    // get saved language
    var savedLanguage = SettingsHelper.getSavedLanguage();
    if (savedLanguage == null) {
      savedLanguage = LocaleDelegate.getLanguagesList().firstWhere((language) =>
          language.languageCode ==
          LocaleDelegate.getDeviceLocale().languageCode);
    }

    final currentLanguageKey = savedLanguage.localeKey;

    return PreferencePage(
      [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: PreferenceTitle(lang.ScreenSettings.sectionUISettings),
        ),
        DropdownPreference(
          lang.ScreenSettings.languageLabel,
          SettingsHelper.language,
          defaultVal: currentLanguageKey,
          values: languageKeys,
          displayValues: languageLocalNames,
          onChange: (value) {
            // check if same language was selected
            if (value == currentLanguageKey) return;

            // get locale by localeKey
            var newLocale = LocaleDelegate.getLanguageByLocaleKey(value).locale;

            // trigger the change language event
            settingsService.setAppLocale(newLocale);
          },
        ),
        SwitchPreference(
          lang.ScreenSettings.enableDarkTheme,
          SettingsHelper.enable_dark_theme,
          onEnable: () {
            ThemeProvider.controllerOf(context).setTheme('dark');
          },
          onDisable: () {
            ThemeProvider.controllerOf(context).setTheme('light');
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: PreferenceTitle(lang.ScreenSettings.sectionMqttSettings),
        ),
        PreferenceDialogLink(
          lang.ScreenSettings.mqttCredentials,
          trailing: Icon(Icons.chevron_right),
          onPop: () {
            // send new broker to the stream to trigger a reconnect event
            settingsService.setMqttSettings(
              PrefService.getString(SettingsHelper.mqtt_broker),
            );
          },
          dialog: PreferenceDialog(
            [
              TextFieldPreference(
                lang.ScreenSettings.mqttBroker,
                SettingsHelper.mqtt_broker,
                padding: const EdgeInsets.only(top: 8.0),
                // autofocus: true,
                maxLines: 1,
                hintText: Constants.defaultMqttBroker,
                defaultVal: Constants.defaultMqttBroker,
                validator: (String str) {
                  if (str == null || str.length == 0) {
                    return lang.ScreenSettings.mqttBrokerError1;
                  }

                  // check for valid domain or IP address
                  // var regex = RegExp(
                  //   r'/^[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.[a-zA-Z]{2,}$/',
                  // );
                  // if (!regex.hasMatch(str)) {
                  //   return "Broker must be a valid domain or IP";
                  // }

                  return null;
                },
              ),
              TextFieldPreference(
                lang.ScreenSettings.mqttPort,
                SettingsHelper.mqtt_port,
                padding: const EdgeInsets.only(top: 8.0),
                maxLines: 1,
                hintText: Constants.defaultMqttPort,
                defaultVal: Constants.defaultMqttPort,
                validator: (str) {
                  if (str == null || str.trim().length == 0) {
                    return lang.ScreenSettings.mqttPortError1;
                  }
                  var port = int.tryParse(str.trim());
                  if (port == null) {
                    return lang.ScreenSettings.mqttPortError2;
                  } else if (port > 65535) {
                    return lang.ScreenSettings.mqttPortError3;
                  }
                  return null;
                },
              ),
              TextFieldPreference(
                lang.ScreenSettings.mqttLogin,
                SettingsHelper.mqtt_login,
                padding: const EdgeInsets.only(top: 8.0),
                maxLines: 1,
                hintText: 'mqtt_username',
                defaultVal: '',
              ),
              TextFieldPreference(
                lang.ScreenSettings.mqttPassword,
                SettingsHelper.mqtt_password,
                padding: const EdgeInsets.only(top: 8.0),
                obscureText: true,
                maxLines: 1,
              ),
            ],
            title: lang.ScreenSettings.mqttCredentials,
            submitText: lang.ScreenSettings.buttonSave,
            cancelText: lang.ScreenSettings.buttonCancel,
            onlySaveOnSubmit: true,
          ),
        ),
        SwitchPreference(
          lang.ScreenSettings.mqttShowLogEntries,
          SettingsHelper.show_log,
        ),
        ListTile(
          // get version info from shared preferences (set on app launch)
          title: Text(PrefService.getString(SettingsHelper.app_version_string)),
          enabled: false,
        ),
      ],
    );
  }
}
