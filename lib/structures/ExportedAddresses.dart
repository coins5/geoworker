import 'dart:convert';
ExportedAddresses exportedAddressesFromJson(String str) => ExportedAddresses.fromJson(json.decode(str));

String exportedAddressesToJson(ExportedAddresses data) => json.encode(data.toJson());

class ExportedAddresses {
  List<Item> items;// = new List<Item>();

  ExportedAddresses({
    this.items,
  });

  factory ExportedAddresses.fromJson(Map<String, dynamic> json) => new ExportedAddresses(
    items: new List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "items": new List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class Item {
  String ruc;
  String direccion;
  bool exact;
  int coincidences;
  double x;
  double y;
  String reason;

  Item({
    this.ruc,
    this.direccion,
    this.exact,
    this.coincidences,
    this.x,
    this.y,
    this.reason,
  });

  factory Item.fromJson(Map<String, dynamic> json) => new Item(
    ruc: json["RUC"],
    direccion: json["DIRECCION"],
    exact: json["exact"],
    coincidences: json["coincidences"],
    x: json["x"].toDouble(),
    y: json["y"].toDouble(),
    reason: json["reason"],
  );

  Map<String, dynamic> toJson() => {
    "RUC": ruc,
    "DIRECCION": direccion,
    "exact": exact,
    "coincidences": coincidences,
    "x": x,
    "y": y,
    "reason": reason,
  };
}
