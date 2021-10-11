import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iot_starter_kit_app/core/constants.dart';
import 'package:iot_starter_kit_app/core/services/mqtt_service.dart';
import 'package:iot_starter_kit_app/core/services/settings_service.dart';
import 'package:iot_starter_kit_app/generated/locale_base.dart';
import 'package:iot_starter_kit_app/locator.dart';
import 'package:iot_starter_kit_app/screens/home/side_menu.dart';
import 'package:iot_starter_kit_app/utils/settings_helper.dart';
import 'package:iot_starter_kit_app/widgets/button_expanded.dart';
import 'package:iot_starter_kit_app/ui/ui_helpers.dart';
import 'package:iot_starter_kit_app/widgets/custom_line_chart.dart';
import 'package:iot_starter_kit_app/widgets/double_back_to_close_app.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:preferences/preference_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class LogEntry {
  final String logText;
  final DateTime logTime;
  final EspEventType logType;
  LogEntry({this.logType, this.logText, this.logTime});
}

class _HomeScreenState extends State<HomeScreen> {
  LocaleBase lang;
  final double cornerRadius = 6;
  ThemeData theme;
  Timer connectionTimer;

  StreamSubscription<MqttConnectionState> mqttConnectionStateSubscription;
  StreamSubscription<EspMessage> espMessageSubscription;
  StreamSubscription<String> settingsSubscription;

  final settingsService = locator.get<SettingsService>();
  final mqttService = locator.get<MqttService>();

  List<LogEntry> eventLog = [];

  List<double> tempData = [0, 0, 0, 0, 0, 0];
  String tempUnit = "C";
  List<double> humidData = [0, 0, 0, 0, 0, 0];
  bool port1Status =
      true; // Port1 closes in 500ms automatically after open command
  bool port2Status = false;
  bool pingStatus = true;
  bool beepStatus = true;

  String deviceUptime = "0:00:00:00";

  String mqttBroker;
  int mqttPort;
  String mqttLogin;
  String mqttPassword;

  @override
  void initState() {
    super.initState();

    // subscribe to connection state stream
    mqttConnectionStateSubscription =
        mqttService.mqttConnectionStateStream.listen(null);
    mqttConnectionStateSubscription.onData(onMqttConnectionState);

    // subscribe to ESP Message stream
    espMessageSubscription = mqttService.espMessageStream.listen(null);
    espMessageSubscription.onData(onEspMessage);

    // subscribe to settings service stream
    settingsSubscription = settingsService.mqttSettings.listen(null);
    settingsSubscription.onData(onSettingsData);

    // start timer to check connection status and
    // to request new sensor data every five seconds
    connectionTimer = new Timer.periodic(Duration(seconds: 5), onTimerCallback);

    // trigger the connection routine
    onTimerCallback(null);
  }

  @override
  void dispose() {
    mqttConnectionStateSubscription.cancel();
    espMessageSubscription.cancel();
    settingsSubscription.cancel();
    super.dispose();
  }

  bool ifConnected() {
    return mqttService.connectionState == MqttConnectionState.connected;
  }

  /// Load MQTT credentials from settings
  loadMqttCredentials() {
    // load mqtt credentials from settings
    mqttBroker = PrefService.getString(SettingsHelper.mqtt_broker);
    mqttPort = int.parse(PrefService.getString(SettingsHelper.mqtt_port));
    mqttLogin = PrefService.getString(SettingsHelper.mqtt_login);
    mqttPassword = PrefService.getString(SettingsHelper.mqtt_password);
  }

  /// Connect mqttService
  connectMqttService() {
    if (mqttService.connectionState == null ||
        mqttService.connectionState == MqttConnectionState.disconnected) {
      loadMqttCredentials();

      // connect mqtt service
      mqttService.connect(
        mqttBroker: mqttBroker,
        port: mqttPort,
        login: mqttLogin,
        password: mqttPassword,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    lang = Localizations.of<LocaleBase>(context, LocaleBase);
    theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: buildAppBar(context),
      drawer: SideMenu(deviceUptime: deviceUptime),
      body: DoubleBackToCloseApp(
        snackBar: UIHelper.getSnackBar(
          message: Text(
            lang.Common.popupBackToExit,
            style: TextStyle(color: Colors.white),
          ),
          bgColor: theme.snackBarTheme.backgroundColor,
        ),
        child: Container(
          color: theme.scaffoldBackgroundColor,
          padding: const EdgeInsets.only(
            left: UIHelper.HorizontalSpaceVerySmall,
            right: UIHelper.HorizontalSpaceVerySmall,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              UIHelper.verticalSpaceVerySmall(),
              // row with top graphs
              Expanded(
                flex: 25,
                child: buildGraphs(context),
              ),
              UIHelper.verticalSpaceVerySmall(),
              // row with event list
              Expanded(
                flex: 100,
                child: buildEventList(context),
              ),
              // row with bottom buttons
              Padding(
                padding: EdgeInsets.only(
                  top: UIHelper.VerticalSpaceVerySmall - 5,
                  bottom: UIHelper.VerticalSpaceVerySmall - 5,
                ),
                child: buildButtons(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// build app bar with title and connection state
  Widget buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(Constants.titleHome),
      actions: <Widget>[
        // build UI for Connection State
        StreamBuilder<MqttConnectionState>(
          stream: mqttService.mqttConnectionStateStream,
          builder: (context, snapshot) {
            return Container(
              padding: EdgeInsets.only(right: 6),
              child: Center(
                child: (snapshot.data == MqttConnectionState.connected)
                    ? IconButton(
                        icon: Icon(
                          Icons.refresh,
                          size: 35,
                        ),
                        onPressed:
                            (snapshot.data == MqttConnectionState.connected)
                                ? () {
                                    mqttService.disconnect();
                                  }
                                : () {},
                      )
                    : Padding(
                        padding: EdgeInsets.only(top: 2, right: 8),
                        child: SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                      ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// build UI for graph for showing data
  Widget buildGraphs(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 5,
          // temperature graph here
          child: Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
            color: Colors.lightGreenAccent,
            elevation: 2.5,
            child: CustomLineChart(
              dataPoints: tempData,
              dataCaption: tempData[tempData.length - 1].toInt().toString() +
                  '°' +
                  tempUnit,
              chartLabel: lang.ScreenHome.graphTempLabel,
              borderRadius: cornerRadius,
              backgroundColor: Color(0xFF29211B),
              gradientColors: [
                const Color(0xFFFA0303),
                const Color(0xFFD36702),
                const Color(0xFFEB482C),
              ],
            ),
          ),
        ),
        UIHelper.horizontalSpaceVerySmall(),
        Expanded(
          flex: 5,
          // humidity graph here
          child: Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
            color: Colors.lightGreenAccent,
            elevation: 2.5,
            child: CustomLineChart(
              dataPoints: humidData,
              dataCaption:
                  humidData[humidData.length - 1].toInt().toString() + '%',
              chartLabel: lang.ScreenHome.graphHumidLabel,
              borderRadius: cornerRadius,
              backgroundColor: Color(0xFF202638),
              gradientColors: [
                const Color(0xff23b6e6),
                const Color(0xff02d39a),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// build panel for Port buttons
  Widget buildButtons(BuildContext context) {
    var theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ButtonExpanded(
              text: lang.ScreenHome.buttonPing,
              color: pingStatus ? theme.primaryColor : theme.buttonColor,
              icon: Icon(Icons.wifi_tethering),
              flex: 5,
              borderRadius: cornerRadius,
              enabled: ifConnected(),
              onPressed: () {
                setState(() {
                  pingStatus = false;
                });
                mqttService.sendCommand(EspEventType.Ping, "");
              },
            ),
            UIHelper.horizontalSpaceVerySmall(),
            ButtonExpanded(
              text: lang.ScreenHome.buttonBeep,
              color: beepStatus ? theme.primaryColor : theme.buttonColor,
              icon: Icon(Icons.volume_up),
              flex: 5,
              borderRadius: cornerRadius,
              enabled: ifConnected(),
              onPressed: () {
                setState(() {
                  beepStatus = false;
                });
                mqttService.sendCommand(EspEventType.Beep, "");
              },
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Port-1 button
            ButtonExpanded(
              text: port1Status
                  ? lang.ScreenHome.buttonPort2On
                  : lang.ScreenHome.buttonPort2Off,
              color: port1Status ? theme.primaryColor : theme.buttonColor,
              icon: Icon(Icons.filter_1),
              flex: 5,
              borderRadius: cornerRadius,
              enabled: ifConnected(),
              onPressed: () {
                setState(() {
                  port1Status = false;
                });
                mqttService.sendCommand(EspEventType.OpenPort, "1");
              },
            ),
            UIHelper.horizontalSpaceVerySmall(),
            // Port-2 button
            ButtonExpanded(
              text: port2Status
                  ? lang.ScreenHome.buttonPort2On
                  : lang.ScreenHome.buttonPort2Off,
              color: port2Status ? theme.primaryColor : theme.buttonColor,
              icon: Icon(Icons.filter_2),
              flex: 5,
              borderRadius: cornerRadius,
              enabled: ifConnected(),
              onPressed: () {
                if (port2Status)
                  mqttService.sendCommand(EspEventType.ClosePort, "2");
                else
                  mqttService.sendCommand(EspEventType.OpenPort, "2");
              },
            ),
          ],
        ),
      ],
    );
  }

  /// build panel for event list
  Widget buildEventList(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildEventLogView(),
      ],
    );
  }

  Widget buildEventLogView() {
    return Expanded(
      flex: 1,
      child: Container(
        child: Material(
          elevation: 2.5,
          color: theme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: ListView.separated(
              itemCount: eventLog.length,
              separatorBuilder: (context, index) {
                return Divider(
                  height: 5,
                );
              },
              itemBuilder: buildEventLogListItem,
            ),
          ),
        ),
      ),
    );
  }

  /// build a list item to be added to event list view
  Widget buildEventLogListItem(context, index) {
    final entry = eventLog[index];

    final double size = 40;
    IconData icon;
    Color color;

    switch (entry.logType) {
      case EspEventType.Uptime:
        icon = Icons.alarm_on;
        color = Colors.green[600];
        break;
      case EspEventType.Log:
        icon = Icons.history;
        color = Colors.amber[700];
        break;
      case EspEventType.ClosePort:
      case EspEventType.OpenPort:
        icon = Icons.swap_horizontal_circle;
        color = Colors.blue[600];
        break;
      case EspEventType.System:
        icon = Icons.info_outline;
        color = Colors.red[800];
        break;
      case EspEventType.Ping:
        icon = Icons.wifi_tethering;
        color = Colors.green[600];
        break;
      case EspEventType.Beep:
        icon = Icons.volume_up;
        color = Colors.green[600];
        break;

      default:
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          dense: true,
          onTap: () {},
          isThreeLine: false,
          contentPadding: EdgeInsets.all(0.0),
          leading: Icon(icon, size: size, color: color),
          title: Text(
            entry.logText,
            textScaleFactor: 1.1,
          ),
          subtitle: Text(timeago.format(
            DateTime.now().subtract(
              DateTime.now().difference(
                entry.logTime,
              ),
            ),
            allowFromNow: true,
          )),
        ),
      ],
    );
  }

  void onTimerCallback(Timer timer) {
    // print('==========>>> Timer Callback');
    connectMqttService();

    if (ifConnected()) {
      mqttService.sendCommand(EspEventType.GetData, "");
    }
  }

  /// on new mqtt settings event
  void onSettingsData(String newMqttBroker) {
    // reconnect with new mqtt settings
    mqttService.disconnect();
  }

  // process MQTT connection state
  void onMqttConnectionState(MqttConnectionState mqttConnectionState) {
    setState(() {
      eventLog.insert(
          0,
          LogEntry(
            logText:
                '${lang.ScreenHome.logConnectionStatus}: ${mqttConnectionState.toString().split('.')[1]}',
            logType: EspEventType.System,
            logTime: DateTime.now(),
          ));

      // maintain 30 items in the [eventLog] list
      if (eventLog.length > 30) {
        eventLog.removeLast();
      }
    });
  }

  /// process ESP Message data
  void onEspMessage(EspMessage espMessage) {
    //   print(
    //     '''=====> espMessageSubscription:
    // ${espMessage.espEventType}
    // ${espMessage.command}
    // ${espMessage.parameter}''',
    //   );

    setState(() {
      // process sensor data
      if (espMessage.espEventType == EspEventType.GetData) {
        Map<String, dynamic> sensorData = jsonDecode(espMessage.command);

        // extract temperature data
        tempData.add(double.parse(sensorData['Temp']));
        tempUnit = sensorData['TempUnit'];
        if (tempData.length > 6) {
          tempData.removeAt(0);
        }

        //extract humidity data
        humidData.add(double.parse(sensorData['Hum']));
        if (humidData.length > 6) {
          humidData.removeAt(0);
        }

        // stop processing further
        return;
      }

      if (espMessage.espEventType == EspEventType.Uptime) {
        deviceUptime = espMessage.parameter;
      }

      if (espMessage.espEventType == EspEventType.Ping) {
        pingStatus = true;
      }

      if (espMessage.espEventType == EspEventType.Beep) {
        beepStatus = true;
      }

      // set port1 status
      if (espMessage.parameter == "1") {
        port1Status = (espMessage.espEventType == EspEventType.OpenPort);
      }

      // set port2 status
      if (espMessage.parameter == "2") {
        port2Status = (espMessage.espEventType == EspEventType.OpenPort);
      }

      // if 'Show Log' settings is not set, skip this log entry
      if (espMessage.espEventType == EspEventType.Log) {
        if (!PrefService.getBool(SettingsHelper.show_log)) return;
      }

      // create an list item entry in the [eventLog] list
      eventLog.insert(
          0,
          LogEntry(
            logText: espMessage.command,
            logType: espMessage.espEventType,
            logTime: DateTime.now(),
          ));

      // maintain 30 items in the [eventLog] list
      if (eventLog.length > 30) {
        eventLog.removeLast();
      }
    });
  }

  // our parse duration function to process uptime data
  Duration parseDuration(String durationString) {
    int days = 0;
    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    List<String> parts = durationString.split(':');

    // if this is a malformed string, return zero duration
    if (parts.length == 0 || parts.length > 4) {
      return Duration.zero;
    }

    days = int.parse(parts[parts.length - 4]);
    hours = int.parse(parts[parts.length - 3]);
    minutes = int.parse(parts[parts.length - 2]);
    seconds = int.parse(parts[parts.length - 1]);

    return Duration(
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }
}
