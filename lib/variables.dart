library variables.global;

import 'dart:async';

import 'package:device_info/device_info.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_client.dart';

class Variable {
  DeviceInfoPlugin deviceInfo =
      DeviceInfoPlugin(); // instantiate device info plugin
  AndroidDeviceInfo androidDeviceInfo;

  String broker;

  int port;
  String clientIdentifier;
  String topic;
  String clientid;

  StreamSubscription subscription;

  double moisture = 0.0;
  double temperature = 0.0;
  double humidity = 0.0;
  double gaspercentage = 0.0;
  double waterlevel = 0.0;

  bool switchValue1 = false;
  bool switchValue2 = false;
  bool switchValue3 = false;
  bool switchValue4 = false;
  bool switchValue5 = false;
  bool switchValue6 = false;

  mqtt.MqttClient client;
  mqtt.MqttConnectionState connectionState = MqttConnectionState.disconnected;
}
