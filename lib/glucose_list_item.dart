import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'glucose_entry.dart';

class GlucoseListItem extends StatelessWidget {
  final GlucoseEntry glucoseEntry;
  final double glucoseDifference;

  GlucoseListItem(this.glucoseEntry, this.glucoseDifference);

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: new EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new Expanded(
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Column(
                  children: [
                    new Text(
                      new DateFormat.MMMEd().format(glucoseEntry.dateTime),
                      textScaleFactor: 0.9,
                      textAlign: TextAlign.left,
                    ),
                    new Text(
                      new TimeOfDay.fromDateTime(glucoseEntry.dateTime)
                          .toString(),
                      textScaleFactor: 0.8,
                      textAlign: TextAlign.right,
                      style: new TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                ),
                (glucoseEntry.note == null || glucoseEntry.note.isEmpty)
                    ? new Container(
                  height: 0.0,
                )
                    : new Padding(
                  padding: new EdgeInsets.only(left: 4.0),
                  child: new Icon(
                    Icons.speaker_notes,
                    color: Colors.grey[300],
                    size: 16.0,
                  ),
                ),
              ],
            ),
          ),
          new Text(
            glucoseEntry.glucose.toString(),
            textScaleFactor: 2.0,
            textAlign: TextAlign.center,
          ),
          new Expanded(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new Text(
                  _differenceText(glucoseDifference),
                  textScaleFactor: 1.6,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _differenceText(double weightDifference) {
    if (weightDifference > 0) {
      return "+" + weightDifference.toStringAsFixed(1);
    } else if (weightDifference < 0) {
      return weightDifference.toStringAsFixed(1);
    } else {
      return "-";
    }
  }
}