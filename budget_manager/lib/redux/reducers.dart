import 'package:budget_manager/redux/actions/account_actions.dart';
import 'package:budget_manager/redux/actions/budget_actions.dart';
import 'package:budget_manager/redux/actions/category_actions.dart';
import 'package:budget_manager/redux/actions/transaction_actions.dart';
import 'package:budget_manager/redux/models/account.dart';
import 'package:budget_manager/redux/models/budget.dart';
import 'package:budget_manager/redux/models/category.dart';
import 'package:budget_manager/redux/models/item.dart';
import 'package:budget_manager/redux/models/transaction.dart';
import 'package:redux/redux.dart';
import 'actions/item_actions.dart';
import 'models/app_state.dart';

AppState appStateReducer(AppState state, action) {
  return AppState(
    itemsList: itemReducer(state.itemsList, action),
    accountsList: accountReducer(state.accountsList, action),
    transactionsList: transactionReducer(state.transactionsList, action),
    categoriesList: categoryReducer(state.categoriesList, action),
    budgetsList: budgetReducer(state.budgetsList, action),
    userID: 1, // TODO change user id source
  );
}

Reducer<ItemsList> itemReducer = combineReducers<ItemsList>([
  TypedReducer<ItemsList, SuccessItemsAction>(successItemsReducer),
  TypedReducer<ItemsList, ErrorItemsAction>(errorItemsReducer),
  TypedReducer<ItemsList, LoadedItemsAction>(loadItemsReducer),
]);

ItemsList successItemsReducer(ItemsList items, SuccessItemsAction action) {
  return items.copyWith(status: Status.SUCCESS, error: "");
}

ItemsList errorItemsReducer(ItemsList items, ErrorItemsAction action) {
  return items.copyWith(
      status: Status.ERROR,
      error: action.statusCode.toString() + " " + action.error);
}

ItemsList loadItemsReducer(ItemsList items, LoadedItemsAction action) {
  return items.copyWith(items: action.items, status: Status.SUCCESS, error: "");
}

Reducer<AccountsList> accountReducer = combineReducers<AccountsList>([
  TypedReducer<AccountsList, SuccessAccountsAction>(successAccountsReducer),
  TypedReducer<AccountsList, ErrorAccountsAction>(errorAccountsReducer),
  TypedReducer<AccountsList, LoadedAccountsAction>(loadAccountsReducer),
  TypedReducer<AccountsList, ToggleSelectedAccountAction>(
      toggleSelectedAccountReducer),
]);

AccountsList successAccountsReducer(
    AccountsList accounts, SuccessAccountsAction action) {
  return accounts.copyWith(status: Status.SUCCESS, error: "");
}

AccountsList errorAccountsReducer(
    AccountsList accounts, ErrorAccountsAction action) {
  return accounts.copyWith(
      status: Status.ERROR,
      error: action.statusCode.toString() + " " + action.error);
}

AccountsList loadAccountsReducer(
    AccountsList accounts, LoadedAccountsAction action) {
  List<Account> updatedSelectedAccounts = [];
  updatedSelectedAccounts
      .addAll(accounts.allAccounts.where((a) => a.selected).toList());
  double totalBalance = updatedSelectedAccounts.fold(
      0, (sum, element) => sum + element.currentBalance);
  return accounts.copyWith(
      allAccounts: action.accounts,
      selectedAccounts: updatedSelectedAccounts,
      totalBalance: totalBalance,
      status: Status.SUCCESS,
      error: "");
}

AccountsList toggleSelectedAccountReducer(
    AccountsList accounts, ToggleSelectedAccountAction action) {
  List<Account> updatedAllAccounts = [];
  updatedAllAccounts.addAll(
      accounts.allAccounts.where((a) => a.id != action.accountID).toList());
  updatedAllAccounts.add(accounts.allAccounts
      .firstWhere((a) => a.id == action.accountID)
      .copyWith(selected: action.selected));
  List<Account> updatedSelectedAccounts = [];
  updatedSelectedAccounts
      .addAll(accounts.allAccounts.where((a) => a.selected).toList());
  return accounts.copyWith(
      allAccounts: updatedAllAccounts,
      selectedAccounts: updatedSelectedAccounts);
}

Reducer<TransactionsList> transactionReducer =
    combineReducers<TransactionsList>([
  TypedReducer<TransactionsList, SuccessTransactionsAction>(
      successTransactionsReducer),
  TypedReducer<TransactionsList, ErrorTransactionsAction>(
      errorTransactionsReducer),
  TypedReducer<TransactionsList, LoadedTransactionsAction>(
      loadTransactionsReducer),
  TypedReducer<TransactionsList, UpdateTransactionDatesAction>(
      updateTransactionDatesReducer),
  TypedReducer<TransactionsList, CategorizeTransactionsAction>(
      categorizeTransactionsReducer),
]);

TransactionsList successTransactionsReducer(
    TransactionsList transactions, SuccessTransactionsAction action) {
  return transactions.copyWith(status: Status.SUCCESS, error: "");
}

TransactionsList errorTransactionsReducer(
    TransactionsList transactions, ErrorTransactionsAction action) {
  return transactions.copyWith(
      status: Status.ERROR,
      error: action.statusCode.toString() + " " + action.error);
}

TransactionsList loadTransactionsReducer(
    TransactionsList transactions, LoadedTransactionsAction action) {
  // Only show transactions that pertain to selected accounts.
  List<Transaction> allTransactions = [];
  allTransactions.addAll(action.transactions
      .where((t) => action.selectedAccounts.any((a) => a.id == t.accountID))
      .toList());
  // Sort transactions chronologically.
  allTransactions.sort(
      (t1, t2) => DateTime.parse(t2.date).compareTo((DateTime.parse(t1.date))));
  // Only show transactions within the time frame of start and end date.
  List<Transaction> selectedTransactions = [];
  selectedTransactions.addAll(allTransactions
      .where((t) =>
          DateTime.parse(t.date).isAfter(transactions.startDate) &&
          DateTime.parse(t.date).isBefore(transactions.endDate))
      .toList());
  return transactions.copyWith(
      allTransactions: action.transactions,
      selectedTransactions: selectedTransactions,
      status: Status.SUCCESS,
      error: "");
}

TransactionsList updateTransactionDatesReducer(
    TransactionsList transactions, UpdateTransactionDatesAction action) {
  return transactions.copyWith(
      startDate: action.newStartDate, endDate: action.newEndDate);
}

TransactionsList categorizeTransactionsReducer(
    TransactionsList transactions, CategorizeTransactionsAction action) {
  // TODO not ideal
  List<Budget> zeroedBudgets = [];
  for (Budget _b in action.budgetsList.budgets) {
    zeroedBudgets.add(_b.copyWith(balance: 0));
  }

  List<Transaction> updatedSelectedTransactions = [];

  for (Transaction _t in transactions.selectedTransactions.reversed) {
    Transaction t = _t.copyWith();
    for (Budget _b in zeroedBudgets) {
      Budget b = _b.copyWith();
      if (t.budgetName == b.name) {
        if (action.budgetCategoriesList.budgetCategories.any(
            (bc) => bc.name.toLowerCase() == b.budgetCategory.toLowerCase())) {
          b = b.copyWith(balance: b.balance + t.amount);
          t = t.copyWith(balanceProgress: b.balance);
        }
        if (action.budgetCategoriesList.incomeCategories.any(
            (bc) => bc.name.toLowerCase() == b.budgetCategory.toLowerCase())) {
          b = b.copyWith(balance: b.balance + (t.amount * -1));
          t = t.copyWith(balanceProgress: b.balance);
        }
        if (action.budgetCategoriesList.transferCategories.any(
            (bc) => bc.name.toLowerCase() == b.budgetCategory.toLowerCase())) {
          b = b.copyWith(balance: b.balance + (t.amount * -1));
          t = t.copyWith(balanceProgress: b.balance);
        }
        if (action.budgetCategoriesList.feesCategories.any(
            (bc) => bc.name.toLowerCase() == b.budgetCategory.toLowerCase())) {
          b = b.copyWith(balance: b.balance + t.amount);
          t = t.copyWith(balanceProgress: b.balance);
        }
      }
    }
    updatedSelectedTransactions.add(t);
  }
  return transactions.copyWith(
      selectedTransactions: updatedSelectedTransactions.reversed);
}

Reducer<CategoriesList> categoryReducer = combineReducers<CategoriesList>([
  TypedReducer<CategoriesList, SuccessCategoriesAction>(
      successCategoriesReducer),
  TypedReducer<CategoriesList, ErrorCategoriesAction>(errorCategoriesReducer),
  TypedReducer<CategoriesList, LoadedCategoriesAction>(loadCategoriesReducer),
]);

CategoriesList successCategoriesReducer(
    CategoriesList categories, SuccessCategoriesAction action) {
  return categories.copyWith(status: Status.SUCCESS, error: "");
}

CategoriesList errorCategoriesReducer(
    CategoriesList categories, ErrorCategoriesAction action) {
  return categories.copyWith(
      status: Status.ERROR,
      error: action.statusCode.toString() + " " + action.error);
}

CategoriesList loadCategoriesReducer(
    CategoriesList categories, LoadedCategoriesAction action) {
  return categories.copyWith(
      categories: action.categories, status: Status.SUCCESS, error: "");
}

Reducer<BudgetsList> budgetReducer = combineReducers<BudgetsList>([
  TypedReducer<BudgetsList, SuccessBudgetsAction>(successBudgetsReducer),
  TypedReducer<BudgetsList, ErrorBudgetsAction>(errorBudgetsReducer),
  TypedReducer<BudgetsList, LoadedBudgetsAction>(loadBudgetsReducer),
  TypedReducer<BudgetsList, FillBudgetsAction>(fillBudgetsReducer),
]);

BudgetsList successBudgetsReducer(
    BudgetsList budgets, SuccessBudgetsAction action) {
  return budgets.copyWith(status: Status.SUCCESS, error: "");
}

BudgetsList errorBudgetsReducer(
    BudgetsList budgets, ErrorBudgetsAction action) {
  return budgets.copyWith(
      status: Status.ERROR,
      error: action.statusCode.toString() + " " + action.error);
}

BudgetsList loadBudgetsReducer(
    BudgetsList budgets, LoadedBudgetsAction action) {
  return budgets.copyWith(
      budgets: action.budgets, status: Status.SUCCESS, error: "");
}

BudgetsList fillBudgetsReducer(BudgetsList budgets, FillBudgetsAction action) {
  double totalSpent = 0;

  List<Budget> updatedBudget = [];
  for (Budget _b in budgets.budgets) {
    Budget b = _b.copyWith(balance: 0);
    for (Transaction _t
        in action.transactionsList.selectedTransactions.reversed) {
      Transaction t = _t.copyWith();
      if (t.budgetName == b.name) {
        if (action.budgetCategoriesList.budgetCategories.any(
            (bc) => bc.name.toLowerCase() == b.budgetCategory.toLowerCase())) {
          totalSpent += t.amount;
          b = b.copyWith(balance: b.balance + t.amount);
        }
        if (action.budgetCategoriesList.incomeCategories.any(
            (bc) => bc.name.toLowerCase() == b.budgetCategory.toLowerCase())) {
          b = b.copyWith(balance: b.balance + (t.amount * -1));
        }
        if (action.budgetCategoriesList.transferCategories.any(
            (bc) => bc.name.toLowerCase() == b.budgetCategory.toLowerCase())) {
          totalSpent += t.amount;
          b = b.copyWith(balance: b.balance + (t.amount * -1));
        }
        if (action.budgetCategoriesList.feesCategories.any(
            (bc) => bc.name.toLowerCase() == b.budgetCategory.toLowerCase())) {
          totalSpent += t.amount;
          b = b.copyWith(balance: b.balance + t.amount);
        }
      }
    }
  }
  return budgets.copyWith(budgets: updatedBudget, totalSpent: totalSpent);
}
