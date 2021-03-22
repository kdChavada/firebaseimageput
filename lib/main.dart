import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Upload firebase Image',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String imageUrl;

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Image"),
      ),
      body: Column(
        children: [
          (imageUrl != null)
              ? Center(
                  child: Image.network(
                    imageUrl,
                    height: h * 0.6,
                    width: w,
                  ),
                )
              : Placeholder(
                  fallbackHeight: 100.0,
                  fallbackWidth: 100.0,
                ),
          SizedBox(
            height: 20.0,
          ),
          RaisedButton(
            onPressed: () {
              uploadImage();
            },
            child: Text("Upload Image"),
            color: Colors.lightBlue,
          ),
        ],
      ),
    );
  }

  uploadImage() async {
    final _storage = FirebaseStorage.instance;

    final _picker = ImagePicker();

    PickedFile image;

    //check permission
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted) {
      //Selected Image
      image = await _picker.getImage(source: ImageSource.gallery);

      var file = File(image.path);

      if (image != null) {
        //Upload to Firebase
        var snapshoat =
            await _storage.ref().child('folderName/imageName').putFile(file);
        var doenloadUrl = await snapshoat.ref.getDownloadURL();

        setState(() {
          imageUrl = doenloadUrl;
        });
      } else {
        print("no Path  Received");
      }
    } else {
      print("Grant Permission And try Again");
    }
  }
}
