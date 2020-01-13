import 'dart:async';
import 'dart:io';
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
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:redux/redux.dart';

import 'models/app_state.dart';

final _jsonHeader = {'Content-Type': 'application/json'};
final _baseUri = 'http://localhost:8080';

class ItemsMiddleware extends MiddlewareClass<AppState> {
  @override
  void call(Store<AppState> store, dynamic action, NextDispatcher next) {
    if (action is AddItemAction) {
      addItemToServer(
              userID: action.userID,
              publicToken: action.token,
              institutionID: action.institutionID,
              accountNames: action.accountNames,
              accountMasks: action.accountMasks,
              accountSubtypes: action.accountSubtype)
          .then((void _) {
        store.dispatch(new SuccessItemsAction());
      }).catchError((Exception error) {
        store.dispatch(
            new ErrorItemsAction(statusCode: 400, error: error.toString()));
      });
    }

    if (action is RemoveItemAction) {
      removeItemFromServer(action.userID, action.itemID).then((void _) {
        store.dispatch(new SuccessItemsAction());
      }).catchError((Exception error) {
        store.dispatch(
            new ErrorItemsAction(statusCode: 400, error: error.toString()));
      });
    }

    if (action is GetItemsAction) {
      if (store.state.itemsList.items.isEmpty || action.forceRefresh) {
        this.getItemsFromServer(action.userID).then((List<Item> items) {
          store.dispatch(LoadedItemsAction(items));
        }).catchError((Exception error) {
          store.dispatch(
              new ErrorItemsAction(statusCode: 400, error: error.toString()));
        });
      } else {
        store.dispatch(SuccessItemsAction());
      }
    }

    next(action);
  }

  // Get parameters from plaid link response.
  Future<Item> addItemToServer(
      {int userID,
      String publicToken,
      String institutionID,
      List<String> accountNames,
      List<String> accountMasks,
      List<String> accountSubtypes}) async {
    final http.Response responseAccessToken = await http.post(
        '$_baseUri/items/$userID/$publicToken/$institutionID/${accountNames[0]}/${accountMasks[0]}/${accountSubtypes[0]}',
        headers: _jsonHeader);
    responsePrint(responseAccessToken.statusCode, responseAccessToken.body);
    if (responseAccessToken.statusCode == 200) {
      var decodedItemJSON = convert.jsonDecode(responseAccessToken.body);
      Item item = Item.fromJson(decodedItemJSON);
      return item;
    } else {
      if (responseAccessToken.statusCode == 406) {
        print("account already exists");
        throw HttpException("Account already exists");
      }
      throw HttpException("Error creating item: " +
          responseAccessToken.statusCode.toString() +
          ": " +
          responseAccessToken.body.toString());
    }
  }

  Future<List<Item>> getItemsFromServer(int userID) async {
    final http.Response responseAccessToken =
        await http.get('$_baseUri/items/userID', headers: _jsonHeader);
    responsePrint(responseAccessToken.statusCode, responseAccessToken.body);

    if (responseAccessToken.statusCode == 200) {
      Iterable decodedItemsJSON = convert.jsonDecode(responseAccessToken.body);
      List<Item> items =
          decodedItemsJSON.map((json) => Item.fromJson(json)).toList();
      return items;
    } else {
      return [];
    }
  }

  Future<void> removeItemFromServer(int userID, int itemID) async {
    final http.Response response = await http
        .delete('$_baseUri/items/$userID/$itemID', headers: _jsonHeader);
    responsePrint(response.statusCode, response.body);
    return;
  }
}

class AccountsMiddleware extends MiddlewareClass<AppState> {
  @override
  void call(Store<AppState> store, dynamic action, NextDispatcher next) {
    if (action is AddAccountsAction) {
      addAccountsToServer(
              userID: action.userID,
              itemID: action.itemID,
              institutionPlaidID: action.institutionPlaidID,
              accountPlaidIDs: action.accountPlaidIDs)
          .then((void _) {
        store.dispatch(new SuccessAccountsAction());
      }).catchError((Exception error) {
        store.dispatch(
            // TODO more descriptive errors.
            new ErrorAccountsAction(statusCode: 400, error: error.toString()));
      });
    }

    if (action is UpdateSelectedAccountsAction) {
      toggleAccountsInServer(
              itemID: action.itemID,
              accountPlaidIDs: action.accountPlaidIDs,
              allAccounts: store.state.accountsList.allAccounts)
          .then((void _) {
        store.dispatch(new SuccessAccountsAction());
      }).catchError((Exception error) {
        store.dispatch(
            new ErrorAccountsAction(statusCode: 400, error: error.toString()));
      });
    }

    if (action is RemoveAccountAction) {
      hideAccountInServer(itemID: action.itemID, accountID: action.accountID)
          .then((void _) {
        store.dispatch(new SuccessAccountsAction());
      }).catchError((Exception error) {
        store.dispatch(
            new ErrorAccountsAction(statusCode: 400, error: error.toString()));
      });
    }

    if (action is UpdateAccountsAction) {
      updateAccountsInServer().then((void _) {
        store.dispatch(new SuccessAccountsAction());
      }).catchError((Exception error) {
        store.dispatch(
            new ErrorAccountsAction(statusCode: 400, error: error.toString()));
      });
    }

    if (action is GetAccountsAction) {
      if (store.state.accountsList.allAccounts.isEmpty || action.forceRefresh) {
        this
            .getAccountsFromServer(
                userID: action.userID, items: store.state.itemsList.items)
            .then((List<Account> accounts) {
          store.dispatch(LoadedAccountsAction(accounts));
        }).catchError((Exception error) {
          store.dispatch(new ErrorAccountsAction(
              statusCode: 400, error: error.toString()));
        });
      } else {
        store.dispatch(SuccessAccountsAction());
      }
    }

    next(action);
  }

  Future<void> addAccountsToServer(
      {int userID,
      int itemID,
      String institutionPlaidID,
      List<String> accountPlaidIDs}) async {
    final http.Response responseAccounts = await http.post(
        '$_baseUri/accounts/$userID/$itemID/$institutionPlaidID',
        headers: _jsonHeader);
    responsePrint(responseAccounts.statusCode, responseAccounts.body);

    for (String accountPlaidID in accountPlaidIDs) {
      final http.Response responseAccount = await http.put(
          '$_baseUri/accounts/select_plaid_id/$itemID/$accountPlaidID/true',
          headers: _jsonHeader);
      responsePrint(responseAccount.statusCode, responseAccount.body);
    }
    return;
  }

  Future<void> toggleAccountsInServer(
      {int itemID,
      List<String> accountPlaidIDs,
      List<Account> allAccounts}) async {
    for (Account account in allAccounts) {
      await http.put(
          '$_baseUri/accounts/select_id/$itemID/${account.id}/${account.selected}',
          headers: _jsonHeader);
    }
    return;
  }

  Future<void> hideAccountInServer({int itemID, int accountID}) async {
    final http.Response response = await http.put(
        '$_baseUri/accounts/select_id/$itemID/$accountID/false',
        headers: _jsonHeader);
    responsePrint(response.statusCode, response.body);
    return;
  }

  Future<void> updateAccountsInServer({List<Account> allAccounts}) async {
    for (Account account in allAccounts) {
      final http.Response responseAccounts = await http.put(
          '$_baseUri/accounts/${account.itemID}/${account.id}',
          headers: _jsonHeader);
      responsePrint(responseAccounts.statusCode, responseAccounts.body);
    }
    return;
  }

  Future<List<Account>> getAccountsFromServer(
      {int userID, List<Item> items}) async {
    List<Account> allAccounts = [];
    List<Account> selectedAccounts = [];
    for (Item item in items) {
      final http.Response responseAccounts =
          await http.get('$_baseUri/accounts/${item.id}', headers: _jsonHeader);
      responsePrint(responseAccounts.statusCode, responseAccounts.body);
      Iterable decodedAccountsJSON = convert.jsonDecode(responseAccounts.body);
      List<Account> accounts =
          decodedAccountsJSON.map((json) => Account.fromJson(json)).toList();
      allAccounts.addAll(accounts);
      accounts = accounts.where((account) => account.selected).toList();
      selectedAccounts.addAll(accounts);
    }
    return allAccounts;
  }
}

class TransactionsMiddleware extends MiddlewareClass<AppState> {
  @override
  void call(Store<AppState> store, dynamic action, NextDispatcher next) {
    if (action is AddTransactionsAction) {
      addTransactionsToServer(itemID: action.itemID).then((void _) {
        store.dispatch(new SuccessTransactionsAction());
      }).catchError((Exception error) {
        store.dispatch(new ErrorTransactionsAction(
            statusCode: 400, error: error.toString()));
      });
    }

    if (action is EditTransactionAction) {
      editTransactionOnServer(transaction: action.editedTransaction)
          .then((void _) {
        store.dispatch(new SuccessTransactionsAction());
      }).catchError((Exception error) {
        store.dispatch(new ErrorTransactionsAction(
            statusCode: 400, error: error.toString()));
      });
    }

    if (action is GetTransactionsAction) {
      if (store.state.transactionsList.allTransactions.isEmpty ||
          action.forceRefresh) {
        this
            .getTransactionsFromServer(items: store.state.itemsList.items)
            .then((List<Transaction> transactions) {
          store.dispatch(LoadedTransactionsAction(
              transactions: transactions,
              selectedAccounts: store.state.accountsList.selectedAccounts));
        }).catchError((Exception error) {
          store.dispatch(new ErrorTransactionsAction(
              statusCode: 400, error: error.toString()));
        });
      } else {
        store.dispatch(SuccessTransactionsAction());
      }
    }

    next(action);
  }

  Future<void> addTransactionsToServer({int itemID}) async {
    // TODO wrap all http calls in a try catch
    final http.Response response =
        await http.post('$_baseUri/transactions/$itemID', headers: _jsonHeader);
    responsePrint(response.statusCode, response.body);
    return;
  }

  Future<void> editTransactionOnServer({Transaction transaction}) async {
    final http.Response response = await http.put(
        '$_baseUri/transactions/${transaction.itemID}/${transaction.transactionID}',
        headers: _jsonHeader);
    responsePrint(response.statusCode, response.body);
    return;
  }

  Future<List<Transaction>> getTransactionsFromServer(
      {List<Item> items}) async {
    List<Transaction> allTransactions = [];
    for (Item item in items) {
      final http.Response responseTransactions = await http
          .get('$_baseUri/transactions/${item.id}', headers: _jsonHeader);
      Iterable decodedTransactionsJSON =
          convert.jsonDecode(responseTransactions.body);
      List<Transaction> transactions = decodedTransactionsJSON
          .map((json) => Transaction.fromJson(json))
          .toList();
      allTransactions.addAll(transactions);
    }
    return allTransactions;
  }
}

class CategoriesMiddleware extends MiddlewareClass<AppState> {
  @override
  void call(Store<AppState> store, dynamic action, NextDispatcher next) {
    if (action is GetCategoriesAction) {
      if (store.state.categoriesList.categories.isEmpty ||
          action.forceRefresh) {
        this.getCategoriesFromServer().then((List<Category> categories) {
          store.dispatch(LoadedCategoriesAction(categories: categories));
        }).catchError((Exception error) {
          store.dispatch(new ErrorCategoriesAction(
              statusCode: 400, error: error.toString()));
        });
      } else {
        store.dispatch(SuccessCategoriesAction());
      }
    }

    next(action);
  }

  Future<List<Category>> getCategoriesFromServer() async {
    final http.Response response =
        await http.get('$_baseUri/categories', headers: _jsonHeader);
    Iterable decodedJSON = convert.jsonDecode(response.body);
    List<Category> categories =
        decodedJSON.map((json) => Category.fromJson(json)).toList();
    return categories;
  }
}

class BudgetsMiddleware extends MiddlewareClass<AppState> {
  @override
  void call(Store<AppState> store, dynamic action, NextDispatcher next) {
    if (action is GetBudgetsAction) {
      if (store.state.budgetsList.budgets.isEmpty || action.forceRefresh) {
        this.getBudgetsFromServer().then((List<Budget> budgets) {
          store.dispatch(LoadedBudgetsAction(budgets: budgets));
        }).catchError((Exception error) {
          store.dispatch(
              new ErrorBudgetsAction(statusCode: 400, error: error.toString()));
        });
      } else {
        store.dispatch(SuccessBudgetsAction());
      }
    }

    next(action);
  }

  Future<List<Budget>> getBudgetsFromServer() async {
    final http.Response response =
        await http.get('$_baseUri/budgets', headers: _jsonHeader);
    Iterable decodedJSON = convert.jsonDecode(response.body);
    List<Budget> budgets =
        decodedJSON.map((json) => Budget.fromJson(json)).toList();
    return budgets;
  }
}

// Print http response helper method.
void responsePrint(int statusCode, String body) {
  print("Status Code: ${statusCode.toString()}. Body: $body");
}
