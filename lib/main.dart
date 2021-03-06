import 'dart:async';
// import 'dart:html';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:flutter_greetings/flutter_greetings.dart';
import 'package:typed_data/typed_buffers.dart' show Uint8Buffer;
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:device_info/device_info.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Dashboard'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
  // _StatefulWidgetDemoState createState() ;
}

class _MyHomePageState extends State<MyHomePage> {
  DeviceInfoPlugin deviceInfo =
      DeviceInfoPlugin(); // instantiate device info plugin
  AndroidDeviceInfo androidDeviceInfo;

  String broker;
  int port;
  String clientIdentifier;
  String topic;
  String clientid;

  // TROQUE AQUI PARA UM TOPIC EXCLUSIVO SEU

  StreamSubscription subscription;
  double _moisture = 0.0;
  bool _switchValue1 = false;
  bool _switchValue2 = false;
  bool _switchValue3 = false;
  bool _switchValue4 = false;
  bool _switchValue5 = false;
  bool _switchValue6 = false;

  mqtt.MqttClient client;
  mqtt.MqttConnectionState connectionState = MqttConnectionState.disconnected;

  // MQTTClientWrapper mqttClientWrapper;

  void getDeviceinfo() async {
    androidDeviceInfo = await deviceInfo
        .androidInfo; // instantiate Android Device Infoformation
    setState(() {
      clientid = androidDeviceInfo.androidId.toString();
    });
    print(clientid);

    broker = 'broker.hivemq.com';
    port = 1883;
    clientIdentifier = clientid;
    topic = 'mainfeed/#';
    WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
  }

  void _connect() async {
    client = mqtt.MqttClient(broker, '');
    client.port = port;
    client.keepAlivePeriod = 30;
    client.onDisconnected = _onDisconnected;

    final mqtt.MqttConnectMessage connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean() // Non persistent session for testing
        .keepAliveFor(30)
        .withWillQos(mqtt.MqttQos.atMostOnce);
    print('[MQTT client] MQTT client connecting....');
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } catch (e) {
      print(e);
      _disconnect();
    }

    /// Check if we are connected
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      print('[MQTT client] connected');
      setState(() {
        connectionState = client.connectionStatus.state;
      });
      // print(connectionState);
    } else {
      print('[MQTT client] ERROR: MQTT client connection failed - '
          'disconnecting, state is ${client.connectionStatus.state}');
      _disconnect();
    }

    subscription = client.updates.listen(_onMessage);
    _subscribeToTopic(topic);
  }

  void _onDisconnected() {
    print('[MQTT client] _onDisconnected');
    setState(() {
      //topics.clear();
      connectionState = client.connectionStatus.state;
      print(connectionState);
      client = null;
      subscription.cancel();
      subscription = null;
    });
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
    print(client.connectionStatus.state);
    print(client.connectionStatus.returnCode);
    print("[MQTT client] message with topic: ${event[0].topic}");
    print("[MQTT client] message with message: $message");

    if (event[0].topic == 'mainfeed/switch/relay1') {
      if (message == "relay1on") {
        setState(() {
          _switchValue1 = true;
        });
      } else if (message == "relay1off") {
        setState(() {
          _switchValue1 = false;
        });
      }
    }

    if (event[0].topic == 'mainfeed/switch/relay2') {
      if (message == "relay2on") {
        setState(() {
          _switchValue2 = true;
        });
      } else if (message == "relay2off") {
        setState(() {
          _switchValue2 = false;
        });
      }
    }

    if (event[0].topic == 'mainfeed/switch/relay3') {
      if (message == "relay3on") {
        setState(() {
          _switchValue3 = true;
        });
      } else if (message == "relay3off") {
        setState(() {
          _switchValue3 = false;
        });
      }
    }

    if (event[0].topic == 'mainfeed/switch/relay4') {
      if (message == "relay4on") {
        setState(() {
          _switchValue4 = true;
        });
      } else if (message == "relay4off") {
        setState(() {
          _switchValue4 = false;
        });
      }
    }

    if (event[0].topic == 'mainfeed/switch/relay5') {
      if (message == "relay5on") {
        setState(() {
          _switchValue5 = true;
        });
      } else if (message == "relay5off") {
        setState(() {
          _switchValue5 = false;
        });
      }
    }

    if (event[0].topic == 'mainfeed/switch/relay6') {
      if (message == "relay6on") {
        setState(() {
          _switchValue6 = true;
        });
      } else if (message == "relay6off") {
        setState(() {
          _switchValue6 = false;
        });
      }
    }

    if (event[0].topic == 'mainfeed/moisture') {
      _moisture = double.parse(message);
      setState(() {});
    }
  }

  void _disconnect() {
    print('[MQTT client] _disconnect()');
    client.disconnect();
    _onDisconnected();
  }

  void _subscribeToTopic(String topic) {
    if (connectionState == mqtt.MqttConnectionState.connected) {
      print('[MQTT client] Subscribing to ${topic.trim()}');
      client.subscribe(topic, mqtt.MqttQos.exactlyOnce);
    }
  }

  String connectionStatus(MqttConnectionState connectionState) {
    if (connectionState != MqttConnectionState.connected) {
      return "Not Connected";
    } else
      return "Connected";
  }

  @override
  void initState() {
    super.initState();
    getDeviceinfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: connectionState != MqttConnectionState.connected
          ? Center(
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
          : Container(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 100,
                              width: 200,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        YonoGreetings.showGreetings(),
                                        textAlign: TextAlign.center,
                                        style: new TextStyle(
                                          fontSize: 24,
                                          fontFamily: 'Helvetica',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 100,
                              width: 200,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text("Connection Status"),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              connectionStatus(connectionState),
                                              // textAlign: TextAlign.center,
                                              style: new TextStyle(
                                                fontSize: 24,
                                                fontFamily: 'Helvetica',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "Client ID: $clientid",
                                              // textAlign: TextAlign.center,
                                              style: new TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'Helvetica',
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                        child: Align(
                          alignment: Alignment
                              .center, // Align however you like (i.e .centerRight, centerLeft)
                          child: Text(
                            "Switches",
                            style: new TextStyle(
                              fontSize: 24,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Container(
                              height: 100,
                              width: 130,
                              child: Card(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Switch 1",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CupertinoSwitch(
                                          value: _switchValue1,
                                          onChanged: (value) {
                                            setState(() {
                                              _switchValue1 = value;
                                              if (!_switchValue1) {
                                                List<int> list =
                                                    'relay1off'.codeUnits;
                                                Uint8List bytes =
                                                    Uint8List.fromList(list);
                                                print(bytes);
                                                Uint8Buffer message =
                                                    Uint8Buffer();
                                                message.addAll(bytes);
                                                client.publishMessage(
                                                    "mainfeed/switch/relay1",
                                                    mqtt.MqttQos.exactlyOnce,
                                                    message,
                                                    retain: true);
                                              }

                                              if (_switchValue1) {
                                                List<int> list =
                                                    'relay1on'.codeUnits;
                                                Uint8List bytes =
                                                    Uint8List.fromList(list);
                                                print(bytes);
                                                Uint8Buffer message =
                                                    Uint8Buffer();
                                                message.addAll(bytes);
                                                client.publishMessage(
                                                    "mainfeed/switch/relay1",
                                                    mqtt.MqttQos.exactlyOnce,
                                                    message,
                                                    retain: true);
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 100,
                              width: 130,
                              child: Card(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Switch 2",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CupertinoSwitch(
                                          value: _switchValue2,
                                          onChanged: (value) {
                                            setState(() {
                                              _switchValue2 = value;
                                              if (!_switchValue2) {
                                                List<int> list =
                                                    'relay2off'.codeUnits;
                                                Uint8List bytes =
                                                    Uint8List.fromList(list);
                                                print(bytes);
                                                Uint8Buffer message =
                                                    Uint8Buffer();
                                                message.addAll(bytes);
                                                client.publishMessage(
                                                    "mainfeed/switch/relay2",
                                                    mqtt.MqttQos.exactlyOnce,
                                                    message,
                                                    retain: true);
                                              }

                                              if (_switchValue2) {
                                                List<int> list =
                                                    'relay2on'.codeUnits;
                                                Uint8List bytes =
                                                    Uint8List.fromList(list);
                                                print(bytes);
                                                Uint8Buffer message =
                                                    Uint8Buffer();
                                                message.addAll(bytes);
                                                client.publishMessage(
                                                    "mainfeed/switch/relay2",
                                                    mqtt.MqttQos.exactlyOnce,
                                                    message,
                                                    retain: true);
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 100,
                              width: 130,
                              child: Card(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Switch 3",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CupertinoSwitch(
                                          value: _switchValue3,
                                          onChanged: (value) {
                                            setState(() {
                                              _switchValue3 = value;
                                              if (!_switchValue3) {
                                                List<int> list =
                                                    'relay3off'.codeUnits;
                                                Uint8List bytes =
                                                    Uint8List.fromList(list);
                                                print(bytes);
                                                Uint8Buffer message =
                                                    Uint8Buffer();
                                                message.addAll(bytes);
                                                client.publishMessage(
                                                    "mainfeed/switch/relay3",
                                                    mqtt.MqttQos.exactlyOnce,
                                                    message,
                                                    retain: true);
                                              }

                                              if (_switchValue3) {
                                                List<int> list =
                                                    'relay3on'.codeUnits;
                                                Uint8List bytes =
                                                    Uint8List.fromList(list);
                                                print(bytes);
                                                Uint8Buffer message =
                                                    Uint8Buffer();
                                                message.addAll(bytes);
                                                client.publishMessage(
                                                    "mainfeed/switch/relay3",
                                                    mqtt.MqttQos.exactlyOnce,
                                                    message,
                                                    retain: true);
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Container(
                              height: 100,
                              width: 130,
                              child: Card(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Switch 4",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CupertinoSwitch(
                                          value: _switchValue4,
                                          onChanged: (value) {
                                            setState(() {
                                              _switchValue4 = value;
                                              if (!_switchValue4) {
                                                List<int> list =
                                                    'relay4off'.codeUnits;
                                                Uint8List bytes =
                                                    Uint8List.fromList(list);
                                                print(bytes);
                                                Uint8Buffer message =
                                                    Uint8Buffer();
                                                message.addAll(bytes);
                                                client.publishMessage(
                                                    "mainfeed/switch/relay4",
                                                    mqtt.MqttQos.exactlyOnce,
                                                    message,
                                                    retain: true);
                                              }

                                              if (_switchValue4) {
                                                List<int> list =
                                                    'relay4on'.codeUnits;
                                                Uint8List bytes =
                                                    Uint8List.fromList(list);
                                                print(bytes);
                                                Uint8Buffer message =
                                                    Uint8Buffer();
                                                message.addAll(bytes);
                                                client.publishMessage(
                                                    "mainfeed/switch/relay4",
                                                    mqtt.MqttQos.exactlyOnce,
                                                    message,
                                                    retain: true);
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 100,
                              width: 130,
                              child: Card(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Switch 5",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CupertinoSwitch(
                                          value: _switchValue5,
                                          onChanged: (value) {
                                            setState(() {
                                              _switchValue5 = value;
                                              if (!_switchValue5) {
                                                List<int> list =
                                                    'relay5off'.codeUnits;
                                                Uint8List bytes =
                                                    Uint8List.fromList(list);
                                                print(bytes);
                                                Uint8Buffer message =
                                                    Uint8Buffer();
                                                message.addAll(bytes);
                                                client.publishMessage(
                                                    "mainfeed/switch/relay5",
                                                    mqtt.MqttQos.exactlyOnce,
                                                    message,
                                                    retain: true);
                                              }

                                              if (_switchValue5) {
                                                List<int> list =
                                                    'relay5on'.codeUnits;
                                                Uint8List bytes =
                                                    Uint8List.fromList(list);
                                                print(bytes);
                                                Uint8Buffer message =
                                                    Uint8Buffer();
                                                message.addAll(bytes);
                                                client.publishMessage(
                                                    "mainfeed/switch/relay5",
                                                    mqtt.MqttQos.exactlyOnce,
                                                    message,
                                                    retain: true);
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 100,
                              width: 130,
                              child: Card(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Switch 6",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CupertinoSwitch(
                                          value: _switchValue6,
                                          onChanged: (value) {
                                            setState(() {
                                              _switchValue6 = value;
                                              if (!_switchValue6) {
                                                List<int> list =
                                                    'relay6off'.codeUnits;
                                                Uint8List bytes =
                                                    Uint8List.fromList(list);
                                                print(bytes);
                                                Uint8Buffer message =
                                                    Uint8Buffer();
                                                message.addAll(bytes);
                                                client.publishMessage(
                                                    "mainfeed/switch/relay6",
                                                    mqtt.MqttQos.exactlyOnce,
                                                    message,
                                                    retain: true);
                                              }

                                              if (_switchValue6) {
                                                List<int> list =
                                                    'relay6on'.codeUnits;
                                                Uint8List bytes =
                                                    Uint8List.fromList(list);
                                                print(bytes);
                                                Uint8Buffer message =
                                                    Uint8Buffer();
                                                message.addAll(bytes);
                                                client.publishMessage(
                                                    "mainfeed/switch/relay6",
                                                    mqtt.MqttQos.exactlyOnce,
                                                    message,
                                                    retain: true);
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  child: Card(
                                      child: SfRadialGauge(
                                          enableLoadingAnimation: true,
                                          animationDuration: 10.0,
                                          title: GaugeTitle(
                                              text: 'Moisture Meter',
                                              textStyle: const TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold)),
                                          axes: <RadialAxis>[
                                        RadialAxis(
                                            minimum: 0,
                                            maximum: 1100,
                                            ranges: <GaugeRange>[
                                              GaugeRange(
                                                  startValue: 680,
                                                  endValue: 1100,
                                                  color: Colors.red,
                                                  startWidth: 10,
                                                  endWidth: 10),
                                              GaugeRange(
                                                  startValue: 340,
                                                  endValue: 680,
                                                  color: Colors.orangeAccent,
                                                  startWidth: 10,
                                                  endWidth: 10),
                                              GaugeRange(
                                                  startValue: 0,
                                                  endValue: 340,
                                                  color: Colors.green,
                                                  startWidth: 10,
                                                  endWidth: 10)
                                            ],
                                            pointers: <GaugePointer>[
                                              NeedlePointer(value: _moisture)
                                            ],
                                            annotations: <GaugeAnnotation>[
                                              GaugeAnnotation(
                                                  widget: Container(
                                                      child: Text(
                                                          _moisture.toString(),
                                                          style: TextStyle(
                                                              fontSize: 25,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))),
                                                  angle: 90,
                                                  positionFactor: 0.8)
                                            ])
                                      ])),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Card(
                                  child: SfRadialGauge(
                                      enableLoadingAnimation: true,
                                      animationDuration: 10.0,
                                      title: GaugeTitle(
                                          text: 'Temperature Meter',
                                          textStyle: const TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold)),
                                      axes: <RadialAxis>[
                                    RadialAxis(
                                        minimum: 0,
                                        maximum: 70,
                                        ranges: <GaugeRange>[
                                          GaugeRange(
                                              startValue: 50,
                                              endValue: 70,
                                              color: Colors.redAccent,
                                              startWidth: 10,
                                              endWidth: 10),
                                          GaugeRange(
                                              startValue: 24,
                                              endValue: 50,
                                              color: Colors.orangeAccent,
                                              startWidth: 10,
                                              endWidth: 10),
                                          GaugeRange(
                                              startValue: 0,
                                              endValue: 24,
                                              color: Colors.blueAccent,
                                              startWidth: 10,
                                              endWidth: 10)
                                        ],
                                        pointers: <GaugePointer>[
                                          NeedlePointer(value: 28)
                                        ],
                                        annotations: <GaugeAnnotation>[
                                          GaugeAnnotation(
                                              widget: Container(
                                                  child: Text(
                                                      // _moisture.toString(),
                                                      "28°C",
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              angle: 90,
                                              positionFactor: 0.8)
                                        ])
                                  ])),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
    );
  }
}
