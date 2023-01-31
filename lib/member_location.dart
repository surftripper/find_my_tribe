class MemberLocation {
  final String memberId;
  final double lat;
  final double long;
  final int lastUpdated;

  MemberLocation(
      {required this.memberId,
      required this.lat,
      required this.long,
      required this.lastUpdated});

  factory MemberLocation.fromRTDB(String key, Map<dynamic, dynamic> data) {
    return MemberLocation(
        memberId: key,
        lat: checkDouble(data['lat']),
        long: checkDouble(data['long']),
        lastUpdated: data['lastupdated']);
  }
  static double checkDouble(dynamic value) {
    if (value is String) {
      return double.parse(value);
    } else if (value is int) {
      return 0.0 + value;
    } else {
      return value;
    }
  }

  // @override
  String toString() {
    return "$memberId $lat $long ${DateTime.fromMicrosecondsSinceEpoch(lastUpdated)}";
  }
}
