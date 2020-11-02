import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tugas_firebase/model/model_sekolah.dart';

class FormScreen extends StatefulWidget {
  final ModelSekolah school;
  final DatabaseReference ref;
  FormScreen({this.school, this.ref});

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  TextEditingController _schoolNameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _latController = TextEditingController();
  TextEditingController _longController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.school != null) {
      _schoolNameController =
          TextEditingController(text: widget.school.schoolName);
      _descriptionController =
          TextEditingController(text: widget.school.description);
      _latController = TextEditingController(text: widget.school.lat);
      _longController = TextEditingController(text: widget.school.long);
    }
  }

  Future<void> createOrUpdateSekolah() async {
    if (widget.school == null) {
      // CREATE
      await addSchool(
          schoolName: _schoolNameController.text,
          description: _descriptionController.text,
          lat: _latController.text,
          long: _longController.text);
    } else {
      // UPDATE
      await updateSchool(school: widget.school);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Sekolah'),
      ),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          TextFormField(
            controller: _schoolNameController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.school),
              labelText: 'School Name',
            ),
          ),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.description),
              labelText: 'Description',
            ),
          ),
          TextFormField(
            controller: _latController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.location_on),
              labelText: 'Latitude',
            ),
          ),
          TextFormField(
            controller: _longController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.location_on),
              labelText: 'Longitude',
            ),
          ),
          SizedBox(height: 20),
          RaisedButton(
            child: widget.school == null ? Text('Create') : Text('Update'),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: () {
              // function insert/update
              createOrUpdateSekolah();
            },
          )
        ],
      ),
    );
  }

  Future<void> addSchool({
    String schoolName,
    String description,
    String lat,
    String long,
  }) async {
    ModelSekolah school = ModelSekolah(
      schoolName: schoolName,
      description: description,
      lat: lat,
      long: long,
    );

    await widget.ref.push().set(school.toJson());
    Navigator.pop(context, 'create');
  }

  Future<void> updateSchool({ModelSekolah school}) async {
    school.schoolName = _schoolNameController.text;
    school.description = _descriptionController.text;
    school.lat = _latController.text;
    school.long = _longController.text;

    await widget.ref.child(school.key).set(school.toJson());
    Navigator.pop(context, 'update');
  }
}
