import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'Fight.dart';
import 'models.dart';
import 'db_services.dart';
import 'main.dart';

class EventPage extends StatelessWidget {
  String eventId;
  EventPage(this.eventId);

  @override
  build(BuildContext context) {
    NavProvider nav = Provider.of<NavProvider>(context);
    return StreamProvider<Event>.value(
      value: DBService().streamEventData(eventId),
      initialData: new Event(name: 'Loading...',),
      child: EventDetails(),
    );
  }
}

class EventDetails extends StatelessWidget {
  DateFormat formatter = DateFormat('MMMM d, yyyy');

  @override
  build(BuildContext context) {
    NavProvider nav = Provider.of<NavProvider>(context);
    Event event = Provider.of<Event>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
        body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 15.0),
                Text(event.name, style: TextStyle(fontSize: 24.0, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                Text(event.date == null ? '' : formatter.format(event.date.toDate()), style: TextStyle(color: Colors.white, fontSize: 16.0),),
                Text('${event.location}', style: TextStyle(color: Colors.white, fontSize: 16.0)),
                Divider(height: 20.0,color: Colors.grey,),
                Expanded(
                    child: event.fights == null ? Center(child: CircularProgressIndicator(),) : StreamProvider<List<Fight>>.value(
                      value: event.fights,
                      initialData: List<Fight>(),
                      child: Padding(
                        padding: EdgeInsets.only(left: 10, right: 10,),
                        child: FightList(),
                      ),
                    )
                )
              ],
            )
        )
    );
  }
}

class FightList extends StatelessWidget {
  @override
  build(BuildContext context) {
    List<Fight> fightList = Provider.of<List<Fight>>(context);
    NavProvider nav = Provider.of<NavProvider>(context);
    Event event = Provider.of<Event>(context);
    return ListView(
      children: fightList.map((fight) {
        return Column(
          children: <Widget>[
            InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(fight.redFighter['first_name'] ?? '', textAlign: TextAlign.start, style: TextStyle(fontSize: 16.0, color: Colors.white),),
                          Text(fight.redFighter['last_name'] ?? '', textAlign: TextAlign.start, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),),
                          Text('${fight.redFighter['wins'].toInt()}-${fight.redFighter['losses'].toInt()}-${fight.redFighter['draws'].toInt()}', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    Container(
                      width: 110,
                        child: Column(
                            children: <Widget>[
                              Text(fight.weightclass, style: TextStyle(fontSize: 16.0, color: Colors.white), textAlign: TextAlign.center,),
                              fight.rank == 1 ? Text('Main Event', style: TextStyle(color: Colors.white)) : Container(),
                            ]
                        )
                    ),
                    Container(
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(fight.blueFighter['first_name'] ?? '', textAlign: TextAlign.end, style: TextStyle(fontSize: 16.0, color: Colors.white),),
                          Text(fight.blueFighter['last_name'] ?? '', textAlign: TextAlign.end, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),),
                          Text('${fight.blueFighter['wins'].toInt()}-${fight.blueFighter['losses'].toInt()}-${fight.blueFighter['draws'].toInt()}', style: TextStyle(color: Colors.white),),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  nav.updateNavigation(FightPage(fight.id,));
                }
            ),
            Divider(height: 8.0, color: Colors.grey,)
          ],
        );
      }).toList(),
    );
  }
}