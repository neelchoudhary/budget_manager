import 'package:budget_manager/redux/actions/account_actions.dart';
import 'package:budget_manager/redux/actions/item_actions.dart';
import 'package:budget_manager/redux/models/account.dart';
import 'package:budget_manager/redux/models/app_state.dart';
import 'package:equatable/equatable.dart';
import 'package:redux/redux.dart';

class AccountsPageSlidingPageViewModel with EquatableMixin {
  final int userID;
  final Status accountsStatus;
  final AccountsList accountsList;
  final Function onOpen;
  final Function toggleAccountCheckbox;
  final Function confirmAccountsButton;

  AccountsPageSlidingPageViewModel(
      {this.userID,
      this.accountsStatus,
      this.accountsList,
      this.onOpen,
      this.toggleAccountCheckbox,
      this.confirmAccountsButton});

  static AccountsPageSlidingPageViewModel fromStore(Store<AppState> store) {
    return AccountsPageSlidingPageViewModel(
        userID: store.state.userID,
        accountsStatus: store.state.accountsList.status,
        accountsList: store.state.accountsList,
        onOpen: () {
          store.dispatch(GetAccountsAction(forceRefresh: true));
        },
        toggleAccountCheckbox: (int accountID, bool selected) => store.dispatch(
            ToggleSelectedAccountAction(
                accountID: accountID, selected: selected)),
        confirmAccountsButton: (int itemID) =>
            store.dispatch(UpdateSelectedAccountsAction(itemID: itemID)));
  }

  @override
  List<Object> get props => [
        userID,
        accountsStatus,
        accountsList,
      ];
}
