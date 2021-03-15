import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';
import 'variables.dart';
import 'main.dart';

class Services extends ChangeNotifier {
  Variable vari = Variable();
  // MyHomePageState home = MyHomePageState();

  Future<String> getDeviceinfo() async {
    vari.androidDeviceInfo = await vari
        .deviceInfo.androidInfo; // instantiate Android Device Infoformation
    // setState(() {
    vari.clientid = vari.androidDeviceInfo.androidId.toString();
    // });
    print(vari.clientid);

    vari.broker = 'broker.hivemq.com';

    vari.port = 1883;
    vari.clientIdentifier = vari.clientid;
    vari.topic = 'mainfeed/#';
    connect(vari.broker, vari.port, vari.clientIdentifier);

    return vari.clientid;
  }

  Future<MqttConnectionState> connect(
      String broker, int port, String clientIdentifier) async {
    vari.client = mqtt.MqttClient(broker, '');
    vari.client.port = port;
    vari.client.keepAlivePeriod = 30;
    vari.client.onDisconnected = _onDisconnected;

    final mqtt.MqttConnectMessage connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier(vari.clientIdentifier)
        .startClean() // Non persistent session for testing
        .keepAliveFor(30)
        .withWillQos(mqtt.MqttQos.atMostOnce);
    print('[MQTT client] MQTT client connecting....');
    vari.client.connectionMessage = connMess;

    try {
      await vari.client.connect();
    } catch (e) {
      print(e);
      _disconnect();
    }

    if (vari.client.connectionStatus.state == MqttConnectionState.connected) {
      print('[MQTT client] connected');
      // setState(() {
      vari.connectionState = vari.client.connectionStatus.state;
      // });
      print(vari.connectionState);
    } else {
      print('[MQTT client] ERROR: MQTT client connection failed - '
          'disconnecting, state is ${vari.client.connectionStatus.state}');
      _disconnect();
    }

    vari.subscription = vari.client.updates.listen(_onMessage);
    _subscribeToTopic(vari.topic);

    return vari.connectionState;
  }

  void _onDisconnected() {
    print('[MQTT client] _onDisconnected');
    // setState(() {
    //topics.clear();
    vari.connectionState = vari.client.connectionStatus.state;
    print(vari.connectionState);
    vari.client = null;
    vari.subscription.cancel();
    vari.subscription = null;
    // });
    print('[MQTT client] MQTT client disconnected');
  }

  void _onMessage(List<mqtt.MqttReceivedMessage> event) {
    print(event.length);
    final mqtt.MqttPublishMessage recMess =
        event[0].payload as mqtt.MqttPublishMessage;
    final String message =
        mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    print('[MQTT client] MQTT message: topic is <${event[0].topic}>, '
        'payload is <-- $message -->');
    print(vari.client.connectionStatus.state);
    print(vari.client.connectionStatus.returnCode);
    print("[MQTT client] message with topic: ${event[0].topic}");
    print("[MQTT client] message with message: $message");

    if (event[0].topic == 'mainfeed/switch/relay1') {
      if (message == "relay1on") {
        // setState(() {
        vari.switchValue1 = true;
        // });
      } else if (message == "relay1off") {
        // setState(() {
        vari.switchValue1 = false;
        // });
      }
    }

    if (event[0].topic == 'mainfeed/switch/relay2') {
      if (message == "relay2on") {
        // setState(() {
        vari.switchValue2 = true;
        // });
      } else if (message == "relay2off") {
        // setState(() {
        vari.switchValue2 = false;
        // });
      }
    }

    // if (event[0].topic == 'mainfeed/switch/relay3') {
    //   if (message == "relay3on") {
    //     setState(() {
    //       vari.switchValue3 = true;
    //     });
    //   } else if (message == "relay3off") {
    //     setState(() {
    //       vari.switchValue3 = false;
    //     });
    //   }
    // }

    // if (event[0].topic == 'mainfeed/switch/relay4') {
    //   if (message == "relay4on") {
    //     setState(() {
    //       vari.switchValue4 = true;
    //     });
    //   } else if (message == "relay4off") {
    //     setState(() {
    //       vari.switchValue4 = false;
    //     });
    //   }
    // }

    // if (event[0].topic == 'mainfeed/switch/relay5') {
    //   if (message == "relay5on") {
    //     setState(() {
    //       vari.switchValue5 = true;
    //     });
    //   } else if (message == "relay5off") {
    //     setState(() {
    //       vari.switchValue5 = false;
    //     });
    //   }
    // }

    // if (event[0].topic == 'mainfeed/switch/relay6') {
    //   if (message == "relay6on") {
    //     setState(() {
    //       vari.switchValue6 = true;
    //     });
    //   } else if (message == "relay6off") {
    //     setState(() {
    //       vari.switchValue6 = false;
    //     });
    //   }
    // }

    // if (event[0].topic == 'mainfeed/moisture') {
    //   vari.moisture = double.parse(message);
    //   setState(() {});
    // }
  }

  void _disconnect() {
    print('[MQTT client] _disconnect()');
    vari.client.disconnect();
    _onDisconnected();
  }

  void _subscribeToTopic(String topic) {
    if (vari.connectionState == mqtt.MqttConnectionState.connected) {
      print('[MQTT client] Subscribing to ${topic.trim()}');
      vari.client.subscribe(topic, mqtt.MqttQos.exactlyOnce);
    }
  }

  String connectionStatus(MqttConnectionState connectionState) {
    if (connectionState != MqttConnectionState.connected) {
      return "Not Connected";
    } else
      return "Connected";
  }

  notifyListeners();
}
