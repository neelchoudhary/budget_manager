import 'dart:collection';

import 'package:budget_manager/models/account.dart';
import 'package:budget_manager/models/budget.dart';
import 'package:budget_manager/models/budget_category.dart';
import 'package:budget_manager/models/category.dart';
import 'package:budget_manager/models/item.dart';
import 'package:budget_manager/models/transaction.dart';
import 'package:budget_manager/networking/plaid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

//const client_id = "";
//const public_key = "";
//const secret_key_dev = "";
//const secret_key_sandbox = "";

const client_id = "5e06c8f083a323001667b4ee";
const public_key = "c6c58d5bd03f477459539909c18188";
const secret_key_dev = "f71c7157bc8a980c8a27f1d5d0ed8f";
const secret_key_sandbox = "02dc5db4dd28681e37559371be7afc";

const bool plaidSandbox = true;

// REDUX BRANCH

Configuration plaidConfig = Configuration(
    plaidPublicKey: public_key,
    plaidBaseUrl: 'https://cdn.plaid.com/link/v2/stable/link.html',
    plaidEnvironment: plaidSandbox ? 'sandbox' : 'development',
    plaidClientId: client_id,
    secret: plaidSandbox ? secret_key_sandbox : secret_key_dev,
    clientName: 'ClientName',
    webhook: 'http://a05e80bc.ngrok.io',
    products: 'auth',
    selectAccount: 'true');

class BudgetData {
  static final BudgetData _budgetData = new BudgetData._internal();

  final _jsonHeader = {'Content-Type': 'application/json'};
  final _baseUri = 'http://localhost:8080';

  int userID = 1; // Set when logging in
  List<Item> items = [];
  List<Account> allAccounts = [];
  List<Account> selectedAccounts = [];
  List<Transaction> allTransactions = [];
  List<Transaction> currentTransactions = [];
  List<Category> categories = [];
  List<Budget> budgets = [];
  Future<bool> hasDataLoaded;
  double totalSpent = 0;
  DateTime startDate;
  DateTime endDate;
  List<BudgetCategory> budgetCategories = [
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

  List<BudgetCategory> incomeCategories = [
    BudgetCategory(
        name: "Income", color: Colors.blue, icon: FontAwesomeIcons.moneyCheck),
  ];

  List<BudgetCategory> transferCategories = [
    BudgetCategory(
        name: "Transfer", color: Colors.green, icon: Icons.attach_money),
  ];

  List<BudgetCategory> feesCategories = [
    BudgetCategory(name: "Fees", color: Colors.orange, icon: Icons.error),
  ];

  HashMap<String, IconData> iconMap = new HashMap<String, IconData>();

  // Initialize mapping of budget names to icons.
  /// TODO app state
  void initIconMap() {
    this.iconMap.clear();
    this.iconMap.putIfAbsent("Dining In", () => Icons.restaurant);
    this.iconMap.putIfAbsent("Dining Out", () => Icons.fastfood);
    this.iconMap.putIfAbsent("Groceries", () => Icons.local_grocery_store);
    this.iconMap.putIfAbsent("Ride Sharing", () => Icons.directions_car);
    this
        .iconMap
        .putIfAbsent("Public Transportation", () => FontAwesomeIcons.train);
    this.iconMap.putIfAbsent("Bars, Drinks", () => Icons.local_bar);
    this.iconMap.putIfAbsent("Arts and Entertainment", () => Icons.local_play);
    this.iconMap.putIfAbsent("Video Games", () => Icons.videogame_asset);
    this
        .iconMap
        .putIfAbsent("Clothes and Accessories", () => FontAwesomeIcons.tshirt);
    this.iconMap.putIfAbsent("Electronics/Digital", () => Icons.tv);
    this.iconMap.putIfAbsent("Online Retail", () => FontAwesomeIcons.opencart);
    this.iconMap.putIfAbsent("Retail", () => FontAwesomeIcons.shoppingCart);
    this.iconMap.putIfAbsent("Salon", () => FontAwesomeIcons.mars);
    this.iconMap.putIfAbsent("Utilities", () => Icons.build);
    this.iconMap.putIfAbsent("Internet", () => FontAwesomeIcons.wifi);
    this.iconMap.putIfAbsent("Cable", () => FontAwesomeIcons.tv);
    this.iconMap.putIfAbsent("Overdraft Fee", () => FontAwesomeIcons.moneyBill);
    this.iconMap.putIfAbsent("ATM Fee", () => Icons.atm);
    this.iconMap.putIfAbsent("Late Payment Fee", () => Icons.assignment_late);

    this.iconMap.putIfAbsent("Gas Station", () => Icons.local_gas_station);
    this.iconMap.putIfAbsent("Air Travel", () => Icons.local_airport);
    this.iconMap.putIfAbsent("Parking", () => Icons.local_parking);
    this.iconMap.putIfAbsent("Investments", () => Icons.person);
    this
        .iconMap
        .putIfAbsent("Other Transfer", () => FontAwesomeIcons.exchangeAlt);
    this.iconMap.putIfAbsent("Interest Income", () => Icons.monetization_on);
    this.iconMap.putIfAbsent("Payroll", () => Icons.monetization_on);
    this.iconMap.putIfAbsent("Venmo", () => Icons.monetization_on);
    this.iconMap.putIfAbsent("Chase QuickPay", () => Icons.monetization_on);
  }

  // Categorize transactions into their respective budgets.
  // Transactions and categories must be loaded.
  void categorizeTransactions() {
    this.totalSpent = 0;

    for (Budget b in this.budgets) {
      b.balance = 0;
      for (Transaction t in this.currentTransactions.reversed) {
        if (t.budgetName == b.name) {
          if (this.budgetCategories.any((bc) =>
              bc.name.toLowerCase() == b.budgetCategory.toLowerCase())) {
            totalSpent += t.amount;
            b.balance += t.amount;
            t.balanceProgress = b.balance;
          }
          if (this.incomeCategories.any((bc) =>
              bc.name.toLowerCase() == b.budgetCategory.toLowerCase())) {
            b.balance += t.amount * -1;
            t.balanceProgress = b.balance;
          }
          if (this.transferCategories.any((bc) =>
              bc.name.toLowerCase() == b.budgetCategory.toLowerCase())) {
            totalSpent += t.amount;
            b.balance += t.amount * -1;
            t.balanceProgress = b.balance;
          }
          if (this.feesCategories.any((bc) =>
              bc.name.toLowerCase() == b.budgetCategory.toLowerCase())) {
            totalSpent += t.amount;
            b.balance += t.amount;
            t.balanceProgress = b.balance;
          }
          //      totalSpent += (t.amount < 0) ? t.amount : 0;
        }
      }
    }
  }

  Future<void> selectAccounts(int itemID) async {
    for (Account account in this.allAccounts) {
      await http.put(
          '${this._baseUri}/accounts/select_id/$itemID/${account.id}/${account.selected}',
          headers: this._jsonHeader);
    }
    this.selectedAccounts = this.allAccounts.where((a) => a.selected).toList();
    await this.refreshAccounts();
    return;
  }

  // Create new item and account(s).
  Future<bool> createItemAndAccounts(
      String publicToken,
      List<String> accountIDsPlaid,
      String institutionID,
      List<String> accountNames,
      List<String> accountMasks,
      List<String> accountSubtypes) async {
    final http.Response responseAccessToken = await http.post(
        '${this._baseUri}/items/${budgetData.userID}/$publicToken/$institutionID/${accountNames[0]}/${accountMasks[0]}/${accountSubtypes[0]}',
        headers: this._jsonHeader);
    responsePrint(responseAccessToken.statusCode, responseAccessToken.body);
    if (responseAccessToken.statusCode == 200) {
      var decodedItemJSON = convert.jsonDecode(responseAccessToken.body);
      Item item = Item.fromJson(decodedItemJSON);
      this.items.add(item);

      final http.Response responseAccounts = await http.post(
          '${this._baseUri}/accounts/${this.userID}/${item.id}/${item.institutionID}',
          headers: _jsonHeader);
      responsePrint(responseAccounts.statusCode, responseAccounts.body);

      for (String accountIDPlaid in accountIDsPlaid) {
        final http.Response responseAccount = await http.put(
            '${this._baseUri}/accounts/select_plaid_id/${item.id}/$accountIDPlaid/true',
            headers: _jsonHeader);
        responsePrint(responseAccount.statusCode, responseAccount.body);
//      var decodedAccountJSON = convert.jsonDecode(responseAccount.body);
//      Account account = Account.fromJson(decodedAccountJSON);
//      this.accounts.add(account);
      }

      await this.createTransactions(item.id);
      await this.refreshAccounts();
      return true;
    } else {
      if (responseAccessToken.statusCode == 406) {
        print("account already exists");
        return false;
      }
      print("bruh");
      return false;
    }
  }

  // Create transactions for an item.
  Future<void> createTransactions(int itemID) async {
    // Format dates as YYYY-MM-DD
    final http.Response response = await http
        .post('${this._baseUri}/transactions/$itemID', headers: _jsonHeader);
    responsePrint(response.statusCode, response.body);
    return;
  }

  // Get items and accounts from db.
  Future<void> getItemsAndAccounts() async {
    this.items.clear();
    this.selectedAccounts.clear();
    this.allAccounts.clear();

    final http.Response responseAccessToken = await http.get(
        '${this._baseUri}/items/${this.userID}',
        headers: this._jsonHeader);
    responsePrint(responseAccessToken.statusCode, responseAccessToken.body);

    Iterable decodedItemsJSON = convert.jsonDecode(responseAccessToken.body);
    List<Item> items =
        decodedItemsJSON.map((json) => Item.fromJson(json)).toList();
    this.items = items;

    for (Item item in items) {
      final http.Response responseAccounts = await http.get(
          '${this._baseUri}/accounts/${item.id}',
          headers: this._jsonHeader);
      responsePrint(responseAccounts.statusCode, responseAccounts.body);
      Iterable decodedAccountsJSON = convert.jsonDecode(responseAccounts.body);
      List<Account> accounts =
          decodedAccountsJSON.map((json) => Account.fromJson(json)).toList();
      this.allAccounts.addAll(accounts);
      accounts = accounts.where((account) => account.selected).toList();
      this.selectedAccounts.addAll(accounts);
    }

    return;
  }

  // Get transactions from db. Must getCategories before transactions.
  Future<void> getTransactions() async {
    this.allTransactions.clear();

    print(this.items.length);
    for (Item item in this.items) {
      final http.Response responseTransactions = await http.get(
          '${this._baseUri}/transactions/${item.id}',
          headers: this._jsonHeader);
      Iterable decodedTransactionsJSON =
          convert.jsonDecode(responseTransactions.body);
      List<Transaction> transactions = decodedTransactionsJSON
          .map((json) => Transaction.fromJson(json))
          .toList();
      this.allTransactions.addAll(transactions);
    }

    // Only show transactions that are selected in account
    this.allTransactions = this
        .allTransactions
        .where((t) => this.selectedAccounts.any((a) => a.id == t.accountId))
        .toList();
    this.allTransactions.sort((t1, t2) =>
        DateTime.parse(t2.date).compareTo((DateTime.parse(t1.date))));
    this.currentTransactions = this
        .allTransactions
        .where((t) =>
            DateTime.parse(t.date).isAfter(this.startDate) &&
            DateTime.parse(t.date).isBefore(this.endDate))
        .toList();
    return;
  }

  void setDefaultDates() {
    int dayOfMonth = DateTime.now().day;
    this.startDate = DateTime.now().add(Duration(days: -dayOfMonth + 1));
    this.endDate = DateTime.now().add(Duration(days: 1));
  }

  void setStartDate(String date) {
    this.startDate = DateTime.parse(date);
  }

  void setEndDate(String date) {
    this.endDate = DateTime.parse(date);
  }

  // Get categories from db.
  Future<void> getCategories() async {
    this.categories.clear();

    final http.Response response = await http.get('${this._baseUri}/categories',
        headers: this._jsonHeader);
    Iterable decodedJSON = convert.jsonDecode(response.body);
    List<Category> categories =
        decodedJSON.map((json) => Category.fromJson(json)).toList();
    this.categories = categories;
    return;
  }

  // Get budgets from db.
  Future<void> getBudgets() async {
    this.budgets.clear();

    final http.Response response =
        await http.get('${this._baseUri}/budgets', headers: this._jsonHeader);
    Iterable decodedJSON = convert.jsonDecode(response.body);
    List<Budget> budgets =
        decodedJSON.map((json) => Budget.fromJson(json)).toList();
    this.budgets = budgets;

    return;
  }

  // Update account data in db and get updated account & transaction data from db.
  Future<void> refreshAccounts() async {
    for (Account account in this.selectedAccounts) {
      final http.Response responseAccounts = await http.put(
          '${this._baseUri}/accounts/${account.itemId}/${account.id}',
          headers: this._jsonHeader);
      responsePrint(responseAccounts.statusCode, responseAccounts.body);
    }
    await getItemsAndAccounts();
    await getTransactions();
    categorizeTransactions();
    return;
  }

  // Update transaction in db and get updated transactions from db.
  Future<void> editTransaction(Transaction t) async {
    final http.Response response = await http.put(
        '${this._baseUri}/transactions/${t.itemId}/${t.transactionId}',
        headers: this._jsonHeader);
    responsePrint(response.statusCode, response.body);
    await getTransactions();
    return;
  }

  // Remove item from db and get updated items, accounts, and transactions from db.
  Future<void> removeItem(int itemID) async {
    final http.Response response = await http.delete(
        '${this._baseUri}/items/$userID/$itemID',
        headers: this._jsonHeader);
    responsePrint(response.statusCode, response.body);
    this.items.removeWhere((item) => item.id == itemID);
    await this.refreshAccounts();
    return;
  }

  // Remove account from db and get updated items, accounts and transactions from db.
  Future<void> removeAccount(int itemID, int accountID) async {
    final http.Response response = await http.put(
        '${this._baseUri}/accounts/select_id/$itemID/$accountID/false',
        headers: this._jsonHeader);
    responsePrint(response.statusCode, response.body);
    this.selectedAccounts.removeWhere((account) => account.id == accountID);
    await this.refreshAccounts();
    return;
  }

  // Calculate total balance from all accounts.
  double balanceTotal() {
    return selectedAccounts.fold(
        0, (sum, element) => sum + element.currentBalance);
  }

  // Print http response helper method.
  void responsePrint(int statusCode, String body) {
    print("Status Code: ${statusCode.toString()}. Body: $body");
  }

  Future<bool> loadDataInit() async {
    //  _budgetData.initMap();
    _budgetData.initIconMap();
    _budgetData.setDefaultDates();
    await _budgetData.getCategories();
    await _budgetData.getItemsAndAccounts();
    await _budgetData.getTransactions();
    await _budgetData.getBudgets();
    _budgetData.categorizeTransactions();
//    return Future.delayed(Duration(seconds: 1), () {
//      return true;
//    });
    return true;
  }

  // Constructor
  factory BudgetData() {
    _budgetData.hasDataLoaded = _budgetData.loadDataInit();
    return _budgetData;
  }
  BudgetData._internal();
}

final budgetData = BudgetData();
