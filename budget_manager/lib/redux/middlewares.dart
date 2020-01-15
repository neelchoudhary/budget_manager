import 'package:budget_manager/networking/network.dart';
import 'package:budget_manager/redux/actions/account_actions.dart';
import 'package:budget_manager/redux/actions/budget_actions.dart';
import 'package:budget_manager/redux/actions/category_actions.dart';
import 'package:budget_manager/redux/actions/item_actions.dart';
import 'package:budget_manager/redux/actions/transaction_actions.dart';
import 'package:budget_manager/redux/models/account.dart';
import 'package:budget_manager/redux/models/budget.dart';
import 'package:budget_manager/redux/models/category.dart';
import 'package:budget_manager/redux/models/item.dart';
import 'package:budget_manager/redux/models/transaction.dart';

import 'package:redux/redux.dart';

import 'models/app_state.dart';

class ItemsMiddleware extends MiddlewareClass<AppState> {
  @override
  void call(Store<AppState> store, dynamic action, NextDispatcher next) {
    if (action is AddInstitutionAction) {
      store.dispatch(LoadItemAction());
      Network.addInstitutionToServer(
              userID: action.userID,
              publicToken: action.token,
              institutionID: action.institutionID,
              accountNames: action.accountNames,
              accountMasks: action.accountMasks,
              accountSubtypes: action.accountSubtype,
              accountPlaidIDs: action.accountPlaidIDs)
          .then((void _) {
        store.dispatch(SuccessItemAction());
        store.dispatch(GetItemsAndAccountsAction(
            userID: action.userID, forceRefresh: true));
      }).catchError((Object error) {
        store.dispatch(
            new ErrorItemAction(statusCode: 400, error: error.toString()));
      });
    }

    if (action is RemoveItemAction) {
      store.dispatch(LoadItemAction());
      Network.removeItemFromServer(userID: action.userID, itemID: action.itemID)
          .then((void _) {
        store.dispatch(new SuccessItemAction());
        store.dispatch(GetItemsAndAccountsAction(
            userID: action.userID, forceRefresh: true));
      }).catchError((Object error) {
        store.dispatch(
            new ErrorItemAction(statusCode: 400, error: error.toString()));
      });
    }

    if (action is GetItemsAndAccountsAction) {
      store.dispatch(LoadItemAction());
      store.dispatch(LoadAccountAction());
      if (store.state.itemsList.items.isEmpty ||
          store.state.accountsList.allAccounts.isEmpty ||
          action.forceRefresh) {
        Network.getItemsFromServer(userID: action.userID)
            .then((List<Item> items) {
          Network.getAccountsFromServer(items: items)
              .then((List<Account> accounts) {
            store.dispatch(SuccessItemAction<List<Item>>(payload: items));
            store.dispatch(
                SuccessAccountAction<List<Account>>(payload: accounts));
          }).catchError((Object error) {
            store.dispatch(new ErrorAccountsAction(
                statusCode: 400, error: error.toString()));
          });
        }).catchError((Object error) {
          print("ERROR: " + error.toString());
          store.dispatch(
              new ErrorItemAction(statusCode: 400, error: error.toString()));
        });
      } else {
        store.dispatch(SuccessItemAction(payload: null));
      }
    }

    if (action is GetItemsAction) {
      store.dispatch(LoadItemAction());
      if (store.state.itemsList.items.isEmpty || action.forceRefresh) {
        Network.getItemsFromServer(userID: action.userID)
            .then((List<Item> items) {
          store.dispatch(SuccessItemAction<List<Item>>(payload: items));
        }).catchError((Object error) {
          print("ERROR: " + error.toString());
          store.dispatch(
              new ErrorItemAction(statusCode: 400, error: error.toString()));
        });
      } else {
        store.dispatch(SuccessItemAction(payload: null));
      }
    }

    next(action);
  }
}

class AccountsMiddleware extends MiddlewareClass<AppState> {
  @override
  void call(Store<AppState> store, dynamic action, NextDispatcher next) {
    if (action is UpdateSelectedAccountsAction) {
      Network.toggleAccountsInServer(
              itemID: action.itemID,
              allAccounts: store.state.accountsList.allAccounts)
          .then((void _) {
        store.dispatch(new SuccessAccountAction());
        store.dispatch(GetItemsAndAccountsAction(
            userID: store.state.userID, forceRefresh: true));
      }).catchError((Object error) {
        store.dispatch(
            // TODO more descriptive errors.
            new ErrorAccountsAction(statusCode: 400, error: error.toString()));
      });
    }

    if (action is RemoveAccountAction) {
      Network.hideAccountInServer(
              itemID: action.itemID, accountID: action.accountID)
          .then((void _) {
        store.dispatch(new SuccessAccountAction());
        store.dispatch(GetItemsAndAccountsAction(
            userID: store.state.userID, forceRefresh: true));
      }).catchError((Object error) {
        store.dispatch(
            new ErrorAccountsAction(statusCode: 400, error: error.toString()));
      });
    }

    if (action is UpdateAccountsAction) {
      Network.updateAccountsInServer().then((void _) {
        store.dispatch(new SuccessAccountAction());
        store.dispatch(GetItemsAndAccountsAction(
            userID: store.state.userID, forceRefresh: true));
      }).catchError((Object error) {
        store.dispatch(
            new ErrorAccountsAction(statusCode: 400, error: error.toString()));
      });
    }

    if (action is GetAccountsAction) {
      store.dispatch(LoadAccountAction());
      if (store.state.accountsList.allAccounts.isEmpty || action.forceRefresh) {
        Network.getAccountsFromServer(items: store.state.itemsList.items)
            .then((List<Account> accounts) {
          store
              .dispatch(SuccessAccountAction<List<Account>>(payload: accounts));
        }).catchError((Object error) {
          store.dispatch(new ErrorAccountsAction(
              statusCode: 400, error: error.toString()));
        });
      } else {
        store.dispatch(SuccessAccountAction());
      }
    }

    next(action);
  }
}

class TransactionsMiddleware extends MiddlewareClass<AppState> {
  @override
  void call(Store<AppState> store, dynamic action, NextDispatcher next) {
    if (action is EditTransactionAction) {
      Network.editTransactionOnServer(transaction: action.editedTransaction)
          .then((void _) {
        store.dispatch(new SuccessTransactionsAction());
      }).catchError((Object error) {
        store.dispatch(new ErrorTransactionsAction(
            statusCode: 400, error: error.toString()));
      });
    }

    if (action is GetTransactionsAction) {
      if (store.state.transactionsList.allTransactions.isEmpty ||
          action.forceRefresh) {
        Network.getTransactionsFromServer(items: store.state.itemsList.items)
            .then((List<Transaction> transactions) {
          store.dispatch(LoadedTransactionsAction(
              transactions: transactions,
              selectedAccounts: store.state.accountsList.selectedAccounts));
        }).catchError((Object error) {
          store.dispatch(new ErrorTransactionsAction(
              statusCode: 400, error: error.toString()));
        });
      } else {
        store.dispatch(SuccessTransactionsAction());
      }
    }

    next(action);
  }
}

class CategoriesMiddleware extends MiddlewareClass<AppState> {
  @override
  void call(Store<AppState> store, dynamic action, NextDispatcher next) {
    if (action is GetCategoriesAction) {
      if (store.state.categoriesList.categories.isEmpty ||
          action.forceRefresh) {
        Network.getCategoriesFromServer().then((List<Category> categories) {
          store.dispatch(LoadedCategoriesAction(categories: categories));
        }).catchError((Object error) {
          store.dispatch(new ErrorCategoriesAction(
              statusCode: 400, error: error.toString()));
        });
      } else {
        store.dispatch(SuccessCategoriesAction());
      }
    }

    next(action);
  }
}

class BudgetsMiddleware extends MiddlewareClass<AppState> {
  @override
  void call(Store<AppState> store, dynamic action, NextDispatcher next) {
    if (action is GetBudgetsAction) {
      if (store.state.budgetsList.budgets.isEmpty || action.forceRefresh) {
        Network.getBudgetsFromServer().then((List<Budget> budgets) {
          store.dispatch(LoadedBudgetsAction(budgets: budgets));
        }).catchError((Object error) {
          store.dispatch(
              new ErrorBudgetsAction(statusCode: 400, error: error.toString()));
        });
      } else {
        store.dispatch(SuccessBudgetsAction());
      }
    }

    next(action);
  }
}
