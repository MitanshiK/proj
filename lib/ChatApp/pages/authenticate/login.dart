import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:proj/ChatApp/helpers/ui_helper.dart';
import 'package:proj/ChatApp/home/home_page.dart';
import 'package:proj/ChatApp/models/user_model.dart';
import 'package:proj/ChatApp/pages/authenticate/sign_in.dart';
import 'package:proj/ChatApp/pages/profiles/complete_profile.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final _emlcontroller = TextEditingController();
  final _passcontroller = TextEditingController();
  bool btnDisabled = true;

  bool passwordVisible = true;
  Color borderColorEml = const Color.fromRGBO(162, 162, 162, 1);
  Color _borderColorPass = const Color.fromRGBO(162, 162, 162, 1);

//error string
  String passwordError = "";
  String emlError = "";

// error flags
  String flagPass = "";
  String flagEml = "";

  FocusNode emlFocus = FocusNode();
  FocusNode passFocus = FocusNode();

  @override
  void initState() {
    emlFocus.addListener(() {
      setState(() {
        borderColorEml = emlFocus.hasFocus
            ? (!(flagEml == ""))
                ? const Color.fromRGBO(238, 75, 75, 1)
                : Theme.of(context).colorScheme.primary
            : const Color.fromRGBO(162, 162, 162, 1);
      });
    });

    passFocus.addListener(() {
      setState(() {
        _borderColorPass = passFocus.hasFocus
            ? (!(flagPass == ""))
                ? const Color.fromRGBO(238, 75, 75, 1)
                : Theme.of(context).colorScheme.primary
            : const Color.fromRGBO(162, 162, 162, 1);
      });
    });

    _emlcontroller.addListener(() {
      setState(() {
        if (_emlcontroller.text.isEmpty ||
            _passcontroller.text.length < 8 ||
            _passcontroller.text.isEmpty) {
          btnDisabled = true;
        } else {
          btnDisabled = false;
        }
      });
    });
    _passcontroller.addListener(() {
      setState(() {
        if (_emlcontroller.text.isEmpty || _passcontroller.text.isEmpty) {
          btnDisabled = true;
        } else {
          btnDisabled = false;
        }
      });
    });

    super.initState();
  }

  AutovalidateMode validationMode = AutovalidateMode.disabled;



  final loginKey = GlobalKey<FormState>();
  bool obscure = true; // visibility of password

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                const SizedBox(
                  height: 40,
                ),
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
                  "Login to your Chat App Account ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600    ,fontFamily:"EuclidCircularB"),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                Form(
                    key: loginKey,
                    autovalidateMode: validationMode, //validationMode
                    child: Column(
                      children: [
                   /* old field
                        TextFormField(
                          style: const TextStyle(fontFamily:"EuclidCircularB"),
                          decoration: const InputDecoration(
                              label: Text("Email Id",style: TextStyle(fontFamily:"EuclidCircularB")),
                              border: OutlineInputBorder()),
                          validator: (value) {
                            if (value.toString().trim() == "") {
                              return "empty field";
                            }
                            else
                           { return null;}
                          },
                          onSaved: (value) {
                            setState(() {
                              email = value!;
                            });
                          },
                        ),
                       */ 
                         Container(
                    height: 56,
                    padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: (!(flagEml == ""))
                              ? const Color.fromRGBO(238, 75, 75, 1)
                              : borderColorEml,
                          width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                        focusNode: emlFocus,
                        controller: _emlcontroller,
                        style: const TextStyle(fontFamily:"EuclidCircularB"),
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          errorStyle: TextStyle(fontSize: 0),
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          labelText: "Email address",
                          labelStyle:  TextStyle(fontFamily:"EuclidCircularB"),
                        ),
                        onChanged:
                            (validationMode == AutovalidateMode.onUserInteraction)
                                ? (value) {
                                    loginKey.currentState!.validate();
                                  }
                                : (value) {},
                        validator: (value) {
                          // if (value?.isEmpty == true) {
                          //  flagEml = "Empty email field";
                          //     return "";
                          //   }
                          //   else
                          if (UiHelper.emailRegExp.hasMatch(value.toString()) !=
                              true) {
                            flagEml = "invald Email";
                            return "";
                          } else {
                            flagEml = "";
                            if (emlFocus.hasFocus) {
                              borderColorEml =
                                  Theme.of(context).colorScheme.primary;
                            }
                            return null;
                          }
                        }),
                  ),
                  Visibility(
                    visible: (flagEml == "") ? false : true,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            emlError,
                            style: UiHelper.errorFont,
                          ),
                        ),
                      ],
                    ),
                  ),
                        
                        const SizedBox(
                          height: 10,
                        ),
                     /* old password   TextFormField(
                          style: const TextStyle(fontFamily:"EuclidCircularB"),
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
                            validator: (value) {
                              if (value.toString().trim() == "") {
                                return "empty field";
                              }
                              else
                              {return null;}
                            },
                            onSaved: (value) {
                              setState(() {
                                password = value!;
                              });
                            }),
                        */
                           // password
                  Container(
                    height: 56,
                    padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: (!(flagPass == ""))
                              ? const Color.fromRGBO(238, 75, 75, 1)
                              : _borderColorPass,
                          width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                        focusNode: passFocus,
                        style: TextStyle(fontFamily:"EuclidCircularB"),
                        obscureText: passwordVisible,
                        controller: _passcontroller,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            labelText: "Password",
                            labelStyle:  TextStyle(fontFamily:"EuclidCircularB"),
                            errorStyle: const TextStyle(
                                fontSize:
                                    0), // so that cursor does not go belyond boundry
                            suffix: IconButton(
                                onPressed: () {
                                  setState(() {
                                    passwordVisible = !passwordVisible;
                                  });
                                },
                                icon:  Image(
                                    image: AssetImage((obscure == true)
                                        ? "assets/eyebrow.png"
                                        : "assets/visibility.png"),
                                    width: 25,
                                    height: 20,
                                  ))),
                        onChanged:
                            (validationMode == AutovalidateMode.onUserInteraction)
                                ? (value) {
                                    loginKey.currentState!.validate();
                                  }
                                : (value) {},
                        validator: (value) {
                          // if (value?.isEmpty == true) {
                          //  flagPass = "password cannot be empty";
                          //     return "";
                          //   } else
                          if (value.toString().isEmpty) {
                            flagPass = "cannot be empty";
                            return "";
                          } else {
                            flagPass = "";
                            if (passFocus.hasFocus) {
                              _borderColorPass =
                                  Theme.of(context).colorScheme.primary;
                            }
                            return null;
                          }
                        }),
                  ),
        
                  // password error
                  Visibility(
                    visible: (flagPass == "") ? false : true,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            flagPass,
                            style: UiHelper.errorFont,
                          ),
                        ),
                      ],
                    ),
                  ),
                        
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          child: TextButton(
                              onPressed: () {

                                if (loginKey.currentState!.validate()) {
                                  debugPrint("submitted");
                                  loginKey.currentState!.save();
                                  setState(() {
                                    passwordError = "";
                                    emlError = "";
                                  });
                                  loginFun();
                                }else {
                        if (flagEml != "") {
                          setState(() {
                            emlError = flagEml;
                            passwordError = flagPass;
                            validationMode = AutovalidateMode.onUserInteraction;
                          });
                        }
        
                        if (flagPass != "") {
                          setState(() {
                            passwordError = flagPass;
                            emlError = flagEml;
                            validationMode = AutovalidateMode.onUserInteraction;
                          });
                        }
                      }
                              },
                              style: ButtonStyle(
                                  padding: const WidgetStatePropertyAll(
                                      EdgeInsets.all(10)),
                                  shape: WidgetStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  )),
                                  backgroundColor: const WidgetStatePropertyAll(
                                      Color.fromARGB(255, 240, 217, 148))),
                              child: const Text(
                                "Log In ",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontFamily:"EuclidCircularB",
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
                      "Don't have an account ?",
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
                                builder: (context) => const SignInPage()));
                      },
                      child: const Text(
                        "Sign Up",
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
      ),
    );
  }

  void loginFun() async {
    auth.UserCredential? userCredential;
    UiHelper.loadingDialogFun(context,"Logging In...");
    try {
      userCredential = await auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _emlcontroller.text.trim(), password: _passcontroller.text.trim());
    } on auth.FirebaseAuthException catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Could Not Login :$e" ,style: const TextStyle(fontFamily:"EuclidCircularB"))));
      debugPrint("login exception $e");
    }
    if (userCredential != null) {
      final userId = userCredential.user!.uid;

      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection("ChatAppUsers")
          .doc(userId)
          .get();
      UserModel userModel = UserModel.fromMap(userData.data() as Map<String, dynamic>);
      Navigator.popUntil(context, (route) => route.isFirst);
      ////////////////
       if (userModel.name == "" || userModel.name == null) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => CompleteUserProfile(
                        firebaseUser: userCredential!.user!,
                        userModel: userModel,
                      )));
        }else{
      //////
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: ((context) => HomePage(
                    firebaseUser: userCredential!.user!,
                    userModel: userModel,
                  ))
                )
              );
        }
  
    }
  }
}
