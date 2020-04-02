import 'package:budget_manager/data_repositories/shared_repository.dart';
import 'package:budget_manager/redux/models/category.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class CategoryRepository {
  /// Get categories from server.
  static Future<List<Category>> getCategoriesFromServer() async {
    final http.Response response =
        await http.get('$baseUri/categories', headers: jsonHeader);
    Iterable decodedJSON = convert.jsonDecode(response.body);
    List<Category> categories =
        decodedJSON.map((json) => Category.fromJson(json)).toList();
    return categories;
  }
}
