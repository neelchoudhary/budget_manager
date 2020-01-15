import 'package:budget_manager/networking/network.dart';
import 'package:budget_manager/redux/actions/account_actions.dart';
import 'package:budget_manager/redux/models/account.dart';
import 'package:budget_manager/redux/models/app_state.dart';
import 'package:budget_manager/redux/models/item.dart';
import 'package:budget_manager/redux/reducers.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux/redux.dart';

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

//class LoadedItemsAction {
//  final List<Item> items;
//
//  LoadedItemsAction({this.items});
//}

//// Thunk action that gets items, then starts to get accounts.
//ThunkAction<AppState> getItemsAction({int userID, bool forceRefresh}) {
//  return (Store<AppState> store) async {
//    if (store.state.itemsList.items.isEmpty || forceRefresh) {
//      var getItems =
//          Network.getItemsFromServer(userID).then((List<Item> items) {
//        store.dispatch(LoadedItemsAction(items: items));
//        store.dispatch(StartGetAccountsAction());
//      }).catc hError((Object error) {
//        print("ERROR: " + error.toString());
//        store.dispatch(
//            new ErrorItemsAction(statusCode: 400, error: error.toString()));
//      });
//      store.dispatch(getItems);
//    } else {
//      store.dispatch(SuccessItemsAction());
//    }
//  };
//}
//
//// Thunk action that adds item, then starts to get items.
//ThunkAction<AppState> addItemAction(
//    {int userID,
//    String token,
//    String institutionID,
//    List<String> accountNames,
//    List<String> accountMasks,
//    List<String> accountSubtypes,
//    List<String> accountPlaidIDs}) {
//  return (Store<AppState> store) async {
//    // TODO maybe start an StartItemAction here to update status to loading.
//    var addItem = Network.addItemToServer(
//            userID: userID,
//            publicToken: token,
//            institutionID: institutionID,
//            accountNames: accountNames,
//            accountMasks: accountMasks,
//            accountSubtypes: accountSubtypes)
//        .then((Item item) {
//      // Change tto thunk maybe? or network call
//      store.dispatch(AddAccountsAction(
//          userID: userID,
//          itemID: item.id,
//          institutionPlaidID: institutionID,
//          accountPlaidIDs: accountPlaidIDs));
//    }).catchError((Object error) {
//      store.dispatch(
//          new ErrorItemsAction(statusCode: 400, error: error.toString()));
//    });
//
//    store.dispatch(addItem);
//  };
//}

//ThunkAction<AppState> getItemsAndAccounts({int userID, bool forceRefresh}) {
//  return (Store<AppState> store) async {
//    if (store.state.itemsList.items.isEmpty || forceRefresh) {
//      final getItemsAndAccounts =
//          Network.getItemsFromServer(userID).then((List<Item> items) {
//        store.dispatch(LoadedItemsAction(items: items));
//        Network.getAccountsFromServer(items: store.state.itemsList.items)
//            .then((List<Account> accounts) {
//          store.dispatch(LoadedAccountsAction(accounts: accounts));
//        }).catchError((Object error) {
//          store.dispatch(new ErrorAccountsAction(
//              statusCode: 400, error: error.toString()));
//        });
//      }).catchError((Object error) {
//        print("ERROR: " + error.toString());
//        store.dispatch(
//            new ErrorItemsAction(statusCode: 400, error: error.toString()));
//      });
//      store.dispatch(getItemsAndAccounts);
//    } else {
//      store.dispatch(SuccessItemsAction());
//    }
//  };
//}
