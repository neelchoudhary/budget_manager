import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BudgetCategory {
  String name;
  Color color;
  IconData icon;
  double balance;
  double total;

//  factory BudgetCategory.fromJson(json) {
//    BudgetCategory b = BudgetCategory();
//    b.budgetID = json['id'];
//    b.userID = json['user_id'];
//    b.categoryIDs = json['category_ids'];
//    b.budgetCategory = json['budget_category'];
//    b.name = json['name'];
//    b.balance = json['balance'];
//    b.total = json['total'];
//    return b;
//  }

  BudgetCategory({this.name, this.color, this.icon, this.balance, this.total});

  BudgetCategory.empty();

  @override
  String toString() {
    return this.name;
  }
}
