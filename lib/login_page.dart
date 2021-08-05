import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ifms_form/formulario.dart';
import 'package:ifms_form/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  // f45d27
  // f5851f

  @override
  void initState() {
    // SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.5,
                decoration: BoxDecoration(
                    color: Color.fromRGBO(58, 66, 86, 1.0),
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(90))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Spacer(),
                    Align(
                      alignment: Alignment.center,
                      child: Image(image: AssetImage('assets/logo.png')),
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 32, right: 32),
                        child: Text(
                          'Login',
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ScopedModelDescendant<UserModel>(
                  builder: (context, child, model) {
                if (model.isLoading)
                  return Center(
                    child: CircularProgressIndicator(),
                  );

                return Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(top: 62),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 45,
                          padding: EdgeInsets.only(
                              top: 4, left: 16, right: 16, bottom: 4),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 5)
                              ]),
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.email,
                                color: Colors.grey,
                              ),
                              hintText: 'Registro',
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 45,
                          margin: EdgeInsets.only(top: 32),
                          padding: EdgeInsets.only(
                              top: 4, left: 16, right: 16, bottom: 4),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 5)
                              ]),
                          child: TextField(
                            controller: _passController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.vpn_key,
                                color: Colors.grey,
                              ),
                              hintText: 'Senha',
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16, right: 32),
                            child: GestureDetector(
                              child: Text(
                                'Esqueceu sua senha ?',
                                style: TextStyle(color: Colors.grey),
                              ),
                              onTap: () {
                                if (_emailController.text.isEmpty)
                                  _scaffoldKey.currentState
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        "Insira seu e-mail para recuperação!"),
                                    backgroundColor: Colors.redAccent,
                                    duration: Duration(seconds: 2),
                                  ));
                                else {
                                  model.recoverPass(_emailController.text);
                                  _scaffoldKey.currentState
                                      .showSnackBar(SnackBar(
                                    content: Text("Confira seu e-mail!"),
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    duration: Duration(seconds: 2),
                                  ));
                                }
                              },
                            ),
                          ),
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: () {
                            model.signIn(
                                email: _emailController.text,
                                pass: _passController.text,
                                onSuccess: _onSuccess,
                                onFail: _onFail);
                          },
                          child: Container(
                            height: 45,
                            width: MediaQuery.of(context).size.width / 1.2,
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50))),
                            child: Center(
                              child: Text(
                                'Login'.toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              })
            ],
          ),
        ),
      ),
    );
  }

  void _onSuccess() {
    if ((defaultTargetPlatform == TargetPlatform.iOS) ||
        (defaultTargetPlatform == TargetPlatform.android)) {
      Navigator.pushReplacementNamed(context, '/form');
    } else {
      Navigator.pushReplacementNamed(context, '/list');

      // Some web specific code there
    }
  }

  void _onFail() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Falha ao Entrar!"),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }
}
