
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cubit_form/cubit_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proj/ChatApp/helpers/firebase_helper.dart';
import 'package:proj/ChatApp/models/Blocs/heart_vis_bloc.dart';
import 'package:proj/ChatApp/models/Blocs/show_story_bloc.dart';
import 'package:proj/ChatApp/models/Blocs/video_arrow_bloc.dart';
import 'package:proj/ChatApp/models/story_model.dart';
import 'package:proj/ChatApp/models/user_model.dart';
import 'package:video_player/video_player.dart';

class ShowStory extends StatefulWidget {
  const ShowStory(
      {super.key, required this.firebaseUser, required this.userModel});
  final User firebaseUser;
  final UserModel userModel;

  @override
  State<ShowStory> createState() => _ShowStoryState();
}

class _ShowStoryState extends State<ShowStory> {
  VideoPlayerController? videoController; // video controller for videoPlayer
  late Future<void> _initializeVideoPlayerFuture; // future for video
  List<StoryModel> recentStoryList = [];  
  var storyUploadedHrs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
      automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            backgroundImage: NetworkImage(widget.userModel.profileUrl!),
          ),
          title: Text(
            widget.userModel.name!,
            style: const TextStyle(
                color: Colors.white, fontFamily: "EuclidCircularB"),
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        width: MediaQuery.sizeOf(context).width / 1.1,
        height: MediaQuery.sizeOf(context).height / 1.1,
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("ChatAppUsers")
                .doc(widget.userModel.uId)
                .collection("status")
                .orderBy("createdOn", descending: true)
                .snapshots(), // to convert into streams

            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                  recentStories(dataSnapshot); // to get only stories uploaded within 24 hours
                  // return BlocProvider<ShowStoryBloc>(
                  //   create: (_)=> ShowStoryBloc(false),
                  //   child: BlocBuilder<ShowStoryBloc,bool>(
                  //     builder: (BuildContext context, state) {  
                      return 
                      CarouselSlider(
                          items: List.generate(recentStoryList.length, (index) {
                            // context.read< ShowStoryBloc>().add(LikeFalse());
                            // var currentStory = recentStoryList[index];
                       
                            //   if(currentStory.likedBy!.contains(widget.firebaseUser.uid)){
                            //      context.read< ShowStoryBloc>().add(LikeTrue());  ///
                      
                            //   }
                            // //
                            // DateTime a = currentStory.createdOn!;
                            // DateTime b = DateTime.now();
                            // var diff = b.difference(a).inHours;
                      
                            // if (recentStoryList[index].type == "video") {
                            //   // setting video in controller
                            //   videoController = VideoPlayerController.networkUrl(
                            //       Uri.parse(currentStory.fileUrl!));
                            //   _initializeVideoPlayerFuture =
                            //       videoController!.initialize();
                            //   videoController!.value.isPlaying == true;
                            // }
                            return MultiBlocProvider(
                              providers: [
                                BlocProvider<ShowStoryBloc>(create: (_)=> ShowStoryBloc(false),),
                                BlocProvider<HeartVisBloc>(create:(_)=> HeartVisBloc(false))
                               ], 
                                   child: BlocBuilder<ShowStoryBloc,bool>(
                                       builder: (BuildContext context, state) {  
                            
                        var currentStory = recentStoryList[index];
                       
                              if(currentStory.likedBy!.contains(widget.firebaseUser.uid)){
                                 context.read< ShowStoryBloc>().add(LikeTrue());  ///
                      
                              }
                            //
                            DateTime a = currentStory.createdOn!;
                            DateTime b = DateTime.now();
                            var diff = b.difference(a).inHours;
                      
                            if (recentStoryList[index].type == "video") {
                              // setting video in controller
                              videoController = VideoPlayerController.network(
                                  Uri.parse(currentStory.fileUrl!).toString());
                              _initializeVideoPlayerFuture =
                                  videoController!.initialize();
                              videoController!.value.isPlaying == true;
                            }
                            return
                                // ConstrainedBox(
                                //   constraints: BoxConstraints(
                                //     maxHeight: MediaQuery.sizeOf(context).height,
                                //     maxWidth: MediaQuery.sizeOf(context).width,
                                //     ),
                                //     child:
                                Stack(
                              children: [
                                (currentStory.type == "image")
                                    ?
                                    // Center(
                                    //   child:
                                    Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                              child: Image.network(
                                                  currentStory.fileUrl!)),
                                        ],
                                      )
                                    // )
                                    : // 1st
                                    (currentStory.type == "video")
                                        ? Center(
                                            child: FutureBuilder(
                                              future: _initializeVideoPlayerFuture,
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<dynamic> snapshot) {
                                                videoController!.value.isPlaying ==
                                                    true;
                                                return BlocProvider<VideoStateBloc>(
                                                    create: (_) =>
                                                        VideoStateBloc(false),
                                                    child: BlocBuilder<
                                                        VideoStateBloc, bool>(
                                                      builder:
                                                          (BuildContext context,
                                                              state) {
                                                        return Center(
                                                          child: Stack(
                                                            alignment: Alignment
                                                                .center, // Align children at the center
                                                            children: [
                                                              AspectRatio(
                                                                aspectRatio:
                                                                    videoController!
                                                                        .value
                                                                        .aspectRatio,
                                                                child: VideoPlayer(
                                                                    videoController!),
                                                              ),
                                                              // Center the play/pause icon
                                                                  IconButton(
                                                                    onPressed: () {
                                                                      if (videoController!.value.isPlaying) {
                                                                        videoController!.pause();
                                                                        context.read< VideoStateBloc>().add(VideoPause());
                                                                      } else {
                                                                        videoController!.play();
                                                                        context.read<VideoStateBloc>().add(
                                                                                VideoPlay());
                                                                      }
                                                                    },
                                                                    icon: Icon(
                                                                      context.watch<VideoStateBloc>().state 
                                                                          ? Icons.pause
                                                                          : Icons
                                                                              .play_circle,
                                                                      size: 80,
                                                                      color:
                                                                          Colors.white,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ));
                                                 
                                                  },
                                                ),
                                              )
                                          : Container(
                                                color: Colors.amber,
                                              ),
                                Positioned(
                                       bottom: 20,
                                       left: 10,
                                    child: (widget.firebaseUser.uid==widget.userModel.uId) 
                                    ? Column(
                                      children: [
                                        IconButton(
                                          onPressed: ()async{
   List<UserModel> likedUserModel= [];
   if(currentStory.likedBy!.isNotEmpty){ 
    for(String i in currentStory.likedBy!){
       UserModel?  userModel = await  FirebaseHelper.getUserModelById(i); 
       likedUserModel.add(userModel!);
   }
   }
                  showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled:
            true, // Set this to true to enable full screen modal
        builder: (BuildContext context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.25,
            maxChildSize: 1,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
            padding: const EdgeInsets.all(20),
            decoration:  const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20))),
            child:   Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(CupertinoIcons.heart_fill,color: Colors.red.shade300,size: 35,),
                  title:const Text("Liked By .....",style: TextStyle(fontFamily: "EuclidCircularB",color: Colors.black,fontSize: 20),),
                ),
                Divider(),
               (likedUserModel.isEmpty)
               ? const Expanded(
                 child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Center(child: Text("No Likes",style: TextStyle(fontFamily:  "EuclidCircularB",color: Colors.black,fontSize: 15),),),
                   ],
                 ),
               )
               : ConstrainedBox(
                   constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height/3,
                    maxWidth: MediaQuery.sizeOf(context).width
                  ),
                  child: ListView(children: List.generate(likedUserModel.length,(int i) {
                    // UserModel? userModel;
                    // Future.microtask(() async{
                    // userModel = await  FirebaseHelper.getUserModelById(currentStory.likedBy![i]); 
                    // });                    
                    return ListTile(
                      leading:  CircleAvatar(
                              radius: 25,
                              backgroundColor:
                                  const Color.fromARGB(255, 158, 219, 241),
                              backgroundImage: NetworkImage(
                                  likedUserModel[i].profileUrl.toString()),
                            ),
                         title: Text("${likedUserModel[i].name}"),
                    );
                  } ),),
                )
              ])
              );
            });
        }
                                             );
                                        }, icon: Icon(CupertinoIcons.heart_fill,color: Colors.red.shade300,size: 35)),
                                        Text("${currentStory.likedBy!.length} Likes" ,style: const TextStyle(color: Colors.white),)
                                      ],
                                    )
                                    
                                    : IconButton(
                                      onPressed: () async {
                                        context.read<ShowStoryBloc>().add(
                                            LikeTrueAndUpd(
                                                widget.userModel.uId,
                                                currentStory.mediaId,
                                                widget.firebaseUser.uid));

                                         context.read<HeartVisBloc>().add(HeartVis());   // make visible 
                                         Future.delayed(const Duration(milliseconds: 400),(){
                                         context.read<HeartVisBloc>().add(HeartNotVis());   // make invisible 
                                            
                                         });
                                      
                                      }, icon: context.watch<ShowStoryBloc>().state  ? Icon(CupertinoIcons.heart_fill,color: Colors.red.shade300,size: 35)  :const Icon(CupertinoIcons.heart,color: Colors.white,size: 35)),
                                              ),
                                 Positioned(
                                          left: 10,
                                          child: Text(" Posted ${diff}hrs ago",style: const TextStyle(color: Colors.white),)),
                                Visibility(
                                  visible: context.watch<HeartVisBloc>().state,
                                  child: Center(
                                  child: Icon(CupertinoIcons.heart_fill,color: Colors.red.shade300,size: 100) ,
                                ))
                                ],
                               );
                          }
                          ));
                            // );
                          }),
                          options: CarouselOptions(
                            pauseAutoPlayOnTouch: true,
                            height: MediaQuery.sizeOf(context).height / 1.1,
                            aspectRatio: 16 / 9,
                            viewportFraction: 0.9,
                            initialPage: 0,
                            enableInfiniteScroll: false,
                            reverse: false,
                            autoPlay: true,
                            // autoPlayInterval: Duration(seconds: 3),
                            autoPlayAnimationDuration:
                                const Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            // onPageChanged:
                            scrollDirection: Axis.horizontal,
                          ));
                   
                //  } ),
                //   );

                  //////
                } else if (snapshot.hasError) {
                  return const Text(
                      "Error Occured !! Please check our internet Connection");
                } else {
                  return const Text("Say Hi to ",
                      style: TextStyle(fontFamily: "EuclidCircularB"));
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }

  void recentStories(QuerySnapshot<Object?> dataSnapshot) {
    storyUploadedHrs=0;
    for (var i in dataSnapshot.docs) {
      late final currentStory = StoryModel.fromMap(// data into model
          i.data() as Map<String, dynamic>);

      DateTime a = currentStory.createdOn!;
      DateTime b = DateTime.now();
      var diff = b.difference(a).inHours; // to know if its been 24 hours or not
      
      if (diff <= 24) {
        recentStoryList.add(currentStory);
      }
      // print("difference between current time ${DateTime.now().hour} and story${currentStory.createdOn!.hour} is ${diff} ");
    }
  }
}
