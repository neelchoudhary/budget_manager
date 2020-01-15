import 'package:budget_manager/redux/actions/item_actions.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;

class ItemsList {
  final List<Item> items;
  final Status status;
  final String error;

  ItemsList({this.items, this.status, this.error});

  ItemsList.initialState()
      : items = List.unmodifiable(<Item>[]),
        status = Status.INITIAL,
        error = "";

  ItemsList copyWith({List<Item> items, Status status, String error}) {
    return ItemsList(
        items: items ?? this.items,
        status: status ?? this.status,
        error: error ?? this.error);
  }
}

class Item {
  final int id;
  final String plaidID;
  final int userID; // TODO changed userId and plaidId to ID.
  final String institutionID;
  final String institutionName;
  final Color institutionColor;
  final Image institutionLogo;

  Item(
      {this.id,
      this.plaidID,
      this.userID,
      this.institutionID,
      this.institutionName,
      this.institutionColor,
      this.institutionLogo});

  Item copyWith(
      {int id,
      String plaidID,
      int userID,
      String institutionID,
      String institutionName,
      Color institutionColor,
      Image institutionLogo}) {
    return Item(
        id: id ?? this.id,
        plaidID: plaidID ?? this.plaidID,
        userID: userID ?? this.userID,
        institutionID: institutionID ?? this.institutionID,
        institutionName: institutionName ?? this.institutionName,
        institutionColor: institutionColor ?? this.institutionColor,
        institutionLogo: institutionLogo ?? this.institutionLogo);
  }

  Item.fromJson(Map json)
      : this.id = json['id'],
        this.plaidID = json["item_id_plaid"],
        this.userID = json["user_id"],
        this.institutionID = json["institution_id_plaid"],
        this.institutionName = json["institution_name"],
        this.institutionColor =
            Color(int.parse("0xff" + json["institution_color"].substring(1))),
        this.institutionLogo =
            Image.memory(convert.base64Decode(json["institution_logo"]));

  Map toJson() => {
        'id': this.id,
        'item_id_plaid': this.plaidID,
        'user_id': this.userID,
        'institution_id_plaid': this.institutionID,
        'institution_name': this.institutionName,
        'institution_color': this.institutionColor,
        'institution_logo': this.institutionLogo,
      };

//  static Item fromJson(json) {
//    Item i = Item();
//    i.id = json["id"];
//    i.plaidId = json["item_id_plaid"];
//    i.userId = json["user_id"];
//    i.institutionID = json["institution_id_plaid"];
//    i.institutionName = json["institution_name"];
//    i.institutionColor =
//        Color(int.parse("0xff" + json["institution_color"].substring(1)));
//    i.institutionLogo =
//        Image.memory(convert.base64Decode(json["institution_logo"]));
//    return i;
//  }

  @override
  String toString() {
    return toJson().toString();
  }
}
