import 'package:clothhut/registerpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emcontroller = TextEditingController();
  String _email = "";
  final TextEditingController _pscontroller = TextEditingController();
  String _password = "";
  bool _rememberMe = false;
  bool _passwordVisible = false;
  SharedPreferences prefs;

  @override
  void initState() {
    loadpref();
    print('Init: $_email');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressAppBar,
        child: Scaffold(
            appBar: AppBar(
              title: Text('Login',
              style: TextStyle(color: Colors.black,
              fontWeight: FontWeight.bold,fontSize:25)),
            ),
            resizeToAvoidBottomPadding: true,
            body: new Container(
              padding: EdgeInsets.all(30.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      "assets/images/logocloth.png",
                       width: 200,
                      height: 200,
                    ),
                    TextField(
                        controller: _emcontroller,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize:18),
                        decoration: InputDecoration(
                            labelText: 'Email', icon: Icon(Icons.email))
                            ),
                    TextField(
                      controller: _pscontroller,
                      style: TextStyle(fontSize:18),
                      decoration: InputDecoration(
                          labelText: 'Password', 
                          icon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),),
                      obscureText: _passwordVisible,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (bool value) {
                            _onChange(value);
                          },
                        ),
                        Text('Remember Me', style: TextStyle(fontSize: 17))
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0)),
                      minWidth: 250,
                      height: 50,
                      child: Text('Login',style: TextStyle(fontSize: 20,
                      fontWeight: FontWeight.bold)),
                      color: Colors.deepOrange,
                      textColor: Colors.black,
                      elevation: 15,
                      onPressed: _onLogin,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                        onTap: _onRegister,
                        child: Text('Register New Account',
                            style: TextStyle(fontSize: 17))),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                        onTap: _onForgot,
                        child: Text('Forgot Password',
                            style: TextStyle(fontSize: 17))),
                  ],
                ),
              ),
            )));
  }

  void _onChange(bool value) {
    setState(() {
      _rememberMe = value;
      savepref(value);
    });
  }

  Future<void> _onLogin() async {
    _email = _emcontroller.text;
    _password = _pscontroller.text;
     ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Login...");
    await pr.show();
    http.post("https://doubleksc.com/clothhut/php/login_user.php", body: {
      "email": _email,
      "password": _password,
    }).then((res) {
      print(res.body);
      if (res.body == "success") {
        Toast.show(
          "Login Success",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.TOP,
        );
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
      } else {
        Toast.show(
          "Login Failed",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.TOP,
        );
      }
    }).catchError((err) {
      print(err);
    });
    await pr.hide();
  }

  Future<bool> _onBackPressAppBar() async {
    SystemNavigator.pop();
    print('Backpress');
    return Future.value(false);
  }

  void _onRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => RegisterPage()));
  }

  void _onForgot() {
    print('Forgot');
  }

  void loadpref() async {
    prefs = await SharedPreferences.getInstance();
    _email = (prefs.getString('email')) ?? '';
    _password = (prefs.getString('password')) ?? '';
    _rememberMe = (prefs.getBool('rememberme')) ?? false;
    if (_email.isNotEmpty) {
      setState(() {
        _emcontroller.text = _email;
        _pscontroller.text = _password;
        _rememberMe = _rememberMe;
      });
    }
  }

  void savepref(bool value) async{
    prefs = await SharedPreferences.getInstance();
    _email = _emcontroller.text;
    _password = _pscontroller.text;
    
     if (value) {
      if (_email.length < 5 && _password.length < 3) {
        print("EMAIL/PASSWORD EMPTY");
        _rememberMe = false;
        Toast.show(
          "Email/password empty!!!",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
        );
        return;
         } else {
        await prefs.setString('email', _email);
        await prefs.setString('password', _password);
        await prefs.setBool('rememberme', value);
        Toast.show(
          "Account will saved",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
        );
        print("SUCCESS");
      }
    } else {
      await prefs.setString('email', '');
      await prefs.setString('password', '');
      await prefs.setBool('rememberme', false);
      setState(() {
        _emcontroller.text = "";
        _pscontroller.text = "";
        _rememberMe = false;
      });
      Toast.show(
          "Perferences unclick",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
        );
  }
}
}