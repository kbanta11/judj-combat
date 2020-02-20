import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'db_services.dart';
import 'main.dart';
import 'SignUp.dart';
import 'EventList.dart';

class SignInPage extends StatelessWidget {

  @override
  build(BuildContext context) {
    NavProvider nav = Provider.of<NavProvider>(context);
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
                child: ChangeNotifierProvider<SignInProvider>(
                    create: (context) => SignInProvider(),
                  child: Container(
                    width: 250,
                    child: Consumer<SignInProvider>(
                      builder: (context, signInProvider, child) {
                        print('Error: ${signInProvider.error}');
                        return SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(signInProvider.error ?? '', style: TextStyle(color: Colors.red, fontSize: 18.0)),
                              Text('E-Mail Address', style: TextStyle(fontSize: 18.0, color: Colors.white)),
                              TextField(
                                style: TextStyle(color: Colors.white, fontSize: 16.0),
                                decoration: InputDecoration(border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))),
                                onChanged: (value) {
                                  signInProvider.updateEmail(value);
                                },
                              ),
                              SizedBox(height: 20.0),
                              Text('Password', style: TextStyle(fontSize: 18.0, color: Colors.white)),
                              TextField(
                                obscureText: true,
                                style: TextStyle(color: Colors.white, fontSize: 16.0),
                                onChanged: (value) {
                                  signInProvider.updatePassword(value);
                                },
                              ),
                              SizedBox(height: 20.0,),
                              FlatButton(
                                child: Text('Sign In', style: TextStyle(color: Colors.white),),
                                color: Colors.deepOrange,
                                onPressed: () async {
                                  await signInProvider.login().then((int result) {
                                    if(result == 1)
                                      nav.updateNavigation(EventList());
                                  });
                                },
                              ),
                              SizedBox(height: 20,),
                              FlatButton(
                                  child: Text('Sign Up', style: TextStyle(color: Colors.white)),
                                  color: Colors.deepOrange,
                                  onPressed: () {
                                    nav.updateNavigation(SignUpPage());
                                  }
                              )
                            ],
                          )
                        );
                      }
                    )
                  )
                )
            )
          ),
        ],
      )
    );
  }
}

class SignInProvider extends ChangeNotifier {
  String email;
  String password;
  String error;

  void updateEmail(String value) {
    email = value;
  }

  void updatePassword(String value) {
    password = value;
  }

  Future<int> login() async {
    error = null;
    if(email == null || password == null)
      error = 'Please enter your email and password';

    if(email != null){
      if(email.length <= 0)
        error = 'Please enter your email';
    }

    if(password != null) {
      if(password.length <= 0)
        error = 'Please enter your password';
    }

    print('Email: $email}/Error: $error');
    if(error == null) {
      await DBService().loginWithEmailAndPassword(email, password).catchError((err) {
        PlatformException e = err;
        print('Login Error: $e');
        if(e.code == 'ERROR_INVALID_EMAIL')
          error = 'Please enter a valid email address';
        if(e.code == 'ERROR_USER_NOT_FOUND')
          error = 'Email Not Found! Sign Up Today!';
        if(e.code == 'ERROR_WRONG_PASSWORD')
          error = 'Incorrect Password!';
        return;
      });
    }
    notifyListeners();
    if(error != null)
      return 1;
    return 0;
  }
}