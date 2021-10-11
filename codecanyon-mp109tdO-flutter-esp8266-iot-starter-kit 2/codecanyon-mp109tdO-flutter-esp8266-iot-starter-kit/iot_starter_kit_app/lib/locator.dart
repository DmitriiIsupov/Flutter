import 'package:get_it/get_it.dart';
import 'package:iot_starter_kit_app/core/services/mqtt_service.dart';
import 'package:iot_starter_kit_app/core/services/settings_service.dart';

/// the main service locator
GetIt locator = GetIt.asNewInstance();

void setupLocator() {
  locator.registerSingleton(SettingsService());
  locator.registerSingleton(MqttService());
}
