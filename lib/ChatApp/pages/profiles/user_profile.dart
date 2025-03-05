import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:proj/ChatApp/models/chat_room_model.dart';
import 'package:proj/ChatApp/models/media_model.dart';
import 'package:proj/ChatApp/models/user_model.dart';
import 'package:proj/ChatApp/pages/for_media/open_media.dart';
import 'package:proj/ChatApp/pages/profiles/all_shared_media.dart';
import 'package:video_player/video_player.dart';

class UserProfile extends StatefulWidget {
  const UserProfile(
      {super.key,
      required this.firebaseUser,
      required this.userModel,
      required this.targetUser,
      required this.chatRoomModel,
      required this.mediaList
      });

  final User firebaseUser; // <us> or current user on our side
  final UserModel userModel; // <us> our info

  final UserModel targetUser; // <other> person we are talking to
  final ChatRoomModel chatRoomModel;
  final List<MediaModel> mediaList;

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String? messageType;
  VideoPlayerController? videoController; // video controller for videoPlayer
  late Future<void> _initializeVideoPlayerFuture; // future for video

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          //  title:
          //       Text(widget.targetUser.name.toString())
          ),
      body: ListView(
        children: [
          const SizedBox(
            height: 10,
          ),
          Center(
            child: CircleAvatar(
              radius: 85,
              backgroundColor: const Color.fromARGB(255, 240, 217, 148),
              child: CircleAvatar(
                radius: 80,
                backgroundColor: const Color.fromARGB(255, 240, 217, 148),
                backgroundImage: NetworkImage(widget.targetUser.profileUrl!),
              ),
            ),
          ),
          // profile img
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Column(
              children: [
                Text(
                  widget.targetUser.name!,
                  style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold ,fontFamily:"EuclidCircularB"),
                ),
                Text(
                  widget.targetUser.email!,
                  style: const TextStyle(fontSize: 16, color: Colors.grey ,fontFamily:"EuclidCircularB"),
                )
              ],
            ),
          ),
          const SizedBox(height: 15),
          const Divider(
            thickness: 5,
            color: Color.fromARGB(255, 240, 217, 148),
          ),

          //media
          const SizedBox(height: 10),
          Visibility(
            visible: (widget.mediaList.isEmpty==true) ? false :true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(children: [
                Text(
                  "Shared videos and images",
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      fontFamily: "EuclidCircularB"),
                ),
                const Spacer(),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AllSharedMedia(
                                    mediaList: widget.mediaList,
                                    userModel: widget.userModel,
                                  )));
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 25,
                    ))
              ]),
            ),
          ),
////////////////////////////////////////
          // StreamBuilder(
          //       stream:  FirebaseFirestore.instance
          //           .collection("chatrooms")
          //           .doc(widget.chatRoomModel.chatRoomId)
          //           .collection("messages")
          //           .orderBy("createdOn",
          //               descending:
          //                   false).snapshots() // so that messages appear from newer to older
          //       // getItems()
          //            // to convert into streams
          //       ,builder: ( context, snapshot) {
          //         // if (snapshot.connectionState == ConnectionState.active) {
          //         //   if (snapshot.hasData) {
          //         var dataSnapshot;
          //           if(snapshot.data!= null){
          //              dataSnapshot = snapshot.data
          //                 as QuerySnapshot; // converting into QuerySnapshot dataType
          //            }
          //                  late MediaModel currentMedia;
          //                     if( snapshot.data==null){
          //                          return const Center(child: CircularProgressIndicator(),);
          //                     }else if(snapshot.hasError){
          //                        return const Center(child: CircularProgressIndicator(),);
          //                     }

                      // return
                       Visibility(
                        visible: (widget.mediaList.isEmpty)?false :true,
                         child: Container(
                          color: const Color.fromARGB(255, 255, 236, 180),
                           child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: 0,
                              maxHeight:  120,
                              maxWidth: MediaQuery.sizeOf(context).width/2,
                              ),
                            child: ListView(
                               scrollDirection: Axis.horizontal,
                                       children: List.generate(widget.mediaList.length, (int index){
                                     if (widget.mediaList[index].type == "image") {
                                          messageType = "image";
                                        }
                                         else if (widget.mediaList[index].type == "video") {
                                          videoController = VideoPlayerController.networkUrl(Uri.parse(widget.mediaList[index].fileUrl!));
                                          _initializeVideoPlayerFuture =videoController!.initialize();
                                          messageType = "video";
                                        } 
                                            return  Container(
                                        padding: const EdgeInsets.all(3),
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment.end,
                                                            children: [
                                                                   GestureDetector(
                                                                          onTap:  () {
                                                                                  // viewing image
                                                                                  Navigator.push(
                                                                                      context,
                                                                                      MaterialPageRoute(
                                                                                          builder: (context) => OpenMedia(
                                                                                                mediamodel: widget.mediaList[index],
                                                                                                senderUid: widget.mediaList[index].senderId!,
                                                                                                date: widget.mediaList[index].createdOn!,
                                                                                                type: widget.mediaList[index].type!, userModel:  widget.userModel,
                                                                                              )));
                                                                                },
                                                                          child: (messageType ==
                                                                                  "image")
                                                                              ? Container(
                                                                                width: 100,
                                                                                height: 100,
                                                                                decoration: BoxDecoration(
                                                                                  // image: DecorationImage(image: NetworkImage(widget.mediaList[index]
                                                                                  //       .fileUrl
                                                                                  //       .toString(),),fit: BoxFit.cover)
                                                                                ),
                                                                                child:   CachedNetworkImage(
                                                                                   imageUrl:widget.mediaList[index]
                                                                                        .fileUrl
                                                                                        .toString(),
                                                                                   placeholder: (context,url) =>
                                                                                          Container(
                                                                      width: 50,
                                                                      height: 50,
                                                                      child: Center(child: CircularProgressIndicator())),
                                                                                   errorWidget: (context,url,error) =>const Icon(Icons.error),
                                                                                   fit: BoxFit.cover,
                                                                                  memCacheWidth: 250,
                                                                ),
                                                                                )
                                                                              // ConstrainedBox(
                                                                              //     constraints: const BoxConstraints(
                                                                              //         maxHeight:
                                                                              //             200,
                                                                              //         maxWidth:
                                                                              //             200),
                                                                              //     child: Image
                                                                              //         .network(
                                                                                  //  widget.mediaList[index]
                                                                                  //       .fileUrl
                                                                                  //       .toString(),
                                                                              //     ),
                                                                              //   )
                         
                                                                              : (messageType ==
                                                                                      "video")
                                                                                  ? // image
                                                                                  FutureBuilder(
                                                                                      future:
                                                                                          _initializeVideoPlayerFuture,
                                                                                      builder:
                                                                                          (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                                                                        return Stack(
                                                                                          children: [
                                                                                            ConstrainedBox(
                                                                                              constraints: const BoxConstraints(maxHeight: 100, maxWidth: 100),
                                                                                              child:
                                                                                              //  AspectRatio(
                                                                                              //   aspectRatio: videoController!.value.aspectRatio,
                                                                                              //   child:
                                                                                                 VideoPlayer(videoController!),
                                                                                              // ),
                                                                                            ),
                                                                                             const Positioned(
                                                                                                bottom: 10,
                                                                                                left: 10,
                                                                                                child:
                                                                                                 Icon(
                                                                                                  Icons.play_arrow,
                                                                                                  color: Colors.white,
                                                                                                  size: 25,
                                                                                                )
                                                                                                ),
                                                                                          ],
                                                                                        );
                                                                                      },
                                                                                    ) 
                                                                                     : Container()),
                                                                                    //text
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                            ]),
                                      );
                                  
                                       }),
                                     ),
                                  
                            // (snapshot.data==[]) 
                            // ? 
                            // ListView.builder(
                            //   scrollDirection: Axis.horizontal,
                            //   itemCount: widget.mediaList.length,
                            //   itemBuilder: (BuildContext context, int index) {
                            //     var dt = dataSnapshot.docs[index].data() as Map< String,dynamic>; // map of data at particular index
                            //
                            //  if (dt.containsValue("image") == true || dt.containsValue("video") == true) {
                            //       currentMedia = MediaModel.fromMap(
                            //          dataSnapshot.docs[index].data()
                            //               as Map<String, dynamic>);
                                     //     
                            //       if (dt.containsValue("image") == true) {
                            //         messageType = "image";
                            //       } else if (dt.containsValue("video") == true) {
                            //         videoController = VideoPlayerController.networkUrl(Uri.parse(currentMedia.fileUrl!));
                            //         _initializeVideoPlayerFuture =videoController!.initialize();
                            //         messageType = "video";
                            //       } 
                            //     }
                            //
                            //     return   Container(
                            //       padding: const EdgeInsets.all(3),
                            //                       child: Column(
                            //                           crossAxisAlignment:
                            //                               CrossAxisAlignment.end,
                            //                           children: [
                            //                                  GestureDetector(
                            //                                         onTap:  () {
                            //                                                 // viewing image
                            //                                                 Navigator.push(
                            //                                                     context,
                            //                                                     MaterialPageRoute(
                            //                                                         builder: (context) => OpenMedia(
                            //                                                               mediamodel: currentMedia,
                            //                                                               senderUid: currentMedia.senderId!,
                            //                                                               date: currentMedia.createdOn!,
                            //                                                               type: currentMedia.type!, userModel:  widget.userModel,
                            //                                                             )));
                            //                                               },
                            //                                         child: (messageType ==
                            //                                                 "image")
                            //                                             ? ConstrainedBox(
                            //                                                 constraints: const BoxConstraints(
                            //                                                     maxHeight:
                            //                                                         200,
                            //                                                     maxWidth:
                            //                                                         200),
                            //                                                 child: Image
                            //                                                     .network(
                            //                                                  widget.mediaList[index]
                            //                                                       .fileUrl
                            //                                                       .toString(),
                            //                                                 ),
                            //                                               )
                            //                                             : (messageType ==
                            //                                                     "video")
                            //                                                 ? // image
                            //                                                 FutureBuilder(
                            //                                                     future:
                            //                                                         _initializeVideoPlayerFuture,
                            //                                                     builder:
                            //                                                         (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                            //                                                       return Stack(
                            //                                                         children: [
                            //                                                           ConstrainedBox(
                            //                                                             constraints: const BoxConstraints(maxHeight: 200, maxWidth: 200),
                            //                                                             child: AspectRatio(
                            //                                                               aspectRatio: videoController!.value.aspectRatio,
                            //                                                               child: VideoPlayer(videoController!),
                            //                                                             ),
                            //                                                           ),
                            //                                                           const Positioned(
                            //                                                               bottom: 10,
                            //                                                               left: 10,
                            //                                                               child: Icon(
                            //                                                                 Icons.play_arrow,
                            //                                                                 color: Colors.white,
                            //                                                                 size: 25,
                            //                                                               )),
                            //                                                         ],
                            //                                                       );
                            //                                                     },
                            //                                                   ) 
                            //                                                    : Container()),
                            //                                                   //text
                            //                             const SizedBox(
                            //                               height: 5,
                            //                             ),
                            //                           ]),
                            //     );
                            //   },
                            // )
                           //
                            // :
                            // Padding(
                            //   padding: EdgeInsets.all(5),
                            //   child:  Text("no shared Media" ,style: TextStyle(fontFamily:"EuclidCircularB"),),),
                                                 ),
                         ),
                       )
                    // } else 
                    // if (snapshot.hasError) {
                    //   return const Text(
                    //       "Error Occured !! Please check our internet Connection");
                    // } else {
                    //   return Text("Say Hi", style: TextStyle(fontFamily:"EuclidCircularB"),);
                    // }
                  // } 
              //   },
              // ),
          // ListView.builder(
          //   scrollDirection: Axis.horizontal,
          //   itemBuilder: (BuildContext context, int index) {
//
          //     },)
        ],
      ),
    );
  }



  Future<List<String>> getItems() async{
     final storageRef = FirebaseStorage.instance.ref();
  List<String> imageList=[];
       final a=  await storageRef.child('AllSharedMedia/${widget.chatRoomModel.chatRoomId}/sharedMedia').listAll();
          final b = await a.items.first.getDownloadURL();
          debugPrint(" list of all the images are $b");

          for(var  i in a.items){
             final b = await i.getDownloadURL();
             imageList.add(b);
             debugPrint(b);
          }  
 return imageList;
}
}

