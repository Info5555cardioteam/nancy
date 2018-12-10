import 'package:flutter/material.dart';
import 'weight_page.dart';
import 'glucose_page.dart';
import 'bp_page.dart';


void main() {
  runApp(TabBarDemo());
}

class TabBarDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.looks_one)),
                Tab(icon: Icon(Icons.looks_two)),
                Tab(icon: Icon(Icons.loyalty)),
              ],
            ),
            title: Text('Nancy'),
          ),
          body: TabBarView(
            children: [
              bp_page(title: 'Blood Pressure'),
              glucose_page(title: 'Glucose'),
              weight_page(title: 'Weight'),
            ],
          ),
        ),
      ),
    );
  }
}