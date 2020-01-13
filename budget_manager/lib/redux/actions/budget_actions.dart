import 'package:budget_manager/redux/models/budget.dart';
import 'package:budget_manager/redux/models/budget_category.dart';
import 'package:budget_manager/redux/models/transaction.dart';

// API Actions
class GetBudgetsAction {
  bool forceRefresh;
  final Budget budget;

  GetBudgetsAction({this.forceRefresh, this.budget});
}

// Response Actions
class SuccessBudgetsAction {}

class ErrorBudgetsAction {
  final int statusCode;
  final String error;

  ErrorBudgetsAction({this.statusCode, this.error});
}

class LoadedBudgetsAction {
  final List<Budget> budgets;

  LoadedBudgetsAction({this.budgets});
}

// State Actions
class FillBudgetsAction {
  final TransactionsList transactionsList;
  final BudgetCategoriesList budgetCategoriesList;

  FillBudgetsAction({this.transactionsList, this.budgetCategoriesList});
}
