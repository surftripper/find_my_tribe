import 'package:find_my_tribe/tribe_page.dart';
import 'package:find_my_tribe/map_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:find_my_tribe/global_state.dart';

//---------------------------------------------------------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  List<DropdownMenuItem<String>> getDropdownItems() {
    List<DropdownMenuItem<String>> dropDownItems = [];
    for (String str
        in Provider.of<GlobalState>(context, listen: false).listTribes()) {
      dropDownItems.add(DropdownMenuItem<String>(value: str, child: Text(str)));
    }
    return dropDownItems;
  }

  void dropdownCallback(String? selectedValue) {
    if (selectedValue is String) {
      setState(() {
        Provider.of<GlobalState>(context, listen: false).myId = selectedValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton<String>(
                  items: getDropdownItems(),
                  value: Provider.of<GlobalState>(context, listen: false).myId,
                  onChanged: dropdownCallback,
                  dropdownColor: Colors.lightBlue,
                  style: const TextStyle(
                      color: Colors.white, //<-- SEE HERE
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                  iconSize: 42.0,
                  iconEnabledColor: Colors.blue),
              SizedBox(width: 10, height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TribePage(title: 'Your Tribe'),
                    ),
                  );
                },
                child: const Text('Your tribe members'),
              ),
              SizedBox(width: 10, height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapPage(),
                    ),
                  );
                },
                child: const Text('View the map'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//---------------------------------------------------------------------