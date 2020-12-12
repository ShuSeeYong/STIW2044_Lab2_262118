import 'package:clothhut/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _namecontroller = new TextEditingController();
  final TextEditingController _emcontroller = new TextEditingController();
  final TextEditingController _pscontroller = new TextEditingController();
  final TextEditingController _phcontroller = new TextEditingController();
  String _email = "";
  String _password = "";
  String _name = "";
  String _phone = "";
  bool _passwordVisible = false;
  bool _rememberMe = false;
  bool _termsConditions = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(primarySwatch: Colors.orange),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Registration',
              style: TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
        ),
        body: new SingleChildScrollView(
          child: new Container(
            margin: new EdgeInsets.all(15.0),
            child: new Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: registrationPart(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget registrationPart(BuildContext context) {
    return new Container(
      child: Padding(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "assets/images/logocloth.png",
                  width: 200,
                  height: 200,
                ),
                Container(
                    child: TextFormField(
                  controller: _namecontroller,
                  validator: validateName,
                  onSaved: (String val) {
                    _name = val;
                  },
                  decoration: InputDecoration(
                      labelText: 'Name', icon: Icon(Icons.person)),
                  keyboardType: TextInputType.name,
                  style: TextStyle(fontSize: 16),
                )),
                Container(
                    child: TextFormField(
                  controller: _emcontroller,
                  validator: validateEmail,
                  onSaved: (String val) {
                    _email = val;
                  },
                  decoration: InputDecoration(
                      labelText: 'Email', icon: Icon(Icons.email)),
                  keyboardType: TextInputType.name,
                  style: TextStyle(fontSize: 16),
                )),
                Container(
                    child: TextFormField(
                  controller: _phcontroller,
                  validator: validatePhone,
                  onSaved: (String val) {
                    _phone = val;
                  },
                  decoration: InputDecoration(
                      labelText: 'Mobile', icon: Icon(Icons.phone)),
                  keyboardType: TextInputType.name,
                  style: TextStyle(fontSize: 16),
                )),
                Container(
                    child: TextFormField(
                  controller: _pscontroller,
                  validator: validatePassword,
                  onSaved: (String val) {
                    _password = val;
                  },
                  style: TextStyle(fontSize: 16),
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
                    ),
                  ),
                  obscureText: _passwordVisible,
                )),
                SizedBox(height: 5),
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
                SizedBox(height: 0),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: _termsConditions,
                      onChanged: (bool value) {
                        _onChange1(value);
                      },
                    ),
                    GestureDetector(
                      onTap: _showEULA,
                      child: Text('I have agree the Terms & Conditions',
                          style: TextStyle(fontSize: 17)),
                    )
                  ],
                ),
                SizedBox(height: 10),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80.0)),
                  minWidth: 250,
                  height: 50,
                  child: Text('Register',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  color: Colors.deepOrange,
                  textColor: Colors.black,
                  elevation: 15,
                  onPressed: _newRegister,
                ),
                SizedBox(height: 10),
                GestureDetector(
                    onTap: _onLogin,
                    child: Text('Sign In',
                        style: TextStyle(fontSize: 17))),
              ],
            ),
          )),
    );
  }

  void _onLogin() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
  }

  void _onRegister() async {
    _name = _namecontroller.text;
    _email = _emcontroller.text;
    _password = _pscontroller.text;
    _phone = _phcontroller.text;

    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Registration...");
    await pr.show();
    http.post("http://www.doubleksc.com/clothhut/php/register_user.php", body: {
      "name": _name,
      "email": _email,
      "password": _password,
      "phone": _phone,
    }).then((res) {
      print(res.body);
      if (res.body == "succes") {
        Toast.show(
          "Registration Success. An email has been sent to .$_email. Please check your email for OTP verification. Also check in your spam folder.",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.TOP,
        );
        if (_rememberMe) {
          savepref();
        }
        _onLogin();
      } else {
        Toast.show(
          "Registration Failed",
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

  void _onChange(bool value) {
    setState(() {
      _rememberMe = value;
    });
  }

  Future<void> savepref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _email = _emcontroller.text;
    _password = _pscontroller.text;
    await prefs.setString('email', _email);
    await prefs.setString('password', _password);
    await prefs.setBool('rememberme', true);
  }

  void _newRegister() {
    _name = _namecontroller.text;
    _email = _emcontroller.text;
    _password = _pscontroller.text;
    _phone = _phcontroller.text;
    if (!_termsConditions) {
      Toast.show(
        "Please click the Terms & Conditions",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.TOP,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          backgroundColor: Colors.amber,
          title: new Text(
            "Do you want to register Clothhut App? ",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: new Text(
            "Are you sure?",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Yes",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _onRegister();
              },
            ),
            new FlatButton(
              child: new Text(
                "No",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onChange1(bool value) {
    setState(() {
      _termsConditions = value;
    });
  }

  void _showEULA() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[100],
          title: new Text(
            "End-User License Agreement (EULA) of Clothhut",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.0,
              fontWeight: FontWeight.bold
            ),
          ),
          content: new Container(
            height: 500,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: new SingleChildScrollView(
                    child: RichText(
                        softWrap: true,
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                          ),
                          text:
                              "This End-User License Agreement is a legal agreement between you and Doubleksc. This EULA agreement governs your acquisition and use of our Clothhut software (Software) directly from Doubleksc or indirectly through a Doubleksc authorized reseller or distributor (a Reseller). Please read this EULA agreement carefully before completing the installation process and using the Clothhut software. It provides a license to use the Clothhut software and contains warranty information and liability disclaimers. If you register for a free trial of the Clothhut software, this EULA agreement will also govern that trial. By clicking accept or installing and/or using the Clothhut software, you are confirming your acceptance of the Software and agreeing to become bound by the terms of this EULA agreement. If you are entering into this EULA agreement on behalf of a company or other legal entity, you represent that you have the authority to bind such entity and its affiliates to these terms and conditions. If you do not have such authority or if you do not agree with the terms and conditions of this EULA agreement, do not install or use the Software, and you must not accept this EULA agreement. This EULA agreement shall apply only to the Software supplied by Doubleksc herewith regardless of whether other software is referred to or described herein. The terms also apply to any Doubleksc updates, supplements, Internet-based services, and support services for the Software, unless other terms accompany those items on delivery. If so, those terms apply. This EULA was created by EULA Template for Clothhut. Doubleksc shall at all times retain ownership of the Software as originally downloaded by you and all subsequent downloads of the Software by you. The Software (and the copyright, and other intellectual property rights of whatever nature in the Software, including any modifications made thereto) are and shall remain the property of Doubleksc. Doubleksc reserves the right to grant licences to use the Software to third parties",
                        )),
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close",
                  style: TextStyle(
                    color: Colors.deepOrangeAccent,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  String validateName(String value) {
    String patttern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Name is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Name must alphabet only";
    }
    return null;
  }

  String validatePhone(String value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Phone Number is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Phone Number must be digits";
    }
    return null;
  }

  String validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "Email is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Invalid Email";
    } else {
      return null;
    }
  }

  String validatePassword(String value) {
    if (value.length == 0) {
      return "Password is Required";
    }
    return null;
  }
}
