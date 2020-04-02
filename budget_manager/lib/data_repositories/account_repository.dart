import 'package:budget_manager/data_repositories/shared_repository.dart';
import 'package:budget_manager/redux/models/account.dart';
import 'package:budget_manager/redux/models/item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class AccountRepository {
  /// GET - Retrieves accounts from server.
  static Future<List<Account>> getAccountsFromServer({List<Item> items}) async {
    await Future.delayed(Duration(milliseconds: delay));

    List<Account> allAccounts = [];
    List<Account> selectedAccounts = [];
    for (Item item in items) {
      final http.Response responseAccounts =
          await http.get('$baseUri/accounts/${item.id}', headers: jsonHeader);
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

  /// UPDATE - Updates the selected accounts in the server.
  static Future<void> toggleAccountsInServer(
      {int itemID, List<Account> allAccounts}) async {
    await Future.delayed(Duration(milliseconds: delay));

    for (Account account in allAccounts) {
      await http.put(
          '$baseUri/accounts/select_id/$itemID/${account.id}/${account.selected}',
          headers: jsonHeader);
    }
    return;
  }

  /// UPDATE - Updates the account to be unselected in the server.
  static Future<void> hideAccountInServer({int itemID, int accountID}) async {
    await Future.delayed(Duration(milliseconds: delay));

    final http.Response response = await http.put(
        '$baseUri/accounts/select_id/$itemID/$accountID/false',
        headers: jsonHeader);
    responsePrint(response.statusCode, response.body);
    return;
  }

  /// UPDATE - Updates the accounts in the server from Plaid.
  static Future<void> updateAccountsInServer(
      {List<Account> allAccounts}) async {
    for (Account account in allAccounts) {
      final http.Response responseAccounts = await http.put(
          '$baseUri/accounts/${account.itemID}/${account.id}',
          headers: jsonHeader);
      responsePrint(responseAccounts.statusCode, responseAccounts.body);
    }
    return;
  }

  /// CREATE - Add new accounts from Plaid to server.
  static Future<void> addAccountsToServer(
      {int userID,
      int itemID,
      String institutionPlaidID,
      List<String> accountPlaidIDs}) async {
    await Future.delayed(Duration(milliseconds: delay));

    final http.Response responseAccounts = await http.post(
        '$baseUri/accounts/$userID/$itemID/$institutionPlaidID',
        headers: jsonHeader);
    responsePrint(responseAccounts.statusCode, responseAccounts.body);

    for (String accountPlaidID in accountPlaidIDs) {
      final http.Response responseAccount = await http.put(
          '$baseUri/accounts/select_plaid_id/$itemID/$accountPlaidID/true',
          headers: jsonHeader);
      responsePrint(responseAccount.statusCode, responseAccount.body);
    }
    return;
  }
}
