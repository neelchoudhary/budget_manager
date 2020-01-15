import 'package:budget_manager/redux/actions/item_actions.dart';
import 'package:flutter/material.dart';
import 'category.dart';

class TransactionsList {
  final List<Transaction> allTransactions;
  final List<Transaction> selectedTransactions;
  final DateTime startDate;
  final DateTime endDate;
  final Status status;
  final String error;

  TransactionsList(
      {this.allTransactions,
      this.selectedTransactions,
      this.startDate,
      this.endDate,
      this.status,
      this.error});

  TransactionsList.initialState()
      : this.allTransactions = List.unmodifiable(<Transaction>[]),
        this.selectedTransactions = List.unmodifiable(<Transaction>[]),
        this.endDate = DateTime.now().add(Duration(days: 1)),
        this.startDate =
            DateTime.now().add(Duration(days: -30)), // TODO CHANGE THIS
        this.status = Status.INITIAL,
        this.error = "";

  TransactionsList copyWith(
      {List<Transaction> allTransactions,
      List<Transaction> selectedTransactions,
      DateTime startDate,
      DateTime endDate,
      Status status,
      String error}) {
    return TransactionsList(
        allTransactions: allTransactions ?? this.allTransactions,
        selectedTransactions: selectedTransactions ?? this.selectedTransactions,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        status: status ?? this.status,
        error: error ?? this.error);
  }
}

class Transaction {
  final int transactionID; // TODO changed all id to ID
  final int itemID;
  final int accountID;
  final int categoryID;
  final String budgetName;
  final double balanceProgress;
  final String name;
  final double amount;
  final Category category;
  final String date;
  final Color color;

  Transaction(
      {this.transactionID,
      this.itemID,
      this.accountID,
      this.categoryID,
      this.budgetName,
      this.balanceProgress,
      this.name,
      this.amount,
      this.category,
      this.date,
      this.color});

  Transaction copyWith(
      {int transactionID,
      int itemID,
      int accountID,
      int categoryID,
      String budgetName,
      double balanceProgress,
      String name,
      double amount,
      Category category,
      String date,
      Color color}) {
    return Transaction(
        transactionID: transactionID ?? this.transactionID,
        itemID: itemID ?? this.itemID,
        accountID: accountID ?? this.accountID,
        categoryID: categoryID ?? this.categoryID,
        budgetName: budgetName ?? this.budgetName,
        balanceProgress: balanceProgress ?? this.balanceProgress,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        date: date ?? this.date,
        color: color ?? this.color);
  }

  Transaction.fromJson(Map json)
      : this.transactionID = json['id'],
        this.itemID = json["item_id"],
        this.accountID = json["account_id"],
        this.categoryID = json["category_id"],
        this.budgetName = json["budget_name"],
        this.balanceProgress = 0, // TODO initial value 0?
        this.name = json["transaction_name"],
        this.amount = json["transaction_amount"],
        this.category = null, // TODO def should not be null
        this.date = (json["transaction_date"] as String).substring(0, 10),
        this.color = Colors.red; // TODO get color from institution from item

  Map toJson() => {
        'id': this.transactionID,
        'item_id': this.itemID,
        'account_id': this.accountID,
        'category_id': this.categoryID,
        'budget_name': this.budgetName,
        'transaction_name': this.name,
        'transaction_amount': this.amount,
        'transaction_date':
            this.date, // TODO dates are weird. see substring above.
        '': this.color,
      };

//  static Transaction fromJson(json) {
//    Transaction t = Transaction();
//    t.transactionId = json["id"];
//    t.itemId = json["item_id"];
//    t.accountId = json["account_id"];
//    t.name = json["transaction_name"] as String;
//    t.amount = json["transaction_amount"].toDouble();
//    t.categoryId = json["category_id"];
//    t.budgetName = json["budget_name"];
//    if (t.budgetName == "" && t.amount > 0) {
//      t.budgetName = "Other";
//    }
//    t.date = json["transaction_date"] as String;
//    t.date = t.date.substring(0, 10);
//    for (Category c in budgetData.categories) {
//      if (c.categoryId == t.categoryId) {
//        t.category = c;
//      }
//    }
//    for (Item i in budgetData.items) {
//      if (i.id == t.itemId) {
//        t.color = i.institutionColor;
//      }
//    }
//    return t;
//  }

  @override
  String toString() {
    //   return "${this.name} - ${this.category}: \$${this.amount}";
    return "${this.category}: \$${this.amount.toString()}";
  }

  String toStringDebug() {
    return this.transactionID.toString();
  }
}
