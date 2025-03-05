// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:keyboard_emoji_picker/keyboard_emoji_picker.dart';
// import 'package:proj/ChatApp/models/chat_room_model.dart';
// import 'package:proj/ChatApp/models/contacts_model.dart';
// import 'package:proj/ChatApp/models/firebase_helper.dart';
// import 'package:proj/ChatApp/models/group_room_model.dart';
// import 'package:proj/ChatApp/models/media_model.dart';
// import 'package:proj/ChatApp/models/message_model.dart';
// import 'package:proj/ChatApp/models/ui_helper.dart';
// import 'package:proj/ChatApp/models/user_model.dart';
// import 'package:proj/ChatApp/pages/splash_screen.dart';
//
// import 'package:proj/local_notifications/notif.dart';
//
// import 'package:uuid/uuid.dart';
// // final navigatorKey=GlobalKey<NavigatorState>();  // Navigator key to navigate

// // Future<void> main() async{
// //    WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp();

// // // for push notifications
// //   await  PushNotiServices().initialize();

// //  ///////////

// //   runApp(const MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   // This widget is the root of your application.
// //   @override
// //   Widget build(BuildContext context) {

// //     return  MaterialApp(
// //       title: 'Flutter Demo',
// //       theme: ThemeData(
// //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
// //         useMaterial3: true,
// //       ),
// //       navigatorKey: navigatorKey,
// //       home:  Loginpage(),
// //     );

// // for push notif
// /*  MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       navigatorKey: navigatorKey,
//       home:  NotiHome(),
//       routes: {
//       Notif.route:(context)=> const Notif()      // route variable declared in ShowData class;
//       },
//     );*/
// ////end
// //   }
// // }

// //////////////////////////////////////chat app
// // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =FlutterLocalNotificationsPlugin(); //for local notification

// // Uuid uuid =Uuid(); 
// // /*
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =FlutterLocalNotificationsPlugin(); //for local notification

// Uuid uuid =Uuid();  // creates unique id

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }
// ////////////////////
// void  main() async {


// // SSLSocketFactory sslSocketFactory;
// // try {
// //     SSLContext sslContext = SSLContext.getInstance("TLSv1.2");
// //     sslContext.init(null, null, null);
// //     sslSocketFactory = sslContext.getSocketFactory();
// // } catch (Exception e) {
// //     throw new RuntimeException("Failed to create SSL Socket Factory", e);
// // }

// // // Use the custom SSLSocketFactory in your client
// // OkHttpClient client = new OkHttpClient.Builder()
// //     .sslSocketFactory(sslSocketFactory, trustManager)
// //     .build();

// HttpOverrides.global = MyHttpOverrides();
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

//   try{
//  Notif.initialNotiSettigs(flutterLocalNotificationsPlugin ); 
//  debugPrint("noti initialized");
//   }catch(e){
//     debugPrint("could no initialize $e");
//   }
  
//   UiHelper.firebaseUser = FirebaseAuth.instance.currentUser; // getting current user
//   //initialize
//   if (UiHelper.firebaseUser != null) {

//    UiHelper.userModel = await FirebaseHelper.getUserModelById(UiHelper.firebaseUser!.uid); // getting data of user using userId
   
//    if(UiHelper.userModel!=null){

//       await FirebaseFirestore.instance
//                     .collection("chatrooms")
//                     .where("participantsId.${UiHelper.userModel!.uId}", isEqualTo: true)
//                     .snapshots().listen((event) { 
                    

//                         for(var i in event.docs){

//              ChatRoomModel chatRoom = ChatRoomModel.fromMap(  // getting chatroom
//                           i.data());

//                      FirebaseFirestore.instance
//                     .collection("chatrooms")
//                     .doc(chatRoom.chatRoomId)
//                     .collection("messages") .orderBy("createdOn",
//                         descending:
//                             true).snapshots().listen((event) async{

                 

//                       // MessageModel message=MessageModel.fromMap(  // getting chatroom
//                       //     event.docs.reversed.last .data() as Map<String, dynamic>); 
//                       /// for type of message
                       
//                       var dt = event.docs.reversed.last .data(); // map of data at particular index
//                           // var a=dt[index];
//                           late final message;
//                          late final messageType;

//                           ///

//                           if (dt.containsValue("text") == true ) {
                          
//                             // if message is text
//                             message = MessageModel.fromMap(
//                                 event.docs.reversed.last.data());

//                     UserModel? sender1 = await FirebaseHelper.getUserModelById(message.senderId);

//                        // if current user is not the user who sent the message , 
//                      // the message is sent in the same minute as now time 
//                      // both user are in part of same chatroom then send the notification       
//                         if(UiHelper.userModel!.uId != message.senderId && message.createdOn!.minute ==DateTime.now().minute){
//                               Notif.showBigTextNotification(title: sender1!.name!, body: message.text.toString(), fn: flutterLocalNotificationsPlugin);
//                           }
                                
//                           } else if (dt.containsValue("image") == true ||
//                               dt.containsValue("video") == true ||
//                               dt.containsValue("audio") 
//                              ) {
//                             message = MediaModel.fromMap(
//                                 event.docs.reversed.last.data());


//                              if(UiHelper.userModel!.uId != message.senderId && message.createdOn!.minute ==DateTime.now().minute){
//                               if (dt.containsValue("image") == true) {
//                               messageType = "image";
                          
//                                   Notif.showBigTextNotification(title: senderModal!.name!, body: "image Recieved", fn: flutterLocalNotificationsPlugin);
                          
//                               debugPrint(" its an image $messageType");
//                             } else if (dt.containsValue("video") == true) {
//                               messageType = "video";
//                                Notif.showBigTextNotification(title: senderModal!.name!, body: "video Recieved", fn: flutterLocalNotificationsPlugin);
//                             } else if (dt.containsValue("audio")) {
//                               messageType = "audio";
//                                Notif.showBigTextNotification(title: senderModal!.name!, body: "audio message Recieved", fn: flutterLocalNotificationsPlugin);
//                             }
//                             }

//                           } else  if(dt.containsValue("contact")==true){  // for contact
//                              message = ContactModal.fromMap(
//                                 event.docs.reversed.last.data());
//                             messageType = "contact";
//                           }
// //////////////////
                  
//                   // // getting senders info         // not in work
//                   // UserModel senderData; 
//                   //  FirebaseFirestore.instance
//                   //   .collection("ChatAppUsers")
//                   //   .where("participantsId.${message.senderId}", isEqualTo: true).snapshots().first.then((value) {
//                   //        senderData=UserModel.fromMap(  
//                   //          value.docs.first.data() as Map<String, dynamic>);
//                   //            debugPrint("${senderData.name} is the sender");
//                   //   });
                  
//                     });
                     
//               } // 1st for loop
//                     });

//     /////////////////////////for groups notification
                  

//               await FirebaseFirestore.instance
//                     .collection("GroupChats")
//                     .where("participantsId.${UiHelper.userModel!.uId}", isEqualTo: true)
//                     .snapshots().listen((event) { 
                    

//                         for(var i in event.docs){

//              GroupRoomModel groupRoom = GroupRoomModel.fromMap(  // getting chatroom
//                           i.data());

//                      FirebaseFirestore.instance
//                     .collection("GroupChats")
//                     .doc(groupRoom.groupRoomId)
//                     .collection("messages") .orderBy("createdOn",
//                         descending:
//                             true).snapshots().listen((event) async{

//                      /// for type of message
//                       var dt = event.docs.reversed.last .data(); // map of data at particular index
//                           // var a=dt[index];
//                           late final message;
//                          late final messageType;

//                           ///
//                           if (dt.containsValue("text") == true ) {
                          
//                             // if message is text
//                             message = MessageModel.fromMap(
//                                 event.docs.reversed.last.data());

//                       // for the senderdata
//                        UserModel? sender = await FirebaseHelper.getUserModelById(message.senderId);
                 
//                        // if current user is not the user who sent the message , 
//                       // the message is sent in the same minute as now time 
//                      // both user are in part of same chatroom then send the notification       
//                         if(UiHelper.userModel!.uId != message.senderId && message.createdOn!.minute ==DateTime.now().minute){
//                               debugPrint("name of sender is ${sender!.name}");
//                               Notif.showBigTextNotification(title: groupRoom.groupName!, body: "${sender.name!}: ${message.text.toString()}", fn: flutterLocalNotificationsPlugin);
//                           }
                                
//                           } else if (dt.containsValue("image") == true ||
//                               dt.containsValue("video") == true ||
//                               dt.containsValue("audio") 
//                              ) {
//                             message = MediaModel.fromMap(
//                                 event.docs.reversed.last.data());


//                              if(UiHelper.userModel!.uId != message.senderId && message.createdOn!.minute ==DateTime.now().minute){
//                               if (dt.containsValue("image") == true) {
//                               messageType = "image";
                          
//                              Notif.showBigTextNotification(title: senderModal!.name!, body: "image Recieved", fn: flutterLocalNotificationsPlugin);
                          
//                               debugPrint(" its an image $messageType");
//                             } else if (dt.containsValue("video") == true) {
//                               messageType = "video";
//                                Notif.showBigTextNotification(title: senderModal!.name!, body: "video Recieved", fn: flutterLocalNotificationsPlugin);
//                             } else if (dt.containsValue("audio")) {
//                               messageType = "audio";
//                                Notif.showBigTextNotification(title: senderModal!.name!, body: "audio message Recieved", fn: flutterLocalNotificationsPlugin);
//                             } 
//                             }

//                           } else  if(dt.containsValue("contact")==true){  // for contact
//                              message = ContactModal.fromMap(
//                                 event.docs.reversed.last.data());
//                             messageType = "contact";
//                           }
                  
//                     });
                     
//               } // 1st for loop
//                     });


//    runApp(
//   //  MaterialApp(home: LocalNotifications())
//     MyAppLoggedIn(
//       firebaseUser:UiHelper.firebaseUser!,
//       userModel: UiHelper.userModel!,
//     )
//     );
//    }else{
//      runApp( MyApp());
//    }
 
  
//   } else {
//     runApp(MyApp());
//   }
// }

// // if no user is  logged in
// class MyApp extends StatefulWidget {
//    MyApp({super.key });

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Chat App',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home:SplashScreen(destination: 'login'),
//     );
//   }
// }

// // if user already logged in
// class MyAppLoggedIn extends StatefulWidget {
//   final UserModel userModel;
//   final User firebaseUser;

//   const MyAppLoggedIn(
//       {super.key, required this.firebaseUser, required this.userModel});

//   @override
//   State<MyAppLoggedIn> createState() => _MyAppLoggedInState();
// }

// class _MyAppLoggedInState extends State<MyAppLoggedIn> with WidgetsBindingObserver {
  
//   ///////////////////////////
//   DateTime? _startTime;
//   DateTime? _endTime;

//   @override
//   void initState() {
//     ///
//     // showBaselines();
//     // highlightRepaints();
//     // showOversizedImages();
//    ///
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//   }
//     @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _startTime = DateTime.now();
//     } else if (state == AppLifecycleState.paused ||
//                state == AppLifecycleState.detached) {
//       _endTime = DateTime.now();
//       _calculateTimeOpen();
//     }
//   }

//   void _calculateTimeOpen() {
//     if (_startTime != null && _endTime != null) {
//       final duration = _endTime!.difference(_startTime!);
//       debugPrint('App was open for: ${duration.inSeconds} seconds');
//       savetimeData(duration);
//     }
//   }

// //// saving screen time to firebase
//   void savetimeData(Duration totDuration) async{
//   debugPrint(" inside saveTime fun");
//  String curDate="${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}";

// DocumentSnapshot<Map<String, dynamic>>? result;
// Map<String, dynamic>? todaytime;
// int prevDuration=0;

//  ////getting
//  try{
//    result= await FirebaseFirestore.instance.collection("ChatAppUsers")
//                .doc(widget.userModel.uId).collection("screenTime").doc(curDate).get();
//               //  .where("${curDate}" ,isGreaterThan: 0).get();
//    todaytime = await result.data();
//      debugPrint("result1 is ${result.data()} , todaytime ");
//    // debugPrint("result1 is ${result.data()!.keys.first} , todaytime ${result.data()![curDate]}");
//     }catch(e){
//       debugPrint("the error in getting result is $e");
//     }
//  debugPrint("outside try");

//   if(result!.data()!=null){
//     //  debugPrint("result2 is ${todaytime![curDate]}");
// //  final docData=todaytime[curDate];
//      prevDuration=result.data()![curDate];
//      int newDuration=totDuration.inSeconds+ prevDuration;
//      debugPrint("value of prevDuration is $prevDuration , new duration is $newDuration" );


//    Map<String,int> newScreenTime={
//     "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}" : newDuration
//    };
//        await FirebaseFirestore.instance.collection("ChatAppUsers")
//   .doc(widget.userModel.uId).collection("screenTime").doc(curDate).update(newScreenTime);
//     //  final docData=result.docs[0].data()[curDate];
//   }

//  if(result.data()==null){
//    debugPrint("inside if null");
//     ///creating
//    Map<String,int> screenTime={
//     "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}" : totDuration.inSeconds
//    };
// try{
//   await FirebaseFirestore.instance.collection("ChatAppUsers")
//   .doc(widget.userModel.uId).collection("screenTime").doc(curDate).set(screenTime);
//   }catch(e){
//     debugPrint("could not create screentime $e");
//   }
//   // chatRoomModel=newChatRoomModel;  // for returning
// }

//   // result.docs.first.data();
//   }
//   //////////////////////////

//   @override
//   Widget build(BuildContext context) {
//     return KeyboardEmojiPickerWrapper(
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'Flutter Demo',
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//           useMaterial3: true,
//         ),
//         home:SplashScreen(destination: 'home', firebaseUser: widget.firebaseUser, userModel: widget.userModel,),
//       ),
//     );
//   }
// }

// void showBaselines() {
//   debugPaintBaselinesEnabled = true;
// }
// void highlightRepaints() {
//   debugRepaintRainbowEnabled = true;
// }
// void showOversizedImages() {
//   debugInvertOversizedImages = true;
// }
// // */
// //////////////////////////////////////chat app
// //    Future notifStream()async{


// //   await FirebaseFirestore.instance
// //                     .collection("chatrooms")
// //                     .where("participantsId.${userModel.uId}", isEqualTo: true)
// //                     .snapshots().listen((event) { 

// //                         // ChatRoomModel chatRoom = ChatRoomModel.fromMap(
// //                         // event.docs[0].data()
// //                         //     as Map<String, dynamic>);

// //                      Notif.showBigTextNotification(title: "hello", body: "body", fn: flutterLocalNotificationsPlugin); ///
// //                     });
// // }
// ////////////////////////////////

// // void main() async {
// //     WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp();
// // runApp(const ProviderScope(child: MyApp()));
// // } 

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   // This widget is the root of your application.
// //   @override
// //   Widget build(BuildContext context) {

// //     return  MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       title: 'Shopping Cart',
// //       theme: ThemeData(
// //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
// //         useMaterial3: true,
// //       ),
// //       home: const Screen1(),
// //     );
// //   }
// // }









import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_emoji_picker/keyboard_emoji_picker.dart';
import 'package:proj/ChatApp/models/chat_room_model.dart';
import 'package:proj/ChatApp/models/contacts_model.dart';
import 'package:proj/ChatApp/helpers/firebase_helper.dart';
import 'package:proj/ChatApp/models/group_room_model.dart';
import 'package:proj/ChatApp/models/media_model.dart';
import 'package:proj/ChatApp/models/message_model.dart';
import 'package:proj/ChatApp/models/user_model.dart';
import 'package:proj/ChatApp/pages/splash_screen.dart';

import 'package:proj/local_notifications/notif.dart';

import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';


// final navigatorKey=GlobalKey<NavigatorState>();  // Navigator key to navigate

// Future<void> main() async{
//    WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

// // for push notifications
//   await  PushNotiServices().initialize();

//  ///////////

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {

//     return  MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       navigatorKey: navigatorKey,
//       home:  Loginpage(),
//     );

// for push notif
/*  MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      home:  NotiHome(),
      routes: {
      Notif.route:(context)=> const Notif()      // route variable declared in ShowData class;
      },
    );*/
////end
//   }
// }

//////////////////////////////////////chat app 
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =FlutterLocalNotificationsPlugin(); //for local notification

Uuid uuid =const Uuid();  // creates unique id 


void myTask() {
  // Define your background task for checking for new messages or notifications
  print("Checking for new messages...");

  // Fetch messages or trigger notifications here
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    myTask();
    return Future.value(true); // Return a value after task is complete
  });
}


void  main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
 /* */

Future<void> backgroundMessageHandler(RemoteMessage message) async {
  // Here, you can handle the notification received in the background.
  // You can use local notifications to show the message as a notification
  print("Background message: ${message.notification?.title}");
    User? currentUser = FirebaseAuth.instance.currentUser; // getting current user

    UserModel? userModel = await FirebaseHelper.getUserModelById(currentUser!.uid);
   if(userModel!=null){

      FirebaseFirestore.instance
                    .collection("chatrooms")
                    .where("participantsId.${userModel.uId}", isEqualTo: true)
                    .snapshots().listen((event) { 
                    

                        for(var i in event.docs){

             ChatRoomModel chatRoom = ChatRoomModel.fromMap(  // getting chatroom
                          i.data());

                     FirebaseFirestore.instance
                    .collection("chatrooms")
                    .doc(chatRoom.chatRoomId)
                    .collection("messages") .orderBy("createdOn",
                        descending:
                            true).snapshots().listen((event) async{

                 

                      // MessageModel message=MessageModel.fromMap(  // getting chatroom
                      //     event.docs.reversed.last .data() as Map<String, dynamic>); 
                      /// for type of message
                       
                      var dt = event.docs.reversed.last .data(); // map of data at particular index
                          // var a=dt[index];
                          late final message;
                         late final messageType;

                          ///

                          if (dt.containsValue("text") == true ) {
                          
                            // if message is text
                            message = MessageModel.fromMap(
                                event.docs.reversed.last.data());

                    UserModel? sender1 = await FirebaseHelper.getUserModelById(message.senderId);

                       // if current user is not the user who sent the message , 
                     // the message is sent in the same minute as now time 
                     // both user are in part of same chatroom then send the notification       
                        if(userModel.uId != message.senderId && message.createdOn!.minute ==DateTime.now().minute){
                              Notif.showBigTextNotification(title: sender1!.name!, body: message.text.toString(), fn: flutterLocalNotificationsPlugin);
                          }
                                
                          } else if (dt.containsValue("image") == true ||
                              dt.containsValue("video") == true ||
                              dt.containsValue("audio") 
                             ) {
                            message = MediaModel.fromMap(
                                event.docs.reversed.last.data());


                             if(userModel.uId != message.senderId && message.createdOn!.minute ==DateTime.now().minute){
                              UserModel? senderModal = await FirebaseHelper.getUserModelById(message.senderId);  //get data of sender
                              
                              if (dt.containsValue("image") == true) {
                              messageType = "image";
                          
                                  Notif.showBigTextNotification(title: senderModal!.name!, body: "image Recieved", fn: flutterLocalNotificationsPlugin);
                          
                              debugPrint(" its an image $messageType");
                            } else if (dt.containsValue("video") == true) {
                              messageType = "video";
                               Notif.showBigTextNotification(title: senderModal!.name!, body: "video Recieved", fn: flutterLocalNotificationsPlugin);
                            } else if (dt.containsValue("audio")) {
                              messageType = "audio";
                               Notif.showBigTextNotification(title: senderModal!.name!, body: "audio message Recieved", fn: flutterLocalNotificationsPlugin);
                            }
                            }

                          } else  if(dt.containsValue("contact")==true){  // for contact
                             message = ContactModal.fromMap(
                                event.docs.reversed.last.data());
                            messageType = "contact";
                          }
//////////////////
                  
                  // // getting senders info         // not in work
                  // UserModel senderData; 
                  //  FirebaseFirestore.instance
                  //   .collection("ChatAppUsers")
                  //   .where("participantsId.${message.senderId}", isEqualTo: true).snapshots().first.then((value) {
                  //        senderData=UserModel.fromMap(  
                  //          value.docs.first.data() as Map<String, dynamic>);
                  //            debugPrint("${senderData.name} is the sender");
                  //   });
                  
                    });
                     
              } // 1st for loop
                    });

    /////////////////////////for groups notification
                  

              FirebaseFirestore.instance
                    .collection("GroupChats")
                    .where("participantsId.${userModel.uId}", isEqualTo: true)
                    .snapshots().listen((event) { 
                    

                        for(var i in event.docs){

             GroupRoomModel groupRoom = GroupRoomModel.fromMap(  // getting chatroom
                          i.data());

                     FirebaseFirestore.instance
                    .collection("GroupChats")
                    .doc(groupRoom.groupRoomId)
                    .collection("messages") .orderBy("createdOn",
                        descending:
                            true).snapshots().listen((event) async{

                     /// for type of message
                      var dt = event.docs.reversed.last .data(); // map of data at particular index
                          // var a=dt[index];
                          late final message;
                         late final messageType;

                          ///
                          if (dt.containsValue("text") == true ) {
                          
                            // if message is text
                            message = MessageModel.fromMap(
                                event.docs.reversed.last.data());

                      // for the senderdata
                       UserModel? sender = await FirebaseHelper.getUserModelById(message.senderId);
                 
                       // if current user is not the user who sent the message , 
                      // the message is sent in the same minute as now time 
                     // both user are in part of same chatroom then send the notification       
                        if(userModel.uId != message.senderId && message.createdOn!.minute ==DateTime.now().minute){
                              debugPrint("name of sender is ${sender!.name}");
                              Notif.showBigTextNotification(title: groupRoom.groupName!, body: "${sender.name!}: ${message.text.toString()}", fn: flutterLocalNotificationsPlugin);
                          }
                                
                          } else if (dt.containsValue("image") == true ||
                              dt.containsValue("video") == true ||
                              dt.containsValue("audio") 
                             ) {
                            message = MediaModel.fromMap(
                                event.docs.reversed.last.data());


                             if(userModel.uId != message.senderId && message.createdOn!.minute ==DateTime.now().minute){
                              UserModel? senderModal = await FirebaseHelper.getUserModelById(message.senderId);  //get data of sender
                             
                              if (dt.containsValue("image") == true) {
                              messageType = "image";
                          
                             Notif.showBigTextNotification(title: senderModal!.name!, body: "image Recieved", fn: flutterLocalNotificationsPlugin);
                          
                              debugPrint(" its an image $messageType");
                            } else if (dt.containsValue("video") == true) {
                              messageType = "video";
                               Notif.showBigTextNotification(title: senderModal!.name!, body: "video Recieved", fn: flutterLocalNotificationsPlugin);
                            } else if (dt.containsValue("audio")) {
                              messageType = "audio";
                               Notif.showBigTextNotification(title: senderModal!.name!, body: "audio message Recieved", fn: flutterLocalNotificationsPlugin);
                            } 
                            }

                          } else  if(dt.containsValue("contact")==true){  // for contact
                             message = ContactModal.fromMap(
                                event.docs.reversed.last.data());
                            messageType = "contact";
                          }
                  
                    });
                     
              } // 1st for loop
                    });



   
   }
}
FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);



  //// Initialize WorkManager
  // Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  //// Schedule the periodic task
  // Workmanager().registerPeriodicTask(
  //   '1',
  //   'simpleTask',
  //   frequency: Duration(hours: 1), // Periodically check for new messages
  //   initialDelay: Duration(seconds: 10),
  // );


/* */

  try{
 Notif.initialNotiSettigs(flutterLocalNotificationsPlugin ); 
 debugPrint("noti initialized");
  }catch(e){
    debugPrint("could no initialize $e");
  }
  
  User? currentUser = FirebaseAuth.instance.currentUser; // getting current user
  //initialize
  if (currentUser != null) {

    UserModel? userModel = await FirebaseHelper.getUserModelById(currentUser.uid); // getting data of user using userId
   
   if(userModel!=null){

      FirebaseFirestore.instance
                    .collection("chatrooms")
                    .where("participantsId.${userModel.uId}", isEqualTo: true)
                    .snapshots().listen((event) { 
                    

                        for(var i in event.docs){

             ChatRoomModel chatRoom = ChatRoomModel.fromMap(  // getting chatroom
                          i.data());

                     FirebaseFirestore.instance
                    .collection("chatrooms")
                    .doc(chatRoom.chatRoomId)
                    .collection("messages") .orderBy("createdOn",
                        descending:
                            true).snapshots().listen((event) async{

                 

                      // MessageModel message=MessageModel.fromMap(  // getting chatroom
                      //     event.docs.reversed.last .data() as Map<String, dynamic>); 
                      /// for type of message
                       
                      var dt = event.docs.reversed.last.data(); // map of data at particular index
                          // var a=dt[index];
                          late final message;
                         late final messageType;

                          ///

                          if (dt.containsValue("text") == true ) {
                          
                            // if message is text
                            message = MessageModel.fromMap(
                                event.docs.reversed.last.data());

                    UserModel? sender1 = await FirebaseHelper.getUserModelById(message.senderId);

                       // if current user is not the user who sent the message , 
                     // the message is sent in the same minute as now time 
                     // both user are in part of same chatroom then send the notification       
                        if(userModel.uId != message.senderId && message.createdOn!.minute ==DateTime.now().minute){
                              Notif.showBigTextNotification(title: sender1!.name!, body: message.text.toString(), fn: flutterLocalNotificationsPlugin);
                          }
                                
                          } else if (dt.containsValue("image") == true ||
                              dt.containsValue("video") == true ||
                              dt.containsValue("audio") 
                             ) {
                            message = MediaModel.fromMap(
                                event.docs.reversed.last.data());


                             if(userModel.uId != message.senderId && message.createdOn!.minute ==DateTime.now().minute){
                              UserModel? senderModal = await FirebaseHelper.getUserModelById(message.senderId);  //get data of sender
                              
                              if (dt.containsValue("image") == true) {
                              messageType = "image";
                          
                                  Notif.showBigTextNotification(title: senderModal!.name!, body: "image Recieved", fn: flutterLocalNotificationsPlugin);
                          
                              debugPrint(" its an image $messageType");
                            } else if (dt.containsValue("video") == true) {
                              messageType = "video";
                               Notif.showBigTextNotification(title: senderModal!.name!, body: "video Recieved", fn: flutterLocalNotificationsPlugin);
                            } else if (dt.containsValue("audio")) {
                              messageType = "audio";
                               Notif.showBigTextNotification(title: senderModal!.name!, body: "audio message Recieved", fn: flutterLocalNotificationsPlugin);
                            }
                            }

                          } else  if(dt.containsValue("contact")==true){  // for contact
                             message = ContactModal.fromMap(
                                event.docs.reversed.last.data());
                            messageType = "contact";
                          }
//////////////////
                  
                  // // getting senders info         // not in work
                  // UserModel senderData; 
                  //  FirebaseFirestore.instance
                  //   .collection("ChatAppUsers")
                  //   .where("participantsId.${message.senderId}", isEqualTo: true).snapshots().first.then((value) {
                  //        senderData=UserModel.fromMap(  
                  //          value.docs.first.data() as Map<String, dynamic>);
                  //            debugPrint("${senderData.name} is the sender");
                  //   });
                  
                    });
                     
              } // 1st for loop
                    });

    /////////////////////////for groups notification
                  

              FirebaseFirestore.instance
                    .collection("GroupChats")
                    .where("participantsId.${userModel.uId}", isEqualTo: true)
                    .snapshots().listen((event) { 
                    

                        for(var i in event.docs){

             GroupRoomModel groupRoom = GroupRoomModel.fromMap(  // getting chatroom
                          i.data());

                     FirebaseFirestore.instance
                    .collection("GroupChats")
                    .doc(groupRoom.groupRoomId)
                    .collection("messages") .orderBy("createdOn",
                        descending:
                            true).snapshots().listen((event) async{

                     /// for type of message
                      var dt = event.docs.reversed.last .data(); // map of data at particular index
                          // var a=dt[index];
                          late final message;
                         late final messageType;

                          ///
                          if (dt.containsValue("text") == true ) {
                          
                            // if message is text
                            message = MessageModel.fromMap(
                                event.docs.reversed.last.data());

                      // for the senderdata
                       UserModel? sender = await FirebaseHelper.getUserModelById(message.senderId);
                 
                       // if current user is not the user who sent the message , 
                      // the message is sent in the same minute as now time 
                     // both user are in part of same chatroom then send the notification       
                        if(userModel.uId != message.senderId && message.createdOn!.minute ==DateTime.now().minute){
                              debugPrint("name of sender is ${sender!.name}");
                              Notif.showBigTextNotification(title: groupRoom.groupName!, body: "${sender.name!}: ${message.text.toString()}", fn: flutterLocalNotificationsPlugin);
                          }
                                
                          } else if (dt.containsValue("image") == true ||
                              dt.containsValue("video") == true ||
                              dt.containsValue("audio") 
                             ) {
                            message = MediaModel.fromMap(
                                event.docs.reversed.last.data());


                             if(userModel.uId != message.senderId && message.createdOn!.minute ==DateTime.now().minute){
                              UserModel? senderModal = await FirebaseHelper.getUserModelById(message.senderId);  //get data of sender
                             
                              if (dt.containsValue("image") == true) {
                              messageType = "image";
                          
                             Notif.showBigTextNotification(title: senderModal!.name!, body: "image Recieved", fn: flutterLocalNotificationsPlugin);
                          
                              debugPrint(" its an image $messageType");
                            } else if (dt.containsValue("video") == true) {
                              messageType = "video";
                               Notif.showBigTextNotification(title: senderModal!.name!, body: "video Recieved", fn: flutterLocalNotificationsPlugin);
                            } else if (dt.containsValue("audio")) {
                              messageType = "audio";
                               Notif.showBigTextNotification(title: senderModal!.name!, body: "audio message Recieved", fn: flutterLocalNotificationsPlugin);
                            } 
                            }

                          } else  if(dt.containsValue("contact")==true){  // for contact
                             message = ContactModal.fromMap(
                                event.docs.reversed.last.data());
                            messageType = "contact";
                          }
                  
                    });
                     
              } // 1st for loop
                    });


   runApp(
  //  MaterialApp(home: LocalNotifications())
    ProviderScope(
      child: MyAppLoggedIn(
        firebaseUser:currentUser,
        userModel: userModel,
      ),
    )
    );
   
   }else{
     runApp( const ProviderScope(child: MyApp()));
   }
 
  
  } else {
    runApp(const ProviderScope(child: MyApp()));
  }
}

// if no user is  logged in
class MyApp extends StatefulWidget {
   const MyApp({super.key });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
        brightness: Brightness.light,
        canvasColor: Colors.grey.shade200,
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:const SplashScreen(destination: 'login'),
    );
  }
}







// if user already logged in
class MyAppLoggedIn extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn(
      {super.key, required this.firebaseUser, required this.userModel});

  @override
  State<MyAppLoggedIn> createState() => _MyAppLoggedInState();
}

class _MyAppLoggedInState extends State<MyAppLoggedIn> with WidgetsBindingObserver {
  
  ///////////////////////////
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void initState() {
    ///
    // showBaselines();
    // highlightRepaints();
    // showOversizedImages();
   ///
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
    @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTime = DateTime.now();
    } else if (state == AppLifecycleState.paused ||
               state == AppLifecycleState.detached) {
      _endTime = DateTime.now();
      _calculateTimeOpen();
    }
  }
// todayDate  ,todayDate
  void _calculateTimeOpen() {
    if (_startTime != null && _endTime != null) {
      final duration = _endTime!.difference(_startTime!);
      debugPrint('App was open for: ${duration.inSeconds} seconds');
      savetimeData(duration);
    }
  }

//// saving screen time to firebase
  void savetimeData(Duration totDuration) async{
     User? currentUser = FirebaseAuth.instance.currentUser;
     debugPrint(" inside saveTime fun");
     String curDate=DateFormat("dd/MM/yyyy").format(DateTime.now()).replaceAll("/", "-");
//  "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}";

DocumentSnapshot<Map<String, dynamic>>? result;
Map<String, dynamic>? todaytime;
int prevDuration=0;

 ////getting
 try{
   result= await FirebaseFirestore.instance.collection("ChatAppUsers")
               .doc(currentUser!.uid).collection("screenTime").doc(curDate).get();
              //  .where("${curDate}" ,isGreaterThan: 0).get();
   todaytime = result.data();
     debugPrint("result1 is ${result.data()} , todaytime ");
   // debugPrint("result1 is ${result.data()!.keys.first} , todaytime ${result.data()![curDate]}");
    }catch(e){
      debugPrint("the error in getting result is $e");
    }
 debugPrint("outside try");

  if(result!.data()!=null){
    //  debugPrint("result2 is ${todaytime![curDate]}");
//  final docData=todaytime[curDate];
     prevDuration=result.data()![curDate];
     int newDuration=totDuration.inSeconds+ prevDuration;
     debugPrint("value of prevDuration is $prevDuration , new duration is $newDuration" );


   Map<String,dynamic> newScreenTime={
    DateFormat("dd/MM/yyyy").format(DateTime.now()).replaceAll("/", "-") : newDuration,
    "todayDate":DateTime.now()
   };
       await FirebaseFirestore.instance.collection("ChatAppUsers")
  .doc(currentUser!.uid).collection("screenTime").doc(curDate).update(newScreenTime);
    //  final docData=result.docs[0].data()[curDate];
  }

 if(result.data()==null){
   debugPrint("inside if null");
    ///creating
   Map<String,dynamic> screenTime={
    DateFormat("dd/MM/yyyy").format(DateTime.now()).replaceAll("/", "-") : totDuration.inSeconds,
     "todayDate":DateTime.now()
   };
try{
  await FirebaseFirestore.instance.collection("ChatAppUsers")
  .doc(currentUser!.uid).collection("screenTime").doc(curDate).set(screenTime);
  }catch(e){
    debugPrint("could not create screentime $e");
  }
  // chatRoomModel=newChatRoomModel;  // for returning
}

  // result.docs.first.data();
  }
  //////////////////////////

  @override
  Widget build(BuildContext context) {
    return KeyboardEmojiPickerWrapper(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chat App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home:SplashScreen(destination: 'home', firebaseUser: widget.firebaseUser, userModel: widget.userModel,),
      ),
    );
  }
}

void showBaselines() {
  debugPaintBaselinesEnabled = true;
}
void highlightRepaints() {
  debugRepaintRainbowEnabled = true;
}
void showOversizedImages() {
  debugInvertOversizedImages = true;
}
// */
//////////////////////////////////////chat app
//    Future notifStream()async{


//   await FirebaseFirestore.instance
//                     .collection("chatrooms")
//                     .where("participantsId.${userModel.uId}", isEqualTo: true)
//                     .snapshots().listen((event) { 

//                         // ChatRoomModel chatRoom = ChatRoomModel.fromMap(
//                         // event.docs[0].data()
//                         //     as Map<String, dynamic>);

//                      Notif.showBigTextNotification(title: "hello", body: "body", fn: flutterLocalNotificationsPlugin); ///
//                     });
// }
////////////////////////////////

// void main() async {
//     WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
// runApp(const ProviderScope(child: MyApp()));
// } 

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {

//     return  MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Shopping Cart',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const Screen1(),
//     );
//   }
// }