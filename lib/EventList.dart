import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'EventPage.dart';
import 'models.dart';
import 'db_services.dart';
import 'main.dart';

class EventList extends StatelessWidget {
  final db = DBService();
  DateFormat formatter = DateFormat('MMMM d, yyyy');

  @override
  build(BuildContext context) {
    NavProvider nav = Provider.of<NavProvider>(context);
    List<Event> eventList = Provider.of<List<Event>>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
            child: eventList == null ? Center(child: Text('No Upcoming Events', style: TextStyle(color: Colors.white),)) : Column(
              children: eventList.map((event) {
                String dateString = formatter.format(event.date.toDate()).toString();
                return Column(
                  children: <Widget>[
                    ListTile(
                        title: Text(event.name, style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(formatter.format(event.date.toDate()), style: TextStyle(color: Colors.white, fontSize: 16.0)),
                            Text('${event.location}', style: TextStyle(color: Colors.white, fontSize: 16.0)),
                          ],
                        ),
                        onTap: () {
                          nav.updateNavigation(EventPage(event.id));
                        }
                    ),
                    Divider(height: 5.0, color: Colors.grey,)
                  ],
                );
              }).toList(),
            )
        )
    );
  }
}