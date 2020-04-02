import 'package:budget_manager/redux/middlewares.dart';
import 'package:budget_manager/redux/models/app_state.dart';
import 'package:budget_manager/redux/reducers.dart';
import 'package:budget_manager/screens/accounts_page.dart';
import 'package:budget_manager/screens/budget_page.dart';
import 'package:budget_manager/screens/dashboard_page.dart';
import 'package:budget_manager/screens/funds_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

void main() {
  final store = new Store<AppState>(appStateReducer,
      middleware: [
        CategoriesMiddleware(),
        BudgetsMiddleware(),
        ItemsMiddleware(),
        AccountsMiddleware(),
        TransactionsMiddleware(),
      ],
      initialState: AppState.initialState(),
      distinct: false);

  /// TODO consider making it distinct, but must override .equals for appstate.
  runApp(BudgetManager(store: store));
}

class BudgetManager extends StatelessWidget {
  final Store<AppState> store;

  BudgetManager({@required this.store}) : assert(store != null);

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: this.store,
      child: MaterialApp(
        routes: {
          '/': (context) => DashboardPage(),
          '/budget': (context) => BudgetPage(),
          '/funds': (context) => FundsPage(),
          '/accounts': (context) => AccountsPage(),
        },
        theme: ThemeData.light().copyWith(
//        primaryColor: ,
//        scaffoldBackgroundColor: ,
//        primaryColor: kColor_main_background_top,
//        scaffoldBackgroundColor: kColor_main_background_top,
            ),
      ),
    );
  }
}
