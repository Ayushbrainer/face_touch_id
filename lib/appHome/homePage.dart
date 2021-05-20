import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_touch_id/colors.dart';
import 'file:///C:/Users/nmabh/AndroidStudioProjects/face_touch_id/lib/appHome/uploadedImages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class homePage extends StatefulWidget {
  String email;
  FirebaseFirestore firestore;
  String id;
  homePage({this.email,this.firestore,this.id});
  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  File _imageFile;
  final picker = ImagePicker();
  final cropper = ImageCropper();
  final firebaseAuth = FirebaseAuth.instance;
  firebase_storage.UploadTask _uploadTask;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  int noOfImages;

  Future<void> pickImage() async {
    PickedFile selectedImg = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(selectedImg.path);
    });
  }

  Future uploadImage() async{
    String s = "images/${DateTime.now()}";
    String field;

    await firestore.collection('users').doc(firebaseAuth.currentUser.uid).get().then((value) => noOfImages = value.data().length);
    setState(() {
      field = "${noOfImages+1}";
    });
    print(s+"  "+widget.id);
    firebase_storage.Reference reference = firebase_storage.FirebaseStorage.instance.ref().child(s);
    print(s);
    reference.putFile(_imageFile).then((value){
        firestore.collection('users').doc(firebaseAuth.currentUser.uid).update({
          field: s
        }).then((value) => print("succesfully stored image"));
        clear();
      })
          .catchError((onError)=>print(onError));
  }

  Future<void> takePic() async {
    PickedFile selectedImg = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _imageFile = File(selectedImg.path);
    });
  }

  Future<void> cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
    );

    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
  }

  void clear() {
    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Images"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      drawer: Drawer(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Icon(Icons.person) ,
                    Text("${widget.email}")
                  ],
                ),
              ),
              Container(
                child: TextButton(
                  onPressed: (){
                    firebaseAuth.signOut().then((value){
                      Navigator.pop(context);
                      Navigator.pop(context);
                    });
                  },
                  child: Row(
                  children: [
                    Icon(Icons.logout) ,
                    Text("Log Out")
                  ],
              ),
                ),),
            ],
          ),
        ),
      ),
      backgroundColor: kPrimaryLightColor,
      body: (_imageFile==null)?Center(
        child: Text("Select an image to upload",style: TextStyle(
          fontSize: 25,
        ),),
      ):imageCropper(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(shape: BoxShape.circle,border: Border.all(color: Colors.white)),
            child: IconButton(icon: Icon(Icons.camera_alt_outlined,size: 36,), onPressed: takePic),
          ),
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            // height: MediaQuery.of(context).size.height*0.12,
            // width: MediaQuery.of(context).size.width*0.12,
            decoration: BoxDecoration(shape: BoxShape.circle,border: Border.all(color: Colors.white)),
            child: IconButton(icon: Icon(Icons.photo,size: 36,), onPressed: pickImage),
          )
        ],
      ),
    );
  }

  Widget imageCropper(){
    return Container(
      child: ListView(
        children: [
          Image.file(_imageFile),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: cropImage, icon: Icon(Icons.crop,color: Colors.white,)),
              IconButton(onPressed: clear, icon: Icon(Icons.cancel,color: Colors.white,)),
            ],
          ),
          TextButton(onPressed: uploadImage, child: Text("Upload to Firebase"))
        ],
      ),
    );

  }
}

