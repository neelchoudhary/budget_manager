import 'package:budget_manager/redux/models/account.dart';

// API Actions
class AddAccountsAction {
  final int userID;
  final int itemID;
  final String institutionPlaidID;
  final List<String> accountPlaidIDs;

  AddAccountsAction(
      this.userID, this.itemID, this.institutionPlaidID, this.accountPlaidIDs);
}

class UpdateSelectedAccountsAction {
  final int itemID;
  final List<String> accountPlaidIDs;

  UpdateSelectedAccountsAction(this.itemID, this.accountPlaidIDs);
}

class GetAccountsAction {
  final bool forceRefresh;
  final int userID;

  GetAccountsAction(this.forceRefresh, this.userID);
}

class UpdateAccountsAction {}

class RemoveAccountAction {
  final int itemID;
  final int accountID;

  RemoveAccountAction(this.itemID, this.accountID);
}

// Response Actions
class SuccessAccountsAction {}

class ErrorAccountsAction {
  final int statusCode;
  final String error;

  ErrorAccountsAction({this.statusCode, this.error});
}

class LoadedAccountsAction {
  final List<Account> accounts;

  LoadedAccountsAction(this.accounts);
}

// State Actions
class ToggleSelectedAccountAction {
  final int accountID;
  final bool selected;

  ToggleSelectedAccountAction(this.accountID, this.selected);
}
