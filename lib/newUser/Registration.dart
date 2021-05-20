import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_touch_id/colors.dart';
import 'package:face_touch_id/components/already_have_an_account_acheck.dart';
import 'package:face_touch_id/components/rounded_button.dart';
import 'package:face_touch_id/components/rounded_input_field.dart';
import 'package:face_touch_id/components/rounded_password_field.dart';
import 'package:face_touch_id/components/text_field_container.dart';
import 'file:///C:/Users/nmabh/AndroidStudioProjects/face_touch_id/lib/appHome/homePage.dart';
import 'package:face_touch_id/newUser/components/background.dart';
import 'package:face_touch_id/newUser/components/or_divider.dart';
import 'package:face_touch_id/newUser/components/social_icon.dart';
import 'package:face_touch_id/oldUser/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_auth/local_auth.dart';


class signUp extends StatefulWidget {
  @override
  _signUpState createState() => _signUpState();
}

class _signUpState extends State<signUp> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String confirmPassword,Password,email;
  bool obscureText = true;
  final FormKey = GlobalKey<FormState>();
  final LocalAuthentication localAuthentication = LocalAuthentication();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  bool useBiometrics = false;

  void auth() async{
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
          storage.write(key: 'email', value: email);
          storage.write(key: 'password', value: Password);
          storage.write(key: 'biometrics', value: 'true');
        }
      }
    }

  }

  void createUser({String email,password}){
    firebaseAuth.createUserWithEmailAndPassword(email: email, password: password).then((value){
      auth();
      firestore.collection('users').doc(firebaseAuth.currentUser.uid).set({
        'name':firebaseAuth.currentUser.email
      });
      Navigator.push(context, MaterialPageRoute(builder: (context)=>homePage(firestore: firestore,id: firebaseAuth.currentUser.uid,email: email,)));
    }).catchError((err){
      print(err.code);
      if (err.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
        showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text(
                    'This email already has an account associated with it'),
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
      }}).then((value) async{
      await firestore.collection('users').doc(firebaseAuth.currentUser.uid);
    });
  }
  @override
  Widget build(BuildContext context) {
    return body(context);
  }


  Widget body(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Material(
      child: Background(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "SIGNUP",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.03),
              SvgPicture.asset(
                "assets/icons/signup.svg",
                height: size.height * 0.35,
              ),
              RoundedInputField(
                hintText: "Your Email",
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              RoundedPasswordField(
                onChanged: (value) {
                  setState(() {
                    Password = value;
                  });
                },
              ),
              confirmPasswordField(),
              RoundedButton(
                text: "SIGNUP",
                press: () {
                  createUser(email: email,password: Password);
                },
              ),
              SizedBox(height: size.height * 0.03),
              AlreadyHaveAnAccountCheck(
                login: false,
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Login();
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

  Widget confirmPasswordField(){
    return TextFieldContainer(
      child: TextFormField(
        obscureText: true,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (pwConfValue) {
          if (pwConfValue != Password) {
            return 'Passwords must match';
          }

          return null;
        },
        onChanged: (pass){
          setState(() {
            confirmPassword =  pass;
          });
        },
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          hintText: "Confirm Password",
          icon: Icon(
            Icons.lock,
            color: kPrimaryColor,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

}
