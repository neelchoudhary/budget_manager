import 'package:budget_manager/networking/network.dart';
import 'package:budget_manager/redux/models/account.dart';
import 'package:budget_manager/redux/models/app_state.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux/redux.dart';

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

// State Actions
class ToggleSelectedAccountAction {
  final int accountID;
  final bool selected;

  ToggleSelectedAccountAction({this.accountID, this.selected});
}

//ThunkAction<AppState> getAccountsAction({bool forceRefresh}) {
//  return (Store<AppState> store) async {
//    if (store.state.accountsList.allAccounts.isEmpty || forceRefresh) {
//      var getAccounts =
//          Network.getAccountsFromServer(items: store.state.itemsList.items)
//              .then((List<Account> accounts) {
//        store.dispatch(LoadedAccountsAction(accounts: accounts));
//      }).catchError((Object error) {
//        store.dispatch(
//            new ErrorAccountsAction(statusCode: 400, error: error.toString()));
//      });
//      store.dispatch(getAccounts);
//    } else {
//      store.dispatch(SuccessAccountsAction());
//    }
//  };
//}
