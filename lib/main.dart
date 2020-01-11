import 'package:budget_manager/screens/accounts_page.dart';
import 'package:budget_manager/screens/budget_page.dart';
import 'package:budget_manager/screens/dashboard_page.dart';
import 'package:budget_manager/screens/funds_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(BudgetManager());

class BudgetManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}
