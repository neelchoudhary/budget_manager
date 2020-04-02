import 'package:budget_manager/components/transaction_tile.dart';
import 'package:budget_manager/controller/data_controller.dart';
import 'package:budget_manager/models/budget.dart';
import 'package:budget_manager/models/transaction.dart';
import 'package:budget_manager/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:percent_indicator/percent_indicator.dart';

class FundsPage extends StatefulWidget {
  @override
  _FundsPageState createState() => _FundsPageState();
}

class _FundsPageState extends State<FundsPage> {
  @override
  void initState() {
    super.initState();
    this._hasDataLoaded = this._loadData();
  }

  Future<bool> _hasDataLoaded;
  List<Widget> _fundTileList = [];

  Future<bool> _loadData() async {
    bool dataLoaded = await budgetData.hasDataLoaded;
    if (dataLoaded) {
      this._updateFundsView();
    } else {
      print("oof");
    }
    return true;
  }

  Future<void> _refreshAccounts() async {
    await budgetData.refreshAccounts();
    this._updateFundsView();
  }

  void _updateFundsView() {
    this._fundTileList.clear();
    this._fundTileList.add(SizedBox(height: 10));
    this._fundTileList.add(FundTile(
          fundName: "New Watch",
          fundIcon: budgetData.iconMap["Retail"],
          fundBalance: 150.00,
          fundGoal: 500.00,
          fundColor: Colors.orange,
          openTransactionsCallback: () {},
        ));
    this._fundTileList.add(SizedBox(height: 10));
    this._fundTileList.add(FundTile(
          fundName: "New Watch",
          fundIcon: budgetData.iconMap["Retail"],
          fundBalance: 150.00,
          fundGoal: 500.00,
          fundColor: Colors.orange,
          openTransactionsCallback: () {},
        ));
    this._fundTileList.add(SizedBox(height: 10));
    this._fundTileList.add(FundTile(
          fundName: "New Watch",
          fundIcon: budgetData.iconMap["Retail"],
          fundBalance: 150.00,
          fundGoal: 500.00,
          fundColor: Colors.orange,
          openTransactionsCallback: () {},
        ));
    this._fundTileList.add(SizedBox(height: 10));
//    for (BudgetCategory budgetCategory in budgetData.budgetCategories) {
//      String budgetCategoryName = budgetCategory.name;
//      List<Budget> budgetsInCategory = budgetData.budgets
//          .where((budget) =>
//              budget.budgetCategory.toLowerCase() ==
//              budgetCategoryName.toLowerCase())
//          .toList();
//      budgetsInCategory
//          .sort((b1, b2) => b2.balance.abs().compareTo(b1.balance.abs()));
//      this._fundTileList.add(FundTile(
//        fundName: budget.name,
//        fundIcon: budgetData.iconMap[budget.name],
//        fundBalance: budget.balance,
//        fundColor: budgetCategory.color,
//        fundGoal: 500.00,
//        openTransactionsCallback: this._openTransactionsSlider,
//      ));
//      this._fundTileList.add(SizedBox(width: 10));
//    }
    setState(() {});
  }

  int _currentPageIndex = 2;
  final PanelController _pc = PanelController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentPageIndex,
        onTap: (value) {
          setState(() {
            _currentPageIndex = value;
            if (value == 0) {
              // go to dashboard
              Navigator.pushReplacementNamed(context, '/');
            } else if (value == 1) {
              // do nothing
              Navigator.pushReplacementNamed(context, '/budget');
            } else if (value == 2) {
              // do nothing
              return;
            } else if (value == 3) {
              Navigator.pushReplacementNamed(context, '/accounts');
            }
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Home")),
          BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart), title: Text("Budget")),
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money), title: Text("Funds")),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance), title: Text("Accounts")),
        ],
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: SlidingUpPanel(
            controller: this._pc,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
            minHeight: 0,
            //  padding: EdgeInsets.all(6.0),
            renderPanelSheet: true,
            backdropEnabled: true,
            panel: null,
            body: Padding(
              padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(5),
//                    decoration: BoxDecoration(
//                      color: Colors.white,
//                      borderRadius: BorderRadius.circular(10.0),
//                      boxShadow: <BoxShadow>[
//                        BoxShadow(
//                          color: Colors.black12,
//                          blurRadius: 20.0,
//                        )
//                      ],
//                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(prof_pic),
                          ),
                        ),
                        Text(
                          "My Funds",
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(
                          width: 60,
                          height: 50,
                          child: FlatButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.settings),
                              label: Text("")),
                        ),
                      ],
                    ),
                  ),
//                  SizedBox(
//                    height: 5,
//                  ),
                  RefreshIndicator(
                    onRefresh: _refreshAccounts,
                    child: Container(
                      height: 800,
                      width: double.infinity,
                      child: ListView.builder(
                        itemCount: this._fundTileList.length,
                        itemBuilder: (BuildContext c, int i) {
                          return this._fundTileList[i];
                        },
                        padding: EdgeInsets.all(8),
                        scrollDirection: Axis.vertical,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SlidingTransactionsPanel extends StatelessWidget {
  final String budgetName;
  final double budgetBalance;
  final List<Widget> _transactionTiles = [];

  SlidingTransactionsPanel({this.budgetName, this.budgetBalance});

  void updateTransactionsListView() {
    this._transactionTiles.clear();
    for (Transaction t in budgetData.currentTransactions
        .where((b) => b.budgetName == this.budgetName)) {
      double amount = t.amount * -1;
      Budget budget = budgetData.budgets
          .firstWhere((b) => b.name == this.budgetName, orElse: () {
        Budget b = Budget();
        b.color = kColor_pink;
        b.icon = Icons.error;
        return b;
      });
      this._transactionTiles.add(
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              child: TransactionTile(
                categoryColor: budget.color,
                category: t.category.toString().length > 25
                    ? t.category.toString().substring(0, 25)
                    : t.category.toString(),
                detail: toTitle(t.name).length > 32
                    ? toTitle(t.name).substring(0, 30) + "..."
                    : toTitle(t.name),
                amount: amount > 0 ? "\$$amount" : "-\$${amount.abs()}",
                date: t.date,
                icon: budget.icon,
                percentFilled: t.balanceProgress / 500.0,
              ),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    this.updateTransactionsListView();
    return Column(
      children: <Widget>[
        SizedBox(
          height: 15.0,
        ),
        Text(
          "${this.budgetName.toUpperCase()} (${this._transactionTiles.length}) - \$${this.budgetBalance.toStringAsFixed(2)}",
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(
          height: 10.0,
        ),
        Container(
          height: 420,
          width: double.infinity,
          child: ListView.builder(
            itemCount: this._transactionTiles.length,
            itemBuilder: (BuildContext c, int i) {
              return this._transactionTiles[i];
            },
            scrollDirection: Axis.vertical,
          ),
        ),
      ],
    );
  }
}

class FundTile extends StatelessWidget {
  final String fundName;
  final double fundBalance;
  final double fundGoal;
  final IconData fundIcon;
  final Color fundColor;
  final Function openTransactionsCallback;

  FundTile(
      {this.fundName,
      this.fundBalance,
      this.fundGoal,
      this.fundIcon,
      this.fundColor,
      this.openTransactionsCallback});

  @override
  Widget build(BuildContext context) {
    double ratio = this.fundBalance / this.fundGoal;
    ratio = ratio > 1 ? 1 : ratio;
    ratio = ratio < 0 ? 0 : ratio;

    return Container(
//      constraints: BoxConstraints(
//        minHeight: 120,
//        maxHeight: 120,
//      ),
      // maxWidth: (MediaQuery.of(context).size.width - 40) / 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [fundColor, fundColor.withOpacity(.6)],
          tileMode: TileMode.repeated,
        ),
        //  color: institutionColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
              spreadRadius: 0,
              color: fundColor.withOpacity(.4),
              blurRadius: 4.0,
              offset: Offset.fromDirection(0, 4))
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Stack(
          children: <Widget>[
            Container(
              constraints: BoxConstraints(minHeight: 120, minWidth: 280),
              alignment: Alignment.topRight,
              child: DropdownButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
                iconSize: 24,
                elevation: 16,
                underline: Container(
                  height: 0,
                  color: Colors.white,
                ),
                onChanged: (String newValue) {
                  if (newValue == 'Transactions') {
                    this.openTransactionsCallback(
                        this.fundName, this.fundBalance);
                  }
                },
                items: <String>['Transactions']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        this.fundIcon,
                        size: 25,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Text(
                        this.fundName,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "\$${this.fundBalance.toStringAsFixed(2)}",
                              style:
                                  TextStyle(fontSize: 24, color: Colors.white),
                            ),
                            SizedBox(
                              height: 3.0,
                            ),
                            Text(
                              "of \$${this.fundGoal.toStringAsFixed(2)}",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      LinearPercentIndicator(
                        width: 200,
                        lineHeight: 14.0,
                        percent: ratio,
                        backgroundColor: Colors.white.withOpacity(.2),
                        progressColor: Colors.white,
                        animation: true,
                        animationDuration: 1000,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
