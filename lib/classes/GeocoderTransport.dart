import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:geoworker/classes/GeocoderWorker.dart' as engine;

class GeocoderTransport {
  // Transport related
  String base = 'http://192.168.0.175:2193';
  String fetchUrl;
  String pushUrl;

  // GeocoderWorker related
  int timesCompleted;
  engine.GeocoderWorker currentGeocoderWorker;
  bool isConnected;
  int currentDataSize;

  int totalSuccessfullyCompleted;
  int totalCompletedWithErrors;

  String identifier;

  GeocoderTransport({String identifier: 'GENERIC'}) {
    this.fetchUrl = '${this.base}/fetch';
    this.pushUrl = '${this.base}/push';
    this.timesCompleted = 0;

    this.totalSuccessfullyCompleted = 0;
    this.totalCompletedWithErrors = 0;

    this.identifier = identifier;

    this.download();
  }

  void download() {
    http.get(this.fetchUrl).then((response) {
      print('Response status: ${response.statusCode}');
      engine.GeocoderWorker geocoderWorker = new engine.GeocoderWorker(response.body, identifer: this.identifier);

      this.currentGeocoderWorker = geocoderWorker;
      this.isConnected = geocoderWorker.importedAddresses.connected;
      this.currentDataSize = geocoderWorker.importedAddresses.items.length;
      print('Is connected: ${this.isConnected}');
      print('Items length: ${this.currentDataSize}');

      if (this.currentDataSize == 0) {
        if (this.isConnected){
          print('Reload App');
          new Timer(new Duration(seconds: 1),() => this.download());
        }
        else return;
      } else {
        print("MULTI CODE");
        geocoderWorker.multiGeocode().then((data) => this.upload(data));
      }
    }).catchError((error) {
      print(error);
    });
  }
  void upload(String data) {
    print("PUSH!");
    print("data: " + data);
    http.post(
        this.pushUrl,
        headers: {"Content-Type": "application/json"},
        body: data
    )
        .then((response) {
          this.totalSuccessfullyCompleted += this.currentGeocoderWorker.successfullyCompleted;
          this.totalCompletedWithErrors += this.totalCompletedWithErrors;
          print('SEND');
          print('Response status: ${response.statusCode}');
          print('Response body: ${response.body}');
          this.timesCompleted++;
          this.download();
        })
        .catchError((error) {
          print(error);
        });
  }
}