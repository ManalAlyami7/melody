// login_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:melody/home_screen_user.dart';

import 'package:melody/model/user_model.dart';
import 'package:toggle_switch/toggle_switch.dart';


class LoginScreen extends StatelessWidget {
  String? errorMessage;
  List<String> userType =['lessor','tenant'];
  String user1 = 'lessor';
  final _auth = FirebaseAuth.instance;
  UserModel userModel = UserModel();
  @override

  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder:(context , snapshot){
        if(snapshot.hasData){
          return  const ItemListScreen();
        }
        else{
          return  FlutterLogin(
            logo: 'assets/logo.png',
            title: "MELODY",
            theme:LoginTheme(
              titleStyle: const TextStyle(color: Colors.black,fontWeight: FontWeight.w900),
            ) ,
            additionalSignupFields: const [
              UserFormField(keyName: 'Name',userType: LoginUserType.name,icon: Icon(Icons.person))
            ],
            onSignup: (SignupData) async {
              try {
                await _auth
                    .createUserWithEmailAndPassword(email: SignupData.name??'', password: SignupData.password??'')
                    .then((value) async => {
                userModel.firstName =SignupData.additionalSignupData!['Name'],
                    await postDetailsToFirestore(),
                })
                    .catchError((e) async {
                });
              } on FirebaseAuthException catch (error) {
                switch (error.code) {
                  case "invalid-email":
                    errorMessage = "Your email address appears to be malformed.";
                    break;
                  case "wrong-password":
                    errorMessage = "Your password is wrong.";
                    break;
                  case "user-not-found":
                    errorMessage = "User with this email doesn't exist.";
                    break;
                  case "user-disabled":
                    errorMessage = "User with this email has been disabled.";
                    break;
                  case "too-many-requests":
                    errorMessage = "Too many requests";
                    break;
                  case "operation-not-allowed":
                    errorMessage = "Signing in with Email and Password is not enabled.";
                    break;
                  default:
                    errorMessage = "An undefined Error happened.";
                }
              }
            },
            onLogin: (LoginData ) async {
              try {
                await _auth
                    .signInWithEmailAndPassword(email: LoginData.name, password: LoginData.password)
                    .then((uid)  => {
                });
              } on FirebaseAuthException catch (error) {
                switch (error.code) {
                  case "invalid-email":
                    errorMessage = "Your email address appears to be malformed.";

                    break;
                  case "wrong-password":
                    errorMessage = "Your password is wrong.";
                    break;
                  case "user-not-found":
                    errorMessage = "User with this email doesn't exist.";
                    break;
                  case "user-disabled":
                    errorMessage = "User with this email has been disabled.";
                    break;
                  case "too-many-requests":
                    errorMessage = "Too many requests";
                    break;
                  case "operation-not-allowed":
                    errorMessage = "Signing in with Email and Password is not enabled.";
                    break;
                  default:
                    errorMessage = "An undefined Error happened.";
                }
                print(error.code);
              }

            }, onRecoverPassword: (String ) {  },
            headerWidget:Padding(
              padding: const EdgeInsets.only(bottom: 20,),
              child: Center(
                child: ToggleSwitch(
                  cornerRadius: 20,
                  animate: true,
                  minWidth: 130,
                  initialLabelIndex: 0,
                  totalSwitches: 2,
                  labels: const ['lessor', 'tenant'],
                  onToggle: (index) {
                    user1 = userType[index??0];
                    print('switched to: $user1');
                  },
                ),
              ),
            ),

          );
        }
      } ,
    );
  }
  postDetailsToFirestore() async {
    // calling our firestore
    // calling our user model
    // sedning these values

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    // writing all the values
    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.role = user1;
    // await firebaseFirestore
    //     .collection("Users")
    //     .doc(user.uid)
    //     .set(userModel.toMap());
    final docUser = FirebaseFirestore.instance.collection('Users').doc(user.uid);
    await docUser.set(userModel.toMap());
    if (userModel.role.toString() == 'tenant') {
    print(userModel.role);
    } else {
      print(userModel.role);
    }
  }
}
