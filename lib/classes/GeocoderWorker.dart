import 'dart:async' show Completer, Future;

import 'package:geocoder/geocoder.dart' show Address, Geocoder;

import 'package:geoworker/structures/ExportedAddresses.dart' as exportedAddress;
import 'package:geoworker/structures/ImportedAddresses.dart' as importedAddress;

class GeocoderWorker {
  importedAddress.ImportedAddresses importedAddresses;
  exportedAddress.ExportedAddresses exportedAddresses;
  int successfullyCompleted;
  int completedWithErrors;
  String identifier;

  GeocoderWorker (String input, {String identifer: 'GENERIC'}) {
    this.importedAddresses = importedAddress.importedAddressesFromJson(input);
    this.exportedAddresses = new exportedAddress.ExportedAddresses(items: new List<exportedAddress.Item>());
    // this.exportedAddresses.items = new List<exportedAddress.Item>();

    this.successfullyCompleted = 0;
    this.completedWithErrors = 0;
    this.identifier = identifer;
  }

  Future multiGeocode () {
    Completer completer = new Completer();
    for(int i = 0; i < this.importedAddresses.items.length; i++) {
      _geocode(this.importedAddresses.items[i], completer);
    }
    return completer.future;
  }

  void _geocode (importedAddress.Item inputItem, Completer completer) {
    Geocoder.local.findAddressesFromQuery(inputItem.direccion)
        .then((response) => this._onLocated(inputItem, response, completer))
        .catchError((error) => this._onErrorLocating(error, completer));
  }

  void _onLocated (importedAddress.Item inputItem, List<Address> response, Completer completer) {
    exportedAddress.Item coords;
    if (response.length == 0) {
      coords = new exportedAddress.Item(
          ruc: inputItem.ruc,
          direccion: inputItem.direccion,
          x: 0.0,
          y: 0.0,
          exact: false,
          coincidences: 0,
          reason: 'Address not found'
      );
    } else {
      Address firstAddress = response.first;
      coords = new exportedAddress.Item(
          ruc: inputItem.ruc,
          direccion: inputItem.direccion,
          x: firstAddress.coordinates.longitude,
          y: firstAddress.coordinates.latitude,
          exact: (response.length == 1),
          coincidences: response.length,
          reason: ''
      );
    }
    this.exportedAddresses.items.add(coords);
    print ("(${this.identifier}): ADDING OK ${this.successfullyCompleted}");
    this._isCompleted(completer);
  }

  void _onErrorLocating (Object error, Completer completer) {
    print(error);
    print("(${this.identifier}): ADDING WITH ERROR ${this.successfullyCompleted}");
    this._isCompleted(completer);
  }

  void _isCompleted (Completer completer) {
    this.successfullyCompleted++;
    if (this.importedAddresses.items.length == this.successfullyCompleted) {
      completer.complete(exportedAddress.exportedAddressesToJson(this.exportedAddresses));
    }
  }
}