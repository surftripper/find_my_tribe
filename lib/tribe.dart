class Tribe {
  final String name;
  final List<String> members;

  Tribe({required this.name, required this.members});

  // @override
  String toString() {
    return "$name $members";
  }
}
