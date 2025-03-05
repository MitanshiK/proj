import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proj/ChatApp/helpers/firebase_helper.dart';
import 'package:proj/ChatApp/models/group_room_model.dart';
import 'package:proj/ChatApp/models/user_model.dart';
import 'package:proj/ChatApp/pages/adding_people/create_group.dart';
import 'package:proj/ChatApp/no_data_pages/no_group_chats.dart';
import 'package:proj/ChatApp/pages/chatrooms/groupchatroom.dart';

class AllGroupChatPage extends StatefulWidget {
   const AllGroupChatPage({super.key , required this.firebaseUser, required this.userModel });
   final UserModel userModel;
  final User firebaseUser; // firebase auth user

  @override
  State<AllGroupChatPage> createState() => _AllGroupChatPageState();
}

class _AllGroupChatPageState extends State<AllGroupChatPage> {
List<UserModel> groupMembers =[];   


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Group Chats",style: TextStyle(fontFamily:"EuclidCircularB" ,fontSize: 18),)
          ,trailing: IconButton(onPressed: (){
               Navigator.push(context, MaterialPageRoute(
                      builder: (context)=> 
                      CreateGroupPage(firebaseUser: widget.firebaseUser, userModel: widget.userModel, existing: false,)));
          }, icon: const Icon(Icons.add)),)
        // 
        ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("GroupChats")
            .where("participantsId.${widget.userModel.uId}", isEqualTo: true)
            .snapshots(), // get the chatroom that contain current User
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
            
              return (dataSnapshot.docs.isNotEmpty) 
              ? ListView.builder(
                itemCount: dataSnapshot.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  GroupRoomModel groupRoomModel = GroupRoomModel.fromMap(
                      dataSnapshot.docs[index].data()
                          as Map<String, dynamic>);
      
      
                 // to get targetUsers Id
                  Map<String, dynamic> participants =
                      groupRoomModel.participantsId!; // getting participants
                  List<String> participantsList = participants.keys
                      .toList(); // getting participants keys and saving in list
                  participantsList.remove(widget.userModel
                      .uId);  // removing currentUser key so that we are left with targetuser id
         
                              // getMembersModel(participantsList);   // to get list of usermodels of members
                          getMembersModel(participantsList);
      
                          
                          String toShow;
                          String msgDate="${groupRoomModel.lastTime!.day}/${groupRoomModel.lastTime!.month}/${groupRoomModel.lastTime!.year}";
                          String currentDate="${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
                          
                   
                           if(currentDate.compareTo(msgDate)==0){
              
                            String msgTime="${groupRoomModel.lastTime!.hour}:${groupRoomModel.lastTime!.minute}";
                            String curTime="${DateTime.now().hour}:${DateTime.now().minute}";
            
                            // inner if start
                            if(msgTime==curTime){
                              toShow="now";
                            }
                            else{
                              toShow=msgTime;
                            }// inner if close
            
                           }else{
                            toShow = msgDate;
                           }
                          return StreamBuilder(
                            stream:  FirebaseFirestore.instance
                                      .collection("ChatAppUsers")
                                      .where("uId", isEqualTo: groupRoomModel.lastMessageBy)
                                       .snapshots(),
                            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                            
                               if (snapshot.hasData){   
                                   QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                            if(dataSnapshot.docs.isNotEmpty){
                            UserModel lastMessageUser = UserModel.fromMap(
                                           dataSnapshot.docs[0].data()
                                        as Map<String, dynamic>);
      
                             // UserModel lastMessageUser=  UserModel.fromMap(dataSnapshot.docs[0].data() as Map<String,dynamic>);
      
                              return  ListTile(
                              onTap: () async{
                               await    getMembersModel(participantsList); 
                                 // to get list of usermodels of members
                                  debugPrint("members are ${groupMembers.toString()}");
                            
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => GroupRoomPage(
                                              firebaseUser: widget.firebaseUser,
                                              userModel: widget.userModel,
                                              groupRoomModel: groupRoomModel,
                                               groupMembers:groupMembers,
                                            )));
                              },
                              title: Text(groupRoomModel.groupName.toString() ,style: const TextStyle(fontFamily:"EuclidCircularB")  ),
                              leading: CircleAvatar(
                                 radius: 25,
                                backgroundColor:
                                    const Color.fromARGB(255, 158, 219, 241),
                                backgroundImage: (groupRoomModel.profilePic!= null && groupRoomModel.profilePic!="")
                                         ?  NetworkImage(groupRoomModel.profilePic.toString())
                                         : const AssetImage("assets/group_image.png") as ImageProvider
                                // (groupRoomModel.profilePic!=null && groupRoomModel.profilePic!="") 
                                // ? NetworkImage(
                                //    groupRoomModel.profilePic.toString(),
                                //    )
                                //    : AssetImage("assets/group_image") as ImageProvider
                                   ,
                              ),
                              subtitle: (groupRoomModel.lastMessage.toString() !=
                                      "")
                                  ? Text((lastMessageUser.uId==widget.userModel.uId )
                                      ? "You : ${groupRoomModel.lastMessage.toString()}"
                                      :  "${lastMessageUser.name} : ${groupRoomModel.lastMessage.toString()}"
                                      
                                      )
                                  : const Text("Say Hello"  ,style: TextStyle(fontFamily:"EuclidCircularB")  ),
                                  trailing: Text(toShow  ,style: const TextStyle(fontFamily:"EuclidCircularB")  ),
                            );
                         } else{
                          return ListTile(
                              onTap: () async{
                               await    getMembersModel(participantsList); 
                                 // to get list of usermodels of members
                                  debugPrint("members are ${groupMembers.toString()}");
                            
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => GroupRoomPage(
                                              firebaseUser: widget.firebaseUser,
                                              userModel: widget.userModel,
                                              groupRoomModel: groupRoomModel,
                                               groupMembers:groupMembers,
                                            )));
                              },
                              title: Text(groupRoomModel.groupName.toString()  ,style: const TextStyle(fontFamily:"EuclidCircularB")  ),
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor:
                                    const Color.fromARGB(255, 158, 219, 241),
                                backgroundImage: NetworkImage(
                                   groupRoomModel.profilePic.toString()),
                              ),
                              subtitle: (groupRoomModel.lastMessage.toString() !=
                                      "")
                                  ? const Text("say hello" 
                                       ,style: TextStyle(fontFamily:"EuclidCircularB")  
                                      )
                                  : const Text("Say Hello"  ,style: TextStyle(fontFamily:"EuclidCircularB")  ),
                                  trailing: Text(toShow),
                            );
                         }
                            }else{
                              return const Text("no data"  ,style: TextStyle(fontFamily:"EuclidCircularB")  );
                            }
                            
                            }
                          );
                },
              )
              : NoGroupChatPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser,);
            
              /////
            } else if (snapshot.hasError) {
              return NoGroupChatPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser,);
            } else {
              return  NoGroupChatPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser,);
            }
          } else {
            return const Center(
               child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );

  }

  // getting usersmodel from uid and adding to members list
Future getMembersModel(List<String> uIds)async{

  List<UserModel> fungroupMembers =[]; 
  for(var id in uIds){
     UserModel? a= await FirebaseHelper.getUserModelById(id);
     fungroupMembers.add(a!);
   }

  groupMembers.clear(); 
 groupMembers.addAll(fungroupMembers);
 groupMembers.add(widget.userModel);

}

}