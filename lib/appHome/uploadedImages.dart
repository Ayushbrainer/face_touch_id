import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class listOfImages extends StatelessWidget {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: firestore.collection('users').doc().get(),
        builder: (context,snapshot){
          if(snapshot.hasData){
            print(snapshot.data);
            return Container();
          }else{
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class imageGrid extends StatefulWidget {

  @override
  _imageGridState createState() => _imageGridState();
}

class _imageGridState extends State<imageGrid> {

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

