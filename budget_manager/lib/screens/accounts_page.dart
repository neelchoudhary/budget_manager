import 'package:budget_manager/controller/data_controller.dart';
import 'package:budget_manager/redux/actions/item_actions.dart';
import 'package:budget_manager/redux/models/account.dart';
import 'package:budget_manager/redux/models/app_state.dart';
import 'package:budget_manager/redux/models/item.dart';
import 'package:budget_manager/screens/account_page_view_model.dart';
import 'package:budget_manager/utilities/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
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
  }

  List<Widget> _institutionsWidgets = [];

  int _currentPageIndex = 3;

  String _selectedInstitutionName = "";

  int _selectedItemID;

  Future<void> _createItemAndAccounts(
      Result result, AccountPageViewModel model) async {
    model.addItemsAndAccountsButton(
        result.token,
        model.userID,
        result.institutionId,
        result.accountIDs,
        result.accountNames,
        result.accountMasks,
        result.accountSubtypes);
  }

  Future<void> _refreshAccounts(AccountPageViewModel model) async {
    model.onRefresh();
  }

  void _removeItem(int itemID, AccountPageViewModel model) {
    model.removeItemButton(model.userID, itemID);
  }

  void _removeAccount(int itemID, int accountID, AccountPageViewModel model) {
    model.removeAccountButton(itemID, accountID);
  }

  void _openAccountsSlider(String institutionName, int itemID) {
    setState(() {
      this._selectedInstitutionName = institutionName;
      this._selectedItemID = itemID;
    });
    this._pc.open();
  }

  void _selectAccount(
      bool selected, int accountID, AccountPageViewModel model) {
    model.toggleAccountCheckbox(accountID, selected);
  }

  void _confirmAccounts(int itemID, AccountPageViewModel model) {
    this._pc.close();
    model.confirmAccountsButton(itemID);
  }

  void _updateView(AccountPageViewModel model) {
    this._institutionsWidgets.clear();
    for (Item item in model.itemsList.items) {
      List<Widget> bankAccountWidgets = [];
      for (Account account in model.accountsList.selectedAccounts) {
        if (account.itemID == item.id) {
          bankAccountWidgets.add(
            BankAccountCard(
                itemID: item.id,
                accountID: account.id,
                accountName: account.accountName,
                accountNumber: account.accountMask,
                accountBalance: account.currentBalance.toString(),
                accountType: account.accountSubType,
                institutionColor: item.institutionColor,
                institutionLogo: item.institutionLogo,
                removeAccountCallback: this._removeAccount,
                model: model),
          );
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
              model: model,
              selectedAccounts: model.accountsList.selectedAccounts,
            ),
          );
      this._institutionsWidgets.add(SizedBox(height: 10));
    }
  }

  final PanelController _pc = PanelController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: this._currentPageIndex,
        onTap: (value) {
          setState(() {
            this._currentPageIndex = value;
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
          child: StoreConnector<AppState, AccountPageViewModel>(
            onInitialBuild: (AccountPageViewModel viewModel) {
              viewModel.onInit();
            },
            converter: (store) => AccountPageViewModel.fromStore(store),
            builder: (BuildContext bc, AccountPageViewModel viewModel) {
              if (viewModel.itemsList.status == Status.LOADING) {
                // Show loading items screen
                print("LOADING ITEMS");
              } else if (viewModel.itemsList.status == Status.SUCCESS) {
                // Show items
                print("SUCCESS ITEMS");
              } else if (viewModel.itemsList.status == Status.ERROR) {
                // Show error items screen
              }

              if (viewModel.accountsList.status == Status.LOADING) {
                // Show loading accounts screen
                print("LOADING ACCOUNTS");
              } else if (viewModel.accountsList.status == Status.SUCCESS) {
                // Show accounts
                print("SUCCESS ACCCOUNTS");
              } else if (viewModel.accountsList.status == Status.ERROR) {
                // Show error accounts screen
              }

              if (viewModel.itemsList.status == Status.SUCCESS &&
                  viewModel.accountsList.status == Status.SUCCESS) {
                // FINISHED GETTING
                print("FINISHED GETTING DATA");
              }
              return _accountPageContent(context, viewModel);
            },
          ),
        ),
      ),
    );
  }

  void _createItemsPlaidLink(context, AccountPageViewModel model) async {
    FlutterPlaidApi flutterPlaidApi = FlutterPlaidApi(plaidConfig);
    flutterPlaidApi.launch(context, (Result result) async {
      this._createItemAndAccounts(result, model);
    });
  }

  RefreshIndicator _accountPageContent(
      BuildContext context, AccountPageViewModel viewModel) {
    _updateView(viewModel);
    return RefreshIndicator(
      onRefresh: () async {
        this._refreshAccounts(viewModel);
        //   await Future.delayed(Duration(seconds: 1));
        return;
      },
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
          allAccounts: viewModel.accountsList.allAccounts,
          model: viewModel,
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
                          _createItemsPlaidLink(context, viewModel);
                        },
                        icon: Icon(Icons.add),
                        label: Text("")),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
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
              )
            ],
          ),
        ),
      ),
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
  final List<Account> selectedAccounts;
  final AccountPageViewModel model;

  InstitutionView(
      {this.itemID,
      this.institutionName,
      this.institutionColor,
      this.institutionLogo,
      this.bankAccountWidgets,
      this.removeItemCallback,
      this.addBankAccountCallback,
      this.selectedAccounts,
      this.model});

  @override
  _InstitutionViewState createState() => _InstitutionViewState();
}

class _InstitutionViewState extends State<InstitutionView> {
  final ScrollController _controller = ScrollController();

  void _scrollListener() {
    double minPos = this._controller.position.minScrollExtent;
    double maxPos = this._controller.position.maxScrollExtent;
    double range = maxPos - minPos;
    int items = this
        .widget
        .selectedAccounts
        .where((a) => a.itemID == this.widget.itemID)
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
                      this.widget.removeItemCallback(
                          this.widget.itemID, this.widget.model);
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
                dotsCount: this
                    .widget
                    .selectedAccounts
                    .where((a) => a.itemID == this.widget.itemID)
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
  final AccountPageViewModel model;

  BankAccountCard(
      {this.itemID,
      this.accountID,
      this.accountName,
      this.accountType,
      this.accountBalance,
      this.accountNumber,
      this.institutionColor,
      this.institutionLogo,
      this.removeAccountCallback,
      this.model});

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
                  this.removeAccountCallback(
                      this.itemID, this.accountID, this.model);
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

class SlidingAccountsPanel extends StatelessWidget {
  final String institutionName;
  final int itemID;
  final List<Widget> _bankAccountTiles = [];
  final Function selectAccountCallback;
  final Function confirmAccountsCallback;
  final List<Account> allAccounts;
  final AccountPageViewModel model;

  SlidingAccountsPanel(
      {this.institutionName,
      this.itemID,
      this.selectAccountCallback,
      this.confirmAccountsCallback,
      this.allAccounts,
      this.model});

  void updateAccountsListView(int itemID) {
    this._bankAccountTiles.clear();
    for (Account account in this.allAccounts) {
      if (account.itemID == itemID) {
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
                model: this.model,
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
                this.confirmAccountsCallback(this.itemID, this.model);
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

class BankAccountTile extends StatelessWidget {
  final int itemID;
  final int accountID;
  final String accountName;
  final String accountBalance;
  final String accountNumber;
  final Color institutionColor;
  final bool isSelected;
  final Function selectButtonCallback;
  final AccountPageViewModel model;

  BankAccountTile(
      {this.itemID,
      this.accountID,
      this.accountName,
      this.accountBalance,
      this.accountNumber,
      this.institutionColor,
      this.isSelected,
      this.selectButtonCallback,
      this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: GestureDetector(
        onTap: () {
          this.selectButtonCallback(!isSelected, this.accountID, this.model);
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
                                    newVal, this.accountID, this.model);
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
