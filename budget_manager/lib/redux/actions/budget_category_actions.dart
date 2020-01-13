import 'package:budget_manager/redux/models/budget_category.dart';

// BUDGET CATEGORY Actions

class AddBudgetCategoryAction {
  final BudgetCategory budgetCategory;

  AddBudgetCategoryAction(this.budgetCategory);
}

class AddAllBudgetCategoriesAction {
  final List<BudgetCategory> budgetCategories;

  AddAllBudgetCategoriesAction(this.budgetCategories);
}

class RemoveAllBudgetCategoriesAction {}
