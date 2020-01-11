import 'package:budget_manager/controller/data_controller.dart';
import 'package:budget_manager/models/account.dart';
import 'package:budget_manager/models/item.dart';
import 'package:budget_manager/utilities/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:dots_indicator/dots_indicator.dart';

import '../networking/plaid.dart';

class AccountsPage extends StatefulWidget {
  @override
  _AccountsPageState createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  @override
  void initState() {
    super.initState();
    this._hasDataLoaded = this._loadData();
  }

  Future<bool> _hasDataLoaded;

  List<Widget> _institutionsWidgets = [];

  int _currentPageIndex = 3;

  String _selectedInstitutionName = "";

  int _selectedItemID;

  Future<bool> _loadData() async {
    bool dataLoaded = await budgetData.hasDataLoaded;
    if (dataLoaded) {
      this._updateView();
    } else {
      print("oof");
    }
    return true;
  }

  Future<void> _createItemAndAccounts(
      Result result, BuildContext context) async {
    bool success = await budgetData.createItemAndAccounts(
        result.token,
        result.accountIDs,
        result.institutionId,
        result.accountNames,
        result.accountMasks,
        result.accountSubtypes);
    if (!success) {
//      final snackBar = SnackBar(
//        content: Text('Account already exists.'),
//      );
//
//      Scaffold.of(context).showSnackBar(snackBar);
    } else {
//      final snackBar = SnackBar(
//        content: Text('Linked Account!.'),
//      );
//
//      Scaffold.of(context).showSnackBar(snackBar);
    }
    await budgetData.getItemsAndAccounts();
    this._updateView();
  }

  Future<void> _refreshAccounts() async {
    await budgetData.refreshAccounts();
    this._updateView();
  }

  Future<void> _removeItem(int itemID) async {
    await budgetData.removeItem(itemID);
    this._updateView();
  }

  Future<void> _removeAccount(int itemID, int accountID) async {
    await budgetData.removeAccount(itemID, accountID);
    this._updateView();
  }

  void _openAccountsSlider(String institutionName, int itemID) {
    setState(() {
      this._selectedInstitutionName = institutionName;
      this._selectedItemID = itemID;
    });
    this._pc.open();
  }

  void _selectAccount(bool selected, int accountID) {
    print("Select accountID: " +
        accountID.toString() +
        " " +
        selected.toString());
    budgetData.allAccounts.firstWhere((a) => a.id == accountID).selected =
        selected;
    setState(() {});
  }

  void _confirmAccounts(int itemID) async {
    this._pc.close();
    await budgetData.selectAccounts(itemID);
    this._updateView();
  }

  void _updateView() {
    this._institutionsWidgets.clear();
    for (Item item in budgetData.items) {
      List<Widget> bankAccountWidgets = [];
      for (Account account in budgetData.selectedAccounts) {
        if (account.itemId == item.id) {
          bankAccountWidgets.add(BankAccountCard(
              itemID: item.id,
              accountID: account.id,
              accountName: account.accountName,
              accountNumber: account.accountMask,
              accountBalance: account.currentBalance.toString(),
              accountType: account.accountSubType,
              institutionColor: item.institutionColor,
              institutionLogo: item.institutionLogo,
              removeAccountCallback: this._removeAccount));
          bankAccountWidgets.add(SizedBox(width: 10));
        }
      }

      this._institutionsWidgets.add(
            InstitutionView(
              itemID: item.id,
              institutionName: item.institutionName,
              institutionColor: item.institutionColor,
              institutionLogo: item.institutionLogo,
              bankAccountWidgets: bankAccountWidgets,
              removeItemCallback: this._removeItem,
              addBankAccountCallback: this._openAccountsSlider,
            ),
          );
      this._institutionsWidgets.add(SizedBox(height: 10));
    }
    setState(() {});
  }

  final PanelController _pc = PanelController();

  @override
  Widget build(BuildContext context) {
    void createItemsPlaidLink(context) async {
      FlutterPlaidApi flutterPlaidApi = FlutterPlaidApi(plaidConfig);
      flutterPlaidApi.launch(context, (Result result) async {
        //    print("RESULTSSSSS: " + result.response.toString());

        this._createItemAndAccounts(result, context);
      });
    }

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
              Navigator.pushReplacementNamed(context, '/budget');
            } else if (value == 2) {
              Navigator.pushReplacementNamed(context, '/funds');
            } else if (value == 3) {
              // do nothing
              return;
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
          child: RefreshIndicator(
            onRefresh: this._refreshAccounts,
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
              padding: EdgeInsets.symmetric(horizontal: 20),
              panel: SlidingAccountsPanel(
                institutionName: this._selectedInstitutionName,
                itemID: this._selectedItemID,
                selectAccountCallback: _selectAccount,
                confirmAccountsCallback: _confirmAccounts,
              ),
              body: Padding(
                padding: const EdgeInsets.fromLTRB(25, 15, 8, 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                          "Bank Accounts",
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(
                          width: 60,
                          height: 50,
                          child: FlatButton.icon(
                              onPressed: () {
                                createItemsPlaidLink(context);
                              },
                              icon: Icon(Icons.add),
                              label: Text("")),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    FutureBuilder<bool>(
                      future: this._hasDataLoaded,
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        Widget content;
                        if (snapshot.hasData) {
                          content = Container(
                            height: 600,
                            width: double.infinity,
                            child: ListView.builder(
                              itemCount: this._institutionsWidgets.length,
                              itemBuilder: (BuildContext c, int i) {
                                return this._institutionsWidgets[i];
                              },
                              padding: EdgeInsets.all(8),
                              scrollDirection: Axis.vertical,
                            ),
                          );
                        } else {
                          content = Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: SizedBox(
                                child: CircularProgressIndicator(),
                                width: 60,
                                height: 60,
                              ),
                            ),
                          );
                        }
                        return content;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SlidingAccountsPanel extends StatelessWidget {
  final String institutionName;
  final int itemID;
  final List<Widget> _bankAccountTiles = [];
  final Function selectAccountCallback;
  final Function confirmAccountsCallback;

  SlidingAccountsPanel(
      {this.institutionName,
      this.itemID,
      this.selectAccountCallback,
      this.confirmAccountsCallback});

  void updateAccountsListView(int itemID) {
    this._bankAccountTiles.clear();
    for (Account account in budgetData.allAccounts) {
      if (account.itemId == itemID) {
        this._bankAccountTiles.add(
              BankAccountTile(
                itemID: this.itemID,
                accountID: account.id,
                accountName: account.accountName,
                accountNumber: account.accountMask,
                accountBalance: account.currentBalance.toString(),
                institutionColor: account.color,
                isSelected: account.selected,
                selectButtonCallback: this.selectAccountCallback,
              ),
            );
        this._bankAccountTiles.add(SizedBox(width: 10));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    this.updateAccountsListView(this.itemID);
    return Column(
      children: <Widget>[
        SizedBox(
          height: 15.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Add ${this.institutionName} Bank Account",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            RaisedButton.icon(
              onPressed: () {
                this.confirmAccountsCallback(this.itemID);
              },
              icon: Icon(Icons.check),
              label: Text("Confirm"),
            ),
          ],
        ),
        SizedBox(
          height: 15.0,
        ),
        Container(
          height: 380,
          width: double.infinity,
          child: ListView.builder(
            itemCount: this._bankAccountTiles.length,
            itemBuilder: (BuildContext c, int i) {
              return this._bankAccountTiles[i];
            },
            scrollDirection: Axis.vertical,
          ),
        ),
      ],
    );
  }
}

class InstitutionView extends StatefulWidget {
  final int itemID;
  final String institutionName;
  final Color institutionColor;
  final Image institutionLogo;
  final List<Widget> bankAccountWidgets;
  final Function removeItemCallback;
  final Function addBankAccountCallback;

  InstitutionView(
      {this.itemID,
      this.institutionName,
      this.institutionColor,
      this.institutionLogo,
      this.bankAccountWidgets,
      this.removeItemCallback,
      this.addBankAccountCallback});

  @override
  _InstitutionViewState createState() => _InstitutionViewState();
}

class _InstitutionViewState extends State<InstitutionView> {
  final ScrollController _controller = ScrollController();

  void _scrollListener() {
    double minPos = this._controller.position.minScrollExtent;
    double maxPos = this._controller.position.maxScrollExtent;
    double range = maxPos - minPos;
    int items = budgetData.selectedAccounts
        .where((a) => a.itemId == this.widget.itemID)
        .length;
    double itemLength = range / items;
    double offset = _controller.offset;
    offset = (offset < minPos) ? minPos : offset;
    offset = (offset >= maxPos) ? maxPos - 10 : offset;
    int itemPos = (offset / itemLength).floor();
    if (this.itemPos != itemPos) {
      setState(() {
        this.itemPos = itemPos;
      });
    }
    return;
  }

  int itemPos = 0;

  @override
  Widget build(BuildContext context) {
    _controller.addListener(_scrollListener);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(this.widget.institutionName,
                      style: TextStyle(fontSize: 20)),
                ),
                DropdownButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.black,
                  ),
                  iconSize: 24,
                  elevation: 16,
                  underline: Container(
                    height: 0,
                    color: Colors.white,
                  ),
                  onChanged: (String newValue) {
                    if (newValue == 'Remove Bank') {
                      _controller.jumpTo(0);
                      this.widget.removeItemCallback(this.widget.itemID);
                    } else if (newValue == 'Add/Remove Accounts') {
                      _controller.jumpTo(0);
                      this.widget.addBankAccountCallback(
                          this.widget.institutionName, this.widget.itemID);
                    }
                  },
                  items: <String>[
                    'Add/Remove Accounts',
                    'Remove Bank',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            Container(
              height: 200,
              width: double.infinity,
              child: ListView.builder(
                itemCount: this.widget.bankAccountWidgets.length,
                itemBuilder: (BuildContext c, int i) {
                  return this.widget.bankAccountWidgets[i];
                },
                padding: EdgeInsets.all(8),
                scrollDirection: Axis.horizontal,
                controller: this._controller,
              ),
            ),
            DotsIndicator(
                dotsCount: budgetData.selectedAccounts
                    .where((a) => a.itemId == this.widget.itemID)
                    .length,
                position: this.itemPos.toDouble()),
          ],
        ),
      ],
    );
  }
}

class BankAccountCard extends StatelessWidget {
  final int itemID;
  final int accountID;
  final String accountName;
  final String accountType;
  final String accountBalance;
  final String accountNumber;
  final Color institutionColor;
  final Image institutionLogo;
  final Function removeAccountCallback;

  BankAccountCard(
      {this.itemID,
      this.accountID,
      this.accountName,
      this.accountType,
      this.accountBalance,
      this.accountNumber,
      this.institutionColor,
      this.institutionLogo,
      this.removeAccountCallback});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 160, minWidth: 280),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [institutionColor, institutionColor.withOpacity(.6)],
          tileMode: TileMode.repeated,
        ),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
              spreadRadius: 0,
              color: institutionColor.withOpacity(.4),
              blurRadius: 4.0,
              offset: Offset.fromDirection(0, 4))
        ],
      ),
      child: Stack(
        children: <Widget>[
          Container(
            constraints: BoxConstraints(minHeight: 160, minWidth: 280),
            alignment: Alignment.bottomRight,
            child: DropdownButton<String>(
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
              ),
              iconSize: 24,
              elevation: 16,
              underline: Container(
                height: 0,
                color: Colors.white,
              ),
              onChanged: (String newValue) {
                if (newValue == 'Delete') {
                  this.removeAccountCallback(this.itemID, this.accountID);
                }
              },
              items: <String>['Delete']
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
              Row(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: this.institutionLogo,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "${this.accountName} (...${this.accountNumber})",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Available Balance: ",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "\$${this.accountBalance}",
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BankAccountTile extends StatelessWidget {
  final int itemID;
  final int accountID;
  final String accountName;
  final String accountBalance;
  final String accountNumber;
  final Color institutionColor;
  final bool isSelected;
  final Function selectButtonCallback;

  BankAccountTile(
      {this.itemID,
      this.accountID,
      this.accountName,
      this.accountBalance,
      this.accountNumber,
      this.institutionColor,
      this.isSelected,
      this.selectButtonCallback});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: GestureDetector(
        onTap: () {
          this.selectButtonCallback(!isSelected, this.accountID);
        },
        child: Container(
          constraints: BoxConstraints(minHeight: 60, minWidth: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [institutionColor, institutionColor.withOpacity(.6)],
              tileMode: TileMode.repeated,
            ),
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: <BoxShadow>[
              BoxShadow(
                spreadRadius: 0,
                color: institutionColor.withOpacity(.4),
                blurRadius: 4.0,
                //     offset: Offset.fromDirection(0, 4)
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          this.accountName.toUpperCase(),
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              letterSpacing: 1.1),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          ".......${this.accountNumber}",
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        SizedBox(
                          height: 25,
                          width: 25,
                          child: Checkbox(
                              value: this.isSelected,
                              onChanged: (newVal) {
                                this.selectButtonCallback(
                                    newVal, this.accountID);
                              }),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "\$${double.parse(this.accountBalance).toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
