import 'package:firebase_database/firebase_database.dart';

class ModelSekolah {
  final String key;
  String schoolName;
  String description;
  String lat;
  String long;

  ModelSekolah({
    this.key,
    this.schoolName,
    this.description,
    this.lat,
    this.long,
  });

  ModelSekolah.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        schoolName = snapshot.value['schoolName'],
        description = snapshot.value['description'],
        lat = snapshot.value['lat'],
        long = snapshot.value['long'];

  Map<String, dynamic> toJson() => {
        'schoolName': schoolName,
        'description': description,
        'lat': lat,
        'long': long,
      };
}
