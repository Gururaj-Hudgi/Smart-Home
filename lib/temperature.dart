// import 'package:flutter/cupertino.dart';
// import 'package:weather/weather.dart';

// class Temperature extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<Temperature> {
//   String key = 'a78922ad48bfcf22a15cc3ef51ec0ae5';
//   WeatherFactory ws;
//   List<Weather> _forecasts = [];
//   List<Weather> _weather = [];
//   double lat, lon;

//   @override
//   void initState() {
//     super.initState();
//     ws = new WeatherFactory(key);
//   }

//    queryForecast() async {
//     /// Removes keyboard
//     FocusScope.of(context).requestFocus(FocusNode());
//     // setState(() {
//     //   _state = AppState.DOWNLOADING;
//     // });

//     List<Weather> forecasts = await ws.fiveDayForecastByLocation(lat, lon);
//     Weather weather = await ws.currentWeatherByLocation(lat, lon);
//     // setState(() {
//       _forecasts = forecasts;
//       _weather =[weather];

//       print(_weather);
//       print(_forecasts);
//     //   _state = AppState.FINISHED_DOWNLOADING;
//     // });

//     return {_weather , _forecasts} ;
//   }

//   // void queryWeather() async {
//   //   /// Removes keyboard
//   //   FocusScope.of(context).requestFocus(FocusNode());

//   //   setState(() {
//   //     _state = AppState.DOWNLOADING;
//   //   });

//   //   Weather weather = await ws.currentWeatherByLocation(lat, lon);
//   //   setState(() {
//   //     _data = [weather];
//   //     _state = AppState.FINISHED_DOWNLOADING;
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     throw UnimplementedError();
//   }

//   // Widget contentFinishedDownload() {
//   //   return Center(
//   //     child: ListView.separated(
//   //       itemCount: _data.length,
//   //       itemBuilder: (context, index) {
//   //         return ListTile(
//   //           title: Text(_data[index].toString()),
//   //         );
//   //       },
//   //       separatorBuilder: (context, index) {
//   //         return Divider();
//   //       },
//   //     ),
//   //   );
//   // }

//   // Widget contentDownloading() {
//   //   return Container(
//   //       margin: EdgeInsets.all(25),
//   //       child: Column(children: [
//   //         Text(
//   //           'Fetching Weather...',
//   //           style: TextStyle(fontSize: 20),
//   //         ),
//   //         Container(
//   //             margin: EdgeInsets.only(top: 50),
//   //             child: Center(child: CircularProgressIndicator(strokeWidth: 10)))
//   //       ]));
//   // }

//   // Widget contentNotDownloaded() {
//   //   return Center(
//   //     child: Column(
//   //       mainAxisAlignment: MainAxisAlignment.center,
//   //       children: <Widget>[
//   //         Text(
//   //           'Press the button to download the Weather forecast',
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   // Widget _resultView() => _state == AppState.FINISHED_DOWNLOADING
//   //     ? contentFinishedDownload()
//   //     : _state == AppState.DOWNLOADING
//   //         ? contentDownloading()
//   //         : contentNotDownloaded();

//   // void _saveLat(String input) {
//   //   lat = double.tryParse(input);
//   //   print(lat);
//   // }

//   // void _saveLon(String input) {
//   //   lon = double.tryParse(input);
//   //   print(lon);
//   // }

//   // Widget _coordinateInputs() {
//   //   return Row(
//   //     children: <Widget>[
//   //       Expanded(
//   //         child: Container(
//   //             margin: EdgeInsets.all(5),
//   //             child: TextField(
//   //                 decoration: InputDecoration(
//   //                     border: OutlineInputBorder(),
//   //                     hintText: 'Enter latitude'),
//   //                 keyboardType: TextInputType.number,
//   //                 onChanged: _saveLat,
//   //                 onSubmitted: _saveLat)),
//   //       ),
//   //       Expanded(
//   //           child: Container(
//   //               margin: EdgeInsets.all(5),
//   //               child: TextField(
//   //                   decoration: InputDecoration(
//   //                       border: OutlineInputBorder(),
//   //                       hintText: 'Enter longitude'),
//   //                   keyboardType: TextInputType.number,
//   //                   onChanged: _saveLon,
//   //                   onSubmitted: _saveLon)))
//   //     ],
//   //   );
//   // }

//   // Widget _buttons() {
//   //   return Row(
//   //     mainAxisAlignment: MainAxisAlignment.center,
//   //     children: <Widget>[
//   //       Container(
//   //         margin: EdgeInsets.all(5),
//   //         child: FlatButton(
//   //           child: Text(
//   //             'Fetch weather',
//   //             style: TextStyle(color: Colors.white),
//   //           ),
//   //           onPressed: queryWeather,
//   //           color: Colors.blue,
//   //         ),
//   //       ),
//   //       Container(
//   //           margin: EdgeInsets.all(5),
//   //           child: FlatButton(
//   //             child: Text(
//   //               'Fetch forecast',
//   //               style: TextStyle(color: Colors.white),
//   //             ),
//   //             onPressed: queryForecast,
//   //             color: Colors.blue,
//   //           ))
//   //     ],
//   //   );
//   // }

//   // @override
//   // Widget build(BuildContext context) {
//   //   return MaterialApp(
//   //     home: Scaffold(
//   //         appBar: AppBar(
//   //           title: Text('Weather Example App'),
//   //         ),
//   //         body: Column(
//   //           children: <Widget>[
//   //             _coordinateInputs(),
//   //             _buttons(),
//   //             Text(
//   //               'Output:',
//   //               style: TextStyle(fontSize: 20),
//   //             ),
//   //             Divider(
//   //               height: 20.0,
//   //               thickness: 2.0,
//   //             ),
//   //             Expanded(child: _resultView())
//   //           ],
//   //         )),
//   //   );
//   }
// }