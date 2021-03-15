import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_client.dart';
import 'variables.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Variable vari = Variable();

    void _connect() async {
    vari.client = mqtt.MqttClient(vari.broker, '');
    vari.client.port = vari.port;
    vari.client.keepAlivePeriod = 30;
    vari.client.onDisconnected = _onDisconnected;

    final mqtt.MqttConnectMessage connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier(vari.clientIdentifier)
        .startClean() // Non persistent session for testing
        .keepAliveFor(60)
        .withWillQos(mqtt.MqttQos.atMostOnce);
    print('[MQTT client] MQTT client connecting....');
    vari.client.connectionMessage = connMess;

    try {
      await vari.client.connect();
    } catch (e) {
      print(e);
      _disconnect();
    }

    /// Check if we are connected
    if (vari.client.connectionStatus.state == MqttConnectionState.connected) {
      print('[MQTT client] connected');
      setState(() {
        vari.connectionState = vari.client.connectionStatus.state;
      });
      // print(connectionState);
    } else {
      print('[MQTT client] ERROR: MQTT client connection failed - '
          'disconnecting, state is ${vari.client.connectionStatus.state}');
      _disconnect();
    }

    vari.subscription = vari.client.updates.listen(_onMessage);
    _subscribeToTopic(vari.topic);
  }

  void _subscribeToTopic(String topic) {
    if (vari.connectionState == mqtt.MqttConnectionState.connected) {
      print('[MQTT client] Subscribing to ${topic.trim()}');
      vari.client.subscribe(topic, mqtt.MqttQos.exactlyOnce);
    }
  }

  void _disconnect() {
    print('[MQTT client] _disconnect()');
    vari.client.disconnect();
    _onDisconnected();
  }

  void _onDisconnected() {
    print('[MQTT client] _onDisconnected');
    setState(() {
      //topics.clear();
      vari.connectionState = vari.client.connectionStatus.state;
      print(vari.connectionState);
      vari.client = null;
      vari.subscription.cancel();
      vari.subscription = null;
    });
    print('[MQTT client] MQTT client disconnected');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("CONNECTING TO MQTT..."),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: CircularProgressIndicator(),
                  ),
                  RaisedButton(
                    onPressed: _connect,
                    child: Text("Reconnect"),
                  )
                ],
              ),
            )
  }
}