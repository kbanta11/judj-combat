import 'package:cloud_firestore/cloud_firestore.dart';
class Event {
  Timestamp date;
  String id;
  String location;
  String name;
  String promoter;
  Stream<List<Fight>> fights;

  Event({this.date, this.name, this.id, this.location, this.promoter, this.fights});

  factory Event.fromFirestore(DocumentSnapshot snap) {
    Map eventData = snap.data;
    return Event(
      date: eventData['date'] ?? '',
      name: eventData['name'] ?? '',
      location: eventData['location'] ?? '',
      id: snap.documentID,
      fights: snap.reference.collection('fights').orderBy('card_rank').snapshots().map((docSnaps) => docSnaps.documents.map((doc) => Fight.fromFirestore(doc)).toList()),
    );
  }
}

class Fight {
  String id;
  String eventId;
  Map eventData;
  String weightclass;
  int weight;
  String weightType;
  Map redFighter;
  Map blueFighter;
  String winner;
  String judge1;
  String judge2;
  String judge3;
  int numRounds;
  int blueTotal;
  int redTotal;
  int numScores;
  int rank;
  Map redScores;
  Map blueScores;

  Fight({
    this.id,
    this.eventId,
    this.eventData,
    this.weightclass,
    this.weight,
    this.weightType,
    this.redFighter,
    this.blueFighter,
    this.winner,
    this.judge1,
    this.judge2,
    this.judge3,
    this.numRounds,
    this.blueTotal,
    this.redTotal,
    this.numScores,
    this.redScores,
    this.blueScores,
    this.rank,
  });

  factory Fight.fromFirestore(DocumentSnapshot snap) {
    Map fightData = snap.data;
    print('${fightData..values.map((value) => value.runtimeType)}');
    return Fight(
      id: snap.documentID,
      eventId: fightData['event_id'],
      eventData: fightData['event_data'],
      weightclass: fightData['weightclass'],
      weight: fightData['weight'].toInt(),
      redFighter: fightData['red_fighter'],
      blueFighter: fightData['blue_fighter'],
      winner: fightData['winner'],
      blueTotal: fightData['blue_total_score'],
      redTotal: fightData['red_total_score'],
      numRounds: fightData['num_rounds'].toInt(),
      numScores: fightData['num_scores'],
      rank: fightData['card_rank'].toInt(),
      redScores: fightData['red_scores'],
      blueScores: fightData['blue_scores'],
    );
  }

  String getAverage(String color, {int round}) {
    Map scoreMap;
    if(color == 'red') {
      scoreMap = redScores;
    } else {
      scoreMap = blueScores;
    }

    if(scoreMap == null)
      return '0';

    if(round != null) {
      double rndAvg;
      Map rndScores = scoreMap[round.toString()];
      int rndTotal = rndScores == null ? 0 : rndScores.values.reduce((sum, next) => sum + next);
      int numScores = rndScores == null ? 1 : rndScores.length;
      rndAvg = rndTotal/numScores;
      return rndAvg.toStringAsFixed(1);
    } else {
      double ttlAvg = 0;
      scoreMap.forEach((key, value) {
        Map roundScores = value;
        int numScores = roundScores.length;
        int totalScore = roundScores.values.reduce((sum, next) => sum + next);
        double roundAvg = totalScore / numScores;
        ttlAvg = ttlAvg + roundAvg;
      });
      return ttlAvg.toStringAsFixed(1);
    }
  }
}

class Score {
  String id;
  String fightId;
  String eventId;
  String userId;
  int numRounds;
  Map redScores;
  Map blueScores;
  int redTotal;
  int blueTotal;
  int rdsScored;

  Score({
    this.id,
    this.fightId,
    this.eventId,
    this.userId,
    this.numRounds,
    this.redScores,
    this.blueScores,
    this.redTotal,
    this.blueTotal,
    this.rdsScored,
  });

  factory Score.fromFirestore(DocumentSnapshot snap) {
    Map scoreData = snap.data;
    return Score(
      id: snap.documentID,
      fightId: scoreData['fight_id'] ?? '',
      eventId: scoreData['event_id'] ?? '',
      userId: scoreData['user_id'] ?? '',
      numRounds: scoreData['num_rounds'] ?? '',
      redScores: scoreData['red_scores'],
      blueScores: scoreData['blue_scores'],
      redTotal: scoreData['red_total'] ?? 0,
      blueTotal: scoreData['blue_total'] ?? 0,
      rdsScored: scoreData['rds_scored'] ?? 0,
    );
  }
}