import 'package:budget_manager/data_repositories/shared_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:budget_manager/redux/models/budget.dart';

class BudgetRepository {
  /// GET - Retrieve budgets from server.
  static Future<List<Budget>> getBudgetsFromServer() async {
    final http.Response response =
        await http.get('$baseUri/budgets', headers: jsonHeader);
    Iterable decodedJSON = convert.jsonDecode(response.body);
    List<Budget> budgets =
        decodedJSON.map((json) => Budget.fromJson(json)).toList();
    return budgets;
  }
}
