import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class LocaleBase {
  Map<String, dynamic> _data;
  String _path;
  Future<void> load(String path) async {
    _path = path;
    final strJson = await rootBundle.loadString(path);
    _data = jsonDecode(strJson);
    initAll();
  }
  
  Map<String, String> getData(String group) {
    return Map<String, String>.from(_data[group]);
  }

  String getPath() => _path;

  LocaleCommon _Common;
  LocaleCommon get Common => _Common;
  LocaleScreenHome _ScreenHome;
  LocaleScreenHome get ScreenHome => _ScreenHome;
  LocaleScreenAbout _ScreenAbout;
  LocaleScreenAbout get ScreenAbout => _ScreenAbout;
  LocaleScreenSettings _ScreenSettings;
  LocaleScreenSettings get ScreenSettings => _ScreenSettings;
  LocaleScreenHelp _ScreenHelp;
  LocaleScreenHelp get ScreenHelp => _ScreenHelp;

  void initAll() {
    _Common = LocaleCommon(Map<String, String>.from(_data['Common']));
    _ScreenHome = LocaleScreenHome(Map<String, String>.from(_data['ScreenHome']));
    _ScreenAbout = LocaleScreenAbout(Map<String, String>.from(_data['ScreenAbout']));
    _ScreenSettings = LocaleScreenSettings(Map<String, String>.from(_data['ScreenSettings']));
    _ScreenHelp = LocaleScreenHelp(Map<String, String>.from(_data['ScreenHelp']));
  }
}

class LocaleCommon {
  final Map<String, String> _data;
  LocaleCommon(this._data);

  String getByKey(String key) {
    return _data[key];
  }

  String get menuSettings => _data["menuSettings"];
  String get menuAbout => _data["menuAbout"];
  String get menuHelp => _data["menuHelp"];
  String get popupBackToExit => _data["popupBackToExit"];
  String get deviceUptime => _data["deviceUptime"];
}

class LocaleScreenHome {
  final Map<String, String> _data;
  LocaleScreenHome(this._data);

  String getByKey(String key) {
    return _data[key];
  }

  String get homeTitle => _data["homeTitle"];
  String get graphTempLabel => _data["graphTempLabel"];
  String get graphHumidLabel => _data["graphHumidLabel"];
  String get buttonPing => _data["buttonPing"];
  String get buttonBeep => _data["buttonBeep"];
  String get buttonPort1On => _data["buttonPort1On"];
  String get buttonPort1Off => _data["buttonPort1Off"];
  String get buttonPort2On => _data["buttonPort2On"];
  String get buttonPort2Off => _data["buttonPort2Off"];
  String get logConnectionStatus => _data["logConnectionStatus"];
}

class LocaleScreenAbout {
  final Map<String, String> _data;
  LocaleScreenAbout(this._data);

  String getByKey(String key) {
    return _data[key];
  }

  String get aboutTitle => _data["aboutTitle"];
  String get appDescription => _data["appDescription"];
  String get copyright => _data["copyright"];
  String get license => _data["license"];
  String get sayHelloLabel => _data["sayHelloLabel"];
  String get emailAddress => _data["emailAddress"];
  String get emailSubject => _data["emailSubject"];
  String get privacyPolicyLabel => _data["privacyPolicyLabel"];
  String get privacyPolicyUrl => _data["privacyPolicyUrl"];
  String get viewReadMe => _data["viewReadMe"];
  String get viewChangelog => _data["viewChangelog"];
  String get viewLicense => _data["viewLicense"];
  String get openSourceLicenses => _data["openSourceLicenses"];
}

class LocaleScreenSettings {
  final Map<String, String> _data;
  LocaleScreenSettings(this._data);

  String getByKey(String key) {
    return _data[key];
  }

  String get settingsTitle => _data["settingsTitle"];
  String get sectionUISettings => _data["sectionUISettings"];
  String get languageLabel => _data["languageLabel"];
  String get enableDarkTheme => _data["enableDarkTheme"];
  String get sectionMqttSettings => _data["sectionMqttSettings"];
  String get mqttBroker => _data["mqttBroker"];
  String get mqttShowLogEntries => _data["mqttShowLogEntries"];
  String get mqttBrokerError1 => _data["mqttBrokerError1"];
  String get mqttPort => _data["mqttPort"];
  String get mqttLogin => _data["mqttLogin"];
  String get mqttPassword => _data["mqttPassword"];
  String get mqttCredentials => _data["mqttCredentials"];
  String get mqttPortError1 => _data["mqttPortError1"];
  String get mqttPortError2 => _data["mqttPortError2"];
  String get mqttPortError3 => _data["mqttPortError3"];
  String get buttonSave => _data["buttonSave"];
  String get buttonCancel => _data["buttonCancel"];
}

class LocaleScreenHelp {
  final Map<String, String> _data;
  LocaleScreenHelp(this._data);

  String getByKey(String key) {
    return _data[key];
  }

  String get helpTitle => _data["helpTitle"];
}

