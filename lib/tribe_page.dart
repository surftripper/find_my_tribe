import 'dart:async';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:find_my_tribe/global_state.dart';
import 'package:flutter/material.dart';
import 'member_location.dart';
import 'tribe.dart';

class TribePage extends StatefulWidget {
  const TribePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<TribePage> createState() => _TribePageState();
}

class _TribePageState extends State<TribePage> {
  List<Tribe> myTribes = [];

  final database = FirebaseDatabase.instance.ref();
  late StreamSubscription _myTribesStream;

  void initState() {
    super.initState();
    _activateRTDBListeners();
  }

  void _activateRTDBListeners() async {
    //Firebase RealTime database listner
    final myTribe = Provider.of<GlobalState>(context, listen: false).myTribe;
    final locationRef = database
        .child('tribes/' + myTribe + '/members/'); // + myTribe + '/members/');
    _myTribesStream = locationRef.onValue.listen((event) {
      final data = Map<dynamic, dynamic>.from(
          event.snapshot.value as Map<dynamic, dynamic>);

      setState(() {
        //1. Retrieve the Changed Tribes from the database
        myTribes.clear();
        final List<String> members =
            data.keys.map((e) => e.toString()).toList();
        myTribes.add(Tribe(name: myTribe, members: members));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    //var myId = Provider.of<GlobalState>(context, listen: false).myId;
    // var myTribeMembers =
    //     Provider.of<GlobalState>(context, listen: false).listTribes();
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Your Tribe:',
            ),
            Text(
              Provider.of<GlobalState>(context, listen: false).myTribe,
              //myTribe[0].memberId,
              style: Theme.of(context).textTheme.headline4,
            ),
            for (var item in myTribes) Text(item.toString()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void deactivate() {
    _myTribesStream.cancel();
    super.deactivate();
  }
}
