import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'EventList.dart';
import 'SignIn.dart';
import 'SignUp.dart';
import 'Profile.dart';
import 'models.dart';
import 'db_services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Judj Combat',
      theme: ThemeData(
        primaryColor: Colors.black,
        backgroundColor: Colors.black87,
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepOrange)),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        )
      ),
      home: MultiProvider(
        providers: [
          StreamProvider<FirebaseUser>.value(value: FirebaseAuth.instance.onAuthStateChanged),
          ChangeNotifierProvider<NavProvider>(create: (context) => NavProvider()),
          StreamProvider<List<Event>>.value(value: DBService().streamEvents(),)
        ],
        child: MyHomePage(title: 'Judj Combat'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DBService _db = DBService();
  @override
  Widget build(BuildContext context) {
    NavProvider nav = Provider.of<NavProvider>(context);
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        leading: nav.previousPages.length == 0 ? Container(width: 0.1) : IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            nav.backPage();
          },
        ),
        title: Center(child: Image.asset('assets/images/Judj-Logo_full.png', fit: BoxFit.contain,)),
        actions: <Widget>[
          PopupMenuButton(
            icon: Icon(Icons.menu, color: Colors.white,),
            color: Colors.grey[900],
            onSelected: (_) {
              if(_ == 'profile' && user != null) {
                print(user.uid);
                nav.updateNavigation(ProfilePage(user.uid));
              }
              if(_ == 'logout') {
                _db.logout();
                nav.updateNavigation(SignInPage());
              }
              if(_ == 'signin') {
                nav.updateNavigation(SignInPage());
              }
              if(_ == 'events') {
                nav.updateNavigation(EventList());
              }
            },
            itemBuilder: (context) {
              List<PopupMenuItem> popButtons = List<PopupMenuItem>();
              popButtons.add(PopupMenuItem(
                child: Text('Events', style: TextStyle(color: Colors.white),),
                value: 'events',
              ));
              if(user != null) {
                popButtons.add(PopupMenuItem(
                  child: Text('Profile', style: TextStyle(color: Colors.white),),
                  value: 'profile',
                ));
                popButtons.add(PopupMenuItem(
                  child: Text('Logout', style: TextStyle(color: Colors.white)),
                  value: 'logout',
                ));
              } else {
                popButtons.add(PopupMenuItem(
                  child: Text(
                    'Sign-In', style: TextStyle(color: Colors.white),),
                  value: 'signin',
                ));
              }
              return popButtons;
            },
          )
        ],
      ),
      body: user == null && nav.currentPage is! SignUpPage ? SignInPage() : nav.currentPage// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class NavProvider with ChangeNotifier {
  Widget currentPage = EventList();
  List<Widget> previousPages = List<Widget>();
  bool skipSignIn = false;

  void backPage() {
    Widget lastPage = previousPages.removeLast();
    currentPage = lastPage;
    notifyListeners();
  }

  void userLoggedOut() {
    skipSignIn = true;
    currentPage = EventList();
    notifyListeners();
  }

  void updateNavigation(Widget newPage) {
    if(!(currentPage is SignInPage || currentPage is SignUpPage))
      previousPages.add(currentPage);
    currentPage = newPage;
    notifyListeners();
  }
}
