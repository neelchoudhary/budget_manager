import 'package:flutter/material.dart';

import 'account.dart';
import 'budget.dart';
import 'category.dart';
import 'item.dart';
import 'transaction.dart';

class AppState {
  final int userID; // Set when logging in
  final ItemsList itemsList;
  final AccountsList accountsList;
  final TransactionsList transactionsList;
  final CategoriesList categoriesList;
  final BudgetsList budgetsList;

  const AppState({
    @required this.userID,
    @required this.itemsList,
    @required this.accountsList,
    @required this.transactionsList,
    @required this.categoriesList,
    @required this.budgetsList,
  });

  AppState.initialState()
      : this.userID = 1,
        this.itemsList = ItemsList.initialState(),
        this.accountsList = AccountsList.initialState(),
        this.transactionsList = TransactionsList.initialState(),
        this.categoriesList = CategoriesList.initialState(),
        this.budgetsList = BudgetsList.initialState();

//  @override
//  String toString() {
//    return toJson().toString();
//  }
}
