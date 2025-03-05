import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proj/ChatApp/home/home_page.dart';
import 'package:proj/ChatApp/models/user_model.dart';
import 'package:proj/ChatApp/pages/authenticate/login.dart';
import 'package:proj/ChatApp/pages/profiles/complete_profile.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key ,required this.destination ,this.firebaseUser ,this.userModel});
 final String destination;  
  final User? firebaseUser;
  final UserModel? userModel;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
 
 @override
  void initState() {
     Timer(const Duration(seconds: 2), () {
      if (widget.destination == "home") {
        Navigator.pop(context);
        if (widget.userModel!.name == "" || widget.userModel!.name == null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CompleteUserProfile(
                        firebaseUser: widget.firebaseUser!,
                        userModel: widget.userModel!,
                      )));
        }else{
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(
                        firebaseUser: widget.firebaseUser!,
                        userModel: widget.userModel!,
                      )));
        }

      } else if (widget.destination == "login") {
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const Loginpage()));
      }
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
       width: MediaQuery.sizeOf(context).width,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(image: AssetImage("assets/chat.png") ,height: 200,width: 200,),
            SizedBox(height: 20,),
            Text(
                "Chat App",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 239, 125, 116)
                   ,fontFamily:"EuclidCircularB"
                    ),
                textAlign: TextAlign.center,
              )

          ],),),
    );
  }
}