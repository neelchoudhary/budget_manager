import 'package:budget_manager/redux/models/category.dart';

// API Actions
class GetCategoriesAction {
  final bool forceRefresh;

  GetCategoriesAction({this.forceRefresh});
}

// Response Actions
class SuccessCategoriesAction {}

class ErrorCategoriesAction {
  final int statusCode;
  final String error;

  ErrorCategoriesAction({this.statusCode, this.error});
}

class LoadedCategoriesAction {
  final List<Category> categories;

  LoadedCategoriesAction({this.categories});
}
