# ESP IoT Device Starter Kit

This firmware is an ESP8266/ESP32 based IoT device which provides a simple yet robust
foundation for a commercial-grade IoT device for remote control and telemetry over MQTT protocol.

The device currently controls two IOs while providing a dedicated LED light with blink behaviors
to show different states of the device, and a port for a beeper to provide audible feedback.

You can customize the device by changing or extending the IOs as needed.

Business inquiries for customization and projects can be sent to: <info@orison.biz>

Copyright 2020 (c) Orison Technologies <https://orison.biz/>

## Version Info

* Version 1.0.0 (10-Feb-2019)
* Version 1.1.0 (13-Mar-2019)
* Version 1.2.0 (27-Mar-2019)
* Version 1.3.0 (4-Apr-2020)
* Version 1.4.0 (27-Oct-2020)

## MQTT Protocol for the Device

### Base Topic

`devices/esp01`

The base topic can be modified in the source code for the macro `_MQTT_BASE`.

### Topic for Ping

#### Topic for command

`devices/esp01/set/ping`

The device will subscribe to this topic on the given MQTT broker to listen for **`ping`**
command in payload, and will publish response on the following topic:

#### Topic for response

`devices/esp01/get/ping`

Any client which wants to get the response to the ping command will subscribe to
this topic.

The device will send a reply as **`pong`** for **`ping`** command.

### Topics for Ports

These MQTT topics are assigned to IO Ports and sending commands to these topics will
change the status of the port.

`devices/esp01/set/port1`

`devices/esp01/set/port2`

Listens to command **`open`** and send back **`open`** to the following topics:

`devices/esp01/get/port1`

`devices/esp01/get/port2`

#### Port 1 Function: Auto Close

The defined `port1` uses only the **`open`** command from MQTT or from the input button
and resets the associated pin for a small amount to time, as defined in the `_DELAY_BUTTON` macro
and then automatically reverts to original state.

#### Port 2 Function: Toggle State

The `port2` is shown as the simple toggle function, which takes a command from MQTT or from the
input button, and toggles its state as per the command `open` or `close`. The `get/port2` topic also
uses the Retain functionality of MQTT to retain the last state of the port.

### Topic for Sensor Data

The device listens to command **`data`** on the following topic to publish sensor data from DHT
sensor for Temperature and Humidity with system timestamp:

`devices/esp01/set/sensor_data`

The sensor data is sent back on the following topic:

`devices/esp01/get/sensor_data`

The data is sent as a JSON object, here is an example:

``` JSON
{
  "Temp": "23.10",
  "TempUnit": "C",
  "Hum": "15.20",
  "Time": "04-Nov-2020 23:52:57"
}
```

Addtionally, the device also sends the above data every 5 minutes on the `get/sensor_data` topic
which is a good example of receiving telemetry data periodically from the devices and using it for
decision-making and presenting on IoT dashboards.

### Topic for Beeper

`devices/esp01/set/beeper`

Sounds the beeper on the device when **`beep`** command is sent and replies on following
topic with **`beep`**:

`devices/esp01/get/beeper`

### Topic for Uptime

`devices/esp01/uptime`

The device sends uptime on this topic every five minutes on this topic. Note that this topic uses
Retain feature of MQTT protocol which retains the last message on the broker. This retained message
is then delivered to any new client as it is connected to the broker and subscribes to this topic.

### Topic for Log

`devices/esp01/log`

The device sends all events log to this topic.

## Device Functions

### WiFi and MQTT Configurations in AP Mode and Captive Portal

The device supports persistent configuration for WiFi Access, MQTT Broker and its credentials.
There are two ways to enter in the AP Mode to set these configuration:

1. Keep the Button1 pressed at power on or reset and the device will enter the AP mode.
2. Long-press Button1 for 8 seconds and the device will reboot and enter the AP mode on the next boot.

Once on AP mode and you can find the device on your mobile WiFi discovery. The device implements
the WiFi Captive Portal (Automatically redirects to the settings webpage), so as soon as you
connect your PC or Smartphone to this device's WiFi Access Point, you will automatically be
redirected to the WiFi and MQTT Settings page. On this page you can choose the AP with internet
access which the device will use to connect to the internet, and also save your MQTT Broker, Port,
Login and Password.

Once you choose an AP and save your settings, the device will reboot and will use the new settings to
connect to the internet and provided MQTT Broker.

### Log on Serial Port and MQTT

The device sends log messages to serial port of all system and data activity, and send some of data
activity to MQTT log topic defined above. Log on serial port is a great way to troubleshoot and
diagnose any problems.

### Public MQTT Broker for Testing

You can use any public MQTT Broker such as `broker.hivemq.com` at standard port `1883` for testing
purposes in device settings and Desktop and Mobile MQTT client. More details can be found at
<https://www.hivemq.com/public-mqtt-broker/>. You can just use their web based MQTT client at
<http://www.hivemq.com/demos/websocket-client/> and subscribe to the MQTT topic `devices/esp01/#`
to listen to all communications from this device. Make sure to use Websocket port `8000` when
connecting to public MQTT broker using the web based client.
