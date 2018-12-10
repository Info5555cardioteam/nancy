import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'bp_entry.dart';
import 'bp_entry_dialog.dart';
import 'bp_list_item.dart';
import 'bp_progress_chart.dart';

class bp_page extends StatefulWidget {
  bp_page({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _bp_pageState createState() => new _bp_pageState();
}

final mainReference = FirebaseDatabase.instance.reference();

class _bp_pageState extends State<bp_page> with AutomaticKeepAliveClientMixin<bp_page>{

  List<BPEntry> bpSaves = new List();
  ScrollController _listViewScrollController = new ScrollController();
  double _itemExtent = 50.0;

  _bp_pageState() {
    mainReference.child("bp").onChildAdded.listen(_onEntryAdded);
    mainReference.child("bp").onChildChanged.listen(_onEntryEdited);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body:
          new Column(
            children: <Widget>[
            new _StatisticCardWrapper(
              child: new Padding(padding: new EdgeInsets.all(8.0),
                  child: new BPProgressChart(bpSaves)),
              height: 200.0,
            ),

            new ListView.builder(
              shrinkWrap: true,
              reverse: true,
              controller: _listViewScrollController,
              itemCount: bpSaves.length,
              itemBuilder: (buildContext, index) {
                //calculating difference
                double Sysdifference = index == 0
                    ? 0.0
                    : bpSaves[index].systolic - bpSaves[index - 1].systolic;
                double Diadifference = index == 0
                    ? 0.0
                    : bpSaves[index].diastolic - bpSaves[index - 1].diastolic;
                return new InkWell(
                    onTap: () => _editEntry(bpSaves[index]),
                    child: new BPListItem(bpSaves[index], Sysdifference,Diadifference));
              },
            ),
          ],),



      floatingActionButton: new FloatingActionButton(
        heroTag: "bp",
        onPressed: _openAddEntryDialog,
        tooltip: 'Add new weight entry',
        child: new Icon(Icons.add),
      ),
    );
  }

  void _addWeightSave(BPEntry bpSave) {
    setState(() {
      bpSaves.add(bpSave);
      _listViewScrollController.animateTo(
        bpSaves.length * _itemExtent,
        duration: const Duration(microseconds: 1),
        curve: new ElasticInCurve(0.01),
      );
    });
  }

  _editEntry(BPEntry bpSave) {
    Navigator
        .of(context)
        .push(
      new MaterialPageRoute<BPEntry>(
        builder: (BuildContext context) {
          return new BPEntryDialog.edit(bpSave);
        },
        fullscreenDialog: true,
      ),
    )
        .then((newSave) {
      if (newSave != null) {
        setState(() => bpSaves[bpSaves.indexOf(bpSave)] = newSave);
      }
    });
  }

  Future _openAddEntryDialog() async {
    BPEntry save =
    await Navigator.of(context).push(new MaterialPageRoute<BPEntry>(
        builder: (BuildContext context) {
          return new BPEntryDialog.add(
              bpSaves.isNotEmpty ? bpSaves.last.systolic : 120.0);
        },
        fullscreenDialog: true));
    if (save != null) {
      //_addWeightSave(save);
      mainReference.child("bp").push().set(save.toJson());
    }
  }

  _onEntryAdded(Event event) {
    setState(() {
      bpSaves.add(new BPEntry.fromSnapshot(event.snapshot));
      bpSaves.sort((we1, we2) => we1.dateTime.compareTo(we2.dateTime));
    });
    _scrollToTop();
  }

  _onEntryEdited(Event event) {
    var oldValue =
    bpSaves.singleWhere((entry) => entry.key == event.snapshot.key);
    setState(() {
      bpSaves[bpSaves.indexOf(oldValue)] =
      new BPEntry.fromSnapshot(event.snapshot);
      bpSaves.sort((we1, we2) => we1.dateTime.compareTo(we2.dateTime));
    });
  }

  _scrollToTop() {
    _listViewScrollController.animateTo(
      bpSaves.length * _itemExtent,
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