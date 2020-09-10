import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:linto_flutter_client/client/client.dart' show AuthenticationStep;
import 'package:linto_flutter_client/gui/dialogs.dart';
import 'package:linto_flutter_client/gui/utils/flaredisplay.dart';
import 'package:linto_flutter_client/logic/customtypes.dart';
import 'package:linto_flutter_client/logic/maincontroller.dart';
import 'package:linto_flutter_client/gui/mainInterface.dart';


class Login extends StatefulWidget {
  final MainController mainController;
  final AuthenticationStep step;
  const Login({ Key key, this.mainController, this.step : AuthenticationStep.SERVERSELECTION}) : super(key: key);
  @override
  _Login createState() => _Login();
}

// Define a corresponding State class.
// This class holds data related to the form.
class _Login extends State<Login> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>
  MainController _mainController;

  void initState() {
    super.initState();
    _mainController = widget.mainController;
    }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    double lintoWidth = MediaQuery.of(context).size.width * (orientation == Orientation.portrait ? 0.9: 0.45);
    AuthenticationWidget authWidget = AuthenticationWidget(mainController : _mainController, scaffoldContext: context, startingStep: widget.step,);
    return WillPopScope(
      onWillPop: () {},
      child: Scaffold(
        body: Builder(
          builder: (context) =>
              SafeArea(
                  child: Center(
                      widthFactor: 1,
                      heightFactor: 1,
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: RadialGradient(
                                colors: [Color.fromRGBO(255, 255, 255, 1), Color.fromRGBO(213, 231, 242, 1)]
                            )
                        ),
                        padding: EdgeInsets.all(20),
                        child: Flex(
                          direction: orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
                          children: <Widget>[
                            authWidget,

                          ],
                        ),
                      )
                  )
              ),
        ),
        resizeToAvoidBottomInset: true,
      ),
    );
  }
}

/// Authentication Widget
class AuthenticationWidget extends StatefulWidget {
  final MainController mainController;
  final BuildContext scaffoldContext;
  final AuthenticationStep startingStep;


  const AuthenticationWidget({ Key key, this.mainController, this.scaffoldContext, this.startingStep : AuthenticationStep.SERVERSELECTION}) : super(key: key);

  @override
  _AuthenticationWidget createState() => _AuthenticationWidget();
}

class _AuthenticationWidget extends State<AuthenticationWidget> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  MainController _mainController;
  BuildContext _scaffoldContext;
  AuthenticationStep _step;

  // Credentials
  final _serverC = TextEditingController(text: "https://");
  final _serverFocus = FocusNode();

  final _loginC = TextEditingController();
  final _loginFocus = FocusNode();

  final _passwordC = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _passCVisible = false;

  // Direct Connexion
  final _deviceIDC = TextEditingController();
  final _deviceIDFocus = FocusNode();
  String _protocol = "mqtts";
  final _brokerC = TextEditingController();
  final _brokerFocus = FocusNode();
  final _portC = TextEditingController();
  final _portFocus = FocusNode();
  final _mqttLoginC = TextEditingController();
  final _mqttLoginFocus = FocusNode();
  final _mqttPassC = TextEditingController();
  final _mqttPassFocus = FocusNode();
  bool _passMVisible = false;
  final _scopeC = TextEditingController();
  final _scopeFocus = FocusNode();

  bool _remember = true;


  void initState() {
    super.initState();
    _mainController = widget.mainController;
    _scaffoldContext = widget.scaffoldContext;
    WidgetsBinding.instance.addPostFrameCallback((_) =>loadUserPref());
    _step = widget.startingStep;
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    switch(_step) {
      case AuthenticationStep.WELCOME : {
        return welcomeWidget();
      }
      break;

      case AuthenticationStep.DIRECTCONNECT : {
        return directWidget();
      }
      break;
      case AuthenticationStep.SERVERSELECTION : {
        return serverSelectionWidget();
      }
      break;
      // Credentials
      case AuthenticationStep.CREDENTIALS : {
        return credentialsWidget();

      }
      break;
      case AuthenticationStep.AUTHENTICATED : {
        return credentialsWidget();
      }
      break;
      case AuthenticationStep.CONNECTED: {}
    }
  }

  Widget serverSelectionWidget() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Spacer(),
          Expanded(
            child: AutoSizeText("Connect to the application server",
              style: TextStyle(fontSize: 25), maxLines: 2, textAlign: TextAlign.center,),
            flex: 1,
          ),
          Expanded(
            child: Form(
              key :_formKey,
              child: TextFormField(
                controller: _serverC,
                focusNode: _serverFocus,
                inputFormatters: [WhitelistingTextInputFormatter(RegExp(r'[a-zA-Z0-9.://]'))],
                decoration: InputDecoration(
                    labelText: ''
                ),
                validator: (value)  {
                  if (value.isEmpty || value == "https://") {
                    return 'Please enter server url';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (term) {
                  _formKey.currentState.validate();
                  requestServerRoutes(_scaffoldContext, _serverC.value.text);
                },
              ),
            ),
            flex: 2,
          ),

          Spacer(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                color: Color.fromRGBO(60, 187, 242, 0.9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Icon(Icons.input, color: Colors.white,),
                    Text("  OK  ", style: TextStyle(fontSize: 20, color: Colors.white),),
                  ],
                ),
                onPressed: () {requestServerRoutes(_scaffoldContext, _serverC.value.text);},
              ),

            ],
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RichText(
                text: TextSpan(
                    text: "More options",
                    style: TextStyle(color: Colors.blue, fontSize: 20, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = () {
                      setState(() {
                        _step = AuthenticationStep.DIRECTCONNECT;
                      });
                    }
                ),
              ),
            ],
          ),
          Spacer()
        ],
      ),
    );
  }

  Widget credentialsWidget() {
    return Expanded(
        child: Form(
          key: _formKey,
          child: Flex(
            direction: MediaQuery.of(context).orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
            children: <Widget>[
              Container(

                width: MediaQuery.of(context).size.width * (MediaQuery.of(context).orientation == Orientation.portrait ? 0.9 : 0.4),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Login :'
                      ),
                      inputFormatters: [WhitelistingTextInputFormatter(RegExp(r'[a-zA-Z0-9@\-.]'))],
                      validator: (value)  {
                        if (value.isEmpty) {
                          return 'Please enter login';
                        }
                        return null;
                      },
                      controller: _loginC,
                      textInputAction: TextInputAction.next,
                      focusNode: _loginFocus,
                      onFieldSubmitted: (term) {
                        _loginFocus.unfocus();
                        FocusScope.of(context).requestFocus(_passwordFocus);
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passCVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _passCVisible = !_passCVisible;
                              });
                            },
                          )
                      ),
                      validator: (value)  {
                        if (value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                      controller: _passwordC,
                      obscureText: !_passCVisible,
                      focusNode: _passwordFocus,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (term) {
                        if (term.isNotEmpty) {
                          authenticate(_scaffoldContext, _loginC.value.text, _passwordC.value.text);
                        }
                      },
                    ),
                    StatefulBuilder(
                      builder: (context, _setState) => CheckboxListTile(
                          title: Text("Remember me"),
                          value: _remember,
                          onChanged: (bool val) {
                            setState(() {
                              _remember = val;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          color: Color.fromRGBO(60, 187, 242, 0.9),
                          child: Icon(Icons.arrow_back, color: Colors.white,),
                          onPressed: () {
                            setState(() {
                              _step = AuthenticationStep.SERVERSELECTION;
                            });
                          },
                        ),
                        RaisedButton(
                          color: Color.fromRGBO(60, 187, 242, 0.9),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Icon(Icons.input, color: Colors.white,),
                              Text("LOGIN", style: TextStyle(fontSize: 20, color: Colors.white),),
                            ],
                          ),
                          onPressed: () {
                            if (_loginC.value.text.isNotEmpty && _passwordC.value.text.isNotEmpty) {
                              authenticate(_scaffoldContext, _loginC.value.text, _passwordC.value.text);
                            }
                          },
                        ),
                      ],
                    )

                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                ),
                padding: EdgeInsets.all(20),
              )
            ],
          ),
        )
    );
  }

  Widget welcomeWidget() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Spacer(),
          Expanded(
            child: AutoSizeText("Welcome,",
              style: TextStyle(fontSize: 40), maxLines: 2, textAlign: TextAlign.center,),
            flex: 1,
          ),
          Expanded(
            child: AutoSizeText("We will guide you through the setup of your smart assistant.",
              style: TextStyle(fontSize: 30), maxLines: 2, textAlign: TextAlign.center,),
            flex: 1,
          ),

          RaisedButton(
            color: Color.fromRGBO(60, 187, 242, 0.9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Icon(Icons.settings, color: Colors.white,),
                AutoSizeText("Get started",
                  style: TextStyle(fontSize: 25), maxLines: 2, textAlign: TextAlign.center,)
              ],
            ),
            onPressed: () async {
              if (! await _mainController.requestPermissions()) {
                displaySnackMessage(context, "Permissions missing");
                return;
              }
              setState(() {
                _step = AuthenticationStep.SERVERSELECTION;
              });
            },
          ),

            Spacer()
        ],
      ),
    );
  }

  Widget directWidget() {
    return Expanded(
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              AutoSizeText("Directly connect to your single application.",
                style: TextStyle(fontSize: 20), maxLines: 2, textAlign: TextAlign.center,),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'This device identifies as (unique ID):'
                ),
                inputFormatters: [WhitelistingTextInputFormatter(RegExp(r'[a-zA-Z0-9\-.@]'))],
                validator: (value)  {
                  if (value.isEmpty) {
                    return 'Please enter a SN';
                  }
                  return null;
                },
                controller: _deviceIDC,
                textInputAction: TextInputAction.next,
                focusNode: _deviceIDFocus,
                onFieldSubmitted: (term) {
                  _deviceIDFocus.unfocus();
                  FocusScope.of(context).requestFocus(_brokerFocus);
                },
              ),
              Row(
                children : [
                  Flexible(
                    flex: 5,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        isDense: true,
                        hasFloatingPlaceholder: true,
                        alignLabelWithHint: true,
                        border: InputBorder.none,
                      ),
                      value: _protocol,
                      items: <String>['mqtt', 'mqtts'].map((String value) {
                        return new DropdownMenuItem(
                            value: value,
                            child: new Text(value)
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _protocol = value;
                        });
                      },
                    ),
                  ),
                  Flexible(
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Connexion server'
                      ),
                      inputFormatters: [WhitelistingTextInputFormatter(RegExp(r'[a-zA-Z0-9:\-.@]'))],
                      validator: (value)  {
                        if (value.isEmpty) {
                          return 'Please enter url';
                        }
                        return null;
                      },
                      controller: _brokerC,
                      textInputAction: TextInputAction.next,
                      focusNode: _brokerFocus,
                      onFieldSubmitted: (term) {
                        _serverFocus.unfocus();
                        FocusScope.of(context).requestFocus(_portFocus);
                      },
                    ),
                    flex: 12,
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Flexible(
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: "port"
                      ),
                      controller: _portC,
                      focusNode: _portFocus,
                      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      onFieldSubmitted: (term) {
                        _portFocus.unfocus();
                        FocusScope.of(context).requestFocus(_mqttLoginFocus);
                      },
                    ),
                    flex: 4
                  ),
                ]
              ),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'MQTT Login',

                ),
                inputFormatters: [WhitelistingTextInputFormatter(RegExp(r'[a-zA-Z0-9:\-.@]'))],
                validator: (value)  {
                  if (value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
                controller: _mqttLoginC,
                focusNode: _mqttLoginFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (term) {
                  _mqttLoginFocus.unfocus();
                  FocusScope.of(context).requestFocus(_mqttPassFocus);

                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'MQTT Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passMVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passMVisible = !_passMVisible;
                      });
                    },
                  )
                ),
                validator: (value)  {
                  if (value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
                controller: _mqttPassC,
                obscureText: !_passMVisible,
                focusNode: _mqttPassFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (term) {
                  _mqttPassFocus.unfocus();
                  FocusScope.of(context).requestFocus(_scopeFocus);
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Application ID',
                ),
                inputFormatters: [WhitelistingTextInputFormatter(RegExp(r'[a-zA-Z0-9:\-.@]'))],
                validator: (value)  {
                  if (value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
                controller: _scopeC,
                focusNode: _scopeFocus,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (term) {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                },
              ),
              StatefulBuilder(
                builder: (context, _setState) => CheckboxListTile(
                    title: Text("Remember me"),
                    value: _remember,
                    onChanged: (bool val) {
                      setState(() {
                        _remember = val;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    color: Color.fromRGBO(60, 187, 242, 0.9),
                    child: Icon(Icons.arrow_back, color: Colors.white,),
                    onPressed: () {
                      setState(() {
                        _step = AuthenticationStep.SERVERSELECTION;
                      });
                    },
                  ),
                  RaisedButton(
                    color: Color.fromRGBO(60, 187, 242, 0.9),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Icon(Icons.input, color: Colors.white,),
                        Text("     Connect     ", style: TextStyle(fontSize: 20, color: Colors.white),),
                      ],
                    ),
                    onPressed: () {
                      directConnect(_scaffoldContext);
                    },
                  ),

                ],
              ),
            ],
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
        )
    );
  }

  void loadUserPref() {
    if (_mainController.userPreferences.clientPreferences['keep_info']) {
      var prefs = _mainController.userPreferences.clientPreferences;
      setState(() {
        _serverC.text = prefs["credentials"]["last_server"];
        _loginC.text = prefs["credetials"]["last_login"];
        _passwordC.text = _mainController.userPreferences.passwordC;

        _deviceIDC.text = prefs["direct"]["serial_number"];
        _brokerC.text = prefs["direct"]["broker_ip"];
        _portC.text = prefs["direct"]["broker_port"];
        _mqttLoginC.text = prefs["direct"]["broker_id"];
        _mqttPassC.text = _mainController.userPreferences.passwordM;
        _scopeC.text = prefs["direct"]["scope"];

      });
    }
  }

  void requestServerRoutes(BuildContext context, String server) async {
    List<dynamic> routes;
    try {
      routes = await _mainController.client.requestRoutes(server.trim());
    } on ClientErrorException catch(error) {
      displaySnackMessage(context, error.error.toString(), isError: true);
      return;
    }
    if (routes.length == 1) {
      _mainController.client.setAuthRoute(routes[0]);
    } else {
      var selected = await showRoutesDialog(context, "Select authentication method", routes);
      _mainController.client.setAuthRoute(selected);
    }
    setState(() {
      _step = AuthenticationStep.CREDENTIALS;
    });
  }

  /// Update connexion information.

  void updateConnPrefs() {
    var prefs = _mainController.userPreferences.clientPreferences;
    prefs["first_login"] = false;
    prefs["keep_info"] = _remember;
    if(_step == AuthenticationStep.CREDENTIALS)  {
      prefs["auth_cred"] = true;
      var credPrefs = prefs["credentials"];
      credPrefs["last_server"] = _serverC.text;
      credPrefs["last_login"] = _loginC.text;
      credPrefs["last_route"] = _mainController.client.authRoute;
      credPrefs["last_scope"] = _mainController.client.currentScope;
      _mainController.userPreferences.updatePasswordC(_passwordC.value.text);
    } else {
      prefs["auth_cred"] = false;
      var dirPrefs = prefs["direct"];
      dirPrefs["serial_number"] = _deviceIDC.text;
      dirPrefs["broker_ip"] = _brokerC.text;
      dirPrefs["broker_port"] = _portC.text;
      dirPrefs["broker_id"] = _mqttLoginC.text;
      dirPrefs["scope"] = _scopeC.text;
      _mainController.userPreferences.updatePasswordM(_passwordC.value.text);
    }

    _mainController.userPreferences.updatePrefs();
  }

  /// Submit credential to the authentication server.
  void authenticate(BuildContext scaffoldContext, String login, String password) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    // 1- Request authentification token
    try {
      await _mainController.client.requestAuthentification(login.trim(), password);
    } on ClientErrorException catch(error) {
      displaySnackMessage(scaffoldContext, error.error.toString(), isError: true);
      return;
    }
    // 2- Request scopes
    var scopes;
    try {
      scopes = await _mainController.client.requestScopes();
    } on ClientErrorException catch(error) {
      displaySnackMessage(scaffoldContext, error.error.toString(), isError: true);
      return;
    }
    print(scopes);

    // 3 Select scope
    var selectedScope = await showScopeDialog(scaffoldContext, "Select application", scopes);

    // 4- Establish connexion to broker
    var success = await _mainController.client.setScope(selectedScope);
    if (!success) {
      displaySnackMessage(scaffoldContext, 'Could not connect to broker', isError: true);
      return;
    }

    if (_remember) {
      updateConnPrefs();
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => MainInterface(mainController: _mainController,)));
  }

  void displaySnackMessage(BuildContext context, String message, {bool isError: false}) async {
    final snackBarError = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Color(0x3db5e4),
    );
    Scaffold.of(context).showSnackBar(snackBarError);
  }

  Future<void> directConnect(BuildContext scaffoldContext) async{
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    bool res = await _mainController.client.directConnexion(_brokerC.value.text,
                                                            _portC.value.text,
                                                            _mqttLoginC.value.text,
                                                            _mqttPassC.value.text,
                                                            _deviceIDC.value.text,
                                                            _scopeC.value.text,
                                                            _protocol == "mqtts");
    if (!res) {
      displaySnackMessage(context, "Could not connect to broker using those informations.", isError: true);
    } else {
      updateConnPrefs();
      Navigator.push(context, MaterialPageRoute(builder: (context) => MainInterface(mainController: _mainController,)));
    }

  }
}