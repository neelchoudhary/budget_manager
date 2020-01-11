import 'package:budget_manager/controller/data_controller.dart';
import 'package:budget_manager/models/budget_category.dart';
import 'package:budget_manager/utilities/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Budget {
  int budgetID;
  int userID;
  String budgetCategory;
  String name;
  double balance = 0;
  double total = 0;
  IconData icon;
  Color color;

  factory Budget.fromJson(json) {
    Budget b = Budget();
    b.budgetID = json['id'];
    b.budgetCategory = json['budget_category'];
    b.name = json['name'];
    b.icon = budgetData.iconMap[b.name];
    b.color = budgetData.budgetCategories.firstWhere(
        (bc) => bc.name.toLowerCase() == b.budgetCategory.toLowerCase(),
        orElse: () {
      BudgetCategory bc = BudgetCategory();
      bc.color = kColor_pink;
      return bc;
    }).color;
    return b;
  }

  Budget();

  @override
  String toString() {
    return this.name +
        " " +
        this.budgetCategory +
        " " +
        this.budgetID.toString();
  }

  String toStringDebug() {
    return this.budgetID.toString();
  }
}
