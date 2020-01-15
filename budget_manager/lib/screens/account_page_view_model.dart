import 'package:budget_manager/redux/actions/account_actions.dart';
import 'package:budget_manager/redux/actions/item_actions.dart';
import 'package:budget_manager/redux/models/account.dart';
import 'package:budget_manager/redux/models/app_state.dart';
import 'package:budget_manager/redux/models/item.dart';
import 'package:redux/redux.dart';

class AccountPageViewModel {
  final int userID;
  final Status itemsStatus;
  final Status accountsStatus;
  final ItemsList itemsList;
  final AccountsList accountsList;
  final Function onInit;
  final Function onRefresh;
  final Function addItemsAndAccountsButton;
  final Function removeItemButton;
  final Function removeAccountButton;
  final Function editAccountsButton;
  final Function toggleAccountCheckbox;
  final Function confirmAccountsButton;

  AccountPageViewModel(
      {this.userID,
      this.itemsStatus,
      this.accountsStatus,
      this.itemsList,
      this.accountsList,
      this.onInit,
      this.onRefresh,
      this.addItemsAndAccountsButton,
      this.removeItemButton,
      this.removeAccountButton,
      this.editAccountsButton,
      this.toggleAccountCheckbox,
      this.confirmAccountsButton});

  static AccountPageViewModel fromStore(Store<AppState> store) {
    return AccountPageViewModel(
        userID: store.state.userID,
        itemsStatus: store.state.itemsList.status,
        accountsStatus: store.state.accountsList.status,
        itemsList: store.state.itemsList,
        accountsList: store.state.accountsList,
        onInit: () {
          store.dispatch(GetItemsAndAccountsAction(
              userID: store.state.userID, forceRefresh: true));
        },
        onRefresh: () {
          store.dispatch(GetItemsAndAccountsAction(
              userID: store.state.userID, forceRefresh: true));
        },
        addItemsAndAccountsButton: (String token,
            int userID,
            String institutionID,
            List<String> accountPlaidIDs,
            List<String> accountNames,
            List<String> accountMasks,
            List<String> accountSubtypes) {
          store.dispatch(AddInstitutionAction(
              token: token,
              userID: userID,
              institutionID: institutionID,
              accountPlaidIDs: accountPlaidIDs,
              accountNames: accountNames,
              accountMasks: accountMasks,
              accountSubtype: accountSubtypes));
        },
        removeItemButton: (int userID, int itemID) =>
            store.dispatch(RemoveItemAction(userID: userID, itemID: itemID)),
        removeAccountButton: (int itemID, int accountID) => store.dispatch(
            RemoveAccountAction(itemID: itemID, accountID: accountID)),
//        editAccountsButton: (int userID) =>
//            store.dispatch(getAccountsAction(forceRefresh: false)),
        toggleAccountCheckbox: (int accountID, bool selected) => store.dispatch(
            ToggleSelectedAccountAction(
                accountID: accountID, selected: selected)),
        confirmAccountsButton: (int itemID) =>
            store.dispatch(UpdateSelectedAccountsAction(itemID: itemID)));
  }
}
