import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:numberpicker/numberpicker.dart';
import 'glucose_entry.dart';

class GlucoseEntryDialog extends StatefulWidget {
  final double initialGlucose;
  final GlucoseEntry glucoseEntryToEdit;

  GlucoseEntryDialog.add(this.initialGlucose) : glucoseEntryToEdit = null;

  GlucoseEntryDialog.edit(this.glucoseEntryToEdit)
      : initialGlucose = glucoseEntryToEdit.glucose;

  @override
  GlucoseEntryDialogState createState() {
    if (glucoseEntryToEdit != null) {
      return new GlucoseEntryDialogState(glucoseEntryToEdit.dateTime,
          glucoseEntryToEdit.glucose, glucoseEntryToEdit.note);
    } else {
      return new GlucoseEntryDialogState(
          new DateTime.now(), initialGlucose, null);
    }
  }
}

class GlucoseEntryDialogState extends State<GlucoseEntryDialog> {
  DateTime _dateTime = new DateTime.now();
  double _glucose;
  String _note;
  TextEditingController _textController;

  GlucoseEntryDialogState(this._dateTime, this._glucose, this._note);

  Widget _createAppBar(BuildContext context) {
    return new AppBar(
      title: widget.glucoseEntryToEdit == null
          ? const Text("New entry")
          : const Text("Edit entry"),
      actions: [
        new FlatButton(
          onPressed: () {
            Navigator
                .of(context)
                .pop(new GlucoseEntry(_dateTime, _glucose, _note));
          },
          child: new Text('SAVE',
              style: Theme
                  .of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white)),
        ),
      ],
    );
  }


  @override
  void initState() {
    super.initState();
    _textController = new TextEditingController(text: _note);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _createAppBar(context),
      body: new Column(
        children: [
          new ListTile(
            leading: new Icon(Icons.today, color: Colors.grey[500]),
            title: new DateTimeItem(
              dateTime: _dateTime,
              onChanged: (dateTime) => setState(() => _dateTime = dateTime),
            ),
          ),
          new ListTile(
            leading: new Image.asset(
              "assets/scale-bathroom.png",
              color: Colors.grey[500],
              height: 24.0,
              width: 24.0,
            ),
            title: new Text(
              "$_glucose mmol/L",
            ),
            onTap: () => _showWeightPicker(context),
          ),
          new ListTile(
            leading: new Icon(Icons.speaker_notes, color: Colors.grey[500]),
            title: new TextField(
              decoration: new InputDecoration(
                hintText: 'Optional note',
              ),
              controller: _textController,
              onChanged: (value) => _note = value,
            ),
          ),
        ],
      ),
    );
  }

  _showWeightPicker(BuildContext context) {
    showDialog(
      context: context,
      child: new NumberPickerDialog.decimal(
        minValue: 1,
        maxValue: 150,
        initialDoubleValue: _glucose,
        title: new Text("Enter your glucose"),
      ),
    ).then((value) {
      if (value != null) {
        setState(() => _glucose = value);
      }
    });
  }
}

class DateTimeItem extends StatelessWidget {
  DateTimeItem({Key key, DateTime dateTime, @required this.onChanged})
      : assert(onChanged != null),
        date = dateTime == null
            ? new DateTime.now()
            : new DateTime(dateTime.year, dateTime.month, dateTime.day),
        time = dateTime == null
            ? new DateTime.now()
            : new TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
        super(key: key);

  final DateTime date;
  final TimeOfDay time;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Expanded(
          child: new InkWell(
            onTap: (() => _showDatePicker(context)),
            child: new Padding(
                padding: new EdgeInsets.symmetric(vertical: 8.0),
                child: new Text(new DateFormat('EEEE, MMMM d').format(date))),
          ),
        ),
        new InkWell(
          onTap: (() => _showTimePicker(context)),
          child: new Padding(
              padding: new EdgeInsets.symmetric(vertical: 8.0),
              child: new Text('$time')),
        ),
      ],
    );
  }

  Future _showDatePicker(BuildContext context) async {
    DateTime dateTimePicked = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: date.subtract(const Duration(days: 20000)),
        lastDate: new DateTime.now());

    if (dateTimePicked != null) {
      onChanged(new DateTime(dateTimePicked.year, dateTimePicked.month,
          dateTimePicked.day, time.hour, time.minute));
    }
  }

  Future _showTimePicker(BuildContext context) async {
    TimeOfDay timeOfDay =
    await showTimePicker(context: context, initialTime: time);

    if (timeOfDay != null) {
      onChanged(new DateTime(
          date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute));
    }
  }
}