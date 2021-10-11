/// holds constants for the APIs and others
class Constants {
  /// app name
  static const String keyApplicationName = 'iot_starter_kit_app';

  /// app name used in settings/about/title
  static const String appName = "IoT Starter Kit";
  static const String titleHome = "IoT Starter Kit";
  static const String appEdition = "Silver Edition";

  /// Google PlayStore Identifier
  static const String googlePlayIdentifier =
      'com.myiotcompany.iotstarterkitapp.iot_starter_kit_app';

  /// MQTT defaults
  /// Public MQTT Broker
  static const String defaultMqttBroker = "broker.emqx.io";

  /// Default MQTT Port
  static const String defaultMqttPort = "1883";

  /// Apple AppStore Link
  static const String googlePlayLink =
      'https://play.google.com/store/apps/details?id=com.myiotcompany.iotstarterkitapp.iot_starter_kit_app';

  /// Apple AppStore Identifier
  static const String appStoreIdentifier = '1234567890';

  /// Apple AppStore Link
  static const String appStoreLink =
      'https://itunes.apple.com/app/id1234567890';

  /// Page size for paginated API calls
  static const int apiPageSize = 20;

  /// API cache duration
  static const int apiCacheDurationHours = 48;
}
