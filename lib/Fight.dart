import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ScoreList.dart';
import 'EventPage.dart';
import 'models.dart';
import 'main.dart';
import 'db_services.dart';

class FightPage extends StatelessWidget {
  final String fightId;
  final String userId;
  FightPage(this.fightId, {this.userId});

  @override
  build(BuildContext context) {
    FirebaseUser currentUser = Provider.of<FirebaseUser>(context);
    return MultiProvider(
      providers: [
        StreamProvider<Fight>.value(
          value: DBService().streamFightData(fightId),
        ),
        StreamProvider<Score>.value(
          value: DBService().streamFightScore(fightId, userId != null ? userId : currentUser.uid).handleError((error) {
            print('Score stream error: $error');
          }),
        )
      ],
      child: FightDetails(),
    );
  }
}

class FightDetails extends StatelessWidget {
  @override
  build(BuildContext context) {
    Fight fight = Provider.of<Fight>(context);
    Score score = Provider.of<Score>(context);
    NavProvider nav = Provider.of<NavProvider>(context);
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
        body: Center(
            child: fight == null ? CircularProgressIndicator() : Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Container(
                      height: 160,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: score == null || score.userId == user.uid ? Text('Your Scorecard', style: TextStyle(color: Colors.white, fontSize: 20.0),) : StreamProvider<DocumentSnapshot>.value(
                                    value: DBService().streamUserDoc(score.userId),
                                    child: Consumer<DocumentSnapshot>(
                                      builder: (context, doc, _) {
                                        return doc == null ? Container() : Text('${doc.data['first_name'] ?? ''} ${doc.data['last_name'] ?? ''} Scorecard', style: TextStyle(color: Colors.white, fontSize: 20.0),);
                                      },
                                    )
                                ),
                              ),
                              FlatButton(
                                  child: Text('Back to Event', style: TextStyle(color: Colors.white),),
                                  onPressed: () {
                                    nav.updateNavigation(EventPage(fight.eventId));
                                  }
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: 120,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(fight.redFighter['first_name'] ?? '', textAlign: TextAlign.start, style: TextStyle(fontSize: 18.0, color: Colors.white),),
                                    Text(fight.redFighter['last_name'] ?? '', textAlign: TextAlign.start, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),),
                                    Text('${fight.redFighter['wins'].toInt()}-${fight.redFighter['losses'].toInt()}-${fight.redFighter['draws'].toInt()}', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                              Container(
                                  width: 110,
                                  child: Column(
                                      children: <Widget>[
                                        Text(fight.weightclass, style: TextStyle(fontSize: 16.0, color: Colors.white,), textAlign: TextAlign.center,),
                                        fight.rank == 1 ? Text('Main Event', style: TextStyle(color: Colors.white),) : Container(),
                                      ]
                                  )
                              ),
                              Container(
                                width: 120,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Text(fight.blueFighter['first_name'] ?? '', textAlign: TextAlign.end, style: TextStyle(fontSize: 18.0, color: Colors.white),),
                                    Text(fight.blueFighter['last_name'] ?? '', textAlign: TextAlign.end, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),),
                                    Text('${fight.blueFighter['wins'].toInt()}-${fight.blueFighter['losses'].toInt()}-${fight.blueFighter['draws'].toInt()}', style: TextStyle(color: Colors.white),),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Container(
                                width: 30,
                                child: Text(score != null ? score.redTotal.toString() : '0', style: TextStyle(fontSize: 26.0, color: Colors.white),),
                              ),
                              Container(
                                height: 40,
                                width: 140,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                                child: Center(child: Text('${fight != null ? fight.getAverage('red') : '0'} - ${fight != null ? fight.getAverage('blue') : '0'}', style: TextStyle(color: Colors.white, fontSize: 25.0), textAlign: TextAlign.center,)),
                              ),
                              Container(
                                width: 30,
                                child: Text(score != null ? score.blueTotal.toString() : '0', style: TextStyle(fontSize: 26.0, color: Colors.white),),
                              ),
                            ],
                          ),
                        ],
                      )
                    ),
                  ),
                  Divider(height: 10.0, color: Colors.grey,),
                  Expanded(
                    child: ListView(
                      children: List<int>.generate(fight.numRounds, (i) => i + 1).map((num) {
                        return Column(
                          children: <Widget>[
                            ChangeNotifierProvider<RoundProvider>(
                                create: (context) => RoundProvider(),
                                child: Round(roundNum: num, fightId: fight.id,)
                            ),
                            Divider(height: 5.0, color: Colors.grey,),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: FlatButton(
                          child: Text('See Fan Scores', style: TextStyle(color: Colors.grey[900], fontSize: 20),),
                          color: Colors.deepOrange,
                          onPressed: () {
                            nav.updateNavigation(ScoreList(fight.id));
                          },
                        ),
                      )
                    ],
                  ),
                ]
            )
        )
    );
  }
}

class Round extends StatelessWidget {
  int roundNum;
  String fightId;
  Round({this.roundNum, this.fightId});

  @override
  build(BuildContext context) {
    RoundProvider roundState = Provider.of<RoundProvider>(context);
    Fight fight = Provider.of<Fight>(context);
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    Score score = Provider.of<Score>(context);
    bool _hideRedArrow = (roundState.winColor == 'red' || score == null) || roundState.getScore(score, 'red', roundNum) == '10';
    bool _hideBlueArrow = (roundState.winColor == 'blue' || score == null) || roundState.getScore(score, 'blue', roundNum) == '10';

    Widget redCheckbox = Container();
    Widget blueCheckbox = Container();
    if(score == null || user.uid == score.userId) {
      redCheckbox = roundState.winColor == 'red' || roundNum > (score != null ? score.rdsScored : 0) + 1 || roundState.getScore(score, 'red', roundNum) == '10' ? IconButton(
        icon: Icon(Icons.check_box, color: Colors.red,),
        iconSize: 40.0,
      ) : IconButton(
          icon: Icon(Icons.check_box, color: Colors.grey[600],),
          iconSize: 40.0,
          onPressed: () {
            roundState.scoreRoundWinner(
              chosenColor: 'red',
              numRnds: fight.numRounds,
              rdNum: roundNum,
              fightID: fightId,
              userId: user.uid,
              eventId: fight.eventId,
              score: score,
            );
          }
      );

      blueCheckbox = roundState.winColor == 'blue' || roundNum > (score != null ? score.rdsScored : 0) + 1 || roundState.getScore(score, 'blue', roundNum) == '10' ? IconButton(
        icon: Icon(Icons.check_box, color: Colors.blue,),
        iconSize: 40.0,
      ) : IconButton(
          icon: Icon(Icons.check_box, color: Colors.grey[600],),
          iconSize: 40.0,
          onPressed: () {
            roundState.scoreRoundWinner(
              chosenColor: 'blue',
              numRnds: fight.numRounds,
              rdNum: roundNum,
              fightID: fightId,
              userId: user.uid,
              eventId: fight.eventId,
              score: score,
            );
          }
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(width: 10),
        Container(
            width: 25,
            child: Text(roundState.getScore(score, 'red', roundNum) == 'null' ? '10' : roundState.getScore(score, 'red', roundNum), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))
        ),
        Container(
          height: 75,
          width: 45,
          child: score == null || score.userId != user.uid || _hideRedArrow || roundNum > (score != null ? score.rdsScored : 0) + 1 ? Container() : IconButton(
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
              onPressed: () {
                roundState.decreaseScore(score, roundNum, 'red');
              }
          )
        ),
        Container(
            height: 75,
            width: 45,
            child: redCheckbox,
        ),
        Container(
          width: 80,
          child: Center(
              child: Column(
                children: <Widget>[
                  Text('Rd ${roundNum}', style: TextStyle(fontSize: 20, color: Colors.white)),
                  SizedBox(height: 5.0),
                  Text('(${fight.getAverage('red', round: roundNum) ?? '0'} - ${fight.getAverage('blue', round: roundNum) ?? '0'})',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              )
          ),
        ),
        Container(
          height: 75,
          width: 45,
          child: blueCheckbox,
        ),
        Container(
            height: 75,
            width: 45,
            child: score == null || score.userId != user.uid || _hideBlueArrow || roundNum > (score != null ? score.rdsScored : 0) + 1 ? Container() : IconButton(
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
                onPressed: () {
                  roundState.decreaseScore(score, roundNum, 'blue');
                }
            )
        ),
        Container(
          width: 25,
          child: Text(roundState.getScore(score, 'blue', roundNum) == 'null' ? '10' : roundState.getScore(score, 'blue', roundNum), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        SizedBox(width: 10),
      ],
    );
  }
}

class RoundProvider extends ChangeNotifier {
  String winColor;
  int redScore = 10;
  int blueScore = 10;

  String getScore(Score score, String color, int roundNum) {
    if(score == null)
      return '0';
    if(color == 'red') {
      Map scoreMap = score.redScores;
      int roundScore = scoreMap[roundNum.toString()];
      return roundScore.toString();
    } else {
      Map scoreMap = score.blueScores;
      int roundScore = scoreMap[roundNum.toString()];
      return roundScore.toString();
    }
  }

  void decreaseScore(Score score, int roundNum, String color) {
    DateTime updateDate = DateTime.now();
    Map<String, dynamic> newScoreData = {'date_updated': updateDate};
    if(color == 'red') {
      if(redScore - 1 > 6)
        redScore = redScore - 1;
      score.redScores[roundNum.toString()] = redScore;
      newScoreData['red_scores'] = score.redScores;
    } else {
      if(blueScore - 1 > 6)
        blueScore = blueScore - 1;
      score.blueScores[roundNum.toString()] = blueScore;
      newScoreData['blue_scores'] = score.blueScores;
    }
    DBService().updateScore(newScoreData, scoreId: score.id);
    notifyListeners();
  }

  void scoreRoundWinner({String chosenColor, int numRnds, int rdNum, String fightID, Score score, String userId, String eventId, }) {
    winColor = chosenColor;
    if(chosenColor == 'red') {
      blueScore = 9;
      redScore = 10;
    }
    if(chosenColor == 'blue') {
      redScore = 9;
      blueScore = 10;
    }
    if(score != null) {
      Map redScores = score.redScores;
      redScores[rdNum.toString()] = redScore;
      Map blueScores = score.blueScores;
      blueScores[rdNum.toString()] = blueScore;
      int redTotal = redScores.values.reduce((sum, next) => sum + next);
      int blueTotal = blueScores.values.reduce((sum, next) => sum + next);
      Map<String, dynamic> data = {
        'date_updated': DateTime.now(),
        'rds_scored': redScores.length,
        'red_total': redTotal,
        'red_scores': redScores,
        'blue_total': blueTotal,
        'blue_scores': blueScores,
      };
      DBService().updateScore(data, scoreId: score.id);
    } else {
      Map<String, dynamic> data = {
        'date_updated': DateTime.now(),
        'event_id': eventId,
        'user_id': userId,
        'fight_id': fightID,
        'rds_scored': rdNum,
        'num_rounds': numRnds,
        'red_total': redScore,
        'red_scores': {
          rdNum.toString(): redScore,
        },
        'blue_total': blueScore,
        'blue_scores': {
          rdNum.toString(): blueScore,
        }
      };
      DBService().updateScore(data,);
    }
    notifyListeners();
  }
}

class ScoreProvider extends ChangeNotifier {

}