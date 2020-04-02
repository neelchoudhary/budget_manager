import 'package:budget_manager/data_repositories/shared_repository.dart';
import 'package:budget_manager/redux/models/item.dart';
import 'package:budget_manager/redux/models/transaction.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class TransactionRepository {
  /// GET - Get transactions from the server.
  static Future<List<Transaction>> getTransactionsFromServer(
      {List<Item> items}) async {
    List<Transaction> allTransactions = [];
    for (Item item in items) {
      final http.Response responseTransactions = await http
          .get('$baseUri/transactions/${item.id}', headers: jsonHeader);
      Iterable decodedTransactionsJSON =
          convert.jsonDecode(responseTransactions.body);
      List<Transaction> transactions = decodedTransactionsJSON
          .map((json) => Transaction.fromJson(json))
          .toList();
      allTransactions.addAll(transactions);
    }
    return allTransactions;
  }

  /// UPDATE - Updates transaction on the server.
  static Future<void> editTransactionOnServer({Transaction transaction}) async {
    final http.Response response = await http.put(
        '$baseUri/transactions/${transaction.itemID}/${transaction.transactionID}',
        headers: jsonHeader);
    responsePrint(response.statusCode, response.body);
    return;
  }

  /// CREATE - Adds new transactions from Plaid to server.
  static Future<void> addTransactionsToServer({int itemID}) async {
    // TODO wrap all http calls in a try catch
    final http.Response response =
        await http.post('$baseUri/transactions/$itemID', headers: jsonHeader);
    responsePrint(response.statusCode, response.body);
    return;
  }
}
