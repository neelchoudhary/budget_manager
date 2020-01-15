// API Actions
class UpdateSelectedAccountsAction {
  final int itemID;

  UpdateSelectedAccountsAction({this.itemID});
}

class UpdateAccountsAction {}

class RemoveAccountAction {
  final int itemID;
  final int accountID;

  RemoveAccountAction({this.itemID, this.accountID});
}

class GetAccountsAction {
  final bool forceRefresh;

  GetAccountsAction({this.forceRefresh});
}

// Response Actions
class SuccessAccountAction<T> {
  final T payload;

  SuccessAccountAction({this.payload});
}

class ErrorAccountsAction {
  final int statusCode;
  final String error;

  ErrorAccountsAction({this.statusCode, this.error});
}

class LoadAccountAction {}

class LoadAccountItemAction {
  final int itemID;

  LoadAccountItemAction({this.itemID});
}

class SuccessAccountItemAction {
  final int itemID;

  SuccessAccountItemAction({this.itemID});
}

class ErrorAccountItemAction {
  final int itemID;
  final int statusCode;
  final String error;

  ErrorAccountItemAction({this.itemID, this.statusCode, this.error});
}

// State Actions
class ToggleSelectedAccountAction {
  final int accountID;
  final bool selected;

  ToggleSelectedAccountAction({this.accountID, this.selected});
}
