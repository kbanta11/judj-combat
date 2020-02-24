import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'db_services.dart';
import 'models.dart';

class ProfilePage extends StatelessWidget {
  String userId;
  ProfilePage(this.userId);

  @override
  build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MultiProvider(
        providers: [
          StreamProvider<DocumentSnapshot>.value(value: DBService().streamUserDoc(userId),),
          StreamProvider<List<Score>>.value(value: DBService().streamScoreList(userId: userId))
        ],
        child: Consumer<DocumentSnapshot>(
          builder: (context, thisUser, _) {
            List<Score> scoreList = Provider.of<List<Score>>(context);
            return thisUser == null ? Container() : !thisUser.exists ? Center(child: CircularProgressIndicator()) : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${thisUser.data['first_name']} ${thisUser.data['last_name']}', style: TextStyle(color: Colors.white, fontSize: 20),),
                          FlatButton(
                            child: Text('Edit Account', style: TextStyle(color: Colors.white),),
                          )
                        ],
                      ),
                      Text('Fights Scored: ${scoreList.length}', style: TextStyle(color: Colors.white, fontSize: 18),),
                    ],
                  )
                ),
                Divider(height: 10.0, color: Colors.grey,),
                scoreList == null ? Container() : Expanded(
                    child: ListView(
                      children: scoreList.map((score) {
                        return Column(
                          children: <Widget>[
                            StreamProvider<Fight>(
                              create: (context) => DBService().streamFightData(score.fightId),
                              child: Consumer<Fight>(
                                builder: (context, fight, _) {
                                  return fight == null ? Container() : InkWell(
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 8, right: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              Text(fight.redFighter['first_name'], style: TextStyle(color: Colors.white, fontSize: 16.0),),
                                              Text(fight.redFighter['last_name'], style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),),
                                            ],
                                          ),
                                          Column(
                                            children: <Widget>[
                                              Text('${fight.weightclass}', style: TextStyle(color: Colors.white, fontSize: 16),),
                                              SizedBox(height: 10.0,),
                                              Text('${score.redTotal} - ${score.blueTotal}', style: TextStyle(color: Colors.white, fontSize: 20),)
                                            ],
                                          ),
                                          Column(
                                            children: <Widget>[
                                              Text(fight.blueFighter['first_name'], style: TextStyle(color: Colors.white, fontSize: 16.0),),
                                              Text(fight.blueFighter['last_name'], style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  );
                                },
                              ),
                            ),
                            Divider(height: 5.0, color: Colors.grey,)
                          ],
                        );
                    }).toList(),
                  )
                )
              ],
            );
          },
        )
      ),
    );
  }
}