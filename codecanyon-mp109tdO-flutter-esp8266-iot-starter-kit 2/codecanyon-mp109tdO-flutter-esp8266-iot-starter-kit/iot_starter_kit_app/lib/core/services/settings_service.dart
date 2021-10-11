import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class SettingsService {
  StreamController<Locale> _appLocale = BehaviorSubject();
  StreamController<String> _mqttSettings = BehaviorSubject();

  Stream<Locale> get appLocale {
    return _appLocale.stream;
  }

  Stream<String> get mqttSettings {
    return _mqttSettings.stream;
  }

  void setAppLocale(Locale newLocale) {
    _appLocale.sink.add(newLocale);
  }

  void setMqttSettings(String newBroker) {
    _mqttSettings.sink.add(newBroker);
  }

  dispose() {
    _appLocale.close();
    _mqttSettings.close();
  }
}
