import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:proj/ChatApp/helpers/ui_helper.dart';
import 'package:proj/ChatApp/models/user_model.dart';
import 'package:proj/ChatApp/pages/authenticate/login.dart';
import 'package:proj/ChatApp/pages/profiles/complete_profile.dart';


class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final signUpKey = GlobalKey<FormState>();
  bool obscure = true;
  TextEditingController passController= TextEditingController();

  String email = "";
  String password = "";
  String rePassword = "";
String uId="";

  @override
  Widget build(BuildContext context) {
    return
    //  Provider<StateClass>(
    //                        create: (context) =>
    //                       StateClass(uId:uId )
    //                           , child:
                               Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Container(
              alignment: Alignment.center,
               padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  const SizedBox(height: 40,),
                  const Image(
                    image: AssetImage("assets/chat.png"),
                    height: 150,
                    width: 150,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Chat App",
                    style: TextStyle(
                      fontFamily:"EuclidCircularB",
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 239, 125, 116)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  const Text(
                    "Sign Up to Chat App ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600   ,fontFamily:"EuclidCircularB"),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Form(
                    key: signUpKey,
                      child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                            label: Text("Email Id" ,style: TextStyle(fontFamily:"EuclidCircularB")), border: OutlineInputBorder()),
                             onSaved: (value){
                             setState(() {
                                 email=value!;
                             });
                            },
                            validator: (value) {
                               if(value.toString().trim()==""){
                                return "Empty field";
                              }
                              else {
                                 return null;
                               }
                          
                            },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: passController,
                        obscureText: obscure,
                        decoration: InputDecoration(
                            suffix: GestureDetector(
                              onTap: () {
                                setState(() {
                                  obscure = !obscure;
                                });
                              },
                              child: Image(
                                image: AssetImage((obscure == true)
                                    ? "assets/eyebrow.png"
                                    : "assets/visibility.png"),
                                width: 25,
                                height: 20,
                              ),
                            ),
                            label: const Text("Password" ,style: TextStyle(fontFamily:"EuclidCircularB")),
                            border: const OutlineInputBorder()),
                            onSaved: (value){
                             setState(() {
                                 password=value!;
                             });
                            },
                            validator: (value) {
                           if(value.toString()==""){
                                return "Empty field";
                              }
                          else{
                           return null;}
                            },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                            label: Text("Confirm Password" ,style: TextStyle(fontFamily:"EuclidCircularB")),
                            border: OutlineInputBorder()),
                             onSaved: (value){
                             setState(() {
                                 rePassword=value!;
                             });
                            },
                            validator: (value) {
                              if(value.toString().trim()!= passController.text.trim()){
                                return "Passwords do not match  ${value.toString().trim()}  value  ${passController.text.trim()}";
                              }
                              else if(value.toString()==""){
                                return "Empty field";
                              }
                              else{
                              return null;}
                            
                            },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        ////////////////// using provider 
                        child: 
                         ///////////////
                                 TextButton(
                              onPressed: () {
                                signUpKey.currentState!.save();
                                if(signUpKey.currentState!.validate()){
                                  debugPrint("validated");
                                  signUpUser();
                                }
                              },
                              style: ButtonStyle(
                                  padding: const WidgetStatePropertyAll(EdgeInsets.all(10)),
                                  shape:
                                      WidgetStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  )),
                                  backgroundColor: const WidgetStatePropertyAll(
                                      Color.fromARGB(255, 240, 217, 148))),
                              child: const Text(
                                "Sign Up ",
                                style: TextStyle(
                                  fontFamily:"EuclidCircularB",
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              )),
                        
                      ),
                    ],
                  )),
                  // const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account ?",
                        style: TextStyle(
                         fontFamily:"EuclidCircularB",
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Loginpage()));
                        },
                        child: const Text(
                          "Log In",
                          style: TextStyle(
                            fontFamily:"EuclidCircularB",
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color.fromARGB(255, 239, 144, 138)),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
       
      // ),
    );
  
  }

 void signUpUser() async {
  auth.UserCredential? userCredential;
  UiHelper.loadingDialogFun(context,"Signing Up...");
    try {
      userCredential =    await auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    

      //  Navigator.push( context,
      //                         MaterialPageRoute(
      //                             builder: (context) => CompleteUserProfile(userModel: user, firebaseUserl: userCredential!.user!,)));
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        debugPrint('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        debugPrint('The account already exists for that email.');
      }
    } catch (e) {
      debugPrint("this is Exception : $e");
    }

// storing data in firestore
    if (userCredential != null) {
      // getting user id
      setState(() {
        uId= userCredential!.user!.uid;
      });
      UserModel userdata = UserModel(
          uId: userCredential.user!.uid,
          name: "",
          email: email.trim(),
          profileUrl: "");

       await FirebaseFirestore.instance  
          .collection("ChatAppUsers")
          .doc(userCredential.user!.uid) // userId created by firebase auth as doc id 
          .set(userdata.toMap()); 
          
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement( context,
                              MaterialPageRoute(
                                  builder: (context) => CompleteUserProfile(userModel: userdata, firebaseUser: userCredential!.user!,)));
    }

  }
}
