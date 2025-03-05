import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proj/ChatApp/models/user_model.dart';
import 'package:proj/ChatApp/pages/adding_people/search_page.dart';

class NoChats extends StatefulWidget {
   const NoChats({super.key ,required this.firebaseUser, required this.userModel});
  final User firebaseUser;
  final UserModel userModel;

  @override
  State<NoChats> createState() => _NoChatsState();
}

class _NoChatsState extends State<NoChats> {
  @override
  Widget build(BuildContext context) {
    return  Padding(padding: const EdgeInsets.all(20),
     child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image(image: const AssetImage("assets/bubble_chat.png"),
        height: MediaQuery.sizeOf(context).width/2,
        width: MediaQuery.sizeOf(context).width/2,
        ),
         const SizedBox(height: 60,),
          ElevatedButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                          Color.fromARGB(255, 247, 155, 148))
                          ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context)=> 
                      SearchPage(firebaseUser: widget.firebaseUser, userModel: widget.userModel)));
                  },
                  child: const Text(
                    "Add Friends",
                    style: TextStyle(
                       fontFamily:"EuclidCircularB",  
                      color: Colors.black),

                  ))
      ],
     ),
    
    );
  }
}