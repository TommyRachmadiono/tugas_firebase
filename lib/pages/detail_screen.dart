import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tugas_firebase/model/model_sekolah.dart';

class DetailScreen extends StatefulWidget {
  final ModelSekolah school;
  DetailScreen({this.school});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data ${widget.school.schoolName}"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          MyMap(
            location: LatLng(double.parse(widget.school.lat),
                double.parse(widget.school.long)),
            school: widget.school,
          )
        ],
      ),
    );
  }
}

class MyMap extends StatelessWidget {
  final LatLng location;
  final ModelSekolah school;

  const MyMap({
    @required this.location,
    @required this.school,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 300,
                width: MediaQuery.of(context).size.width,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: location,
                    zoom: 14,
                  ),
                  markers: <Marker>[
                    Marker(
                        markerId: MarkerId(school.schoolName),
                        position: location,
                        infoWindow: InfoWindow(title: school.schoolName)),
                  ].toSet(),
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                    Factory<OneSequenceGestureRecognizer>(
                        () => ScaleGestureRecognizer()),
                  ].toSet(),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.school),
              title: Text(
                school.schoolName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: Text(
                school.description,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text(
                "Latitude : ${school.lat}",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text(
                "Longitude : ${school.long}",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
