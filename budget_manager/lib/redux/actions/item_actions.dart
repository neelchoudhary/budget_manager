import 'package:budget_manager/redux/models/item.dart';

// TODO move Status somewhere else
enum Status { LOADING, SUCCESS, ERROR }

// API Actions
class AddItemAction {
  final int userID;
  final String token;
  final List<String> accountIDs;
  final String institutionID;
  final List<String> accountNames;
  final List<String> accountMasks;
  final List<String> accountSubtype;

  AddItemAction(
      {this.userID,
      this.token,
      this.accountIDs,
      this.institutionID,
      this.accountNames,
      this.accountMasks,
      this.accountSubtype});
}

class RemoveItemAction {
  final int userID;
  final int itemID;

  RemoveItemAction(this.userID, this.itemID);
}

class GetItemsAction {
  final bool forceRefresh;
  final int userID;

  GetItemsAction({this.forceRefresh, this.userID});
}

// Response Actions
class SuccessItemsAction {}

class ErrorItemsAction {
  final int statusCode;
  final String error;

  ErrorItemsAction({this.statusCode, this.error});
}

class LoadedItemsAction {
  final List<Item> items;

  LoadedItemsAction(this.items);
}
