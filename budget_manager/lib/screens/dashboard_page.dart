import 'dart:math';

import 'package:budget_manager/components/transaction_tile.dart';
import 'package:budget_manager/controller/data_controller.dart';
import 'package:budget_manager/models/budget.dart';
import 'package:budget_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';

import '../models/transaction.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
//  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    this.initView();
    this.initLists();
    this._hasDataLoaded = _loadData();
    setState(() {});
  }

  Future<bool> _hasDataLoaded;

  String _accountTotals;
  int _daysHistory = 7;
  List<Widget> _widgetList = [];
  List<Widget> _transactionTiles = [];
  String _dropdownValue = 'Week';
  int _currentPageIndex = 0;
  List<Text> _week = [];
  List<Text> _month = [];
  List<Text> _year = [];
  List<Text> _xAxis = [];

  Future<bool> _loadData() async {
    bool dataLoaded = await budgetData.hasDataLoaded;
    if (dataLoaded) {
      this._accountTotals = budgetData.balanceTotal().toStringAsFixed(2);
      this.updateTransactionsListView();
      this._xAxis = _week;
      this.topView(_dropdownValue, _daysHistory, _xAxis);
    } else {
      print("oof");
    }
    return true;
  }

  Future<bool> loadedData(bool hasLoaded) async {
    return hasLoaded;
  }

  Future<void> _refreshAccounts() async {
    this._hasDataLoaded = loadedData(false);
    budgetData.setDefaultDates();
    await budgetData.refreshAccounts();
    updateTransactionsListView();
    this.topView(_dropdownValue, _daysHistory, _xAxis);
    this._accountTotals = budgetData.balanceTotal().toString();
    this._hasDataLoaded = loadedData(true);
  }

  List<double> graphComputation(int daysHistory) {
    // Week view
    DateTime today = DateTime.now();
    //  DateTime weekAgo = today.add(new Duration(days: -7));
    List<DateTime> dates = [];
    DateTime curr = today;
    for (int i = 0; i < daysHistory; i++) {
      dates.add(curr);
      curr = curr.add(new Duration(days: -1));
    }

    int modulo = 1;
    if (daysHistory == 7) {
      modulo = 1;
    } else if (daysHistory == 30) {
      modulo = 4;
    } else if (daysHistory == 365) {
      modulo = 30;
    }

    List<double> data = [];
    int total = 0;
    for (DateTime d in dates) {
      double currDateSum = 0;
      total++;
      for (Transaction t in budgetData.allTransactions) {
        if (d.toString().contains(t.date)) {
          currDateSum += (t.amount > 0) ? t.amount : 0;
        }
      }
      if (total % modulo == 0) {
        if (currDateSum == 0) {
          currDateSum = Random().nextDouble();
        }
        data.add(currDateSum);
      }
    }

    // Log scale:
    List<double> logScaledData = [];
    for (double dataPoint in data) {
      double logScaledDataPoint;
      if (dataPoint > 0) {
        logScaledDataPoint = log(dataPoint);
      } else {
        logScaledDataPoint = 0;
      }
      logScaledData.add(logScaledDataPoint);
    }

    //  return data;
    return logScaledData;
  }

  void initLists() {
    _week = [
      Text("S"),
      Text("M"),
      Text("T"),
      Text("W"),
      Text("R"),
      Text("F"),
      Text("S")
    ];

    this._month.clear();
    for (int i = 1; i <= 30; i += 4) {
      this._month.add(Text(i.toString()));
    }

    _year = [
      Text("Ja"),
      Text("Fe"),
      Text("Ma"),
      Text("Ap"),
      Text("Ma"),
      Text("Ju"),
      Text("Ju"),
      Text("Au"),
      Text("Se"),
      Text("Oc"),
      Text("No"),
      Text("De"),
    ];
  }

  void initView() {
    topView(_dropdownValue, _daysHistory, _xAxis);
    _widgetList.add(Padding(
      padding: EdgeInsets.only(top: 10),
      child: Center(
        child: SizedBox(
          child: CircularProgressIndicator(),
          width: 60,
          height: 60,
        ),
      ),
    ));
  }

  void topView(String dropdownValue, int daysHistory, List<Text> xAxis) {
    initLists();
    _widgetList.clear();
    _widgetList.add(Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Spending Summary",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2),
                ),
                DropdownButton<String>(
                  value: dropdownValue,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.black),
                  onChanged: (String newValue) {
                    setState(() {
                      _dropdownValue = newValue;
                      if (newValue == "Week") {
                        _daysHistory = 7;
                        _xAxis = this._week;
                      } else if (newValue == "Month") {
                        _daysHistory = 30;
                        _xAxis = this._month;
                      } else if (newValue == "Year") {
                        _daysHistory = 365;
                        _xAxis = this._year;
                      }
                      topView(_dropdownValue, _daysHistory, _xAxis);
                    });
                  },
                  items: <String>['Week', 'Month', 'Year']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(color: Colors.black12, blurRadius: 20.0)
                ],
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: FutureBuilder<bool>(
                      future: this
                          ._hasDataLoaded, // a previously-obtained Future<String> or null
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        Widget content;
                        if (snapshot.hasData) {
                          content = Sparkline(
                            data: this.graphComputation(daysHistory),
                            lineWidth: 5.0,
                            lineColor: Colors.lightBlue,
                            pointsMode: PointsMode.all,
                            pointSize: 5.0,
                          );
                        } else {
                          content = SizedBox(
                            child: CircularProgressIndicator(),
                            width: 60,
                            height: 60,
                          );
                        }
                        return content;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 0, 25.0, 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: xAxis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
    _widgetList.add(Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 5.0),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Recent Transactions (${budgetData.currentTransactions.length})",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2),
                ),
                //       Text("Today"),
              ],
            ),
          ],
        ),
      ),
    ));

    setState(() {});
  }

  void updateTransactionsListView() {
    this._transactionTiles.clear();
    bool todayLabelUsed = false;
    bool yesterdayLabelUsed = false;
    bool lastWeekLabelUsed = false;
    bool lastMonthLabelUsed = false;
    for (int i = 0; i < budgetData.currentTransactions.length; i++) {
      double amount = budgetData.currentTransactions[i].amount * -1;
      Transaction transaction = budgetData.currentTransactions[i];
      Budget budget = budgetData.budgets.firstWhere(
          (budget) => budget.name == transaction.budgetName, orElse: () {
        Budget b = Budget();
        b.color = kColor_pink;
        b.icon = Icons.error;
        return b;
      });
      DateTime today = DateTime.now().add(Duration(days: -1));
      DateTime yesterday = DateTime.now().add(Duration(days: -2));
      DateTime lastWeek = DateTime.now().add(Duration(days: -8));
      DateTime lastMonth = DateTime.now().add(Duration(days: -31));
      if (DateTime.parse(transaction.date).isAfter(today)) {
        if (!todayLabelUsed) {
          this._transactionTiles.add(Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 5.0),
                child: Text("Today"),
              ));
        }
        todayLabelUsed = true;
      } else if (DateTime.parse(transaction.date).isAfter(yesterday)) {
        if (!yesterdayLabelUsed) {
          this._transactionTiles.add(Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 5.0),
                child: Text("Yesterday"),
              ));
        }
        yesterdayLabelUsed = true;
      } else if (DateTime.parse(transaction.date).isAfter(lastWeek)) {
        if (!lastWeekLabelUsed) {
          this._transactionTiles.add(Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 5.0),
                child: Text("This Week"),
              ));
        }
        lastWeekLabelUsed = true;
      } else if (DateTime.parse(transaction.date).isAfter(lastMonth)) {
        if (!lastMonthLabelUsed) {
          this._transactionTiles.add(Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 5.0),
                child: Text("This Month"),
              ));
        }
        lastMonthLabelUsed = true;
      }
      this._transactionTiles.add(
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              child: TransactionTile(
                categoryColor: budget.color,
                category: transaction.category.toString().length > 25
                    ? transaction.category.toString().substring(0, 25)
                    : transaction.category.toString(),
                detail: transaction.name.length > 33
                    ? toTitle(transaction.name.substring(0, 33)) + "..."
                    : toTitle(transaction.name),
                amount: amount > 0 ? "\$$amount" : "-\$${amount.abs()}",
                date: transaction.date,
                icon: budget.icon,
                percentFilled: transaction.balanceProgress / 500,
              ),
            ),
          );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //   key: _scaffoldKey,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: this._currentPageIndex,
        onTap: (value) {
          setState(() {
            this._currentPageIndex = value;
            if (value == 0) {
              // do nothing
              return;
            } else if (value == 1) {
              Navigator.pushReplacementNamed(context, '/budget');
            } else if (value == 2) {
              Navigator.pushReplacementNamed(context, '/funds');
            } else if (value == 3) {
              // go to accounts page
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
      body: RefreshIndicator(
        onRefresh: this._refreshAccounts,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 220.0,
              floating: true,
              pinned: true,
              snap: true,
              elevation: 50,
              backgroundColor: Colors.pink,
              title: Text(
                '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Total Balance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                      ),
                    ),
                    FutureBuilder<bool>(
                      future: this
                          ._hasDataLoaded, // a previously-obtained Future<String> or null
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        Widget content;
                        if (snapshot.hasData) {
                          content = Text(
                            '\$${this._accountTotals}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.0,
                            ),
                          );
                        } else {
                          content = Text(
                            '\$',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.0,
                            ),
                          );
                        }
                        return content;
                      },
                    ),
                  ],
                ),
                background: Image.network(
                  'https://images.pexels.com/photos/443356/pexels-photo-443356.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverList(
              delegate: new SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                List<Widget> children =
                    this._widgetList + this._transactionTiles;
                return children[index];
              },
                  addAutomaticKeepAlives: false,
                  childCount:
                      _widgetList.length + this._transactionTiles.length),
            ),
          ],
        ),
      ),
    );
  }
}
