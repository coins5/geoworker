import 'dart:convert';

ImportedAddresses importedAddressesFromJson(String str) => ImportedAddresses.fromJson(json.decode(str));

String importedAddressesToJson(ImportedAddresses data) => json.encode(data.toJson());

class ImportedAddresses {
  bool connected;
  List<Item> items;

  ImportedAddresses({
    this.connected,
    this.items,
  });

  factory ImportedAddresses.fromJson(Map<String, dynamic> json) => new ImportedAddresses(
    connected: json["connected"],
    items: new List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "connected": connected,
    "items": new List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class Item {
  String ruc;
  String direccion;

  Item({
    this.ruc,
    this.direccion,
  });

  factory Item.fromJson(Map<String, dynamic> json) => new Item(
    ruc: json["RUC"],
    direccion: json["DIRECCION"],
  );

  Map<String, dynamic> toJson() => {
    "RUC": ruc,
    "DIRECCION": direccion,
  };
}