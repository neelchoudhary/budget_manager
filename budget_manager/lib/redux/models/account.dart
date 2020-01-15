import 'package:flutter/material.dart';
import 'package:budget_manager/redux/actions/item_actions.dart';

class AccountsList {
  final List<Account> allAccounts;
  final List<Account> selectedAccounts;
  final double totalBalance;
  final Status status;
  final String error;

  AccountsList(
      {this.allAccounts,
      this.selectedAccounts,
      this.totalBalance,
      this.status,
      this.error});

  AccountsList.initialState()
      : this.allAccounts = List.unmodifiable(<Account>[]),
        this.selectedAccounts = List.unmodifiable(<Account>[]),
        this.totalBalance = 0,
        this.status = Status.INITIAL,
        this.error = "";

  AccountsList copyWith(
      {List<Account> allAccounts,
      List<Account> selectedAccounts,
      double totalBalance,
      Status status,
      String error}) {
    return AccountsList(
        allAccounts: allAccounts ?? this.allAccounts,
        selectedAccounts: selectedAccounts ?? this.selectedAccounts,
        totalBalance: totalBalance ?? this.totalBalance,
        status: status ?? this.status,
        error: error ?? this.error);
  }
}

class Account {
  final int id;
  final int itemID;
  final String accountPlaidID;
  final double currentBalance;
  final String accountName;
  final String officialName;
  final String accountType;
  final String accountSubType;
  final String accountMask;
  final bool selected;
  final Color color;

  Account(
      {@required this.id,
      @required this.itemID,
      @required this.accountPlaidID,
      @required this.currentBalance,
      @required this.accountName,
      @required this.officialName,
      @required this.accountType,
      @required this.accountSubType,
      @required this.accountMask,
      @required this.selected,
      @required this.color});

  Account copyWith(
      {int id,
      int itemID,
      String accountPlaidID,
      double currentBalance,
      String accountName,
      String officialName,
      String accountType,
      String accountSubType,
      String accountMask,
      bool selected,
      Color color}) {
    return Account(
        id: id ?? this.id,
        itemID: itemID ?? this.itemID,
        accountPlaidID: accountPlaidID ?? this.accountPlaidID,
        currentBalance: currentBalance ?? this.currentBalance,
        accountName: accountName ?? this.accountName,
        officialName: officialName ?? this.officialName,
        accountType: accountType ?? this.accountType,
        accountSubType: accountSubType ?? this.accountSubType,
        accountMask: accountMask ?? this.accountMask,
        selected: selected ?? this.selected,
        color: color ?? this.color);
  }

  Account.fromJson(Map json)
      : this.id = json['id'],
        this.itemID = json["item_id"],
        this.accountPlaidID = json["account_id_plaid"],
        this.currentBalance = json["current_balance"].toDouble(),
        this.accountName = json["account_name"],
        this.officialName = json["official_name"],
        this.accountType = json["account_type"],
        this.accountSubType = json["account_subtype"],
        this.accountMask = json["account_mask"],
        this.selected = json['selected'],
        this.color =
            Colors.orange; // TODO fix color, get color from institution

  Map toJson() => {
        'id': this.id,
        'item_id': this.itemID,
        'account_id_plaid': this.accountPlaidID,
        'current_balance': this.currentBalance,
        'account_name': this.accountName,
        'official_name': this.officialName,
        'account_type': this.accountType,
        'account_subtype': this.accountSubType,
        'account_mask': this.accountMask,
        'selected': this.selected,
      };

  @override
  String toString() {
    return toJson().toString();
  }
}
