import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_firebase/model/model_sekolah.dart';
import 'package:tugas_firebase/pages/detail_screen.dart';
import 'package:tugas_firebase/pages/form_screen.dart';
import 'package:tugas_firebase/pages/login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  DatabaseReference _schoolRef;
  User user;
  List<ModelSekolah> schoolList = [];

  StreamSubscription<Event> _onSchoolAddedSubscription;
  StreamSubscription<Event> _onSchoolChangedSubscription;

  Future getUserLogin() async {
    user = auth.currentUser;
  }

  @override
  void initState() {
    super.initState();
    getUserLogin();
    _schoolRef = _database.reference().child('schools');
    _onSchoolAddedSubscription = _schoolRef.onChildAdded.listen(_onNewSchool);
    _onSchoolChangedSubscription =
        _schoolRef.onChildChanged.listen(_onChangedSchool);
  }

  @override
  void dispose() {
    super.dispose();
    _onSchoolAddedSubscription.cancel();
    _onSchoolChangedSubscription.cancel();
  }

  logout() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Home Page'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormScreen(ref: _schoolRef),
              ));
          if (result == 'create') {
            Fluttertoast.showToast(
              msg: 'Berhasil menambah data baru',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        },
        child: Icon(
          Icons.add_location_alt,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user.photoURL),
                      minRadius: 30,
                      maxRadius: 40,
                    ),
                    Spacer(),
                    Text(user.displayName),
                    Text(user.email),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Text('SIGN OUT'),
              leading: Icon(
                Icons.logout,
              ),
              onTap: () {
                logout();
              },
            ),
          ],
        ),
      ),
      body: Container(
        child: _showSchoolList(),
      ),
    );
  }

  Widget _showSchoolList() {
    if (schoolList.length > 0) {
      return ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(color: Colors.black);
        },
        itemCount: schoolList.length,
        itemBuilder: (context, index) {
          ModelSekolah school = schoolList[index];

          return Dismissible(
            key: Key(school.key),
            background: Container(
              color: Colors.red,
            ),
            onDismissed: (direction) async {
              deleteSchool(school.key, index);
            },
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      school: school,
                    ),
                  ),
                );
              },
              child: ListTile(
                leading: Icon(Icons.school),
                title: Text(
                  school.schoolName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                subtitle: Text(school.description),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormScreen(
                          ref: _schoolRef,
                          school: school,
                        ),
                      ),
                    );

                    if (result == 'update') {
                      Fluttertoast.showToast(
                        msg: 'Berhasil mengubah data',
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                ),
              ),
            ),
          );
        },
      );
    } else {
      return Center(
        child: Text('No School Data Available'),
      );
    }
  }

  // LISTENER
  void _onNewSchool(Event event) {
    setState(() {
      schoolList.add(ModelSekolah.fromSnapshot(event.snapshot));
    });
  }

  void _onChangedSchool(Event event) {
    var oldEntry = schoolList.singleWhere((school) {
      return school.key == event.snapshot.key;
    });

    setState(() {
      schoolList[schoolList.indexOf(oldEntry)] =
          ModelSekolah.fromSnapshot(event.snapshot);
    });
  }

  Future<void> deleteSchool(String key, int index) async {
    await _schoolRef.child(key).remove();
    setState(() {
      schoolList.removeAt(index);
    });
    Fluttertoast.showToast(
      msg: 'Berhasil menghapus data',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
