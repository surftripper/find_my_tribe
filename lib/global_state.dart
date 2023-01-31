import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class GlobalState extends ChangeNotifier {
  /// Internal, private state of the application.
  final List<String> _tribeMemberIds = [
    "stu-kelly@outlook-com",
    "benkelly2012@outlook-com",
    "kath-kelly@outlook-com",
    "ekfairy@outlook-com"
  ];

  /// An unmodifiable view of the items in the cart.
  //UnmodifiableListView<Item> get items => UnmodifiableListView(_items);

  /// The users's ID which will be their unique identifier.
  String myId = "stu-kelly@outlook-com";
  String myTribe = "kelly-family";

  List<String> listTribes() {
    return _tribeMemberIds;
  }

  /// Adds [item] to cart. This and [removeAll] are the only ways to modify the
  /// cart from the outside.
  // void add(Item item) {
  //   _items.add(item);
  //   // This call tells the widgets that are listening to this model to rebuild.
  //   notifyListeners();
  // }

  /// Removes all items from the cart.
  // void removeAll() {
  //   _items.clear();
  //   // This call tells the widgets that are listening to this model to rebuild.
  //   notifyListeners();
  // }
}
