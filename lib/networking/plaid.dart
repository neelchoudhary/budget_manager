library plaid;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FlutterPlaidApi {
  FlutterPlaidApi(Configuration configuration) {
    _configuration = configuration;
  }
  Configuration _configuration;

  launch(BuildContext context, success(Result result)) {
    final _WebViewPage _webViewPage = _WebViewPage();
    _webViewPage._init(_configuration, success, context);

    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return _webViewPage.build(context);
    }));
  }
}

class _WebViewPage {
  String _url;
  Function(Result result) _success;
  BuildContext _context;

  _init(Configuration config, success(Result result), BuildContext context) {
    _success = success;
    _context = context;
    _url = config.plaidBaseUrl +
        '?key=' +
        config.plaidPublicKey +
        '&clientName=' +
        config.clientName +
        '&isWebview=' +
        config.isWebview +
        '&product=' +
        config.products +
        '&isMobile=' +
        config.isMobile +
        '&apiVersion=' +
        config.apiVersion +
        '&selectAccount=' +
        config.selectAccount +
        '&webhook=' +
        config.webhook +
        '&env=' +
        config.plaidEnvironment;
    debugPrint('init plaid: ' + _url);
  }

  _parseUrl(String url) {
    if (url?.isNotEmpty != null) {
      final Uri uri = Uri.parse(url);
      debugPrint('PLAID uri: ' + uri.toString());
      final Map<String, String> queryParams = uri.queryParameters;
      final List<String> segments = uri.pathSegments;
      debugPrint('queryParams: ' + queryParams?.toString());
      debugPrint('segments: ' + segments?.toString());
      _processParams(queryParams, url);
    }
  }

  _processParams(var queryParams, String url) async {
    if (queryParams != null) {
      final String eventName = queryParams['event_name'] ?? 'unknow';
      debugPrint('PLAID Event name:  $eventName');

      if (eventName == 'EXIT' || (url?.contains('/exit?') ?? false)) {
        _closeWebView();
      } else if (eventName == 'HANDOFF') {
        _closeWebView();
      }

      final dynamic token = queryParams['public_token'];
      final dynamic accountID = queryParams['account_id'];
      final String accountType = queryParams['account_type'];
      final String accountSubtype = queryParams['account_subtype'];
      final String accountName = queryParams['account_name'];
      final String institutionId = queryParams['institution_id'];
      final String institutionName = queryParams['institution_name'];

      if (token != null && accountID != null) {
        final Iterable iterable =
            json.decode(queryParams['accounts'].toString());
        var queryList = iterable.toList();
        final List<String> accountIDs = [];
        final List<String> accountNames = [];
        final List<String> accountMasks = [];
        final List<String> accountSubtypes = [];
        for (var accountQuery in queryList) {
          accountIDs.add(accountQuery["_id"]);
          accountNames.add(accountQuery["meta"]["name"]);
          accountMasks.add(accountQuery["meta"]["number"]);
          accountSubtypes.add(accountQuery["subtype"]);
        }
        this._success(Result(
            token: token,
            accountID: accountID,
            accountName: accountName,
            accountType: accountType,
            accountSubtype: accountSubtype,
            institutionId: institutionId,
            institutionName: institutionName,
            accountIDs: accountIDs,
            accountNames: accountNames,
            accountMasks: accountMasks,
            accountSubtypes: accountSubtypes,
            response: queryParams));
      }
    }
  }

  _closeWebView() {
    if (_context != null && Navigator.canPop(_context)) {
      Navigator.pop(_context);
    }
  }

  Widget build(BuildContext context) {
    final webView = WebView(
      initialUrl: _url,
      javascriptMode: JavascriptMode.unrestricted,
      navigationDelegate: (NavigationRequest navigation) {
        if (navigation.url.contains('plaidlink://')) {
          _parseUrl(navigation.url);
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
    );
    return Scaffold(body: webView);
  }
}

class Configuration {
  Configuration(
      {@required this.plaidPublicKey,
      @required this.plaidBaseUrl,
      @required this.plaidEnvironment,
      @required this.plaidClientId,
      @required this.secret,
      @required this.clientName,
      this.webhook = 'https://requestb.in',
      this.products = 'auth', //e.g. auth or auth,income
      this.selectAccount = 'true', //e.g. auth or auth,income
      this.isMobile = 'true',
      this.apiVersion = 'v2',
      this.isWebview = 'true'});
  String plaidPublicKey;
  String plaidBaseUrl;
  String plaidEnvironment;
  String plaidClientId;
  String secret;
  String clientName;
  String webhook;
  String products;
  String selectAccount;
  String apiVersion;
  String isMobile;
  String isWebview;
  String token;
  bool updateMode;
}

class Result {
  Result(
      {@required this.response,
      @required this.token,
      this.accountID,
      this.accountType,
      this.accountSubtype,
      this.accountName,
      this.institutionId,
      this.institutionName,
      this.accountIDs,
      this.accountNames,
      this.accountMasks,
      this.accountSubtypes});
  dynamic response;
  String token;
  String accountID;
  String accountType;
  String accountSubtype;
  String accountName;
  String institutionId;
  String institutionName;
  List<String> accountIDs;
  List<String> accountNames;
  List<String> accountMasks;
  List<String> accountSubtypes;
}
