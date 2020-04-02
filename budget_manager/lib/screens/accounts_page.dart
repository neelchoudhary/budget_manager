import 'package:budget_manager/controller/data_controller.dart';
import 'package:budget_manager/redux/actions/item_actions.dart';
import 'package:budget_manager/redux/models/account.dart';
import 'package:budget_manager/redux/models/app_state.dart';
import 'package:budget_manager/redux/models/item.dart';
import 'package:budget_manager/screens/accounts_page_institution_view_model.dart';
import 'package:budget_manager/screens/accounts_page_sliding_panel_view_model.dart';
import 'package:budget_manager/screens/accounts_page_view_model.dart';
import 'package:budget_manager/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

  // Btn2
  void _openAccountsSlider(String institutionName, int itemID) {
    setState(() {
      this._selectedInstitutionName = institutionName;
      this._selectedItemID = itemID;
    });
    _pc.open();
  }

  // Refresh
  Future<void> _refreshAccounts(AccountPageViewModel model) async {
    model.onRefresh();
  }

  void _updateView(AccountPageViewModel model) {
    this._institutionsWidgets.clear();
    for (Item item in model.itemsList.items) {
      this._institutionsWidgets.add(
            InstitutionView(
              itemID: item.id,
              institutionName: item.institutionName,
              institutionColor: item.institutionColor,
              institutionLogo: item.institutionLogo,
              addBankAccountCallback: this._openAccountsSlider,
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
          child: SlidingUpPanel(
            controller: this._pc,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
            minHeight: 0,
            renderPanelSheet: true,
            backdropEnabled: true,
            padding: EdgeInsets.symmetric(horizontal: 20),
            panel: SlidingAccountsPanel(
              institutionName: this._selectedInstitutionName,
              itemID: this._selectedItemID,
              panelController: _pc,
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(25, 15, 8, 8),
              child: StoreConnector<AppState, AccountPageViewModel>(
                distinct: true,
                onInitialBuild: (AccountPageViewModel viewModel) {
                  viewModel.onInit();
                },
                converter: (store) => AccountPageViewModel.fromStore(store),
                builder: (BuildContext bc, AccountPageViewModel viewModel) {
                  if (viewModel.itemsStatus == Status.LOADING) {
                    // Show loading items screen
                    print("LOADING ITEMS");
                    return _loadingContent(viewModel);
                  } else if (viewModel.itemsStatus == Status.SUCCESS) {
                    // Show items
                    print("SUCCESS ITEMS");
                  } else if (viewModel.itemsStatus == Status.ERROR) {
                    // Show error items screen
                  }
                  return _accountPageContent(context, viewModel);
                },
              ),
            ),
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

  // Btn1
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

  Widget _accountPageContent(
      BuildContext context, AccountPageViewModel viewModel) {
    _updateView(viewModel);
    return Column(
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
        RefreshIndicator(
          onRefresh: () async {
            this._refreshAccounts(viewModel);
            //   await Future.delayed(Duration(seconds: 1));
            return;
          },
          child: Container(
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
          ),
        )
      ],
    );
  }

  Widget _loadingContent(AccountPageViewModel viewModel) {
    return Column(
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
          height: 35,
        ),
        SpinKitDoubleBounce(
          color: kColor_pink,
          size: 50.0,
        ),
      ],
    );
  }
}

class InstitutionView extends StatelessWidget {
  final int itemID;
  final String institutionName;
  final Color institutionColor;
  final Image institutionLogo;
  final Function addBankAccountCallback;

  InstitutionView(
      {this.itemID,
      this.institutionName,
      this.institutionColor,
      this.institutionLogo,
      this.addBankAccountCallback});

  // Btn3
  void _removeItem(int itemID, AccountsPageInstitutionViewModel model) {
    model.removeItemButton(model.userID, itemID);
  }

  List<Widget> _updateAccountsView(AccountsPageInstitutionViewModel model) {
    List<Widget> bankAccountWidgets = [];
    for (Account account in model.accountsForInstitution) {
      bankAccountWidgets.add(
        BankAccountCard(
            itemID: this.itemID,
            accountID: account.id,
            accountName: account.accountName,
            accountNumber: account.accountMask,
            accountBalance: account.currentBalance.toString(),
            accountType: account.accountSubType,
            institutionColor: model.item.institutionColor,
            institutionLogo: model.item.institutionLogo,
            model: model),
      );
      bankAccountWidgets.add(SizedBox(width: 10));
    }
    return bankAccountWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      /// TODO why two columns??
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StoreConnector<AppState, AccountsPageInstitutionViewModel>(
            distinct: true,
            converter: (store) =>
                AccountsPageInstitutionViewModel.fromStore(store, this.itemID),
            builder:
                (BuildContext bc, AccountsPageInstitutionViewModel viewModel) {
              if (viewModel.accountsStatus == Status.LOADING) {
                // Show loading accounts screen
                print("LOADING ACCOUNTS1");
                return _loadingContent();
              } else if (viewModel.accountsStatus == Status.SUCCESS) {
                // Show accounts
                print("SUCCESS ACCCOUNTS1");
              } else if (viewModel.accountsStatus == Status.ERROR) {
                // Show error accounts screen
              }

              return _institutionContent(viewModel);
            }),
      ],
    );
  }

  Widget _institutionContent(AccountsPageInstitutionViewModel model) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(this.institutionName, style: TextStyle(fontSize: 20)),
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
                  //   this._controller.jumpTo(0);
                  this._removeItem(this.itemID, model);
                } else if (newValue == 'Add/Remove Accounts') {
                  //     this._controller.jumpTo(0);
                  this.addBankAccountCallback(
                      this.institutionName, this.itemID);
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
        new InstitutionHolderWidget(
          bankAccountWidgets: _updateAccountsView(model),
        ),
      ],
    );
  }

  Widget _loadingContent() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(this.institutionName, style: TextStyle(fontSize: 20)),
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
            ),
          ],
        ),
        Container(
          height: 240,
          width: 300,
          child: SpinKitDoubleBounce(
            color: kColor_pink,
            size: 50.0,
          ),
        ),
      ],
    );
  }
}

class InstitutionHolderWidget extends StatefulWidget {
  final int dotCount;
  final List<Widget> bankAccountWidgets;

  InstitutionHolderWidget({this.bankAccountWidgets})
      : this.dotCount = bankAccountWidgets.length ~/ 2;

  @override
  _InstitutionHolderWidgetState createState() =>
      _InstitutionHolderWidgetState();
}

class _InstitutionHolderWidgetState extends State<InstitutionHolderWidget> {
  final ScrollController _controller = ScrollController();
  int itemPos = 0;

  void _scrollListener() {
    double minPos = this._controller.position.minScrollExtent;
    double maxPos = this._controller.position.maxScrollExtent;
    double range = maxPos - minPos;
    int items = this.widget.dotCount;
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

  @override
  Widget build(BuildContext context) {
    this._controller.addListener(this._scrollListener);
    return Column(
      children: <Widget>[
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
            dotsCount: this.widget.dotCount, position: this.itemPos.toDouble()),
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
  final AccountsPageInstitutionViewModel model;

  BankAccountCard(
      {this.itemID,
      this.accountID,
      this.accountName,
      this.accountType,
      this.accountBalance,
      this.accountNumber,
      this.institutionColor,
      this.institutionLogo,
      this.model});

  // Btn4
  void _removeAccount(int itemID, int accountID) {
    this.model.removeAccountButton(itemID, accountID);
  }

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
                  this._removeAccount(this.itemID, this.accountID);
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
  final PanelController panelController;

  SlidingAccountsPanel(
      {this.institutionName, this.itemID, this.panelController});

  // Btn5
  void _confirmAccounts(int itemID, AccountsPageSlidingPageViewModel model) {
    this.panelController.close();
    model.confirmAccountsButton(itemID);
  }

  void _onOpenSlidePanel(AccountsPageSlidingPageViewModel model) {
    if (this.panelController.isPanelAnimating() &&
        this.panelController.isPanelShown()) {
      model.onOpen();
    }
  }

  @override
  Widget build(BuildContext context) {
    // this.updateAccountsListView(this.itemID);
    return StoreConnector<AppState, AccountsPageSlidingPageViewModel>(
      distinct: true,
      converter: (store) => AccountsPageSlidingPageViewModel.fromStore(store),
      builder: (BuildContext bc, AccountsPageSlidingPageViewModel viewModel) {
        if (viewModel.accountsList.status == Status.LOADING) {
          // Show loading accounts screen
          print("LOADING ACCOUNTS");
          return _loadingContent();
        } else if (viewModel.accountsList.status == Status.SUCCESS) {
          // Show accounts
          print("SUCCESS ACCCOUNTS");
        } else if (viewModel.accountsList.status == Status.ERROR) {
          // Show error accounts screen
        }
        return _slidingAccountsContent(viewModel);
      },
    );
  }

  void updateAccountsListView(
      int itemID, AccountsPageSlidingPageViewModel model) {
    this._bankAccountTiles.clear();
    for (Account account in model.accountsList.allAccounts) {
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
                model: model,
              ),
            );
        this._bankAccountTiles.add(SizedBox(width: 10));
      }
    }
  }

  Widget _slidingAccountsContent(AccountsPageSlidingPageViewModel model) {
    this._onOpenSlidePanel(model);
    updateAccountsListView(itemID, model);
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
                this._confirmAccounts(this.itemID, model);
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

  Widget _loadingContent() {
    return SpinKitRotatingCircle(
      color: kColor_pink,
      size: 50.0,
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
  final AccountsPageSlidingPageViewModel model;

  BankAccountTile(
      {this.itemID,
      this.accountID,
      this.accountName,
      this.accountBalance,
      this.accountNumber,
      this.institutionColor,
      this.isSelected,
      this.model});

  // Chk1
  void _selectAccount(
      bool selected, int accountID, AccountsPageSlidingPageViewModel model) {
    model.toggleAccountCheckbox(accountID, selected);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: GestureDetector(
        onTap: () {
          this._selectAccount(!this.isSelected, this.accountID, this.model);
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
                                this._selectAccount(
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
