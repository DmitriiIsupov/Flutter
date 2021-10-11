/*
This program is a firmware starterkit for ESP8266/ESP32 for programming commercial-grade IoT
edge-devices for remote control and data collection (telemetry) over MQTT protocol.

Business inquiries for customization and projects can be sent to: <info@orison.biz>

Copyright 2020 (c) Orison Technologies <https://orison.biz/>
*/

#include <FS.h>  //this needs to be first
// the rest of the includes
#include <Adafruit_Sensor.h>
#include <Arduino.h>
#include <ArduinoJson.h>
#include <AsyncDelay.h>
#include <DHT.h>
#include <DebounceEvent.h>
#include <ESP8266WiFi.h>
#include <NTPClient.h>
#include <PubSubClient.h>
#include <Ticker.h>
#include <Time.h>
#include <TimeLib.h>
#include <WiFiManager.h>
#include <WiFiUdp.h>

#include "Flasher.cpp"
#include "Uptime.cpp"

// SERVER INFO
#define _VERSION "ESP IoT Device Starter Kit v1.4.0"
#define _HOSTNAME "ESP-IoT-Device1-"

// MQTT TOPICS
#define _MQTT_BASE "devices/esp01"

#define _MQTT_LOG _MQTT_BASE "/log"
#define _MQTT_UPTIME _MQTT_BASE "/uptime"

#define _MQTT_SET_PING _MQTT_BASE "/set/ping"
#define _MQTT_GET_PING _MQTT_BASE "/get/ping"

#define _MQTT_SET_PORT1 _MQTT_BASE "/set/port1"
#define _MQTT_GET_PORT1 _MQTT_BASE "/get/port1"

#define _MQTT_SET_PORT2 _MQTT_BASE "/set/port2"
#define _MQTT_GET_PORT2 _MQTT_BASE "/get/port2"

#define _MQTT_SET_BEEPER _MQTT_BASE "/set/beeper"
#define _MQTT_GET_BEEPER _MQTT_BASE "/get/beeper"

#define _MQTT_SET_SENSOR_DATA _MQTT_BASE "/set/sensor_data"
#define _MQTT_GET_SENSOR_DATA _MQTT_BASE "/get/sensor_data"

// OUTPUT PINS
#define _PIN_OUT_PORT1 4
#define _PIN_OUT_PORT2 5
#define _PIN_OUT_BEEPER 13
#define _PIN_OUT_LED 15

// INPUT PINS
#define _PIN_IN_PORT1 14
#define _PIN_IN_PORT2 2

// SENSOR PINS
#define _PIN_DHT_SENSOR 12

#define _DELAY_BUTTON 500
#define _DELAY_BEEPER 1000
#define _DELAY_BUTTON_LONG_PRESS 8000

// every 5 minutes
#define _DELAY_SENSOR_DATA 300 * 1000

#define _DELAY_SYSTEM_STEPS 1500

//#define DHT_TYPE  DHT11   // for DHT 11 type sensor
#define DHT_TYPE DHT22  // for DHT 22 (AM2302), AM2321 type sensor

// ***************** function declarations ********************
void mqttCallback(char *topic, byte *payload, unsigned int length);
void log(String message, bool sendMQTT = false);
boolean isValidNumber(String str);

void connectWiFi();
void connectMqtt();
void resetWiFiSettings();
void wifiConfigModeCallback(WiFiManager *myWiFiManager);
void tickerWifiMqttConfigCallback();
void tickerOneSecondCallback();

time_t syncSystemTime();
String getSystemDateTime();
void publishUptime();

bool loadConfigFile();
bool saveConfigFile();
void saveConfigCallback();

void openPort(int portNumber);
void startBeeper();
void getSensorData();

// Strings
String systemIpInfo;

WiFiClient wifiClient;
PubSubClient mqttClient(wifiClient);

// for wifiManager
// to save settings, Spiffs, FS
const char *CONFIG_FILE = "/config.json";

bool shouldSaveConfig = false;

char mqttServer[40] = "";
char mqttPort[7] = "";
char mqttUser[40] = "";
char mqttPass[40] = "";

Uptime systemUptime;

// time string
char strTime[32];

// NTP clock
WiFiUDP ntpUDP;

// You can specify the time server pool and the offset (in seconds, can be
// changed later with setTimeOffset() ). Additionally you can specify the
// update interval (in milliseconds, can be changed using setUpdateInterval() ).
NTPClient timeClient(ntpUDP, "europe.pool.ntp.org", (60 * 60 * 5), (60000 * 60));

Ticker tickerWiFiMqttConfig;
Ticker tickerOneSecond;

// delays
AsyncDelay delayPort1;
AsyncDelay delayPort2;  // for auto reset the state (not used)
AsyncDelay delayBeeper;
AsyncDelay delaySensorData;

bool isPort1Pressed = false;
bool isPort2Pressed = false;
bool isBeeperStarted = false;

DebounceEvent *buttonPort1;
DebounceEvent *buttonPort2;

// LED and buzzer flash patterns
uint32_t sequencePing[] = {100, 80, 100, 80, 100, 80, 0};
uint32_t sequenceBeep[] = {500, 250, 0};
uint32_t sequenceReady[] = {1600, 800, 0};

Flasher flasherPing(_PIN_OUT_LED, sequencePing, false);
Flasher flasherBeep(_PIN_OUT_BEEPER, sequenceBeep, false);
Flasher flasherReady(_PIN_OUT_LED, sequenceReady, true);

// Sensors
DHT dht(_PIN_DHT_SENSOR, DHT_TYPE);

// ************************ Functions ***********************
// ==========================================================
// called when data in MQTT is received
void mqttCallback(char *topic, byte *payload, unsigned int length) {
    String strPayload = "";
    String strTopic = String(topic);

    for (uint8_t i = 0; i < length; i++) {
        strPayload += (char)payload[i];
    }

    String msg = "MQTT: " + strTopic + ": " + strPayload;
    log(msg);

    // check for matching mqtt topic
    // "ping" command
    if (strTopic.indexOf(_MQTT_SET_PING) >= 0) {
        if (strPayload == "ping") {
            mqttClient.publish(_MQTT_GET_PING, "pong");
            log("Ping replied");
            publishUptime();

            flasherPing.start();
        }
    }

    // "data" command
    if (strTopic.indexOf(_MQTT_SET_SENSOR_DATA) >= 0) {
        if (strPayload == "data")
            getSensorData();
    }

    // "beep" command
    if (strTopic.indexOf(_MQTT_SET_BEEPER) >= 0) {
        if (strPayload == "beep")
            startBeeper();
    }

    // "open" command for port 1
    if (strTopic.indexOf(_MQTT_SET_PORT1) >= 0) {
        if (strPayload == "open") {
            openPort(1);
        }
    }

    // "open" or "close" command for port 2
    if (strTopic.indexOf(_MQTT_SET_PORT2) >= 0) {
        if (strPayload == "open") {
            isPort2Pressed = false;
            openPort(2);
        }
        if (strPayload == "close") {
            isPort2Pressed = true;
            openPort(2);
        }
    }
}

// ==========================================================
void tickerOneSecondCallback() {
    //publish system uptime every hour
    // if ((systemUptime.Minutes + systemUptime.Seconds) == 0) {}

    //publish system uptime every minute
    if (systemUptime.Seconds == 0) {
        publishUptime();
    }

    //publish sensor data every 5 minutes
    // if ((systemUptime.Minutes % 5) == 0) {
    //     if (systemUptime.Seconds == 0) {
    //         log("tickerOneSecondCallback: Send sensor data");
    //         getSensorData();
    //     }
    // }
}

// ==========================================================
void tickerWifiMqttConfigCallback() {
    //toggle state
    int state = digitalRead(_PIN_OUT_LED);  // get the current state of GPIO pin
    digitalWrite(_PIN_OUT_LED, !state);     // set pin to the opposite state
}

// ==========================================================
//gets called when WiFiManager enters configuration mode
void wifiConfigModeCallback(WiFiManager *myWiFiManager) {
    log("Entered WiFi Config Mode...");
    log("AP IP: " + WiFi.softAPIP().toString());

    //if you used auto generated SSID, print it
    log("AP Setup at " + myWiFiManager->getConfigPortalSSID());
}

// ==========================================================
void connectWiFi() {
    WiFi.enableAP(false);

    log("Connecting WiFi...");

    // Set hostname, called before WiFi.begin()
    String hostName = String(_HOSTNAME) + WiFi.macAddress().substring(9);
    hostName.replace(":", "");
    WiFi.hostname(hostName);

    tickerWiFiMqttConfig.attach(0.15, tickerWifiMqttConfigCallback);

    // Connect using WiFiManager
    // Local initialization. Once its business is done, there is no need to keep it around
    WiFiManager wifiManager;

    //reset settings - for testing
    // wifiManager.resetSettings();

    //set callback that gets called when connecting to previous WiFi fails, and enters Access Point mode
    wifiManager.setAPCallback(wifiConfigModeCallback);

    wifiManager.setSaveConfigCallback(saveConfigCallback);

    //sets timeout until configuration portal gets turned off
    //useful to make it all retry or go to sleep
    //in seconds
    wifiManager.setConfigPortalTimeout(120);

    //sets timeout to attempt conecting WiFI
    wifiManager.setConnectTimeout(15);

    loadConfigFile();

    // set up some additional parameters
    WiFiManagerParameter custom_text("<p><b>MQTT Settings</b></p><hr/>");

    WiFiManagerParameter custom_mqtt_server("mqttServer", "MQTT Broker", mqttServer, 40);
    WiFiManagerParameter custom_mqtt_port("mqttPort", "MQTT Port", mqttPort, 10);
    WiFiManagerParameter custom_mqtt_user("mqttUser", "MQTT User", mqttUser, 40);
    WiFiManagerParameter custom_mqtt_pass("mqttPass", "MQTT Password", mqttPass, 40);

    wifiManager.addParameter(&custom_text);
    wifiManager.addParameter(&custom_mqtt_server);
    wifiManager.addParameter(&custom_mqtt_port);
    wifiManager.addParameter(&custom_mqtt_user);
    wifiManager.addParameter(&custom_mqtt_pass);

    //fetches SSID and password and tries to connect
    //if it does not connect it starts an access point with the specified name
    //here  "AutoConnectAP"
    //and goes into a blocking loop awaiting configuration
    if (!wifiManager.autoConnect(String(hostName + "-ConfigAP").c_str())) {
        log("Failed to connect and hit timeout");

        digitalWrite(_PIN_OUT_LED, LOW);

        //reset and try again, or maybe put it to deep sleep
        ESP.restart();
        delay(_DELAY_SYSTEM_STEPS);
    }

    //if you get here you have connected to the WiFi
    // log("Connected... yey :)");
    // Serial.println();

    strcpy(mqttServer, custom_mqtt_server.getValue());
    strcpy(mqttPort, custom_mqtt_port.getValue());
    strcpy(mqttUser, custom_mqtt_user.getValue());
    strcpy(mqttPass, custom_mqtt_pass.getValue());

    // save the custom parameters to FS
    if (shouldSaveConfig) {
        saveConfigFile();
        shouldSaveConfig = false;
    }

    String ip = WiFi.localIP().toString();
    systemIpInfo = "IP: " + ip + " Hostname: " + hostName;
    log("WiFi connected at SSID: [" + WiFi.SSID() + "] " + systemIpInfo);

    digitalWrite(_PIN_OUT_LED, LOW);
    tickerWiFiMqttConfig.detach();
    delay(_DELAY_SYSTEM_STEPS);
}

// ==========================================================
void resetWiFiSettings() {
    flasherReady.stop();

    log("Going to reset WiFi settings...");

    // blink LED
    for (byte i = 0; i < 3; i++) {
        digitalWrite(_PIN_OUT_LED, HIGH);
        delay(120);
        digitalWrite(_PIN_OUT_LED, LOW);
        delay(120);
    }

    delay(_DELAY_SYSTEM_STEPS);

    WiFiManager wifiManager;

    //reset wifi settings
    wifiManager.resetSettings();

    log("Rebooting device...");
    delay(500);

    //reset device
    ESP.restart();
    delay(_DELAY_SYSTEM_STEPS);
}

// ==========================================================
void connectMqtt() {
    log("Connecting to MQTT broker [" + String(mqttServer) + "]...");

    tickerWiFiMqttConfig.attach(0.05, tickerWifiMqttConfigCallback);

    int port = 1883;
    if (isValidNumber(String(mqttPort))) {
        port = atoi(mqttPort);
    } else {
        log("ERR - Invalid MQTT port defined in configs, using default port 1883");
    }

    mqttClient.setServer(mqttServer, port);
    mqttClient.setCallback(mqttCallback);

    // connect and re-try until connected
    while (!mqttClient.connect(mqttServer, mqttUser, mqttPass)) {
        delay(500);

        digitalWrite(_PIN_OUT_LED, LOW);
        tickerWiFiMqttConfig.detach();

        delay(_DELAY_SYSTEM_STEPS);

        return;
    }

    // subscribe to data streams
    mqttClient.subscribe(_MQTT_SET_PING);
    mqttClient.subscribe(_MQTT_SET_PORT1);
    mqttClient.subscribe(_MQTT_SET_PORT2);
    mqttClient.subscribe(_MQTT_SET_BEEPER);
    mqttClient.subscribe(_MQTT_SET_SENSOR_DATA);

    log("MQTT broker connected", true);

    digitalWrite(_PIN_OUT_LED, LOW);
    tickerWiFiMqttConfig.detach();
    delay(_DELAY_SYSTEM_STEPS);
}

// ==========================================================
// sync system time
time_t syncSystemTime() {
    // update time from NTP to system time
    return timeClient.getEpochTime();
}

// ==========================================================
// get system date time string
String getSystemDateTime() {
    // "dd-Mmm-yyyy hh:mm:ss"
    sprintf(strTime, "%02d-%s-%04d %02d:%02d:%02d", day(), monthShortStr(month()), year(), hour(), minute(), second());
    return strTime;
}

// ==========================================================
void publishUptime() {
    String timeString = systemUptime.getUptime();

    // publish update on MQTT
    mqttClient.publish(_MQTT_UPTIME, timeString.c_str(), true);

    log("System Uptime: " + timeString, true);
}

// ==========================================================
// log to serial and MQTT
void log(String message, bool sendMQTT) {
    String logMessage = "Log: " + message;

    // write to serial
    Serial.println(logMessage);

    // send to MQTT
    if (sendMQTT && mqttClient.connected()) {
        String mqttMessage = getSystemDateTime() + " | " + message;
        mqttClient.publish(_MQTT_LOG, mqttMessage.c_str());
    }
}

// ==========================================================
bool saveConfigFile() {
    // write configs to local file store
    log("Saving config file...");
    DynamicJsonBuffer jsonBuffer;
    JsonObject &json = jsonBuffer.createObject();

    json["mqttServer"] = mqttServer;
    json["mqttPort"] = mqttPort;
    json["mqttUser"] = mqttUser;
    json["mqttPass"] = mqttPass;

    // Open file for writing
    File file = SPIFFS.open(CONFIG_FILE, "w");
    if (!file) {
        log("ERR - Failed to open config file for saving");
        return false;
    }

    json.prettyPrintTo(Serial);
    Serial.println("");

    // Write data to file and close it
    json.printTo(file);
    file.close();

    log("Config file was successfully saved");
    return true;
}

// ==========================================================
void saveConfigCallback() {
    //callback notifying us of the need to save config
    log(">>> Should save config!");
    shouldSaveConfig = true;
}

// ==========================================================
bool loadConfigFile() {
    //clean FS, for testing
    //SPIFFS.format(); // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    //read configuration from FS json
    log("Mounting FS...");

    if (SPIFFS.begin()) {
        log("FS mounted.");
        if (SPIFFS.exists(CONFIG_FILE)) {
            //file exists, reading and loading
            log("Reading config file... ");
            File configFile = SPIFFS.open(CONFIG_FILE, "r");
            if (configFile) {
                log("Config file opened and retrieved data: ");
                size_t size = configFile.size();

                // Allocate a buffer to store contents of the file.
                std::unique_ptr<char[]> buf(new char[size]);

                configFile.readBytes(buf.get(), size);
                DynamicJsonBuffer jsonBuffer;
                JsonObject &json = jsonBuffer.parseObject(buf.get());
                json.prettyPrintTo(Serial);
                Serial.println("");

                if (json.success()) {
                    // set up the extra parameters
                    if (json.containsKey("mqttServer")) {
                        strcpy(mqttServer, json["mqttServer"]);
                    }
                    if (json.containsKey("mqttPort")) {
                        strcpy(mqttPort, json["mqttPort"]);
                    }
                    if (json.containsKey("mqttUser")) {
                        strcpy(mqttUser, json["mqttUser"]);
                    }
                    if (json.containsKey("mqttPass")) {
                        strcpy(mqttPass, json["mqttPass"]);
                    }

                    log("Successfully loaded json config");
                } else {
                    log("ERR - failed to load json config");
                    return false;
                }
            }
        }
    } else {
        log("ERR - failed to mount FS");
        return false;
    }
    //end read

    return true;
}

// ==========================================================
boolean isValidNumber(String str) {
    if (!(str.charAt(0) == '+' || str.charAt(0) == '-' || isDigit(str.charAt(0))))
        return false;

    for (byte i = 1; i < str.length(); i++) {
        if (!(isDigit(str.charAt(i)) || str.charAt(i) == '.'))
            return false;
    }
    return true;
}

// ==========================================================
// sound the beeper
void startBeeper() {
    isBeeperStarted = true;
    delayBeeper.start(_DELAY_BEEPER, AsyncDelay::MILLIS);

    // sound the beeper
    digitalWrite(_PIN_OUT_BEEPER, LOW);
    digitalWrite(_PIN_OUT_LED, HIGH);

    // send MQTT ack
    mqttClient.publish(_MQTT_GET_BEEPER, "beep");

    log("Beeper started");
}

// ==========================================================
// open the port
void openPort(int portNumber) {
    if (portNumber <= 0 || portNumber >= 10) {
        log("ERR: Invalid port number");
        return;
    }

    if (portNumber == 1) {
        isPort1Pressed = true;
        delayPort1.start(_DELAY_BUTTON, AsyncDelay::MILLIS);

        // set Port 1 to ON
        digitalWrite(_PIN_OUT_PORT1, LOW);
        startBeeper();

        // send MQTT ack
        mqttClient.publish(_MQTT_GET_PORT1, "open");

        //debug: write to serial
        log("Port 1: OPEN", true);
    }

    if (portNumber == 2) {
        // Toggle Port 2
        if (isPort2Pressed == true) {
            // set Port 2 to OFF
            digitalWrite(_PIN_OUT_PORT2, LOW);
            // send MQTT ack
            mqttClient.publish(_MQTT_GET_PORT2, "close", true);

            startBeeper();
            isPort2Pressed = false;
        } else if (isPort2Pressed == false) {
            // set Port 2 to ON
            digitalWrite(_PIN_OUT_PORT2, HIGH);
            // send MQTT ack
            mqttClient.publish(_MQTT_GET_PORT2, "open", true);

            startBeeper();
            isPort2Pressed = true;
        }

        //debug: write to serial
        log("Port 2: " + String(isPort2Pressed ? "OPEN" : "CLOSED"), false);
    }
}

// ==========================================================
// get sensor data: temperature and humidity
void getSensorData() {
    // Reading temperature or humidity takes about 250 milliseconds!
    // Sensor readings may also be up to 2 seconds 'old' (its a very slow sensor)
    float hum = dht.readHumidity();
    // Read temperature as Celsius (the default)
    float temp = dht.readTemperature();
    // Read temperature as Fahrenheit (isFahrenheit = true)
    // float f = dht.readTemperature(true);

    // Check if any reads failed and exit early (to try again).
    if (isnan(hum) || isnan(temp)) {
        log("ERR: Failed to read from DHT sensor!");
        return;
    }

    // // Compute heat index in Fahrenheit (the default)
    // float hif = dht.computeHeatIndex(f, hum);
    // // Compute heat index in Celsius (isFahrenheit = false)
    // float hic = dht.computeHeatIndex(temp, hum, false);

    // generate playload
    char buffer[5];
    // JSON message template
    String dhtPlayload =
        "{\r\n \
        \"Temp\": \"{TEMP}\",\r\n \
        \"TempUnit\": \"C\",\r\n \
        \"Hum\": \"{HUM}\",\r\n \
        \"Time\": \"{TIME}\"\r\n}";

    dhtPlayload.replace("{TEMP}", dtostrf(temp, 4, 2, buffer));
    dhtPlayload.replace("{HUM}", dtostrf(hum, 4, 2, buffer));
    dhtPlayload.replace("{TIME}", getSystemDateTime());

    // send MQTT response
    mqttClient.publish(_MQTT_GET_SENSOR_DATA, dhtPlayload.c_str());

    //debug: write to serial
    log("DHT Data: \r\n" + dhtPlayload, false);
}

// ==========================================================
void setup() {
    // init serial
    Serial.begin(115200);
    Serial.println("\n\n===== STARTING =====");

    // init IOs
    pinMode(_PIN_OUT_PORT1, OUTPUT);
    pinMode(_PIN_OUT_PORT2, OUTPUT);
    pinMode(_PIN_OUT_BEEPER, OUTPUT);
    pinMode(_PIN_OUT_LED, OUTPUT);

    // reset pins
    digitalWrite(_PIN_OUT_PORT1, HIGH);
    digitalWrite(_PIN_OUT_PORT2, HIGH);
    digitalWrite(_PIN_OUT_BEEPER, HIGH);
    digitalWrite(_PIN_OUT_LED, LOW);

    // inputs
    pinMode(_PIN_IN_PORT1, INPUT_PULLUP);
    pinMode(_PIN_IN_PORT2, INPUT_PULLUP);

    // DHT sensor
    dht.begin();

    // to handle longpress
    buttonPort1 = new DebounceEvent(_PIN_IN_PORT1, BUTTON_PUSHBUTTON | BUTTON_DEFAULT_HIGH | BUTTON_SET_PULLUP, 40, 0);
    buttonPort2 = new DebounceEvent(_PIN_IN_PORT2, BUTTON_PUSHBUTTON | BUTTON_DEFAULT_HIGH | BUTTON_SET_PULLUP, 40, 0);

    // read Button1 for input, if pressed, reset WiFi settings
    if (digitalRead(_PIN_IN_PORT1) == LOW) {
        log("Button1 pressed at boot to reset WiFi");
        resetWiFiSettings();
    }

    connectWiFi();
    connectMqtt();

    // NTP Clock setup
    timeClient.begin();
    timeClient.update();

    setSyncProvider(syncSystemTime);
    setSyncInterval(60 * 5);

    // sync time for the first time
    setTime(syncSystemTime());

    // to send system uptime
    tickerOneSecond.attach(1, tickerOneSecondCallback);

    // start async delay for sensor data
    delaySensorData.start(_DELAY_SENSOR_DATA, AsyncDelay::MILLIS);

    // signal ready state - 3 blinks
    for (byte i = 0; i < 3; i++) {
        digitalWrite(_PIN_OUT_LED, HIGH);
        delay(120);
        digitalWrite(_PIN_OUT_LED, LOW);
        delay(120);
    }

    // publish uptime
    systemUptime.update();
    publishUptime();

    // system ready message
    log("System " + systemIpInfo, true);
    String msg = String(_VERSION);
    msg.concat(" | System ready");
    log(msg, true);

    flasherPing.setup();
    flasherBeep.setup();
    flasherReady.setup();

    flasherReady.start();
}

// ==========================================================
void loop() {
    systemUptime.update();

    flasherPing.loop();
    flasherBeep.loop();
    flasherReady.loop();

    // check inputs
    // check for buttonPort1 is released
    if (unsigned int event = buttonPort1->loop()) {
        if (event == EVENT_RELEASED) {
            if (buttonPort1->getEventLength() < _DELAY_BUTTON_LONG_PRESS) {
                openPort(1);
            } else {
                // button1 long pressed!
                // reset wifi settings
                resetWiFiSettings();
            }
        }
    }

    // check for buttonPort2 is released
    if (unsigned int event = buttonPort2->loop()) {
        if (event == EVENT_RELEASED) {
            openPort(2);
        }
    }

    // NTP Clock update
    timeClient.update();

    if (WiFi.status() != WL_CONNECTED) {
        // reconnect wifi
        connectWiFi();
    }

    if (!mqttClient.connected()) {
        // reconnect mqtt
        connectMqtt();
    } else {
        // process mqtt mesages
        mqttClient.loop();
    }

    // reset port PIN states automatically after delay
    if (isPort1Pressed && delayPort1.isExpired()) {
        digitalWrite(_PIN_OUT_PORT1, HIGH);
        isPort1Pressed = false;
    }

    // stop beeper automatically after delay
    if (isBeeperStarted && delayBeeper.isExpired()) {
        isBeeperStarted = false;
        digitalWrite(_PIN_OUT_BEEPER, HIGH);
        digitalWrite(_PIN_OUT_LED, LOW);
    }

    // send sensor data and re-arm the timer
    if (delaySensorData.isExpired()) {
        delaySensorData.repeat();
        getSensorData();
    }

    delay(10);
}
