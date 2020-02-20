import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:judj_app/models.dart';

class DBService {
  final Firestore _db = Firestore.instance;

  Future<void> createUserWithEmailAndPassword(String fname, String lname, String email, String password) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password).then((AuthResult authResult) {
      FirebaseUser newUser = authResult.user;
      Firestore.instance.collection('users').document(newUser.uid).setData({
        'userId': newUser.uid,
        'email': email,
        'first_name': fname,
        'last_name': lname
      }).catchError((error) {
        print('Error saving user data: $error');
      });
    });
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() {
    return FirebaseAuth.instance.signOut();
  }

  updateScore(Map data, {String scoreId}) {
    DocumentReference scoreRef;
    if(scoreId != null) {
      scoreRef = Firestore.instance.collection('scores').document(scoreId);
      scoreRef.updateData(data);
    } else {
      scoreRef = Firestore.instance.collection('scores').document();
      scoreRef.setData(data);
    }
  }

  Stream<List<Event>> streamEvents() {
    Query query = _db.collection('events').orderBy('date',);
    return query.snapshots().map((QuerySnapshot docList) {
      return docList.documents.map((doc) => Event.fromFirestore(doc)).toList();
    }).handleError((error) => print('Error creating Event List: $error'));
  }

  Stream<Score> streamFightScore(String fightId, String userId) {
    Stream<QuerySnapshot> fightQuery = _db.collection('scores').where('fight_id', isEqualTo: fightId).where('user_id', isEqualTo: userId).snapshots();
    return fightQuery.map((QuerySnapshot querySnap) {
      return querySnap.documents.map((snap) => Score.fromFirestore(snap)).first;
    });
  }

  Stream<List<Score>> streamScoreList({String fightId, String userId}) {
    Stream<QuerySnapshot> fightQuery =_db.collection('scores').snapshots();
    if(fightId != null)
      fightQuery = _db.collection('scores').where('fight_id', isEqualTo: fightId).snapshots();
    if(userId != null)
      fightQuery = _db.collection('scores').where('user_id', isEqualTo: userId).snapshots();
    return fightQuery.map((QuerySnapshot querySnap) {
      print('QuerySnaps: ${querySnap.documents.length}');
      return querySnap.documents.map((snap) => Score.fromFirestore(snap)).toList();
    });
  }

  Stream<DocumentSnapshot> streamUserDoc(String userId) {
    print('userId: $userId');
    return _db.collection('users').document(userId).snapshots().handleError((error) {
      print('User Doc Stream Error: $error');
    });
  }

  Stream<Event> streamEventData(String eventId) {
    return _db.collection('events').document(eventId).snapshots().map((snapshot) => Event.fromFirestore(snapshot));
  }

  Stream<Fight> streamFightData(String fightId) {
    return _db.collection('fights').document(fightId).snapshots().map((snapshot) => Fight.fromFirestore(snapshot));
  }
}