import 'package:budget_manager/redux/actions/item_actions.dart';
import 'package:flutter/material.dart';

class BudgetsList {
  final List<Budget> budgets;
  final double totalSpent;
  final Status status;
  final String error;

  BudgetsList({this.budgets, this.totalSpent, this.status, this.error});

  BudgetsList.initialState()
      : this.budgets = List.unmodifiable(<Budget>[]),
        this.totalSpent = 0,
        this.status = Status.SUCCESS,
        this.error = "";

  BudgetsList copyWith(
      {List<Budget> budgets, double totalSpent, Status status, String error}) {
    return BudgetsList(
        budgets: budgets ?? this.budgets,
        totalSpent: totalSpent ?? this.totalSpent,
        status: status ?? this.status,
        error: error ?? this.error);
  }
}

class Budget {
  final int budgetID;
  final int userID;
  final String budgetCategory;
  final String name;
  final double balance; // TODO default 0
  final double total; // TODO default 0
  final IconData icon;
  final Color color;

  Budget(
      {@required this.budgetID,
      @required this.userID,
      @required this.budgetCategory,
      @required this.name,
      @required this.balance,
      @required this.total,
      @required this.icon,
      @required this.color});

  Budget copyWith(
      {int budgetID,
      int userID,
      String budgetCategory,
      String name,
      double balance,
      double total,
      IconData icon,
      Color color}) {
    return Budget(
        budgetID: budgetID ?? this.budgetID,
        userID: userID ?? this.userID,
        budgetCategory: budgetCategory ?? this.budgetCategory,
        name: name ?? this.name,
        balance: balance ?? this.balance,
        total: total ?? this.total,
        icon: icon ?? this.icon,
        color: color ?? this.color);
  }

  Budget.fromJson(Map json)
      : this.budgetID = json['id'],
        this.budgetCategory = json["budget_category"],
        this.name = json["name"],
        this.userID =
            1, // TODO fix default values for userID, balance, total, icon, and color.
        this.balance = 0,
        this.total = 0,
        this.icon = Icons.accessibility,
        this.color = Colors.orange;

  Map toJson() => {
        'id': this.budgetID,
        'budget_category': this.budgetCategory,
        'name': this.name,
      };

  @override
  String toString() {
    return toJson().toString();
  }

  String toStringDebug() {
    return this.budgetID.toString();
  }
}
