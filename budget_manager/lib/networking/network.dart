import 'dart:async';
import 'dart:io';
import 'package:budget_manager/redux/models/account.dart';
import 'package:budget_manager/redux/models/budget.dart';
import 'package:budget_manager/redux/models/category.dart';
import 'package:budget_manager/redux/models/item.dart';
import 'package:budget_manager/redux/models/transaction.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

final _jsonHeader = {'Content-Type': 'application/json'};
final _baseUri = 'http://localhost:8080';

class Network {
  // Get parameters from plaid link response.

  // TODO Add.
  static Future<void> addInstitutionToServer(
      {int userID,
      String publicToken,
      String institutionID,
      List<String> accountNames,
      List<String> accountMasks,
      List<String> accountSubtypes,
      List<String> accountPlaidIDs}) async {
    Item item = await _addItemToServer(
        userID: userID,
        publicToken: publicToken,
        institutionID: institutionID,
        accountNames: accountNames,
        accountMasks: accountMasks,
        accountSubtypes: accountSubtypes);
    await _addAccountsToServer(
        userID: userID,
        itemID: item.id,
        institutionPlaidID: institutionID,
        accountPlaidIDs: accountPlaidIDs);
    await _addTransactionsToServer(itemID: item.id);
    return;
  }

  /// TODO add.
  static Future<Item> _addItemToServer(
      {int userID,
      String publicToken,
      String institutionID,
      List<String> accountNames,
      List<String> accountMasks,
      List<String> accountSubtypes}) async {
    final http.Response responseAccessToken = await http.post(
        '$_baseUri/items/$userID/$publicToken/$institutionID/${accountNames[0]}/${accountMasks[0]}/${accountSubtypes[0]}',
        headers: _jsonHeader);
    responsePrint(responseAccessToken.statusCode, responseAccessToken.body);
    if (responseAccessToken.statusCode == 200) {
      var decodedItemJSON = convert.jsonDecode(responseAccessToken.body);
      Item item = Item.fromJson(decodedItemJSON);
      return item;
    } else {
      if (responseAccessToken.statusCode == 406) {
        print("account already exists");
        throw HttpException("Account already exists");
      }
      throw HttpException("Error creating item: " +
          responseAccessToken.statusCode.toString() +
          ": " +
          responseAccessToken.body.toString());
    }
  }

  static Future<List<Item>> getItemsFromServer({int userID}) async {
    final http.Response responseAccessToken =
        await http.get('$_baseUri/items/$userID', headers: _jsonHeader);
    responsePrint(responseAccessToken.statusCode, responseAccessToken.body);

    if (responseAccessToken.statusCode == 200) {
      Iterable decodedItemsJSON = convert.jsonDecode(responseAccessToken.body);
      List<Item> items =
          decodedItemsJSON.map((json) => Item.fromJson(json)).toList();
      return items;
    } else {
      return [];
    }
  }

  /// TODO remove
  static Future<void> removeItemFromServer({int userID, int itemID}) async {
    final http.Response response = await http
        .delete('$_baseUri/items/$userID/$itemID', headers: _jsonHeader);
    responsePrint(response.statusCode, response.body);
    return;
  }

  /// TODO add.
  static Future<void> _addAccountsToServer(
      {int userID,
      int itemID,
      String institutionPlaidID,
      List<String> accountPlaidIDs}) async {
    final http.Response responseAccounts = await http.post(
        '$_baseUri/accounts/$userID/$itemID/$institutionPlaidID',
        headers: _jsonHeader);
    responsePrint(responseAccounts.statusCode, responseAccounts.body);

    for (String accountPlaidID in accountPlaidIDs) {
      final http.Response responseAccount = await http.put(
          '$_baseUri/accounts/select_plaid_id/$itemID/$accountPlaidID/true',
          headers: _jsonHeader);
      responsePrint(responseAccount.statusCode, responseAccount.body);
    }
    return;
  }

  /// TODO update
  static Future<void> toggleAccountsInServer(
      {int itemID, List<Account> allAccounts}) async {
    for (Account account in allAccounts) {
      await http.put(
          '$_baseUri/accounts/select_id/$itemID/${account.id}/${account.selected}',
          headers: _jsonHeader);
    }
    return;
  }

  /// TODO update
  static Future<void> hideAccountInServer({int itemID, int accountID}) async {
    final http.Response response = await http.put(
        '$_baseUri/accounts/select_id/$itemID/$accountID/false',
        headers: _jsonHeader);
    responsePrint(response.statusCode, response.body);
    return;
  }

  /// TODO update maybe delete
  static Future<void> updateAccountsInServer(
      {List<Account> allAccounts}) async {
    for (Account account in allAccounts) {
      final http.Response responseAccounts = await http.put(
          '$_baseUri/accounts/${account.itemID}/${account.id}',
          headers: _jsonHeader);
      responsePrint(responseAccounts.statusCode, responseAccounts.body);
    }
    return;
  }

  static Future<List<Account>> getAccountsFromServer({List<Item> items}) async {
    List<Account> allAccounts = [];
    List<Account> selectedAccounts = [];
    for (Item item in items) {
      final http.Response responseAccounts =
          await http.get('$_baseUri/accounts/${item.id}', headers: _jsonHeader);
      responsePrint(responseAccounts.statusCode, responseAccounts.body);
      Iterable decodedAccountsJSON = convert.jsonDecode(responseAccounts.body);
      List<Account> accounts =
          decodedAccountsJSON.map((json) => Account.fromJson(json)).toList();
      allAccounts.addAll(accounts);
      accounts = accounts.where((account) => account.selected).toList();
      selectedAccounts.addAll(accounts);
    }
    return allAccounts;
  }

  /// TODO add
  static Future<void> _addTransactionsToServer({int itemID}) async {
    // TODO wrap all http calls in a try catch
    final http.Response response =
        await http.post('$_baseUri/transactions/$itemID', headers: _jsonHeader);
    responsePrint(response.statusCode, response.body);
    return;
  }

  /// TODO update
  static Future<void> editTransactionOnServer({Transaction transaction}) async {
    final http.Response response = await http.put(
        '$_baseUri/transactions/${transaction.itemID}/${transaction.transactionID}',
        headers: _jsonHeader);
    responsePrint(response.statusCode, response.body);
    return;
  }

  static Future<List<Transaction>> getTransactionsFromServer(
      {List<Item> items}) async {
    List<Transaction> allTransactions = [];
    for (Item item in items) {
      final http.Response responseTransactions = await http
          .get('$_baseUri/transactions/${item.id}', headers: _jsonHeader);
      Iterable decodedTransactionsJSON =
          convert.jsonDecode(responseTransactions.body);
      List<Transaction> transactions = decodedTransactionsJSON
          .map((json) => Transaction.fromJson(json))
          .toList();
      allTransactions.addAll(transactions);
    }
    return allTransactions;
  }

  static Future<List<Category>> getCategoriesFromServer() async {
    final http.Response response =
        await http.get('$_baseUri/categories', headers: _jsonHeader);
    Iterable decodedJSON = convert.jsonDecode(response.body);
    List<Category> categories =
        decodedJSON.map((json) => Category.fromJson(json)).toList();
    return categories;
  }

  static Future<List<Budget>> getBudgetsFromServer() async {
    final http.Response response =
        await http.get('$_baseUri/budgets', headers: _jsonHeader);
    Iterable decodedJSON = convert.jsonDecode(response.body);
    List<Budget> budgets =
        decodedJSON.map((json) => Budget.fromJson(json)).toList();
    return budgets;
  }

  // Print http response helper method.
  static void responsePrint(int statusCode, String body) {
    print("Status Code: ${statusCode.toString()}. Body: $body");
  }
}
