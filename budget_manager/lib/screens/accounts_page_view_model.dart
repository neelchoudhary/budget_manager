import 'package:budget_manager/redux/actions/item_actions.dart';
import 'package:budget_manager/redux/models/app_state.dart';
import 'package:budget_manager/redux/models/item.dart';
import 'package:equatable/equatable.dart';
import 'package:redux/redux.dart';

class AccountPageViewModel with EquatableMixin {
  final int userID;
  final Status itemsStatus;
  final ItemsList itemsList;
  final Function onInit;
  final Function onRefresh;
  final Function addItemsAndAccountsButton;

  AccountPageViewModel({
    this.userID,
    this.itemsStatus,
    this.itemsList,
    this.onInit,
    this.onRefresh,
    this.addItemsAndAccountsButton,
  });

  static AccountPageViewModel fromStore(Store<AppState> store) {
    return AccountPageViewModel(
      userID: store.state.userID,
      itemsStatus: store.state.itemsList.status,
      itemsList: store.state.itemsList,
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
    );
  }

  @override
  List<Object> get props => [userID, itemsStatus, itemsList];
}
