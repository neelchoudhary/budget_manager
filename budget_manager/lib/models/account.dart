import 'dart:ui';

import 'package:budget_manager/controller/data_controller.dart';
import 'package:budget_manager/models/item.dart';

class Account {
  int id;
  int itemId;
  String idPlaid;
  double currentBalance;
  String accountName;
  String officialName;
  String accountType;
  String accountSubType;
  String accountMask;
  bool selected;
  Color color;

  static Account fromJson(json) {
    Account a = Account();
    a.id = json["id"];
    a.itemId = json["item_id"];
    a.idPlaid = json["account_id_plaid"];
    a.currentBalance = json["current_balance"].toDouble();
    a.accountName = json["account_name"];
    a.officialName = json["official_name"];
    a.accountType = json["account_type"];
    a.accountSubType = json["account_subtype"];
    a.accountMask = json["account_mask"];
    a.selected = json["selected"];
    for (Item i in budgetData.items) {
      if (i.id == a.itemId) {
        a.color = i.institutionColor;
      }
    }
    return a;
  }

  @override
  String toString() {
    return "${this.id}: ${this.accountName}";
    // return "${this.accountName} ${this.accountType}: \$${this.balance}";
  }
}
