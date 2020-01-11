import 'dart:ui';

import 'package:budget_manager/controller/data_controller.dart';

import 'category.dart';
import 'item.dart';

class Transaction {
  int transactionId;
  int itemId;
  int accountId;
  int categoryId;
  String budgetName;
  double balanceProgress;
  String name;
  double amount;
  Category category;
  String date;
  Color color;

  static Transaction fromJson(json) {
    Transaction t = Transaction();
    t.transactionId = json["id"];
    t.itemId = json["item_id"];
    t.accountId = json["account_id"];
    t.name = json["transaction_name"] as String;
    t.amount = json["transaction_amount"].toDouble();
    t.categoryId = json["category_id"];
    t.budgetName = json["budget_name"];
    if (t.budgetName == "" && t.amount > 0) {
      t.budgetName = "Other";
    }
    t.date = json["transaction_date"] as String;
    t.date = t.date.substring(0, 10);
    for (Category c in budgetData.categories) {
      if (c.categoryId == t.categoryId) {
        t.category = c;
      }
    }
    for (Item i in budgetData.items) {
      if (i.id == t.itemId) {
        t.color = i.institutionColor;
      }
    }
    return t;
  }

  @override
  String toString() {
    //   return "${this.name} - ${this.category}: \$${this.amount}";
    return "${this.category}: \$${this.amount.toString()}";
    //  return this.accountId;
  }

  String toStringDebug() {
    return this.transactionId.toString();
  }
}
