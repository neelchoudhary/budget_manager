import 'package:budget_manager/redux/actions/account_actions.dart';
import 'package:budget_manager/redux/actions/item_actions.dart';
import 'package:budget_manager/redux/models/account.dart';
import 'package:budget_manager/redux/models/app_state.dart';
import 'package:budget_manager/redux/models/item.dart';
import 'package:equatable/equatable.dart';
import 'package:redux/redux.dart';

class AccountsPageInstitutionViewModel with EquatableMixin {
  final int userID;
  final Item item;
  final Status accountsStatus;
  final List<Account> accountsForInstitution;
  final Status accountsForInstitutionStatus;
  final Function removeItemButton;
  final Function removeAccountButton;

  AccountsPageInstitutionViewModel(
      {this.userID,
      this.item,
      this.accountsStatus,
      this.accountsForInstitution,
      this.accountsForInstitutionStatus,
      this.removeItemButton,
      this.removeAccountButton});

  static AccountsPageInstitutionViewModel fromStore(
      Store<AppState> store, int itemID) {
    return AccountsPageInstitutionViewModel(
      userID: store.state.userID,
      item: store.state.itemsList.items.firstWhere((i) => i.id == itemID),
      accountsStatus: store.state.accountsList.status,
      accountsForInstitutionStatus:
          store.state.accountsList.accountsByItemStatus[itemID],
      accountsForInstitution: store.state.accountsList.selectedAccounts
          .where((a) => a.itemID == itemID)
          .toList(),
      removeItemButton: (int userID, int itemID) =>
          store.dispatch(RemoveItemAction(userID: userID, itemID: itemID)),
      removeAccountButton: (int itemID, int accountID) => store
          .dispatch(RemoveAccountAction(itemID: itemID, accountID: accountID)),
    );
  }

  @override
  List<Object> get props =>
      [userID, item, accountsForInstitution, accountsForInstitutionStatus];
}
