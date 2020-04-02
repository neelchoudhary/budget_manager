import 'dart:io';

import 'package:budget_manager/data_repositories/account_repository.dart';
import 'package:budget_manager/data_repositories/shared_repository.dart';
import 'package:budget_manager/data_repositories/transaction_repository.dart';
import 'package:budget_manager/redux/models/item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class ItemRepository {
  /// GET - Retrieves items from server.
  static Future<List<Item>> getItemsFromServer(int userID) async {
    await Future.delayed(Duration(milliseconds: delay));

    final http.Response responseAccessToken =
        await http.get('$baseUri/items/$userID', headers: jsonHeader);
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

  /// CREATE - Adds item, and associated accounts and transactions to server.
  static Future<void> addInstitutionToServer(
      {int userID,
      String publicToken,
      String institutionID,
      List<String> accountNames,
      List<String> accountMasks,
      List<String> accountSubtypes,
      List<String> accountPlaidIDs}) async {
    await Future.delayed(Duration(milliseconds: delay));
    Item item = await addItemToServer(
        userID: userID,
        publicToken: publicToken,
        institutionID: institutionID,
        accountNames: accountNames,
        accountMasks: accountMasks,
        accountSubtypes: accountSubtypes);
    await AccountRepository.addAccountsToServer(
        userID: userID,
        itemID: item.id,
        institutionPlaidID: institutionID,
        accountPlaidIDs: accountPlaidIDs);
    await TransactionRepository.addTransactionsToServer(itemID: item.id);
    return;
  }

  /// CREATE - Adds new item to server after going through Plaid Link.
  static Future<Item> addItemToServer(
      {int userID,
      String publicToken,
      String institutionID,
      List<String> accountNames,
      List<String> accountMasks,
      List<String> accountSubtypes}) async {
    await Future.delayed(Duration(milliseconds: delay));
    final http.Response responseAccessToken = await http.post(
        '$baseUri/items/$userID/$publicToken/$institutionID/${accountNames[0]}/${accountMasks[0]}/${accountSubtypes[0]}',
        headers: jsonHeader);
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

  /// DELETE - Remove item from server.
  static Future<void> removeItemFromServer({int userID, int itemID}) async {
    await Future.delayed(Duration(milliseconds: delay));

    final http.Response response = await http
        .delete('$baseUri/items/$userID/$itemID', headers: jsonHeader);
    responsePrint(response.statusCode, response.body);
    return;
  }
}
