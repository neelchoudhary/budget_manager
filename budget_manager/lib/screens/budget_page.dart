import 'package:budget_manager/components/transaction_tile.dart';
import 'package:budget_manager/controller/data_controller.dart';
import 'package:budget_manager/models/budget.dart';
import 'package:budget_manager/models/budget_category.dart';
import 'package:budget_manager/models/transaction.dart';
import 'package:budget_manager/utilities/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class BudgetPage extends StatefulWidget {
  @override
  _BudgetPageState createState() => _BudgetPageState();
}

final GlobalKey<AnimatedCircularChartState> _chartKey =
    new GlobalKey<AnimatedCircularChartState>();

class _BudgetPageState extends State<BudgetPage> {
  @override
  void initState() {
    super.initState();
    this._hasDataLoaded = this._loadData();
  }

  Future<bool> _hasDataLoaded;
  double _totalBudget = 2000.00;
  double _usedBudget = 0;
  double _ratio = 0;
  String _selectedBudgetName = "";
  double _selectedBudgetBalance = 0.0;
  int _selectedSwitcherValue = 0;

  Future<bool> _loadData() async {
    bool dataLoaded = await budgetData.hasDataLoaded;
    if (dataLoaded) {
      this._displayTiles();
      this._usedBudget = budgetData.totalSpent;
      this._ratio =
          (_usedBudget / _totalBudget) > 1 ? 1 : (_usedBudget / _totalBudget);
      _updateCircularView();
    } else {
      print("oof");
    }
    return true;
  }

  void _displayTiles() {
    if (this._selectedSwitcherValue == 0) {
      _updateBudgetView();
    } else if (this._selectedSwitcherValue == 1) {
      _updateIncomeView();
    } else if (this._selectedSwitcherValue == 2) {
      _updateTransferView();
    } else if (this._selectedSwitcherValue == 3) {
      _updateFeeView();
    }
  }

  Future<void> _refreshAccounts() async {
    await budgetData.refreshAccounts();
    this._usedBudget = budgetData.totalSpent;
    this._ratio =
        (_usedBudget / _totalBudget) > 1 ? 1 : (_usedBudget / _totalBudget);
    this._displayTiles();
    this._updateCircularView();
  }

  List<Widget> budgetCategoriesPanel = [];

  void _openTransactionsSlider(String budgetName, double budgetBalance) {
    setState(() {
      this._selectedBudgetName = budgetName;
      this._selectedBudgetBalance = budgetBalance;
    });
    this._pc.open();
  }

  void _updateBudgetView() {
    this.budgetCategoriesPanel.clear();
    budgetData.categorizeTransactions();
    for (BudgetCategory budgetCategory in budgetData.budgetCategories) {
      String budgetCategoryName = budgetCategory.name;
      List<Widget> budgetTiles = [];

      List<Budget> budgetsInCategory = budgetData.budgets
          .where((budget) =>
              budget.budgetCategory.toLowerCase() ==
              budgetCategoryName.toLowerCase())
          .toList();
      budgetsInCategory
          .sort((b1, b2) => b2.balance.abs().compareTo(b1.balance.abs()));
      for (Budget budget in budgetsInCategory) {
        budgetTiles.add(BudgetTile(
          budgetName: budget.name,
          budgetIcon: budgetData.iconMap[budget.name],
          budgetBalance: budget.balance,
          budgetColor: budgetCategory.color,
          budgetTotal: 500.00,
          openTransactionsCallback: this._openTransactionsSlider,
        ));
        budgetTiles.add(SizedBox(width: 10));
      }
      this.budgetCategoriesPanel.add(BudgetCategoryPanel(
            budgetCategoryTitle: budgetCategoryName,
            budgetCategoryColor: budgetCategory.color,
            budgetTiles: budgetTiles,
          ));
      this.budgetCategoriesPanel.add(SizedBox(height: 10));
    }
    setState(() {});
  }

  void _updateIncomeView() {
    this.budgetCategoriesPanel.clear();
    for (BudgetCategory budgetCategory in budgetData.incomeCategories) {
      String budgetCategoryName = budgetCategory.name;
      List<Widget> incomeTiles = [];

      List<Budget> budgetsInCategory = budgetData.budgets
          .where((budget) =>
              budget.budgetCategory.toLowerCase() ==
              budgetCategoryName.toLowerCase())
          .toList();
      budgetsInCategory
          .sort((b1, b2) => b2.balance.abs().compareTo(b1.balance.abs()));
      for (Budget budget in budgetsInCategory) {
        incomeTiles.add(IncomeTile(
          incomeName: budget.name,
          incomeIcon: budgetData.iconMap[budget.name],
          incomeBalance: budget.balance,
          incomeColor: budgetCategory.color,
          openTransactionsCallback: this._openTransactionsSlider,
        ));
        incomeTiles.add(SizedBox(width: 10));
      }
      this.budgetCategoriesPanel.add(BudgetCategoryPanel(
            budgetCategoryTitle: budgetCategoryName,
            budgetCategoryColor: budgetCategory.color,
            budgetTiles: incomeTiles,
          ));
      this.budgetCategoriesPanel.add(SizedBox(height: 10));
    }
    setState(() {});
  }

  void _updateTransferView() {
    this.budgetCategoriesPanel.clear();
    for (BudgetCategory budgetCategory in budgetData.transferCategories) {
      String budgetCategoryName = budgetCategory.name;
      List<Widget> incomeTiles = [];

      List<Budget> budgetsInCategory = budgetData.budgets
          .where((budget) =>
              budget.budgetCategory.toLowerCase() ==
              budgetCategoryName.toLowerCase())
          .toList();
      budgetsInCategory
          .sort((b1, b2) => b2.balance.abs().compareTo(b1.balance.abs()));
      for (Budget budget in budgetsInCategory) {
        incomeTiles.add(TransferTile(
          transferName: budget.name,
          transferIcon: budgetData.iconMap[budget.name],
          transferBalance: budget.balance,
          transferColor: budgetCategory.color,
          openTransactionsCallback: this._openTransactionsSlider,
        ));
        incomeTiles.add(SizedBox(width: 10));
      }
      this.budgetCategoriesPanel.add(BudgetCategoryPanel(
            budgetCategoryTitle: budgetCategoryName,
            budgetCategoryColor: budgetCategory.color,
            budgetTiles: incomeTiles,
          ));
      this.budgetCategoriesPanel.add(SizedBox(height: 10));
    }
    setState(() {});
  }

  void _updateFeeView() {
    this.budgetCategoriesPanel.clear();
    for (BudgetCategory budgetCategory in budgetData.feesCategories) {
      String budgetCategoryName = budgetCategory.name;
      List<Widget> incomeTiles = [];

      List<Budget> budgetsInCategory = budgetData.budgets
          .where((budget) =>
              budget.budgetCategory.toLowerCase() ==
              budgetCategoryName.toLowerCase())
          .toList();
      budgetsInCategory
          .sort((b1, b2) => b2.balance.abs().compareTo(b1.balance.abs()));
      for (Budget budget in budgetsInCategory) {
        incomeTiles.add(FeeTile(
          feeName: budget.name,
          feeIcon: budgetData.iconMap[budget.name],
          feeBalance: budget.balance,
          feeColor: budgetCategory.color,
          openTransactionsCallback: this._openTransactionsSlider,
        ));
        incomeTiles.add(SizedBox(width: 10));
      }
      this.budgetCategoriesPanel.add(BudgetCategoryPanel(
            budgetCategoryTitle: budgetCategoryName,
            budgetCategoryColor: budgetCategory.color,
            budgetTiles: incomeTiles,
          ));
      this.budgetCategoriesPanel.add(SizedBox(height: 10));
    }
    setState(() {});
  }

  void _updateCircularView() {
    List<CircularStackEntry> nextData = <CircularStackEntry>[
      new CircularStackEntry(
        <CircularSegmentEntry>[
          new CircularSegmentEntry(
            this._ratio * 75,
            Colors.blue[400],
            rankKey: 'completed',
          ),
          new CircularSegmentEntry(
            75 - (this._ratio * 75),
            Colors.blueGrey[600],
            rankKey: 'remaining',
          ),
        ],
      ),
    ];
    setState(() {
      _chartKey.currentState.updateData(nextData);
    });
  }

  void _prevMonth() async {
    int _selectedMonth = budgetData.startDate.month;
    int _selectedYear = budgetData.startDate.year;
    _selectedYear = (_selectedMonth == 1) ? _selectedYear - 1 : _selectedYear;
    _selectedMonth = (_selectedMonth == 1) ? 12 : _selectedMonth - 1;
    String strStartMonth = _selectedMonth.toString();
    int endYear = (_selectedMonth == 12) ? _selectedYear + 1 : _selectedYear;
    String strEndMonth =
        (_selectedMonth == 12) ? "1" : (_selectedMonth + 1).toString();
    if (_selectedMonth < 10) {
      strStartMonth = "0" + strStartMonth.toString();
    }
    if ((_selectedMonth + 1) < 10 || _selectedMonth == 12) {
      strEndMonth = "0" + strEndMonth.toString();
    }
    String startDate =
        _selectedYear.toString() + "-" + strStartMonth + "-" + "01";
    String endDate = endYear.toString() + "-" + strEndMonth + "-" + "01";
    budgetData.setStartDate(startDate);
    budgetData.setEndDate(endDate);

    await _refreshAccounts();
  }

  void _nextMonth() async {
    int _selectedMonth = budgetData.startDate.month;
    int _selectedYear = budgetData.startDate.year;
    _selectedYear = (_selectedMonth == 12) ? _selectedYear + 1 : _selectedYear;
    _selectedMonth = (_selectedMonth == 12) ? 1 : _selectedMonth + 1;
    String strStartMonth = _selectedMonth.toString();
    int endYear = (_selectedMonth == 12) ? _selectedYear + 1 : _selectedYear;
    String strEndMonth =
        (_selectedMonth == 12) ? "1" : (_selectedMonth + 1).toString();
    if (_selectedMonth < 10) {
      strStartMonth = "0" + strStartMonth.toString();
    }
    if ((_selectedMonth + 1) < 10 || _selectedMonth == 12) {
      strEndMonth = "0" + strEndMonth.toString();
    }
    String startDate =
        _selectedYear.toString() + "-" + strStartMonth + "-" + "01";
    String endDate = endYear.toString() + "-" + strEndMonth + "-" + "01";
    budgetData.setStartDate(startDate);
    budgetData.setEndDate(endDate);
    budgetData.getTransactions();

    await _refreshAccounts();
  }

  int _currentPageIndex = 1;
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
              return;
            } else if (value == 2) {
              Navigator.pushReplacementNamed(context, '/funds');
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
            panel: SlidingTransactionsPanel(
              budgetName: this._selectedBudgetName,
              budgetBalance: this._selectedBudgetBalance,
            ),
            body: Padding(
              padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(prof_pic),
                        ),
                      ),
                      Text(
                        "My Budget",
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        width: 60,
                        height: 50,
                        child: FlatButton.icon(
                            onPressed: () => _updateIncomeView(),
                            icon: Icon(Icons.settings),
                            label: Text("")),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: FlatButton.icon(
                            onPressed: this._prevMonth,
                            icon: Icon(Icons.navigate_before),
                            label: Text("")),
                      ),
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
//                                    SizedBox(
//                                      height: 35,
//                                    ),
                                    Text(
                                      "\$${budgetData.totalSpent.toStringAsFixed(2)}",
                                      style: TextStyle(
                                          fontSize: 24, color: Colors.black87),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      "of \$${this._totalBudget.toStringAsFixed(2)}",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black87),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${DateFormat.yMMM().format(budgetData.startDate)}",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black87),
                                ),
                              ],
                            ),
                            AnimatedCircularChart(
                              key: _chartKey,
                              size: Size(250.0, 250.0),
                              startAngle: 135,
                              initialChartData: <CircularStackEntry>[
                                new CircularStackEntry(
                                  <CircularSegmentEntry>[
                                    // Total should be 75
                                    new CircularSegmentEntry(
                                      this._ratio * 75,
                                      Colors.blue[400],
                                      rankKey: 'completed',
                                    ),
                                    new CircularSegmentEntry(
                                      75 - (this._ratio * 75),
                                      Colors.blueGrey[600],
                                      rankKey: 'remaining',
                                    ),
                                  ],
                                  rankKey: 'progress',
                                ),
                              ],
                              chartType: CircularChartType.Radial,
                              edgeStyle: SegmentEdgeStyle.round,
                              percentageValues: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: FlatButton.icon(
                            onPressed: this._nextMonth,
                            icon: Icon(Icons.navigate_next),
                            label: Text("")),
                      ),
                    ],
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CupertinoSegmentedControl(
                        children: <int, Widget>{
                          0: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Expenses"),
                          ),
                          1: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Income"),
                          ),
                          2: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Transfers"),
                          ),
                          3: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Fees"),
                          ),
                        },
                        groupValue: this._selectedSwitcherValue,
                        onValueChanged: (val) {
                          setState(() {
                            this._selectedSwitcherValue = val;
                          });
                          _displayTiles();
                        },
                      ),
                    ),
                  ),
                  RefreshIndicator(
                    onRefresh: _refreshAccounts,
                    child: Container(
                      height: 450,
                      width: double.infinity,
                      child: ListView.builder(
                        itemCount: this.budgetCategoriesPanel.length,
                        itemBuilder: (BuildContext c, int i) {
                          return this.budgetCategoriesPanel[i];
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

class BudgetCategoryPanel extends StatelessWidget {
  final List<Widget> budgetTiles;
  final String budgetCategoryTitle;
  final Color budgetCategoryColor;

  BudgetCategoryPanel(
      {this.budgetTiles, this.budgetCategoryTitle, this.budgetCategoryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  this.budgetCategoryTitle.toUpperCase(),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1),
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            height: 200,
            child: ListView.builder(
              itemCount: this.budgetTiles.length,
              itemBuilder: (BuildContext c, int i) {
                return this.budgetTiles[i];
              },
              scrollDirection: Axis.horizontal,
            ),
          ),
        ],
      ),
    );
  }
}

class BudgetTile extends StatelessWidget {
  final String budgetName;
  final double budgetBalance;
  final double budgetTotal;
  final IconData budgetIcon;
  final Color budgetColor;
  final Function openTransactionsCallback;

  BudgetTile(
      {this.budgetName,
      this.budgetBalance,
      this.budgetTotal,
      this.budgetIcon,
      this.budgetColor,
      this.openTransactionsCallback});

  @override
  Widget build(BuildContext context) {
    double ratio = this.budgetBalance / this.budgetTotal;
    ratio = ratio > 1 ? 1 : ratio;
    ratio = ratio < 0 ? 0 : ratio;

    return Container(
      constraints: BoxConstraints(
        minHeight: 160,
        minWidth: 160,
        maxHeight: 160,
        maxWidth: 160,
      ),
      // maxWidth: (MediaQuery.of(context).size.width - 40) / 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [budgetColor, budgetColor.withOpacity(.6)],
          tileMode: TileMode.repeated,
        ),
        //  color: institutionColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
              spreadRadius: 0,
              color: budgetColor.withOpacity(.4),
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
                        this.budgetName, this.budgetBalance);
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
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircularPercentIndicator(
                  radius: 50.0,
                  lineWidth: 4.0,
                  circularStrokeCap: CircularStrokeCap.round,
                  percent: ratio,
                  //   reverse: true,
                  //  startAngle: 40,
                  center: Icon(
                    this.budgetIcon,
                    size: 23,
                    color: Colors.white,
                  ),
                  backgroundColor: Colors.white.withOpacity(.2),
                  progressColor: Colors.white,
                  animation: true,
                  animationDuration: 500,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        this.budgetName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        "\$${this.budgetBalance.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                      SizedBox(
                        height: 3.0,
                      ),
                      Text(
                        "of \$${this.budgetTotal.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class IncomeTile extends StatelessWidget {
  final String incomeName;
  final double incomeBalance;
  final IconData incomeIcon;
  final Color incomeColor;
  final Function openTransactionsCallback;

  IncomeTile(
      {this.incomeName,
      this.incomeBalance,
      this.incomeIcon,
      this.incomeColor,
      this.openTransactionsCallback});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 160,
        minWidth: 160,
        maxHeight: 160,
        maxWidth: 160,
      ),
      // maxWidth: (MediaQuery.of(context).size.width - 40) / 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [incomeColor, incomeColor.withOpacity(.6)],
          tileMode: TileMode.repeated,
        ),
        //  color: institutionColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
              spreadRadius: 0,
              color: incomeColor.withOpacity(.4),
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
                        this.incomeName, this.incomeBalance);
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
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: Icon(
                      this.incomeIcon,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        this.incomeName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        "\$${this.incomeBalance.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TransferTile extends StatelessWidget {
  final String transferName;
  final double transferBalance;
  final IconData transferIcon;
  final Color transferColor;
  final Function openTransactionsCallback;

  TransferTile(
      {this.transferName,
      this.transferBalance,
      this.transferIcon,
      this.transferColor,
      this.openTransactionsCallback});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 160,
        minWidth: 160,
        maxHeight: 160,
        maxWidth: 160,
      ),
      // maxWidth: (MediaQuery.of(context).size.width - 40) / 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [transferColor, transferColor.withOpacity(.6)],
          tileMode: TileMode.repeated,
        ),
        //  color: institutionColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
              spreadRadius: 0,
              color: transferColor.withOpacity(.4),
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
                        this.transferName, this.transferBalance);
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
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: Icon(
                      this.transferIcon,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        this.transferName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        "\$${this.transferBalance.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FeeTile extends StatelessWidget {
  final String feeName;
  final double feeBalance;
  final IconData feeIcon;
  final Color feeColor;
  final Function openTransactionsCallback;

  FeeTile(
      {this.feeName,
      this.feeBalance,
      this.feeIcon,
      this.feeColor,
      this.openTransactionsCallback});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 160,
        minWidth: 160,
        maxHeight: 160,
        maxWidth: 160,
      ),
      // maxWidth: (MediaQuery.of(context).size.width - 40) / 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [feeColor, feeColor.withOpacity(.6)],
          tileMode: TileMode.repeated,
        ),
        //  color: institutionColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
              spreadRadius: 0,
              color: feeColor.withOpacity(.4),
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
                        this.feeName, this.feeBalance);
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
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: Icon(
                      this.feeIcon,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        this.feeName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        "\$${this.feeBalance.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
