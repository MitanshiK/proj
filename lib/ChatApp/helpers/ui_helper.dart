import 'package:flutter/material.dart';

class UiHelper{
// to show loading
  static void loadingDialogFun(BuildContext context,String content){
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
       return AlertDialog(
        backgroundColor: Colors.transparent,
          content: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Image.asset("assets/loader2.gif",width: 100,height: 100,),
              const SizedBox(height: 10,),
              Text(content.toUpperCase() ,style: TextStyle(fontFamily: "EuclidCircularB",fontSize: 15,fontWeight: FontWeight.w500,color: const Color.fromARGB(255, 244, 211, 111)),)
            ],),
          ),
       );
      }, );

  }

  // to show some message
  static void messageDialog(BuildContext context ,String content){
    showDialog(
      barrierDismissible: false,
      context: context,
       builder: (BuildContext context) { 
      return AlertDialog(
        title: const Text("Error"),
        content: Text(content),
        actions: [
          TextButton(onPressed: (){
           Navigator.pop(context);
          }, child: const Text("Ok"))
        ],
      );
    },
   );
  }
static final emailRegExp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
static final passRegExp=RegExp(r'^(?=.*?[A-Z])(?=.*?[0-9]).{8,}$'); 

  static const errorFont=TextStyle(
                    color: Color.fromRGBO(238, 75, 75, 1),
                    fontWeight: FontWeight.w500,
                    fontFamily: "EuclidCircularB",
                    fontSize: 12,
                  );
// // to choose if we want a video or picture camera to open
//   static String cameraType(BuildContext context ){
//     String CamType="";
//     showDialog(
//       context: context,
//      builder: (BuildContext context) { 
//       return AlertDialog(
//        title: const Text("Camera"),
//        content: Row(children: [
//         // for picture
//         IconButton(onPressed: (){
//         CamType= "picture";
//         }, icon: const Icon(Icons.image)),
       
//         // for video
//         IconButton(onPressed: (){
//         CamType="video";
//         }, icon: const Icon(Icons.video_camera_back))
//        ],)
//       );
//       });
//       return CamType;
//   }
}