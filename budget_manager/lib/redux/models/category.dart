import 'package:budget_manager/redux/actions/item_actions.dart';
import 'package:flutter/material.dart';

class CategoriesList {
  final List<Category> categories;
  final Status status;
  final String error;

  CategoriesList({this.categories, this.status, this.error});

  CategoriesList.initialState()
      : this.categories = List.unmodifiable(<Category>[]),
        this.status = Status.INITIAL,
        this.error = "";

  CategoriesList copyWith(
      {List<Category> categories, Status status, String error}) {
    return CategoriesList(
        categories: categories ?? this.categories,
        status: status ?? this.status,
        error: error ?? this.error);
  }
}

class Category {
  final int categoryID;
  final String categoryPlaidID;
  final String group;
  final List<String> categories; // TODO default is empty list []

  Category(
      {@required this.categoryID,
      @required this.categoryPlaidID,
      @required this.group,
      @required this.categories});

  Category copyWith(
      {int categoryID,
      String categoryPlaidID,
      String group,
      List<String> categories}) {
    return Category(
        categoryID: categoryID ?? this.categoryID,
        categoryPlaidID: categoryPlaidID ?? this.categoryPlaidID,
        group: group ?? this.group,
        categories: categories ?? this.categories);
  }

  Category.fromJson(Map json)
      : this.categoryID = json['id'],
        this.categoryPlaidID = json["category_id_plaid"],
        this.group = json["category_group"],
        this.categories = []
          ..add(json["category1"])
          ..add(json["category2"])
          ..add(json["category3"]);
  // TODO changed how categories work. Categories will always have length of 3. But some values might be empty string.

  Map toJson() => {
        'id': this.categoryID,
        'category_id_plaid': this.categoryPlaidID,
        'category_group': this.group,
        'category1': this.categories[0],
        'category2': this.categories[1],
        'category3': this.categories[2],
      };

//  factory Category.fromJson(json) {
//    Category c = Category();
//    c.categoryId = json['id'];
//    c.categoryPlaidID = json['category_id_plaid'];
//    c.group = json['category_group'] as String;
//    c.categories.add(json['category1'] as String);
//    if (json['category2'] != "") {
//      c.categories.add(json['category2'] as String);
//    }
//    if (json['category3'] != "") {
//      c.categories.add(json['category3'] as String);
//    }
//
//    return c;
//  }

  @override
  String toString() {
    return toJson().toString();
  }

  String toStringDebug() {
    return this.categoryID.toString();
  }
}
