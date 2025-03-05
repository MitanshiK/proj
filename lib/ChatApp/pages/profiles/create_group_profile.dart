import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proj/ChatApp/helpers/ui_helper.dart';
import 'package:proj/ChatApp/models/user_model.dart';
import 'package:proj/ChatApp/models/group_room_model.dart';
import 'package:proj/ChatApp/pages/chatrooms/groupchatroom.dart';


class CreateGroupProfile extends StatefulWidget {
  const CreateGroupProfile({super.key ,required this.firebaseUser , required this.userModel ,required this.groupRoomModel ,required this.groupMembers});
  final  UserModel userModel;
  final  User firebaseUser;  
  final GroupRoomModel  groupRoomModel;
 final List<UserModel> groupMembers;

  @override
  State<CreateGroupProfile> createState() => _CreateGroupProfileState();
}

class _CreateGroupProfileState extends State<CreateGroupProfile> {

 File? profilePic;
  bool picked = false;
  String name = "";
  // TextEditingController groupNameController= TextEditingController();

@override
  void initState() {
   if(widget.groupRoomModel.groupName!=null || widget.groupRoomModel.groupName!=""){
    name=widget.groupRoomModel.groupName!;
   }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final groupProfileKey = GlobalKey<FormState>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
           backgroundColor: Colors.white,
        title: const Text("Complete Profile"  ,style: TextStyle(fontFamily:"EuclidCircularB")  ),
        
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color.fromARGB(255, 240, 217, 148),
                    backgroundImage: (picked == true)
                        ? FileImage(profilePic!)
                        : (widget.groupRoomModel.profilePic!=null && widget.groupRoomModel.profilePic!="") ? NetworkImage(widget.groupRoomModel.profilePic.toString()) : const AssetImage("assets/group_image.png") as ImageProvider,
                    // child: (picked == false)
                    //     ? const Icon(
                    //         Icons.person,
                    //         size: 60,
                    //         color: Colors.black,
                    //       )
                    //     : null
                        ),
                Positioned(
                    bottom: -1,
                    right: 5,
                    // change profile
                    child:
                     GestureDetector(
                        onTap: () {
                          showoptions();
                        },
                        child: const CircleAvatar(
                          radius: 15,
                          backgroundColor:  Color.fromARGB(255, 240, 217, 148),
                          child: Icon(Icons.edit)))
                        
                        ),
              ],
            ),
            const SizedBox(
              height: 30,
             ),
            Form(
                key: groupProfileKey,
                child: Column(
                  children: [
                    TextFormField(
                      // controller: groupNameController,
                      initialValue: (name!="")  ? name : "${widget.userModel.name} group",
                      decoration: const InputDecoration(
                          label: Text("Name"  ,style: TextStyle(fontFamily :"EuclidCircularB")  ), border: OutlineInputBorder()),
                          validator: (value){
                           if(value!.trim()==""){
                              return "empty name field";
                           }
                           else
                           {
                            return null;
                            }
                          },
                          onSaved: (newValue) {
                            if(newValue!.trim()!=""){
                            setState(() {
                              name=newValue;
                            });
                            }
                          },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      child: TextButton(
                          onPressed: () {
                             if(groupProfileKey.currentState!.validate())
                             {
                               groupProfileKey.currentState!.save();
                             uploadData();
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
                            "Save",
                            style: TextStyle(
                             fontFamily:"EuclidCircularB",  
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                                ),
                          )),
                    ),
                  
                    
                  ],
                )),
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width/1.2,
                     height: MediaQuery.sizeOf(context).height/3,
                     
                      child: ListView(
                          children:List.generate(widget.groupMembers.length, (index){
                           return ListTile(
                              leading: CircleAvatar(
                                backgroundColor:  const Color.fromARGB(255, 240, 217, 148),
                                backgroundImage: NetworkImage(widget.groupMembers[index].profileUrl!),
                                radius: 30,
                                ),
                                title: Text(widget.groupMembers[index].name!  ,style: const TextStyle(fontFamily:"EuclidCircularB")  ),
                                subtitle:  Text(widget.groupMembers[index].email!  ,style: const TextStyle(fontFamily:"EuclidCircularB")  ),
                            );
                          }),
                        ),
                    ),
                  )
          ],
        ),
      ),
    );
  }
  //////////////

///////1

void showoptions(){
 showDialog(context: context,
  builder: ( context) { 
   return AlertDialog(
    title: const Text("Upload Profile from"  ,style: TextStyle(fontFamily:"EuclidCircularB")  ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
      ListTile(
        onTap: (){
          fromCamera(ImageSource.camera);
          Navigator.pop(context);
        },
        leading: const Icon(Icons.camera),
      title: const Text("Open Camera"  ,style: TextStyle(fontFamily:"EuclidCircularB")  ),),

      ListTile(
          onTap: (){
        selectProfile();
          Navigator.pop(context);
          },
          leading: const Icon(Icons.image),
               title: const Text("Upload from Gallary"  ,style: TextStyle(fontFamily:"EuclidCircularB")  ),),
    ],),
   );
   });
}
//////2
//from gallary
  Future selectProfile() async {        // select image from gallary 
    final result = await FilePicker.platform.pickFiles(type: FileType.image,);

    if(result!=null){
      cropImage(result.files.first);
    }
  }
  // from camera
    void fromCamera(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if(pickedFile != null) {
      cropImageCamera(pickedFile);
    }
  }
///////3

void cropImageCamera(XFile file) async {
    final croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20
    );

    if(croppedImage != null) {
      setState(() {
         picked = true;
        profilePic = File(croppedImage.path);
      });
    }
  }

  void cropImage(PlatformFile? selectedImg) async{           // to crop the image 
      final croppedImage = await ImageCropper().cropImage(             
      sourcePath: selectedImg!.path!,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20
    );
     debugPrint("path of cropped image file is ${croppedImage!.path} ");
     
       setState(() {
      picked = true;
      profilePic = File(croppedImage.path);
    });
    debugPrint("path of cropped image file is ${profilePic!.path}  and picked value is $picked");
  }

  // 4//////////////////////////////////////////////////to change
  void uploadData() async{
    // uploading image to the firebase storage 
    UiHelper.loadingDialogFun(context, "Saving..");
  if(picked==true){
    final result=await FirebaseStorage.instance.ref("ProfilePictures").child(widget.groupRoomModel.groupRoomId.toString()).putFile(profilePic!);  
    
    // getting the download link of image uploaded in storage
    String? imageUrl= await result.ref.getDownloadURL();

    // saving name and imageurl in the empty fields of usermodel
    widget.groupRoomModel.profilePic =imageUrl;
  }

    widget.groupRoomModel.groupName=name;
   // updating data in firestore 
    await FirebaseFirestore.instance.collection("GroupChats").doc(widget.groupRoomModel.groupRoomId).set(widget.groupRoomModel.toMap()).then((value){
    debugPrint("profile complete !");
    
    Navigator.pop(context);   
    Navigator.pushReplacement(context, MaterialPageRoute(builder: ((context) => GroupRoomPage(firebaseUser: widget.firebaseUser, userModel: widget.userModel, groupMembers: widget.groupMembers, groupRoomModel: widget.groupRoomModel,))));
    });
  }
  
}