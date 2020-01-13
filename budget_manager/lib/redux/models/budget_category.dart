import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BudgetCategoriesList {
  final List<BudgetCategory> budgetCategories = [
    BudgetCategory(name: "Food", color: Colors.red, icon: Icons.restaurant),
    BudgetCategory(
        name: "Transportation",
        color: Colors.green,
        icon: FontAwesomeIcons.car),
    BudgetCategory(
        name: "Entertainment",
        color: Colors.blue,
        icon: FontAwesomeIcons.cocktail),
    BudgetCategory(
        name: "Shopping",
        color: Colors.orange,
        icon: FontAwesomeIcons.shoppingBasket),
    BudgetCategory(
        name: "Services",
        color: Colors.cyan,
        icon: FontAwesomeIcons.servicestack),
    BudgetCategory(name: "Other", color: Colors.pink, icon: Icons.category),
  ];

  final List<BudgetCategory> incomeCategories = [
    BudgetCategory(
        name: "Income", color: Colors.blue, icon: FontAwesomeIcons.moneyCheck),
  ];

  final List<BudgetCategory> transferCategories = [
    BudgetCategory(
        name: "Transfer", color: Colors.green, icon: Icons.attach_money),
  ];

  final List<BudgetCategory> feesCategories = [
    BudgetCategory(name: "Fees", color: Colors.orange, icon: Icons.error),
  ];

  BudgetCategoriesList.initialState();
}

class BudgetCategory {
  final String name;
  final Color color;
  final IconData icon;

  BudgetCategory(
      {@required this.name, @required this.color, @required this.icon});

  BudgetCategory copyWith({String name, Color color, IconData icon}) {
    return BudgetCategory(
        name: name ?? this.name,
        color: color ?? this.color,
        icon: icon ?? this.icon);
  }

  @override
  String toString() {
    return this.name;
  }
}
