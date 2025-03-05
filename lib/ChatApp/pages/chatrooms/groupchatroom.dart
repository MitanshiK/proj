import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cubit_form/cubit_form.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proj/ChatApp/models/Blocs/emoji_bloc.dart';
import 'package:proj/ChatApp/models/Blocs/player_bloc.dart';
import 'package:proj/ChatApp/models/contacts_model.dart';
import 'package:proj/ChatApp/models/group_room_model.dart';
import 'package:proj/ChatApp/models/media_model.dart';
import 'package:proj/ChatApp/models/Blocs/message_bloc.dart';
import 'package:proj/ChatApp/models/message_model.dart';
import 'package:proj/ChatApp/models/user_model.dart';
import 'package:proj/ChatApp/pages/audio_recording/mic_widget.dart';
import 'package:proj/ChatApp/pages/audio_recording/recorded_player.dart';
import 'package:proj/ChatApp/pages/profiles/group_info.dart';
import 'package:proj/ChatApp/pages/for_media/open_media.dart';
import 'package:proj/ChatApp/pages/for_media/send_media.dart';
import 'package:proj/ChatApp/pages/share_bottom_modal.dart';
import 'package:proj/main.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart' as ap;

class GroupRoomPage extends StatefulWidget {
  final User firebaseUser; // <us> or current user on our side
  final UserModel userModel; // <us> our info

  final List<UserModel> groupMembers; // <other> person we are talking to
  final GroupRoomModel groupRoomModel;

  const GroupRoomPage(
      {super.key,
      required this.firebaseUser,
      required this.userModel,
      required this.groupMembers,
      required this.groupRoomModel});

  @override
  State<GroupRoomPage> createState() => _GroupRoomPageState();
}

class _GroupRoomPageState extends State<GroupRoomPage>
    with TickerProviderStateMixin {
  bool showPlayer = false;
  ap.AudioSource? audioSource;
  String? audioFilePath;
  List<MediaModel> mediaList = [];

  // late final animationController =
  //     AnimationController(vsync: this, duration: const Duration(seconds: 2));
  VideoPlayerController? videoController; // video controller for videoPlayer
  late Future<void> _initializeVideoPlayerFuture; // future for video
  TextEditingController messageController = TextEditingController();

  PlatformFile? pickedMedia;
  String? capturedFile; // captured by camera
  String? messageType;
  String? time;

  @override
  void dispose() {
    // animationController.dispose();
    videoController?.dispose();
    super.dispose();
  }

// @override
// void didChangeDependencies(){

// }

  @override
  Widget build(BuildContext context) {
    void sendMessage() async {
      String msg = messageController.text.trim();
      messageController
          .clear(); // to clear textfield after we send the  message

      if (msg != "") {
        MessageModel newMessage = MessageModel(
            // creating message
            messageId: uuid.v1(),
            senderId: widget.userModel.uId,
            text: msg,
            seen: false,
            createdOn: DateTime.now(),
            type: "text");

        // creating a messages collection inside chatroom docs and saving messages in them
        FirebaseFirestore.instance
            .collection("GroupChats")
            .doc(widget.groupRoomModel.groupRoomId)
            .collection("messages")
            .doc(newMessage.messageId)
            .set(newMessage.toMap())
            .then((value) {
          debugPrint("message sent");
        });

        // setting last message in chatroom and saving in firestore
        widget.groupRoomModel.lastMessage = msg;
        widget.groupRoomModel.lastTime = newMessage.createdOn;
        widget.groupRoomModel.lastMessageBy = newMessage.senderId;
        FirebaseFirestore.instance
            .collection("GroupChats")
            .doc(widget.groupRoomModel.groupRoomId)
            .set(widget.groupRoomModel.toMap());
      }
    }

////////// chat bg
    bool defaultBg = true;
    File? chatBg;

    void crophatBg(XFile file) async {
      final croppedImage = await ImageCropper().cropImage(
          sourcePath: file.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 2),
          compressQuality: 30);

      if (croppedImage != null) {
        setState(() {
          defaultBg = false;
          chatBg = File(croppedImage.path);
        });
      }
    }

    void pickChatBg() async {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        crophatBg(pickedFile);
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          PopupMenuButton(
              itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                        child: ListTile(
                      title: const Text("Change Background"),
                      trailing: PopupMenuButton(
                        itemBuilder: (BuildContext context) => [
                          //default bg
                          PopupMenuItem(
                              child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      defaultBg = true;
                                    });
                                  },
                                  title: const Text("Default"))),

                          //pic bgImage
                          PopupMenuItem(
                              onTap: () {
                                pickChatBg();
                              },
                              child:
                                  const ListTile(title: Text("Form Gallary"))),
                        ],
                      ),
                    ))
                  ])
        ],
        title: GestureDetector(
          onTap: () {
            //   group Info page

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GroupInfo(
                          firebaseUser: widget.firebaseUser,
                          userModel: widget.userModel,
                          groupMembers: widget.groupMembers,
                          groupRoomModel: widget.groupRoomModel,
                          mediaList: mediaList,
                        )));
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: (widget.groupRoomModel.profilePic != null && widget.groupRoomModel.profilePic != "")
                    ? NetworkImage(widget.groupRoomModel.profilePic.toString())
                    : const AssetImage("assets/group_image.png")
                        as ImageProvider,
                backgroundColor: const Color.fromARGB(255, 240, 217, 148),
              ),
              const SizedBox(
                width: 20,
              ),
              Text(widget.groupRoomModel.groupName.toString())
            ],
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 113, 210, 246),
      ),
      body: SafeArea(
          child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.2), BlendMode.dstATop),
                //  image:
                //  (defaultBg==true)
                //  ?FileImage(chatBg!) as ImageProvider
                //  : AssetImage("assets/chatBg.jpg")
                //  image: chatBg!=null ? FileImage(chatBg) :AssetImage("assets/chatBg.jpg")
                image: const AssetImage("assets/chatBg.jpg"))),
        child: Column(
          children: [
            // to show messages
            Expanded(
                child: Container(
              margin: const EdgeInsets.all(12),
              // messages stream builder
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("GroupChats")
                    .doc(widget.groupRoomModel.groupRoomId)
                    .collection("messages")
                    .orderBy("createdOn",
                        descending:
                            false) // so that messages appear from newer to older
                    .snapshots(), // to convert into streams

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot = snapshot.data
                          as QuerySnapshot; // converting into QuerySnapshot dataType
///////////
                      getMediaList();

//////////////
                      return ListView.builder(
                        itemCount: dataSnapshot.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          var dt = dataSnapshot.docs[index].data() as Map<
                              String,
                              dynamic>; // map of data at particular index
                          // var a=dt[index];
                          debugPrint("${dt.containsValue("hyy")}");
                          late final currentMessage;
                          late final prevMessage;

                          ///

                          if (dt.containsValue("text") == true) {
                            // if message is text
                            currentMessage = MessageModel.fromMap(
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>);
                            messageType = "text";

                            if (index != 0) {
                              prevMessage = MessageModel.fromMap(
                                  ///////////////////////date
                                  dataSnapshot.docs[index - 1].data()
                                      as Map<String, dynamic>);
                            }
                          } else if (dt.containsValue("image") == true ||
                              dt.containsValue("video") == true ||
                              dt.containsValue("audio")) {
                            currentMessage = MediaModel.fromMap(
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>);

                            if (index != 0) {
                              prevMessage = MediaModel.fromMap(
                                  ///////////////////////date
                                  dataSnapshot.docs[index - 1].data()
                                      as Map<String, dynamic>);
                            }

                            if (dt.containsValue("image") == true) {
                              messageType = "image";
                            } else if (dt.containsValue("video") == true) {
                              videoController =
                                  VideoPlayerController.networkUrl(
                                      Uri.parse(currentMessage.fileUrl));
                              _initializeVideoPlayerFuture =
                                  videoController!.initialize();
                              messageType = "video";
                            } else if (dt.containsValue("audio")) {
                              messageType = "audio";
                            }
                          } else if (dt.containsValue("contact") == true) {
                            // for contact
                            currentMessage = ContactModal.fromMap(
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>);

                            messageType = "contact";

                            if (index != 0) {
                              prevMessage = ContactModal.fromMap(
                                  ///////////////////////date
                                  dataSnapshot.docs[index - 1].data()
                                      as Map<String, dynamic>);
                            }
                          }

                          UserModel? currentUserMess;
                          for (var i in widget.groupMembers) {
                            if (currentMessage.senderId == i.uId) {
                              currentUserMess = i;
                            }
                          }

                          String date =
                              "${currentMessage.createdOn!.day}/ ${currentMessage.createdOn!.month}/ ${currentMessage.createdOn!.year}";
                          time =
                              "${currentMessage.createdOn!.hour}: ${currentMessage.createdOn!.minute}";

                          return
                              //  Flexible(
                              //   fit: FlexFit.tight,
                              //   child: GestureDetector(
                              //     // for selecting
                              //     child:
                              Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Visibility(
                                    visible: (index != 0)
                                        ? ((showdate(currentMessage.createdOn,
                                                prevMessage.createdOn))
                                            ? true
                                            : false)
                                        : true,
                                    child: Container(
                                        margin: const EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.grey[300]),
                                        height: 25,
                                        width:
                                            MediaQuery.sizeOf(context).width /
                                                3,
                                        child: Text(date)),
                                  ),
                                ],
                              ),
                              Row(
                                  // one single message row

                                  // wraped in row so that width of message box is occourdung to content
                                  mainAxisAlignment: (currentMessage.senderId ==
                                          widget.userModel.uId)
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 10, 0, 0),
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 5, 10, 10),
                                      decoration: BoxDecoration(
                                          borderRadius: (currentMessage
                                                      .senderId ==
                                                  widget.userModel.uId)
                                              ? const BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight: Radius.circular(20),
                                                  bottomLeft:
                                                      Radius.circular(20))
                                              : const BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight: Radius.circular(20),
                                                  bottomRight:
                                                      Radius.circular(20)),
                                          color: (currentMessage.senderId ==
                                                  widget.userModel.uId)
                                              ? const Color.fromARGB(
                                                  255, 240, 217, 148)
                                              : const Color.fromARGB(
                                                  255, 251, 162, 156)),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Row(
                                              // mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  (currentUserMess !=
                                                          widget.userModel)
                                                      ? (currentUserMess !=
                                                              null)
                                                          ? currentUserMess
                                                              .name!
                                                          : "(removed)"
                                                      : "you",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        "EuclidCircularB",
                                                    color: (currentUserMess !=
                                                            null)
                                                        ? Colors.purple
                                                        : Colors.red,
                                                    fontSize: 12,
                                                  ),
                                                )
                                              ],
                                            ),
                                            (messageType == "text")
                                                ? Text(
                                                    currentMessage.text
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontFamily:
                                                            "EuclidCircularB"),
                                                  )
                                                :
                                                // subconition 1
                                                (messageType != "text")
                                                    ? GestureDetector(
                                                        onTap: (messageType ==
                                                                "contact") // if its contact then first option otherwise other
                                                            ? () {}
                                                            : () {
                                                                // viewing image
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            OpenMedia(
                                                                              mediamodel: currentMessage,
                                                                              userModel: widget.userModel,
                                                                              senderUid: currentMessage.senderId,
                                                                              date: currentMessage.createdOn,
                                                                              type: currentMessage.type,
                                                                            )));
                                                              },
                                                        child: (messageType ==
                                                                "image")
                                                            ? ConstrainedBox(
                                                                constraints:
                                                                    const BoxConstraints(
                                                                        maxHeight:
                                                                            200,
                                                                        maxWidth:
                                                                            200),
                                                                child:  CachedNetworkImage(
                                                                  imageUrl:currentMessage.fileUrl.toString(),
                                                                  placeholder: (context,url) =>
                                                                     Container(
                                                                      width: 50,
                                                                      height: 50,
                                                                      child: Center(child: CircularProgressIndicator())),
                                                                  errorWidget: (context,url,
                                                                          error) =>const Icon(Icons.error),
                                                                   fit: BoxFit.scaleDown,
                                                                   memCacheWidth: 230,
                                                                ),
                                                              )
                                                            : (messageType ==
                                                                    "video")
                                                                ? // image
                                                                FutureBuilder(
                                                                    future:
                                                                        _initializeVideoPlayerFuture,
                                                                    builder: (BuildContext
                                                                            context,
                                                                        AsyncSnapshot<dynamic>
                                                                            snapshot) {
                                                                      return Stack(
                                                                        children: [
                                                                          ConstrainedBox(
                                                                            constraints:
                                                                                const BoxConstraints(maxHeight: 200, maxWidth: 200),
                                                                            child:
                                                                              //   AspectRatio(
                                                                              // aspectRatio: videoController!.value.aspectRatio,
                                                                              // child: 
                                                                              VideoPlayer(videoController!),
                                                                            // ),
                                                                          ),
                                                                          const Positioned(
                                                                              bottom: 10,
                                                                              left: 10,
                                                                              child: Icon(
                                                                                Icons.play_arrow,
                                                                                color: Colors.white,
                                                                                size: 25,
                                                                              )),
                                                                        ],
                                                                      );
                                                                    },
                                                                  ) //video
                                                                : (messageType ==
                                                                        "audio")
                                                                    ? ConstrainedBox(
                                                                        constraints:
                                                                            const BoxConstraints(maxWidth: 200),
                                                                        child:
                                                                            AudioPlayer(
                                                                          source: ap.AudioSource.uri(Uri.parse(currentMessage
                                                                              .fileUrl
                                                                              .toString())),
                                                                          onDelete:
                                                                              () {
                                                                            context.read<PlayerVisBloc>().add(PlayerVisibility());
                                                                            context.read<MessageBloc>().add(NoText());
                                                                          },
                                                                          inChat:
                                                                              true,
                                                                        ),
                                                                      )
                                                                    : (messageType ==
                                                                            "contact") // audio
                                                                        ? ConstrainedBox(
                                                                            constraints:
                                                                                const BoxConstraints(
                                                                              maxWidth: 200,
                                                                            ),
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                ListTile(
                                                                                  contentPadding: EdgeInsets.zero,
                                                                                  leading: const CircleAvatar(
                                                                                    backgroundColor: Colors.blue,
                                                                                    child: Icon(
                                                                                      Icons.person,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                  ),
                                                                                  title: Text(currentMessage.name.toString(), style: const TextStyle(fontFamily: "EuclidCircularB")),
                                                                                  subtitle: Text(currentMessage.phone.toString(), style: const TextStyle(fontFamily: "EuclidCircularB")),
                                                                                ),
                                                                                ListTile(
                                                                                  contentPadding: EdgeInsets.zero,
                                                                                  title: TextButton(
                                                                                    style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.white)),
                                                                                    onPressed: () async {
                                                                                      /////
                                                                                      await _requestContactsPermission();

                                                                                      if (await Permission.contacts.isGranted) {
                                                                                        // Create a new contact
                                                                                        Contact newContact = Contact(
                                                                                          name: Name(first: currentMessage.name),
                                                                                          phones: [
                                                                                            Phone(currentMessage.phone, label: PhoneLabel.mobile)
                                                                                          ],
                                                                                        );

                                                                                        try {
                                                                                          // Add the contact to the device's contact list
                                                                                          await FlutterContacts.insertContact(newContact);
                                                                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Contact added successfully!!")));
                                                                                          debugPrint('Contact added successfully');
                                                                                        } catch (e) {
                                                                                          debugPrint('Failed to add contact: $e');
                                                                                        }
                                                                                      } else {
                                                                                        debugPrint('Contact permission not granted');
                                                                                      }

                                                                                      /////
                                                                                    },
                                                                                    child: const Text(
                                                                                      "Add to Contacts",
                                                                                      style: TextStyle(color: Colors.blue, fontFamily: "EuclidCircularB"),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ))
                                                                        : const Placeholder(),
                                                      ) // contact
                                                    : const Placeholder(), //text
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              // time stamp
                                              time!,
                                              style: const TextStyle(
                                                  fontFamily: "EuclidCircularB",
                                                  fontSize: 10),
                                            )
                                          ]),
                                    )
                                  ]),
                            ],
                          );
                          //   ),
                          // );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return const Text(
                          "Error Occured !! Please check our internet Connection");
                    } else {
                      return const Text("Say Hi you your group Members",
                          style: TextStyle(fontFamily: "EuclidCircularB"));
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            )),

            //
            MultiBlocProvider(
                providers: [
                  //1
                  BlocProvider<MessageBloc>(
                    // bloc provider  for typing messages
                    create: (_) => MessageBloc(),
                  ),
                  //2
                  BlocProvider<PlayerVisBloc>(
                    // bloc provider for audio player visibility
                    create: (_) => PlayerVisBloc(false),
                  ),
                  //3
                  BlocProvider<EmojiVisBloc>(
                    // bloc provider for emoji keyboard visibility
                    create: (_) => EmojiVisBloc(false),
                  ),
                ],
                child: BlocBuilder<MessageBloc, bool>(// bloc builder
                    builder: (BuildContext context, state) {
                  return Column(
                    children: [
                      ListTile(
                        minLeadingWidth: 0,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Container(
                            padding: const EdgeInsets.fromLTRB(10, 5, 5, 0),
                            margin: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 230, 229, 229),
                                borderRadius: BorderRadius.circular(20)),
                            child: context.watch<PlayerVisBloc>().state
                                ? // Audio Player
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25),
                                    child: AudioPlayer(
                                      source: audioSource!,
                                      onDelete: () {
                                        context
                                            .read<PlayerVisBloc>()
                                            .add(PlayerVisibility());
                                        context
                                            .read<MessageBloc>()
                                            .add(NoText());
                                      },
                                      inChat: false,
                                    ),
                                  )
                                : Row(
                                    children: [
                                      // for emoji
                                      IconButton(
                                          onPressed: () async {
                                            context
                                                .read<EmojiVisBloc>()
                                                .add(EmojiVisiblety());
                                          },
                                          icon:
                                              const Icon(Icons.emoji_emotions)),

                                      // message Field
                                      Expanded(
                                        child: TextFormField(
                                          style: const TextStyle(
                                              fontFamily: "EuclidCircularB"),
                                          maxLines: null,
                                          onTapOutside: (event) {
                                            //  context.read<EmojiVisBloc>().add(emojiHide());
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          controller: messageController,
                                          decoration: const InputDecoration(
                                              hintText: "message",
                                              border: InputBorder.none),
                                          onChanged: (value) {
                                            if (value == "") {
                                              context
                                                  .read<MessageBloc>()
                                                  .add(NoText());
                                            } else {
                                              context
                                                  .read<MessageBloc>()
                                                  .add(HasText());
                                            }
                                          },
                                        ),
                                      ),
                                      // for media

                                      // modal sheet for media
                                      IconButton(
                                          onPressed: () {
                                            showModalBottomSheet(
                                                backgroundColor:
                                                    Colors.transparent,
                                                context: context,
                                                isScrollControlled:
                                                    true, // Set this to true to enable full screen modal
                                                builder:
                                                    (BuildContext context) {
                                                  return ShareBottomModal(
                                                    groupRoomModel:
                                                        widget.groupRoomModel,
                                                    userModel: widget.userModel,
                                                  );
                                                });
                                          },
                                          icon: const Icon(Icons.attach_file)),
                                      // camera
                                      Visibility(
                                        visible:
                                            context.watch<MessageBloc>().state
                                                ? false
                                                : true,
                                        child: IconButton(
                                            onPressed: () async {
                                              await chooseDialog();
                                            },
                                            icon: const Icon(
                                                Icons.camera_alt_outlined)),
                                      ),
                                    ],
                                  )),
                        trailing: Container(
                          width: 60,
                          height: 60,
                          margin: const EdgeInsets.only(right: 5),
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromARGB(255, 230, 229, 229)),
                          child: context.watch<MessageBloc>().state
                              ? context.watch<PlayerVisBloc>().state
                                  ?
                                  // audio message
                                  IconButton(
                                      onPressed: () async {
                                        try {
                                          // saving aufio in storage
                                          final result = await FirebaseStorage
                                              .instance
                                              .ref("AllSharedMedia")
                                              .child(widget
                                                  .groupRoomModel.groupRoomId
                                                  .toString())
                                              .child("sharedMedia")
                                              .child(uuid.v1())
                                              .putFile(File(audioFilePath!));

                                          // getting download url
                                          String? mediaUrl =
                                              await result.ref.getDownloadURL();

                                          final newMessage = MediaModel(
                                              // creating message
                                              mediaId: uuid.v1(),
                                              senderId: widget.userModel.uId,
                                              fileUrl: mediaUrl,
                                              createdOn: DateTime.now(),
                                              type: "audio");

                                          // creating a messages collection inside chatroom docs and saving messages in them
                                          FirebaseFirestore.instance
                                              .collection("GroupChats")
                                              .doc(widget
                                                  .groupRoomModel.groupRoomId)
                                              .collection("messages")
                                              .doc(newMessage.mediaId)
                                              .set(newMessage.toMap())
                                              .then((value) {
                                            debugPrint("message sent");
                                          });

                                          // setting last message in chatroom and saving in firestore
                                          widget.groupRoomModel.lastMessage =
                                              newMessage.type;
                                          widget.groupRoomModel.lastTime =
                                              newMessage.createdOn;
                                          widget.groupRoomModel.lastMessageBy =
                                              newMessage.senderId;
                                          FirebaseFirestore.instance
                                              .collection("GroupChats")
                                              .doc(widget
                                                  .groupRoomModel.groupRoomId)
                                              .set(widget.groupRoomModel
                                                  .toMap());

                                          /////////////////////////
                                          context.read<PlayerVisBloc>().add(
                                              PlayerVisibility()); // make audio player visible
                                          context
                                              .read<MessageBloc>()
                                              .add(NoText());

                                          debugPrint(
                                              "${File(audioFilePath!)} is path $audioFilePath ");
                                        } catch (e) {
                                          debugPrint(
                                              "error in sending audio is $e");
                                        }
                                      },
                                      icon: const Icon(Icons.send_outlined))
                                  :
                                  // text message
                                  IconButton(
                                      onPressed: () {
                                        sendMessage();
                                        context
                                            .read<MessageBloc>()
                                            .add(NoText());
                                      },
                                      icon: const Icon(Icons.send))
                              : MicWidget(
                                  onStop: (String path) {
                                    // setState(() {
                                    audioFilePath = path;
                                    audioSource = ap.AudioSource.uri(
                                        Uri.parse(path)); // set the source
                                    // });
                                    context.read<PlayerVisBloc>().add(
                                        PlayerVisibility()); // make audio player visible
                                    context
                                        .read<MessageBloc>()
                                        .add(HasText()); // showing send arrow
                                  },
                                ),
                        ),
                      ),
                      // emoji keyboard
                      Visibility(
                        visible: context.watch<EmojiVisBloc>().state,
                        child: EmojiPicker(
                          onEmojiSelected: (category, emoji) =>
                              {context.read<MessageBloc>().add(HasText())},
                          onBackspacePressed: () {
                            if (messageController.text == "") {
                              context.read<MessageBloc>().add(NoText());
                            }
                          },
                          textEditingController: messageController,
                          config: const Config(
                            height: 256,
                            checkPlatformCompatibility: true,
                            // swapCategoryAndBottomBar: false,
                            skinToneConfig: SkinToneConfig(),
                            categoryViewConfig: CategoryViewConfig(),
                            bottomActionBarConfig: BottomActionBarConfig(),
                            searchViewConfig: SearchViewConfig(),
                          ),
                        ),
                      ),
                    ],
                  ); //
                }) //
                ) //
          ],
        ),
      )),
    );
  }

  // selecting image from gallary to send
  Future selectImage(FileType mediaType) async {
    final result = await FilePicker.platform.pickFiles(type: mediaType);

    setState(() {
      pickedMedia = result!.files.first;
    });
  }
  /////

// video Or image from camera
  Future fromCamera(String cameraType) async {
    late final captured;
    if (cameraType == "picture") {
      captured = await ImagePicker().pickImage(source: ImageSource.camera);
    } else if (cameraType == "video") {
      captured = await ImagePicker().pickVideo(source: ImageSource.camera);
    }

    if (captured != null) {
      setState(() {
        capturedFile = captured.path;
      });
    }
  }

  //
  Future chooseDialog() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text("Camera",
                  style: TextStyle(fontFamily: "EuclidCircularB")),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // for picture
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                          IconButton(
                          iconSize: 40,
                          onPressed: () async {
                            await fromCamera("picture");
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SendMedia(
                                        mediaToSend: capturedFile ?? "",
                                        groupRoomModel: widget.groupRoomModel,
                                        userModel: widget.userModel,
                                        type: "image")));
                          },
                          icon: const Icon(Icons.image)),
                            const Text("Picture" ,style:  TextStyle(fontFamily: "EuclidCircularB"),)
                        ],
                  ),

                  // for video
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        iconSize: 40,
                        onPressed: () async {
                          await fromCamera("video");
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SendMedia(
                                      mediaToSend: capturedFile ?? "",
                                      groupRoomModel: widget.groupRoomModel,
                                      userModel: widget.userModel,
                                      type: "video")));
                        },
                        icon: const Icon(Icons.video_camera_back),
                      ),
                        const Text("video" ,style: TextStyle(fontFamily: "EuclidCircularB"),)
                    ],
                  )
                ],
              ));
        });
  }

  // to add contact to phone
  Future<void> _requestContactsPermission() async {
    if (await Permission.contacts.request().isGranted) {
      debugPrint('Contact permission granted');
    } else {
      debugPrint('Contact permission denied');
    }
  }

// for date visibility
  bool showdate(current, previous) {
    String date1 = "${current.day}/ ${current.month}/ ${current.year}";
    String date2 = "${previous.day}/ ${previous.month}/ ${previous.year}";

    debugPrint("$date1 and $date2");
    if (date1 != date2) {
      return true;
    } else {
      return false;
    }
  }

  ///get list of media and send it to userprofile when profiled opened

  Future<void> getMediaList() async {
    mediaList.clear();
    FirebaseFirestore.instance
        .collection("GroupChats")
        .doc(widget.groupRoomModel.groupRoomId)
        .collection("messages")
        .orderBy("createdOn",
            descending: false) // so that messages appear from newer to older
        .snapshots()
        .listen((value) {
      for (var i in value.docs) {
        var dt = i.data() as Map<String, dynamic>;

        if (dt.containsValue("image") == true ||
            dt.containsValue("video") == true) {
          MediaModel mediaModel = MediaModel.fromMap(// getting media
              i.data());
          debugPrint("media data is ${mediaModel.type}");
          mediaList.add(mediaModel);
        }
      }
      debugPrint("media list in intstate $mediaList");
    });
  }
}
