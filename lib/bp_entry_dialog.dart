import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:numberpicker/numberpicker.dart';
import 'bp_entry.dart';

class BPEntryDialog extends StatefulWidget {
  final double initialBP;
  final BPEntry bpEntryToEdit;

  BPEntryDialog.add(this.initialBP) : bpEntryToEdit = null;

  BPEntryDialog.edit(this.bpEntryToEdit)
      : initialBP = bpEntryToEdit.systolic;

  @override
  BPEntryDialogState createState() {
    if (bpEntryToEdit != null) {
      return new BPEntryDialogState(bpEntryToEdit.dateTime,
          bpEntryToEdit.systolic, bpEntryToEdit.diastolic, bpEntryToEdit.note);
    } else {
      return new BPEntryDialogState(
          new DateTime.now(), initialBP, initialBP, null);
    }
  }
}

class BPEntryDialogState extends State<BPEntryDialog> {
  DateTime _dateTime = new DateTime.now();
  double _systolic;
  double _diastolic;
  String _note;
  TextEditingController _textController;

  BPEntryDialogState(this._dateTime, this._systolic, this._diastolic, this._note);

  Widget _createAppBar(BuildContext context) {
    return new AppBar(
      title: widget.bpEntryToEdit == null
          ? const Text("New entry")
          : const Text("Edit entry"),
      actions: [
        new FlatButton(
          onPressed: () {
            Navigator
                .of(context)
                .pop(new BPEntry(_dateTime, _systolic, _diastolic, _note));
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
              "$_systolic mmHg Systolic",
            ),
            onTap: () => _showSystolicPicker(context),
          ),
          new ListTile(
            leading: new Image.asset(
              "assets/scale-bathroom.png",
              color: Colors.grey[500],
              height: 24.0,
              width: 24.0,
            ),
            title: new Text(
              "$_diastolic mmHg Diastolic",
            ),
            onTap: () => _showDiastolicPicker(context),
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

  _showSystolicPicker(BuildContext context) {
    showDialog(
      context: context,
      child: new NumberPickerDialog.decimal(
        minValue: 1,
        maxValue: 250,
        initialDoubleValue: _systolic,
        title: new Text("Enter your Systolic BP"),
      ),
    ).then((value) {
      if (value != null) {
        setState(() => _systolic = value);
      }
    });
  }

  _showDiastolicPicker(BuildContext context) {
    showDialog(
      context: context,
      child: new NumberPickerDialog.decimal(
        minValue: 1,
        maxValue: 150,
        initialDoubleValue: 80.0,
        title: new Text("Enter your Diastolic BP"),
      ),
    ).then((value) {
      if (value != null) {
        setState(() => _diastolic = value);
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