import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:find_my_tribe/global_state.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'member_location.dart';
import 'tribe.dart';

class MapPage extends StatefulWidget {
  //const MapPage({super.key, required this.title});
  const MapPage({Key? key}) : super(key: key);

  // This widget will display the locations of the tribe for the user

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title = "Map Page";

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Set<Marker> mapMarkers = {};
  List<MemberLocation> memberLocations = [];
  final database = FirebaseDatabase.instance.ref();
  late StreamSubscription _memberLocationsStream;
  late StreamSubscription<Position> _positionStream;
  Position? _position;
  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

//--------------MAP
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _initalMapStartingPos = CameraPosition(
    target: LatLng(0.0, 0.0),
    zoom: 256,
  );

  // static const CameraPosition _kLake = CameraPosition(
  //     bearing: 192.8334901395799,
  //     target: LatLng(37.43296265331129, -122.08832357078792),
  //     tilt: 59.440717697143555,
  //     zoom: 19.151926040649414);
//------------MAP

  @override
  void initState() {
    super.initState();
    //_setUpMarkers(); //must move to afer have member locatosn
    _activateRTDBListeners();
    _activateGeoLocatorListner();
    getCurrentLocation();
  }

  /*  void _setUpMarkers() {
    mapMarkers.add(Marker(
      markerId: MarkerId('unique1'),
      position: LatLng(41.4617533, -2.90688174), //position of marker
      infoWindow: InfoWindow(
        title: 'Marker Title First ',
        snippet: 'My Custom Subtitle',
      ),
      icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    ));
  } */

  void getCurrentLocation() async {
    checkLocationPermissions();
    Position position = await _determinePosition();
    setState(() {
      if (position != null) {
        _position = position;
        updateRTDBwithLocation(position);
        moveToPosition(position);
      }
    });
  }

  void _activateRTDBListeners() async {
    //Firebase RealTime database listner
    final locationRef = database.child('memberlocations/');
    _memberLocationsStream = locationRef.onValue.listen((event) {
      final data = Map<String, dynamic>.from(
          event.snapshot.value! as Map<dynamic, dynamic>);

      setState(() {
        //1. Retrieve the Changed Member Locations from the database
        // and update the map marker set
        memberLocations.clear();
        mapMarkers.clear();
        data.forEach((key, value) {
          Map<dynamic, dynamic> innerRecord = value;
          MemberLocation _loc = MemberLocation.fromRTDB(key, innerRecord);
          memberLocations.add(_loc);
          mapMarkers.add(Marker(
            markerId: MarkerId(key),
            position: LatLng(_loc.lat, _loc.long), //position of marker
            infoWindow: InfoWindow(
              title: key,
              snippet: DateTime.fromMicrosecondsSinceEpoch(_loc.lastUpdated)
                  .toString(),
            ),
            icon: BitmapDescriptor.defaultMarker,
          ));
        });
      });
    });
  }

  void _activateGeoLocatorListner() {
    //GeoLocator listner
    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      checkLocationPermissions();

      setState(() {
        if (position != null) {
          _position = position;
          updateRTDBwithLocation(position);
          moveToPosition(position);
        }
      });
    });
  }

  Future<void> moveToPosition(Position position) async {
    final GoogleMapController controller = await _controller.future;
    LatLng latLng = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: 15);
    controller.moveCamera(CameraUpdate.newCameraPosition(cameraPosition));
    //controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  void updateRTDBwithLocation(Position position) async {
    final myId = Provider.of<GlobalState>(context, listen: false).myId;
    final locationRef = database.child('memberlocations/');
    try {
      final location = <String, dynamic>{
        myId: {
          'lastupdated': DateTime.now().microsecondsSinceEpoch,
          'lat': position.latitude,
          'long': position.longitude
        }
      };
      await locationRef
          .update(location)
          .then((_) => print("member location written to database"));
    } catch (e) {
      print('You got an error! $e');
    }
  }

  void checkLocationPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
  }

  // Determine the current position of the device.
  //
  // When the location services are not enabled or permissions
  // are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _addMarker() {}

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called

    //var myId = Provider.of<GlobalState>(context, listen: false).myId;

    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Stack(children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initalMapStartingPos,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationEnabled: true,
            markers: mapMarkers,
          ),
          Positioned(
            bottom: 50,
            left: 10,
            child: FloatingActionButton(
              child: Icon(Icons.pin_drop, color: Colors.white),
              backgroundColor: Colors.green,
              onPressed: (null),
            ),
          )
        ])

        // child: Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: <Widget>[
        //     const Text(
        //       'Your Tribe Locations:',
        //     ),

        //     Text(
        //       myId,
        //       style: Theme.of(context).textTheme.headline4,
        //     ),
        //     Text(
        //       _position != null ? _position.toString() : 'No location',
        //     ),
        //     for (var item in memberLocations) Text(item.toString()),
        //   ],
        // ),

        // floatingActionButton: FloatingActionButton(
        //   onPressed: _incrementCounter,
        //   tooltip: 'Increment',
        //   child: const Icon(Icons.map),
        // ), // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  @override
  void deactivate() {
    _memberLocationsStream.cancel();
    _positionStream.cancel();
    super.deactivate();
  }
}
