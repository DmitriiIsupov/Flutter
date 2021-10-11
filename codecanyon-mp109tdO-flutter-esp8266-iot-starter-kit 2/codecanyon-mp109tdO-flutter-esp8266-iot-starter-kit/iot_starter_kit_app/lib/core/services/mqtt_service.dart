import 'dart:async';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:mqtt_client/mqtt_client.dart';

/// Custom event type for events and commands
enum EspEventType {
  OpenPort,
  ClosePort,
  GetData,
  Ping,
  Beep,
  Uptime,
  Log,
  System,
}

/// This class is used to carry MQTT commands and Responses
class EspMessage {
  EspEventType espEventType;
  String command;
  String parameter;

  EspMessage({this.espEventType, this.command, this.parameter});
}

class MqttService {
  // ESP IoT MQTT Topics
  static const String _MQTT_BASE_DEVICE = ""; // "/node3d" // for testing

  static const String _MQTT_BASE = "devices/esp01" + _MQTT_BASE_DEVICE;

  static const _MQTT_LOG = _MQTT_BASE + "/log";
  static const _MQTT_UPTIME = _MQTT_BASE + "/uptime";

  static const _MQTT_SET_PING = _MQTT_BASE + "/set/ping";
  static const _MQTT_GET_PING = _MQTT_BASE + "/get/ping";

  static const _MQTT_SET_PORT1 = _MQTT_BASE + "/set/port1";
  static const _MQTT_GET_PORT1 = _MQTT_BASE + "/get/port1";

  static const _MQTT_SET_PORT2 = _MQTT_BASE + "/set/port2";
  static const _MQTT_GET_PORT2 = _MQTT_BASE + "/get/port2";

  static const _MQTT_SET_BEEPER = _MQTT_BASE + "/set/beeper";
  static const _MQTT_GET_BEEPER = _MQTT_BASE + "/get/beeper";

  static const _MQTT_SET_SENSOR_DATA = _MQTT_BASE + "/set/sensor_data";
  static const _MQTT_GET_SENSOR_DATA = _MQTT_BASE + "/get/sensor_data";

  MqttServerClient _mqttClient;
  StreamController<EspMessage> _espMessageStream;
  StreamController<MqttConnectionState> _mqttConnectionStateStream;

  Stream<MqttPublishMessage> get mqttMessageStream => _mqttClient.published;
  Stream<EspMessage> get espMessageStream => _espMessageStream.stream;
  Stream<MqttConnectionState> get mqttConnectionStateStream =>
      _mqttConnectionStateStream.stream;
  MqttConnectionState get connectionState => _mqttClient.connectionStatus.state;

  MqttService() {
    _mqttClient = new MqttServerClient('', '');
    _espMessageStream = new BehaviorSubject();
    _mqttConnectionStateStream = new BehaviorSubject();
  }

  dispose() {
    _espMessageStream.close();
    _mqttConnectionStateStream.close();
  }

  Future<bool> connect({
    String mqttBroker,
    int port,
    String login,
    String password,
  }) async {
    // cleanup
    if (_mqttClient != null) {
      if (_mqttClient.connectionStatus.state == MqttConnectionState.connected)
        _mqttClient.disconnect();
    }

    // send new connection state
    _mqttConnectionStateStream.sink.add(MqttConnectionState.connecting);

    _mqttClient = new MqttServerClient('', '');
    _mqttClient.logging(on: false);
    _mqttClient.keepAlivePeriod = 20;
    _mqttClient.onConnected = _onConnected;
    _mqttClient.onDisconnected = _onDisconnected;
    _mqttClient.onSubscribed = _onSubscribed;

    // return await Future.delayed(Duration(seconds: 2));
    final MqttConnectMessage connMessage = MqttConnectMessage()
        .withClientIdentifier('esp_iot_app_${Uuid().v1().replaceAll('-', '')}')
        .keepAliveFor(20) // Must agree with the keep alive set above or not set
        // .withWillTopic(
        //     'willtopic') // If you set this you must set a will message
        // .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);

    _mqttClient.connectionMessage = connMessage;
    _mqttClient.server = mqttBroker;
    _mqttClient.port = port;

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.
    try {
      await _mqttClient.connect(login, password);
    } on Exception catch (e) {
      print('_mqttClient::client exception - $e');
      _mqttClient.disconnect();
      return false;
    }

    /// Check if we are connected
    if (_mqttClient.connectionStatus.state == MqttConnectionState.connected) {
      return true;
    } else {
      /// Use status here rather than state if you also want the broker return code.
      print(
          '_mqttClient::ERROR connection failed - disconnecting, status is ${_mqttClient.connectionStatus}');

      _mqttClient.disconnect();

      return false;
    }
  }

  void disconnect() {
    _mqttClient.disconnect();
  }

  void _onConnected() {
    print('_mqttClient::_OnConnected Client connection was successful');

    // subscribe to topics
    _mqttClient.subscribe(_MQTT_GET_PORT1, MqttQos.atMostOnce);
    _mqttClient.subscribe(_MQTT_GET_PORT2, MqttQos.atMostOnce);
    _mqttClient.subscribe(_MQTT_GET_PING, MqttQos.atMostOnce);
    _mqttClient.subscribe(_MQTT_GET_BEEPER, MqttQos.atMostOnce);
    _mqttClient.subscribe(_MQTT_GET_SENSOR_DATA, MqttQos.atMostOnce);
    _mqttClient.subscribe(_MQTT_LOG, MqttQos.atMostOnce);
    _mqttClient.subscribe(_MQTT_UPTIME, MqttQos.atMostOnce);

    _mqttConnectionStateStream.sink.add(MqttConnectionState.connected);

    // _mqttClient.published.listen(_getUpdates);
    _mqttClient.updates.listen(_onData);
  }

  /// The unsolicited disconnect callback
  void _onDisconnected() {
    print(
      '_mqttClient::_OnDisconnected client callback - Client disconnection',
    );
    if (_mqttClient.connectionStatus.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      print(
        '_mqttClient::_OnDisconnected callback is solicited, this is correct',
      );
    }
    _mqttConnectionStateStream.sink.add(MqttConnectionState.disconnected);
  }

  void _onSubscribed(String topic) {
    print('_mqttClient::_onSubscribed confirmed for topic $topic');
  }

  void publishMessage(String topic, String payload) {}

  /// send MQTT message to broker
  /// set [command] and its parameters, if required
  /// for example (EspEventType.OpenPort, "2") to open port 2
  void sendCommand(EspEventType command, String parameter) {
    String payload;
    String topic;

    if (_mqttClient.connectionStatus.state != MqttConnectionState.connected) {
      print(
        '_mqttClient::sendCommand called while MqttConnectionState is not Connected',
      );
      return;
    }

    // prepare MQTT message
    switch (command) {
      case EspEventType.OpenPort:
        payload = 'open';
        if (parameter == "1") {
          topic = _MQTT_SET_PORT1;
        } else if (parameter == "2") {
          topic = _MQTT_SET_PORT2;
        }
        break;
      case EspEventType.ClosePort:
        payload = 'close';
        if (parameter == "1") {
          topic = _MQTT_SET_PORT1;
        } else if (parameter == "2") {
          topic = _MQTT_SET_PORT2;
        }
        break;
      case EspEventType.GetData:
        topic = _MQTT_SET_SENSOR_DATA;
        payload = 'data';
        break;
      case EspEventType.Ping:
        topic = _MQTT_SET_PING;
        payload = 'ping';
        break;
      case EspEventType.Beep:
        topic = _MQTT_SET_BEEPER;
        payload = 'beep';
        break;
      default:
    }

    // send to mqtt client
    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    _mqttClient.publishMessage(topic, MqttQos.exactlyOnce, builder.payload);
  }

  // void _getUpdates(MqttPublishMessage message) {
  //   print(
  //     '_mqttClient::_getUpdates topic ${message.variableHeader.topicName}, payload ${message.payload.message.toString()}',
  //   );
  // }

  void _onData(List<MqttReceivedMessage<MqttMessage>> messages) {
    messages.forEach((listItem) {
      MqttPublishMessage message = listItem.payload;

      final topic = listItem.topic;
      final payload = MqttPublishPayload.bytesToStringAsString(
        message.payload.message,
      );

      print('_mqttClient::_onData topic: $topic, payload: $payload');

      _processData(topic, payload);
    });
  }

  /// process incoming data and adds corresponding events to [espMessageStream]
  /// as [EspMessage] class instance
  void _processData(String topic, String payload) {
    if (topic.contains('/uptime')) {
      _espMessageStream.sink.add(EspMessage(
        espEventType: EspEventType.Uptime,
        command: "Uptime: $payload",
        parameter: payload,
      ));
    }

    if (topic.contains('get/ping')) {
      _espMessageStream.sink.add(EspMessage(
        espEventType: EspEventType.Ping,
        command: payload,
        parameter: "",
      ));
    }

    if (topic.contains('get/beep')) {
      _espMessageStream.sink.add(EspMessage(
        espEventType: EspEventType.Beep,
        command: "Beep on Device",
        parameter: "",
      ));
    }

    if (topic.contains('/log')) {
      _espMessageStream.sink.add(EspMessage(
        espEventType: EspEventType.Log,
        command: payload,
        parameter: "",
      ));
    }
    if (topic.contains('/get/port1')) {
      if (payload == "open")
        _espMessageStream.sink.add(EspMessage(
          espEventType: EspEventType.OpenPort,
          command: "Port 1: Open",
          parameter: "1",
        ));
      else if (payload == "close")
        _espMessageStream.sink.add(EspMessage(
          espEventType: EspEventType.ClosePort,
          command: "Port 1: Close",
          parameter: "1",
        ));
    }
    if (topic.contains('/get/port2')) {
      if (payload == "open")
        _espMessageStream.sink.add(EspMessage(
          espEventType: EspEventType.OpenPort,
          command: "Port 2: Open",
          parameter: "2",
        ));
      else if (payload == "close")
        _espMessageStream.sink.add(EspMessage(
          espEventType: EspEventType.ClosePort,
          command: "Port 2: Close",
          parameter: "2",
        ));
    }

    if (topic.contains('/get/sensor_data')) {
      _espMessageStream.sink.add(EspMessage(
        espEventType: EspEventType.GetData,
        command: payload,
        parameter: "",
      ));
    }
  }
}
