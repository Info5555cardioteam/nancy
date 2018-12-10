import 'package:firebase_database/firebase_database.dart';

class BPEntry {
  String key;
  DateTime dateTime;
  double systolic;
  double diastolic;
  String note;

  BPEntry(this.dateTime, this.systolic, this.diastolic, this.note);

  BPEntry.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        dateTime =
        new DateTime.fromMillisecondsSinceEpoch(snapshot.value["date"]),
        systolic = snapshot.value["systolic"].toDouble(),
        diastolic = snapshot.value["diastolic"].toDouble(),
        note = snapshot.value["note"];

  toJson() {
    return {
      "systolic": systolic,
      "diastolic": diastolic,
      "date": dateTime.millisecondsSinceEpoch,
      "note": note
    };
  }
}