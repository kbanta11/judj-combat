import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Fight.dart';
import 'models.dart';
import 'db_services.dart';
import 'main.dart';

class ScoreList extends StatelessWidget {
  String fightId;
  ScoreList(this.fightId);

  @override
  build(BuildContext context) {
    NavProvider nav = Provider.of<NavProvider>(context);
    return MultiProvider(
      providers: [
        StreamProvider<List<Score>>.value(value: DBService().streamScoreList(fightId: fightId)),
        StreamProvider<Fight>.value(value: DBService().streamFightData(fightId))
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: <Widget>[
            Consumer<Fight>(
              builder: (context, fight, _) {
                return fight == null ? Center(child: CircularProgressIndicator(),) : Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Container(
                          height: 120,
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 15,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    width: 100,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(fight.redFighter['first_name'] ?? '', textAlign: TextAlign.start, style: TextStyle(fontSize: 18.0, color: Colors.white),),
                                        Text(fight.redFighter['last_name'] ?? '', textAlign: TextAlign.start, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),),
                                        Text('${fight.redFighter['wins']}-${fight.redFighter['losses']}-${fight.redFighter['draws']}', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                          width: 100,
                                          child: Column(
                                              children: <Widget>[
                                                Text(fight.weightclass, style: TextStyle(fontSize: 16.0, color: Colors.white)),
                                                fight.rank == 1 ? Text('Main Event', style: TextStyle(color: Colors.white),) : Container(),
                                              ]
                                          )
                                      ),
                                      SizedBox(height: 10.0,),
                                      Container(
                                        height: 50,
                                        width: 150,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.white),
                                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                        ),
                                        child: Center(child: Text('${fight != null ? fight.getAverage('red') : '0'} - ${fight != null ? fight.getAverage('blue') : '0'}', style: TextStyle(color: Colors.white, fontSize: 25.0), textAlign: TextAlign.center,)),
                                      )
                                    ],
                                  ),
                                  Container(
                                    width: 100,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Text(fight.blueFighter['first_name'] ?? '', textAlign: TextAlign.end, style: TextStyle(fontSize: 18.0, color: Colors.white),),
                                        Text(fight.blueFighter['last_name'] ?? '', textAlign: TextAlign.end, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),),
                                        Text('${fight.blueFighter['wins']}-${fight.blueFighter['losses']}-${fight.blueFighter['draws']}', style: TextStyle(color: Colors.white),),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                      ),
                    )
                  ],
                );
              },
            ),
            Divider(height: 5.0, color: Colors.grey,),
            Consumer<List<Score>>(
              builder: (context, scoreList, _) {
                print('Score List: $scoreList');
                return scoreList == null ? Center(child: CircularProgressIndicator(),) : Expanded(
                  child: ListView(
                    children: scoreList.map((score) {
                      return Column(
                        children: <Widget>[
                          ListTile(
                            leading: Text(score.redTotal.toString(), style: TextStyle(color: Colors.white, fontSize: 24.0),),
                            title: StreamProvider<DocumentSnapshot>.value(
                              value: DBService().streamUserDoc(score.userId),
                              child: Consumer<DocumentSnapshot>(
                                builder: (context, doc, _) {
                                  return doc == null ? Container() : Center(
                                    child: Text('${doc.data['first_name']} ${doc.data['last_name']}',
                                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                                    ),
                                  );
                                },
                              ),
                            ),
                            trailing: Text(score.blueTotal.toString(), style: TextStyle(color: Colors.white, fontSize: 24.0),),
                            onTap: () {
                              nav.updateNavigation(FightPage(fightId, userId: score.userId,));
                            },
                          ),
                          Divider(height: 5.0, color: Colors.grey,)
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}