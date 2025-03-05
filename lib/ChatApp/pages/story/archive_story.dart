import 'package:cubit_form/cubit_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proj/ChatApp/models/Blocs/video_arrow_bloc.dart';
import 'package:proj/ChatApp/models/media_model.dart';
import 'package:proj/ChatApp/models/user_model.dart';
import 'package:video_player/video_player.dart';
// opening shared media
class ArchiveStory extends StatefulWidget {
  const ArchiveStory(
      {super.key,
      required this.mediamodel,
      required this.userModel,
      required this.senderUid,
      required this.type,
      required this.date});
     final MediaModel mediamodel;

  final UserModel userModel;
  final String senderUid;
  final String type;
  final DateTime date;

  @override
  State<ArchiveStory> createState() => _ArchiveStoryState();
}

class _ArchiveStoryState extends State<ArchiveStory> {
 VideoPlayerController? videoController; // video controller for videoPlayer
  late Future<void> _initializeVideoPlayerFuture; // future for video

  @override
  void initState() {
   if(widget.type=="video"){
      videoController =
          VideoPlayerController.networkUrl(Uri.parse(widget.mediamodel.fileUrl!));
      _initializeVideoPlayerFuture = videoController!.initialize();
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          title:Text(DateFormat("dd/MM/yyyy").format(widget.date)),
          titleTextStyle: const TextStyle(color: Colors.white ,fontFamily:"EuclidCircularB"),      
        ),
        backgroundColor: Colors.black,
      
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints:
                 BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height-50,
              maxWidth: MediaQuery.sizeOf(context).width-50),
              child:
              (widget.type=="image")
              ? Image.network(widget.mediamodel.fileUrl! ,cacheWidth: 700)
              : (widget.type=="video")
              ? FutureBuilder(
                        future: _initializeVideoPlayerFuture,
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          return 
                          BlocProvider<VideoStateBloc>(
                            create: (_)=> VideoStateBloc(false),
                            child: 
                            BlocBuilder<VideoStateBloc, bool>(
  builder: (BuildContext context, state) {
    return Center(
      child: Stack(
        alignment: Alignment.center, // Align children at the center
        children: [
          // AspectRatio(
          //   aspectRatio: videoController!.value.aspectRatio,
          //   child: 
            VideoPlayer(videoController!),
          // ),
          // Center the play/pause icon
          IconButton(
            onPressed: () {
              if (videoController!.value.isPlaying) {
                videoController!.pause();
                context.read<VideoStateBloc>().add(VideoPause());
              } else {
                videoController!.play();
                context.read<VideoStateBloc>().add(VideoPlay());
              }
            },
            icon: Icon(
              state ? Icons.pause : Icons.play_circle,
              size: 80,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  },
)
                          );
                        
                          //   BlocBuilder<VideoStateBloc,bool>(
                          //     builder: (BuildContext context, state) {  
                          //     return Center(
                          //       child: Stack(
                          //         children: [
                          //           AspectRatio(
                          //             aspectRatio: videoController!.value.aspectRatio,
                          //             child: VideoPlayer(videoController!),
                          //           ),
                          //       Positioned(
                          //         top: MediaQuery.sizeOf(context).height/3,
                          //         child: SizedBox(
                          //           width: 
                          //            MediaQuery.sizeOf(context).width,
                          //           child: Column(
                          //             crossAxisAlignment:
                          //                 CrossAxisAlignment.center,
                          //             children: [
                          //               IconButton(
                          //                 onPressed: () {
                          //                   if (videoController!.value.isPlaying) {
                          //                     videoController!.pause();
                          //                     context.read<VideoStateBloc>().add(VideoPause()); 
                          //                   } else {
                          //                     videoController!.play();
                          //                     context.read<VideoStateBloc>().add(VideoPlay()); 
                          //                   }
                          //                 },
                          //                 icon: Icon(
                          //                 (context.watch<VideoStateBloc>().state==false)
                          //                       ? Icons.play_circle
                          //                       :Icons.pause ,
                          //                   size: 80,
                          //                   color: Colors.white,
                          //                 ),
                          //               ),
                          //             ],
                          //           ),
                          //         ),
                          //       ),
                                     
                          //         ],
                          //       ),
                          //     );
                          //  },
                          //   ),
                          // );
                      
                        },
                      ) :const Placeholder()
                      ///
              
              ),
            )
            ],
        ),
      ),
    );
  }



}
