import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'EventList.dart';
import 'db_services.dart';
import 'main.dart';


class SignUpPage extends StatelessWidget {

  @override
  build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
            child: Container(
                width: 300,
                child: SingleChildScrollView(
                  child: ChangeNotifierProvider(
                    create: (context) => SignUpProvider(),
                    child: SignUpForm(),
                  )
                )
            )
        )
    );
  }
}

class SignUpForm extends StatelessWidget {
  @override
  build(BuildContext context) {
    SignUpProvider signUpProvider = Provider.of<SignUpProvider>(context);
    NavProvider nav = Provider.of<NavProvider>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('First Name', style: TextStyle(fontSize: 18.0, color: Colors.white)),
        TextField(
          style: TextStyle(color: Colors.white, fontSize: 16.0,),
          decoration: InputDecoration(
            errorText: signUpProvider.firstNameError ?? '',
            errorStyle: TextStyle(color: Colors.red),
          ),
          onChanged: (value) {
            signUpProvider.updateValue(fname: value);
          }
        ),
        SizedBox(height: 20.0),
        Text('Last Name', style: TextStyle(fontSize: 18.0, color: Colors.white)),
        TextField(
          style: TextStyle(color: Colors.white, fontSize: 16.0),
          decoration: InputDecoration(
            errorText: signUpProvider.lastNameError ?? '',
            errorStyle: TextStyle(color: Colors.red),
          ),
          onChanged: (value) {
            signUpProvider.updateValue(lname: value);
          }
        ),
        SizedBox(height: 20.0),
        Text('E-Mail Address', style: TextStyle(fontSize: 18.0, color: Colors.white)),
        TextField(
          style: TextStyle(color: Colors.white, fontSize: 16.0),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            errorText: signUpProvider.emailError ?? '',
            errorStyle: TextStyle(color: Colors.red),
          ),
          onChanged: (value) {
            signUpProvider.updateValue(eMail: value);
          }
        ),
        SizedBox(height: 20.0),
        Text('Password', style: TextStyle(fontSize: 18.0, color: Colors.white)),
        TextField(
          decoration: InputDecoration(
            errorText: signUpProvider.passwordError ?? '',
            errorStyle: TextStyle(color: Colors.red),
          ),
          obscureText: true,
          style: TextStyle(color: Colors.white, fontSize: 16.0),
          onChanged: (value) {
            signUpProvider.updateValue(pass: value);
          },
        ),
        SizedBox(height: 20.0),
        Text('Confirm Password', style: TextStyle(fontSize: 18.0, color: Colors.white)),
        TextField(
          decoration: InputDecoration(
            errorText: signUpProvider.confirmPasswordMismatch ?? '',
            errorStyle: TextStyle(color: Colors.red),
          ),
          obscureText: true,
          style: TextStyle(color: Colors.white, fontSize: 16.0),
          onChanged: (value) {
            signUpProvider.updateValue(confirmPass: value);
          },
        ),
        SizedBox(height: 20.0,),
        Center(
            child: FlatButton(
                child: Container(
                  width: 200.0,
                  child: Text('Sign Up', style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
                ),
                color: Colors.deepOrange,
                onPressed: () async {
                  await signUpProvider.submitSignUp().then((_) {
                    nav.updateNavigation(EventList());
                  });
                }
            )
        ),
      ],
    );
  }
}

class SignUpProvider extends ChangeNotifier {
  String firstNameError;
  String lastNameError;
  String emailError;
  String passwordError;
  String confirmPasswordMismatch;
  String firstName;
  String lastName;
  String email;
  String password;
  String confirmPassword;

  String _validateEmail(String value) {
    if (value.isEmpty) {
      return "Please enter email address";
    }

    String pattern = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
        "\\@" +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
        "(" +
        "\\." +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
        ")+";
    RegExp regExp = new RegExp(pattern);

    if (regExp.hasMatch(value)) {
      // So, the email is valid
      return null;
    }
    return 'Please enter a valid email address';
  }

  void updateValue({String fname, String lname, String eMail, String pass, String confirmPass}) {
    if(fname != null)
      firstName = fname;
    if(lname != null)
      lastName = lname;
    if(eMail != null)
      email = eMail;
    if(pass != null)
      password = pass;
    if(confirmPass != null)
      confirmPassword = confirmPass;
  }

  Future<void> submitSignUp() async {
    firstNameError = null;
    lastNameError = null;
    emailError = null;
    passwordError = null;
    confirmPasswordMismatch = null;
    print('Signing up $firstName $lastName, $email');
    //Check if passwords match
    if(password != confirmPassword)
      confirmPasswordMismatch = 'Passwords do not match!';
    //Check password format

    if(password != null) {
      if (password.length < 8)
        passwordError = 'Passwords must be at least 8 characters';
      if (!password.contains(new RegExp(r'[A-Z]')) || !password.contains(new RegExp(r'[a-z]')))
        passwordError = 'Passwords must contain both upper and lower case characters';
      if(!password.contains(new RegExp(r'\d')))
        passwordError = 'Passwords must contain at least one number';
    } else {
      passwordError = 'Password is empty!';
    }
    //Check if email
    if(email == null){
      emailError = 'Please enter email address';
    } else {
      emailError = _validateEmail(email);
    }

    //Check if last name is empty
    if(lastName == null)
      lastNameError = 'Please enter your last name';
    else {
      if (lastName.length <= 0)
        lastNameError = 'Please enter your last name';
    }
    //Check if first name is empty
    if(firstName == null)
      firstNameError = 'Please enter your first name';
    else {
      if (firstName.length <= 0)
        firstNameError = 'Please enter your first name';
    }
    if(firstNameError == null && lastNameError == null && emailError == null && passwordError == null && confirmPasswordMismatch == null) {
      print('Creating user!');
      await DBService().createUserWithEmailAndPassword(firstName, lastName, email, password).catchError((error) {
        PlatformException e = error;
        if(e.code == 'ERROR_EMAIL_ALREADY_IN_USE'){
          emailError = 'Email is already in use!';
          print('email in use');
        }
        return;
      });
      print('DB Service Complete');
    }
    notifyListeners();
  }
}