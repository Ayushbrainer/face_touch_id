import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_touch_id/components/already_have_an_account_acheck.dart';
import 'package:face_touch_id/components/rounded_button.dart';
import 'package:face_touch_id/components/rounded_input_field.dart';
import 'package:face_touch_id/components/rounded_password_field.dart';
import 'file:///C:/Users/nmabh/AndroidStudioProjects/face_touch_id/lib/appHome/homePage.dart';
import 'package:face_touch_id/newUser/Registration.dart';
import 'package:face_touch_id/oldUser/components/background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_auth/local_auth.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String confirmPassword,Password,email;
  bool obscureText = true;
  final FormKey = GlobalKey<FormState>();
  final LocalAuthentication localAuthentication = LocalAuthentication();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  void biometricLogin() async{
    bool canCheckBiometrics =
    await localAuthentication.canCheckBiometrics;

    List<BiometricType> availableBiometrics =
    await localAuthentication.getAvailableBiometrics();

    if (Platform.isIOS) {
      if (availableBiometrics.contains(BiometricType.face)) {
        bool didAuthenticate =
        await localAuthentication.authenticate(
            localizedReason: 'Please authenticate to proceed');
        // Face ID.
      }
    }else if(Platform.isAndroid){
      if (availableBiometrics.contains(BiometricType.fingerprint)) {
        bool didAuthenticate =
        await localAuthentication.authenticate(
            localizedReason: 'Please authenticate to proceed');// Touch ID.

        if(didAuthenticate){
          final userEmail = await storage.read(key: 'email');
          final userPass = await storage.read(key: 'password');

          login(email: userEmail,password: userPass);
        }
      }
    }
  }

  void login({String email,password}){
    firebaseAuth.signInWithEmailAndPassword(email: email, password: password).then((value){
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      storage.write(key: 'email', value: email);
      storage.write(key: 'password', value: password);
      storage.write(key: 'usingBiometric', value: 'true');
          Navigator.push(context, MaterialPageRoute(builder: (context) => homePage(firestore: firestore,email: email,)));
    }).catchError((err){
      print(err.code);
      if (err.code == 'ERROR_WRONG_PASSWORD') {
        showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text('The password was incorrect, please try again'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Material(
      child: Background(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "LOGIN",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.03),
              SvgPicture.asset(
                "assets/icons/login.svg",
                height: size.height * 0.35,
              ),
              SizedBox(height: size.height * 0.03),
              RoundedInputField(
                hintText: "Your Email",
                onChanged: (value) {},
              ),
              RoundedPasswordField(
                onChanged: (value) {},
              ),
              IconButton(icon: Icon(Icons.fingerprint,color: Colors.black87,size: 35,), onPressed: biometricLogin),
              RoundedButton(
                text: "LOGIN",
                press: () {
                  login(email: email,password:Password);
                },
              ),
              SizedBox(height: size.height * 0.03),
              AlreadyHaveAnAccountCheck(
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return signUp();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
