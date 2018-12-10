import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'bp_entry.dart';

class BPListItem extends StatelessWidget {
  final BPEntry bpEntry;
  final double bpSysDifference;
  final double bpDiaDifference;

  BPListItem(this.bpEntry, this.bpSysDifference,this.bpDiaDifference);

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
                      new DateFormat.MMMEd().format(bpEntry.dateTime),
                      textScaleFactor: 0.9,
                      textAlign: TextAlign.left,
                    ),
                    new Text(
                      new TimeOfDay.fromDateTime(bpEntry.dateTime)
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
                (bpEntry.note == null || bpEntry.note.isEmpty)
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
            bpEntry.systolic.toString()+ "/",
            textScaleFactor: 1.0,
            textAlign: TextAlign.center,
          ),
          new Text(
            bpEntry.diastolic.toString(),
            textScaleFactor: 1.0,
            textAlign: TextAlign.center,
          ),
          new Expanded(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new Text(
                  bpSysDifference.toString(),
                  textScaleFactor: 1.0,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          new Expanded(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new Text(
                  bpDiaDifference.toString(),
                  textScaleFactor: 1.0,
                  textAlign: TextAlign.center,

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