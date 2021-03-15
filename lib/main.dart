import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:typed_data/typed_buffers.dart' show Uint8Buffer;
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'variables.dart';
import 'greetings.dart';

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
}

class _MyHomePageState extends State<MyHomePage> {
  Variable vari = Variable();

  void getDeviceinfo() async {
    vari.androidDeviceInfo = await vari
        .deviceInfo.androidInfo; // instantiate Android Device Infoformation
    setState(() {
      vari.clientid = vari.androidDeviceInfo.androidId.toString();
    });
    print(vari.clientid);

    vari.broker = 'broker.hivemq.com';
    vari.port = 1883;
    vari.clientIdentifier = vari.clientid;
    vari.topic = 'mainfeed/#';
    WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
  }

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
        setState(() {
          vari.switchValue1 = true;
        });
      } else if (message == "relay1off") {
        setState(() {
          vari.switchValue1 = false;
        });
      }
    }

    if (event[0].topic == 'mainfeed/switch/relay2') {
      if (message == "relay2on") {
        setState(() {
          vari.switchValue2 = true;
        });
      } else if (message == "relay2off") {
        setState(() {
          vari.switchValue2 = false;
        });
      }
    }

    if (event[0].topic == 'mainfeed/switch/relay3') {
      if (message == "relay3on") {
        setState(() {
          vari.switchValue3 = true;
        });
      } else if (message == "relay3off") {
        setState(() {
          vari.switchValue3 = false;
        });
      }
    }

    if (event[0].topic == 'mainfeed/switch/relay4') {
      if (message == "relay4on") {
        setState(() {
          vari.switchValue4 = true;
        });
      } else if (message == "relay4off") {
        setState(() {
          vari.switchValue4 = false;
        });
      }
    }

    if (event[0].topic == 'mainfeed/switch/relay5') {
      if (message == "relay5on") {
        setState(() {
          vari.switchValue5 = true;
        });
      } else if (message == "relay5off") {
        setState(() {
          vari.switchValue5 = false;
        });
      }
    }

    if (event[0].topic == 'mainfeed/switch/relay6') {
      if (message == "relay6on") {
        setState(() {
          vari.switchValue6 = true;
        });
      } else if (message == "relay6off") {
        setState(() {
          vari.switchValue6 = false;
        });
      }
    }

    if (event[0].topic == 'mainfeed/moisture') {
      vari.moisture = double.parse(message);
      setState(() {});
    }

    if (event[0].topic == 'mainfeed/temperature') {
      vari.temperature = double.parse(message);
      setState(() {});
    }

    if (event[0].topic == 'mainfeed/humidity') {
      vari.humidity = double.parse(message);
      setState(() {});
    }

    if (event[0].topic == 'mainfeed/waterlevel') {
      vari.waterlevel = double.parse(message);
      setState(() {});
    }

    if (event[0].topic == 'mainfeed/gaspercentage') {
      vari.gaspercentage = double.parse(message);
      setState(() {});
    }
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
      body: vari.connectionState != MqttConnectionState.connected
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
          : SingleChildScrollView(
              child: Container(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: Greetings()),
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
                                                connectionStatus(
                                                    vari.connectionState),
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
                                                "Client ID: ${vari.clientid}",
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
                                            value: vari.switchValue1,
                                            onChanged: (value) {
                                              setState(() {
                                                vari.switchValue1 = value;
                                                if (!vari.switchValue1) {
                                                  List<int> list =
                                                      'relay1off'.codeUnits;
                                                  Uint8List bytes =
                                                      Uint8List.fromList(list);
                                                  print(bytes);
                                                  Uint8Buffer message =
                                                      Uint8Buffer();
                                                  message.addAll(bytes);
                                                  vari.client.publishMessage(
                                                      "mainfeed/switch/relay1",
                                                      mqtt.MqttQos.exactlyOnce,
                                                      message,
                                                      retain: true);
                                                }

                                                if (vari.switchValue1) {
                                                  List<int> list =
                                                      'relay1on'.codeUnits;
                                                  Uint8List bytes =
                                                      Uint8List.fromList(list);
                                                  print(bytes);
                                                  Uint8Buffer message =
                                                      Uint8Buffer();
                                                  message.addAll(bytes);
                                                  vari.client.publishMessage(
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
                                            value: vari.switchValue2,
                                            onChanged: (value) {
                                              setState(() {
                                                vari.switchValue2 = value;
                                                if (!vari.switchValue2) {
                                                  List<int> list =
                                                      'relay2off'.codeUnits;
                                                  Uint8List bytes =
                                                      Uint8List.fromList(list);
                                                  print(bytes);
                                                  Uint8Buffer message =
                                                      Uint8Buffer();
                                                  message.addAll(bytes);
                                                  vari.client.publishMessage(
                                                      "mainfeed/switch/relay2",
                                                      mqtt.MqttQos.exactlyOnce,
                                                      message,
                                                      retain: true);
                                                }

                                                if (vari.switchValue2) {
                                                  List<int> list =
                                                      'relay2on'.codeUnits;
                                                  Uint8List bytes =
                                                      Uint8List.fromList(list);
                                                  print(bytes);
                                                  Uint8Buffer message =
                                                      Uint8Buffer();
                                                  message.addAll(bytes);
                                                  vari.client.publishMessage(
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
                                            value: vari.switchValue3,
                                            onChanged: (value) {
                                              setState(() {
                                                vari.switchValue3 = value;
                                                if (!vari.switchValue3) {
                                                  List<int> list =
                                                      'relay3off'.codeUnits;
                                                  Uint8List bytes =
                                                      Uint8List.fromList(list);
                                                  print(bytes);
                                                  Uint8Buffer message =
                                                      Uint8Buffer();
                                                  message.addAll(bytes);
                                                  vari.client.publishMessage(
                                                      "mainfeed/switch/relay3",
                                                      mqtt.MqttQos.exactlyOnce,
                                                      message,
                                                      retain: true);
                                                }

                                                if (vari.switchValue3) {
                                                  List<int> list =
                                                      'relay3on'.codeUnits;
                                                  Uint8List bytes =
                                                      Uint8List.fromList(list);
                                                  print(bytes);
                                                  Uint8Buffer message =
                                                      Uint8Buffer();
                                                  message.addAll(bytes);
                                                  vari.client.publishMessage(
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
                                            value: vari.switchValue4,
                                            onChanged: (value) {
                                              setState(() {
                                                vari.switchValue4 = value;
                                                if (!vari.switchValue4) {
                                                  List<int> list =
                                                      'relay4off'.codeUnits;
                                                  Uint8List bytes =
                                                      Uint8List.fromList(list);
                                                  print(bytes);
                                                  Uint8Buffer message =
                                                      Uint8Buffer();
                                                  message.addAll(bytes);
                                                  vari.client.publishMessage(
                                                      "mainfeed/switch/relay4",
                                                      mqtt.MqttQos.exactlyOnce,
                                                      message,
                                                      retain: true);
                                                }

                                                if (vari.switchValue4) {
                                                  List<int> list =
                                                      'relay4on'.codeUnits;
                                                  Uint8List bytes =
                                                      Uint8List.fromList(list);
                                                  print(bytes);
                                                  Uint8Buffer message =
                                                      Uint8Buffer();
                                                  message.addAll(bytes);
                                                  vari.client.publishMessage(
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
                                            value: vari.switchValue5,
                                            onChanged: (value) {
                                              setState(() {
                                                vari.switchValue5 = value;
                                                if (!vari.switchValue5) {
                                                  List<int> list =
                                                      'relay5off'.codeUnits;
                                                  Uint8List bytes =
                                                      Uint8List.fromList(list);
                                                  print(bytes);
                                                  Uint8Buffer message =
                                                      Uint8Buffer();
                                                  message.addAll(bytes);
                                                  vari.client.publishMessage(
                                                      "mainfeed/switch/relay5",
                                                      mqtt.MqttQos.exactlyOnce,
                                                      message,
                                                      retain: true);
                                                }

                                                if (vari.switchValue5) {
                                                  List<int> list =
                                                      'relay5on'.codeUnits;
                                                  Uint8List bytes =
                                                      Uint8List.fromList(list);
                                                  print(bytes);
                                                  Uint8Buffer message =
                                                      Uint8Buffer();
                                                  message.addAll(bytes);
                                                  vari.client.publishMessage(
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
                                            value: vari.switchValue6,
                                            onChanged: (value) {
                                              setState(() {
                                                vari.switchValue6 = value;
                                                if (!vari.switchValue6) {
                                                  List<int> list =
                                                      'relay6off'.codeUnits;
                                                  Uint8List bytes =
                                                      Uint8List.fromList(list);
                                                  print(bytes);
                                                  Uint8Buffer message =
                                                      Uint8Buffer();
                                                  message.addAll(bytes);
                                                  vari.client.publishMessage(
                                                      "mainfeed/switch/relay6",
                                                      mqtt.MqttQos.exactlyOnce,
                                                      message,
                                                      retain: true);
                                                }

                                                if (vari.switchValue6) {
                                                  List<int> list =
                                                      'relay6on'.codeUnits;
                                                  Uint8List bytes =
                                                      Uint8List.fromList(list);
                                                  print(bytes);
                                                  Uint8Buffer message =
                                                      Uint8Buffer();
                                                  message.addAll(bytes);
                                                  vari.client.publishMessage(
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
                                                    fontWeight:
                                                        FontWeight.bold)),
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
                                                NeedlePointer(
                                                    value: vari.moisture)
                                              ],
                                              annotations: <GaugeAnnotation>[
                                                GaugeAnnotation(
                                                    widget: Container(
                                                        child: Text(
                                                            vari.moisture
                                                                .toString(),
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
                                            NeedlePointer(
                                                value: vari.temperature)
                                          ],
                                          annotations: <GaugeAnnotation>[
                                            GaugeAnnotation(
                                                widget: Container(
                                                    child: Text(
                                                        "${vari.temperature.toString()}°C",
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
                                                text: 'Humidity Meter',
                                                textStyle: const TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight:
                                                        FontWeight.bold)),
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
                                                NeedlePointer(
                                                    value: vari.humidity)
                                              ],
                                              annotations: <GaugeAnnotation>[
                                                GaugeAnnotation(
                                                    widget: Container(
                                                        child: Text(
                                                            vari.humidity
                                                                .toString(),
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
                                            text: 'Gas Percentage',
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
                                            NeedlePointer(
                                                value: vari.gaspercentage)
                                          ],
                                          annotations: <GaugeAnnotation>[
                                            GaugeAnnotation(
                                                widget: Container(
                                                    child: Text(
                                                        vari.gaspercentage
                                                            .toString(),
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
                                                text: 'Water Level',
                                                textStyle: const TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight:
                                                        FontWeight.bold)),
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
                                                NeedlePointer(
                                                    value: vari.waterlevel)
                                              ],
                                              annotations: <GaugeAnnotation>[
                                                GaugeAnnotation(
                                                    widget: Container(
                                                        child: Text(
                                                            vari.waterlevel
                                                                .toString(),
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
                            // Expanded(
                            //   child: Container(
                            //     child: Card(
                            //         child: SfRadialGauge(
                            //             enableLoadingAnimation: true,
                            //             animationDuration: 10.0,
                            //             title: GaugeTitle(
                            //                 text: 'Temperature Meter',
                            //                 textStyle: const TextStyle(
                            //                     fontSize: 20.0,
                            //                     fontWeight: FontWeight.bold)),
                            //             axes: <RadialAxis>[
                            //           RadialAxis(
                            //               minimum: 0,
                            //               maximum: 70,
                            //               ranges: <GaugeRange>[
                            //                 GaugeRange(
                            //                     startValue: 50,
                            //                     endValue: 70,
                            //                     color: Colors.redAccent,
                            //                     startWidth: 10,
                            //                     endWidth: 10),
                            //                 GaugeRange(
                            //                     startValue: 24,
                            //                     endValue: 50,
                            //                     color: Colors.orangeAccent,
                            //                     startWidth: 10,
                            //                     endWidth: 10),
                            //                 GaugeRange(
                            //                     startValue: 0,
                            //                     endValue: 24,
                            //                     color: Colors.blueAccent,
                            //                     startWidth: 10,
                            //                     endWidth: 10)
                            //               ],
                            //               pointers: <GaugePointer>[
                            //                 NeedlePointer(value: 28)
                            //               ],
                            //               annotations: <GaugeAnnotation>[
                            //                 GaugeAnnotation(
                            //                     widget: Container(
                            //                         child: Text(
                            //                             // _moisture.toString(),
                            //                             "28°C",
                            //                             style: TextStyle(
                            //                                 fontSize: 25,
                            //                                 fontWeight:
                            //                                     FontWeight
                            //                                         .bold))),
                            //                     angle: 90,
                            //                     positionFactor: 0.8)
                            //               ])
                            //         ])),
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    )),
              ),
            ),
    );
  }
}
