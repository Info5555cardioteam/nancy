import 'package:firebase_database/firebase_database.dart';

class GlucoseEntry {
  String key;
  DateTime dateTime;
  double glucose;
  String note;

  GlucoseEntry(this.dateTime, this.glucose, this.note);

  GlucoseEntry.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        dateTime =
        new DateTime.fromMillisecondsSinceEpoch(snapshot.value["date"]),
        glucose = snapshot.value["glucose"].toDouble(),
        note = snapshot.value["note"];

  toJson() {
    return {
      "glucose": glucose,
      "date": dateTime.millisecondsSinceEpoch,
      "note": note
    };
  }
}