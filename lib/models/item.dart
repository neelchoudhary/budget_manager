import 'package:flutter/material.dart';
import 'dart:convert' as convert;

class Item {
  int id;
  String plaidId;
  int userId;
  String institutionID;
  String institutionName;
  Color institutionColor;
  Image institutionLogo;

  static Item fromJson(json) {
    Item i = Item();
    i.id = json["id"];
    i.plaidId = json["item_id_plaid"];
    i.userId = json["user_id"];
    i.institutionID = json["institution_id_plaid"];
    i.institutionName = json["institution_name"];
    i.institutionColor =
        Color(int.parse("0xff" + json["institution_color"].substring(1)));
    i.institutionLogo =
        Image.memory(convert.base64Decode(json["institution_logo"]));
    return i;
  }

  @override
  String toString() {
    return "${this.id}: ${this.institutionName}";
  }
}
