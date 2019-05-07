import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:geoworker/classes/GeocoderTransport.dart' as transport;

class Isolator {
  List<IsolatorStructure> isolates = new List<IsolatorStructure>();

  void createIsolates() {
    for (int i = 0; i < 5; i++) {
      isolates.add(new IsolatorStructure(identifier: 'I$i', onSpawn: runTimer));
    }
  }
  void spawnIsolates() {
    isolates.forEach((i) => i.spawnIsolate());
  }
}

class IsolatorStructure {
  String identifier;
  Isolate isolate;
  ReceivePort port;
  var onSpawn;

  IsolatorStructure({
    this.identifier,
    this.onSpawn
  });

  void spawnIsolate () async {
    this.port = ReceivePort();
    this.isolate = await Isolate.spawn(this.onSpawn, this.port.sendPort);
    final String message = 'RECEIVE FROM ${this.identifier}: ';
    this.port.listen((data) {
      print(message + data + ', ');
    });
  }
}

void runTimer(SendPort sendPort) {
  new DumbClass().runTimer(sendPort);
  /*
    int counter = 0;
    Timer.periodic(new Duration(seconds: 1), (Timer t) {
      counter++;
      String msg = 'notification ' + counter.toString();
      stdout.write('SEND: ' + msg + ' - ');
      sendPort.send(msg);
    });
  */
}


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geoworker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Geoworker'),
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
  int _counter = 0;
  List<transport.GeocoderTransport> transporters = new List<transport.GeocoderTransport>();

  void _incrementCounter() {
    ReceivePort receivePort= ReceivePort();
    Isolate.spawn(runDownload, receivePort.sendPort).then((_isolate) {
      isolate = _isolate;
    });
    setState(() {
      _counter++;
    });
  }

  void runDownload(SendPort sendPort) {
    print("RUN ISOLATE");
    transport.GeocoderTransport t = new transport.GeocoderTransport(identifier: 'Transporter $_counter');
    transporters.add(t);
    t.download();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
