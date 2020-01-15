// TODO move Status somewhere else
enum Status { INITIAL, LOADING, SUCCESS, ERROR }

// API Actions
class AddInstitutionAction {
  final int userID;
  final String token;
  final String institutionID;
  final List<String> accountPlaidIDs;
  final List<String> accountNames;
  final List<String> accountMasks;
  final List<String> accountSubtype;

  AddInstitutionAction(
      {this.userID,
      this.token,
      this.institutionID,
      this.accountPlaidIDs,
      this.accountNames,
      this.accountMasks,
      this.accountSubtype});
}

class GetItemsAndAccountsAction {
  bool forceRefresh;
  final int userID;

  GetItemsAndAccountsAction({this.forceRefresh, this.userID});
}

class GetItemsAction {
  bool forceRefresh;
  final int userID;

  GetItemsAction({this.forceRefresh, this.userID});
}

class RemoveItemAction {
  final int userID;
  final int itemID;

  RemoveItemAction({this.userID, this.itemID});
}

// Response Actions
class LoadItemAction {}

class SuccessItemAction<T> {
  final T payload;

  SuccessItemAction({this.payload});
}

class ErrorItemAction {
  final int statusCode;
  final String error;

  ErrorItemAction({this.statusCode, this.error});
}
