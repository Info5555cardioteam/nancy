import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'weight_entry.dart';
import 'weight_entry_dialog.dart';
import 'weight_list_item.dart';
import 'weight_progress_chart.dart';


class weight_page extends StatefulWidget {
  weight_page({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _weight_pageState createState() => new _weight_pageState();
}

final mainReference = FirebaseDatabase.instance.reference();

class _weight_pageState extends State<weight_page> with AutomaticKeepAliveClientMixin<weight_page>{
  List<WeightEntry> weightSaves = new List();
  ScrollController _listViewScrollController = new ScrollController();
  double _itemExtent = 50.0;

  _weight_pageState() {
    mainReference.child("weight").onChildAdded.listen(_onEntryAdded);
    mainReference.child("weight").onChildChanged.listen(_onEntryEdited);
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
                child: new WeightProgressChart(weightSaves)),
            height: 200.0,
          ),

          new ListView.builder(
            shrinkWrap: true,
            reverse: true,
            controller: _listViewScrollController,
            itemCount: weightSaves.length,
            itemBuilder: (buildContext, index) {
              //calculating difference
              double difference = index == 0
                  ? 0.0
                  : weightSaves[index].weight - weightSaves[index - 1].weight;

              return new InkWell(
                  onTap: () => _editEntry(weightSaves[index]),
                  child: new WeightListItem(weightSaves[index], difference));
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

  void _addWeightSave(WeightEntry weightSave) {
    setState(() {
      weightSaves.add(weightSave);
      _listViewScrollController.animateTo(
        weightSaves.length * _itemExtent,
        duration: const Duration(microseconds: 1),
        curve: new ElasticInCurve(0.01),
      );
    });
  }

  _editEntry(WeightEntry weightSave) {
    Navigator
        .of(context)
        .push(
      new MaterialPageRoute<WeightEntry>(
        builder: (BuildContext context) {
          return new WeightEntryDialog.edit(weightSave);
        },
        fullscreenDialog: true,
      ),
    )
        .then((newSave) {
      if (newSave != null) {
        setState(() => weightSaves[weightSaves.indexOf(weightSave)] = newSave);
      }
    });
  }

  Future _openAddEntryDialog() async {
    WeightEntry save =
    await Navigator.of(context).push(new MaterialPageRoute<WeightEntry>(
        builder: (BuildContext context) {
          return new WeightEntryDialog.add(
              weightSaves.isNotEmpty ? weightSaves.last.weight : 180.0);
        },
        fullscreenDialog: true));
    if (save != null) {
      //_addWeightSave(save);
      //mainReference.push().set(save.toJson());
      mainReference.child("weight").push().set(save.toJson());
    }
  }

  _onEntryAdded(Event event) {
    setState(() {
      weightSaves.add(new WeightEntry.fromSnapshot(event.snapshot));
      weightSaves.sort((we1, we2) => we1.dateTime.compareTo(we2.dateTime));
    });
    _scrollToTop();
  }

  _onEntryEdited(Event event) {
    var oldValue =
    weightSaves.singleWhere((entry) => entry.key == event.snapshot.key);
    setState(() {
      weightSaves[weightSaves.indexOf(oldValue)] =
      new WeightEntry.fromSnapshot(event.snapshot);
      weightSaves.sort((we1, we2) => we1.dateTime.compareTo(we2.dateTime));
    });
  }

  _scrollToTop() {
    _listViewScrollController.animateTo(
      weightSaves.length * _itemExtent,
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