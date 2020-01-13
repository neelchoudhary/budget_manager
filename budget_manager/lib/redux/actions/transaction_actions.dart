import 'package:budget_manager/models/budget_category.dart';
import 'package:budget_manager/redux/models/account.dart';
import 'package:budget_manager/redux/models/budget.dart';
import 'package:budget_manager/redux/models/budget_category.dart';
import 'package:budget_manager/redux/models/transaction.dart';

// API Actions
class AddTransactionsAction {
  final int itemID;

  AddTransactionsAction(this.itemID);
}

class GetTransactionsAction {
  final bool forceRefresh;
  final int itemID;
  final int accountID;

  GetTransactionsAction({this.forceRefresh, this.itemID, this.accountID});
}

class EditTransactionAction {
  final Transaction editedTransaction;

  EditTransactionAction({this.editedTransaction});
}

class CategorizeTransactionsAction {
  final BudgetsList budgetsList;
  final BudgetCategoriesList budgetCategoriesList;

  CategorizeTransactionsAction({this.budgetsList, this.budgetCategoriesList});
}

// Response Actions
class SuccessTransactionsAction {}

class ErrorTransactionsAction {
  final int statusCode;
  final String error;

  ErrorTransactionsAction({this.statusCode, this.error});
}

class LoadedTransactionsAction {
  final List<Transaction> transactions;
  final List<Account> selectedAccounts;

  LoadedTransactionsAction({this.transactions, this.selectedAccounts});
}

// State Actions
class UpdateTransactionDatesAction {
  final DateTime newStartDate;
  final DateTime newEndDate;

  UpdateTransactionDatesAction({this.newStartDate, this.newEndDate});
}
