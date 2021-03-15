import 'package:flutter/material.dart';
import 'package:flutter_greetings/flutter_greetings.dart';

class Greetings extends StatelessWidget {
  const Greetings({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
