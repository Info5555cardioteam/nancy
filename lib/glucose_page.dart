import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'glucose_entry.dart';
import 'glucose_entry_dialog.dart';
import 'glucose_list_item.dart';
import 'glucose_progress_chart.dart';

class glucose_page extends StatefulWidget {
  glucose_page({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _glucose_pageState createState() => new _glucose_pageState();
}

final mainReference = FirebaseDatabase.instance.reference();

class _glucose_pageState extends State<glucose_page> with AutomaticKeepAliveClientMixin<glucose_page>{

  List<GlucoseEntry> glucoseSaves = new List();

  ScrollController _listViewScrollController = new ScrollController();
  double _itemExtent = 50.0;

  _glucose_pageState() {
    mainReference.child("glucose").onChildAdded.listen(_onEntryAdded);
    mainReference.child("glucose").onChildChanged.listen(_onEntryEdited);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Column(
        children: <Widget>[
          new _StatisticCardWrapper(
            child: new Padding(padding: new EdgeInsets.all(8.0),
                child: new GlucoseProgressChart(glucoseSaves)),
            height: 200.0,
          ),

          new ListView.builder(
            shrinkWrap: true,
            reverse: true,
            controller: _listViewScrollController,
            itemCount: glucoseSaves.length,
            itemBuilder: (buildContext, index) {
              //calculating difference
              double difference = index == 0
                  ? 0.0
                  : glucoseSaves[index].glucose - glucoseSaves[index - 1].glucose;

              return new InkWell(
                  onTap: () => _editEntry(glucoseSaves[index]),
                  child: new GlucoseListItem(glucoseSaves[index], difference));
            },
          ),
        ],),
      floatingActionButton: new FloatingActionButton(
        heroTag: "weight",
        onPressed: _openAddEntryDialog,
        tooltip: 'Add new weight entry',
        child: new Icon(Icons.add),
      ),
    );
  }

  void _addGlucoseSave(GlucoseEntry glucoseSave) {
    setState(() {
      glucoseSaves.add(glucoseSave);
      _listViewScrollController.animateTo(
        glucoseSaves.length * _itemExtent,
        duration: const Duration(microseconds: 1),
        curve: new ElasticInCurve(0.01),
      );
    });
  }

  _editEntry(GlucoseEntry glucoseSave) {
    Navigator
        .of(context)
        .push(
      new MaterialPageRoute<GlucoseEntry>(
        builder: (BuildContext context) {
          return new GlucoseEntryDialog.edit(glucoseSave);
        },
        fullscreenDialog: true,
      ),
    )
        .then((newSave) {
      if (newSave != null) {
        setState(() => glucoseSaves[glucoseSaves.indexOf(glucoseSave)] = newSave);
      }
    });
  }

  Future _openAddEntryDialog() async {
    GlucoseEntry save =
    await Navigator.of(context).push(new MaterialPageRoute<GlucoseEntry>(
        builder: (BuildContext context) {
          return new GlucoseEntryDialog.add(
              glucoseSaves.isNotEmpty ? glucoseSaves.last.glucose : 60.0);
        },
        fullscreenDialog: true));
    if (save != null) {
      //_addGlucoseSave(save);
      mainReference.child("glucose").push().set(save.toJson());
    }
  }

  _onEntryAdded(Event event) {
    setState(() {
      glucoseSaves.add(new GlucoseEntry.fromSnapshot(event.snapshot));
      glucoseSaves.sort((we1, we2) => we1.dateTime.compareTo(we2.dateTime));
    });
    _scrollToTop();
  }

  _onEntryEdited(Event event) {
    var oldValue =
    glucoseSaves.singleWhere((entry) => entry.key == event.snapshot.key);
    setState(() {
      glucoseSaves[glucoseSaves.indexOf(oldValue)] =
      new GlucoseEntry.fromSnapshot(event.snapshot);
      glucoseSaves.sort((we1, we2) => we1.dateTime.compareTo(we2.dateTime));
    });
  }

  _scrollToTop() {
    _listViewScrollController.animateTo(
      glucoseSaves.length * _itemExtent,
      duration: const Duration(microseconds: 1),
      curve: new ElasticInCurve(0.01),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _StatisticCardWrapper extends StatelessWidget {
  final double height;
  final Widget child;

  _StatisticCardWrapper({this.height = 120.0, this.child});

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: [
        new Expanded(
          child: new Container(
            height: height,
            child: new Card(child: child),
          ),
        ),
      ],
    );
  }
}