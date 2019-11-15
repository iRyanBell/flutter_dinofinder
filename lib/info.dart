import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: Image.asset('assets/images/title.png',
              height: 24, fit: BoxFit.contain),
        ),
        backgroundColor: Color.fromARGB(255, 25, 25, 27),
        body: Stack(children: <Widget>[
          Image.asset('assets/images/bkg.jpg',
              width: size.width, height: size.height, fit: BoxFit.cover),
          Container(
            width: size.width,
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Created by:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Youngjun Choi & Ryan Bell",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 21.0),
                  ),
                ],
              ),
            ),
          )
        ]));
  }
}
