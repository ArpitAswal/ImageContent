import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:ImageContent/widgets/chatbubble.dart";

import "model/chatmodel.dart";

class ChatScreen extends StatefulWidget {

   ChatScreen({super.key, required String id}){
    postId=id;
  }

  static late String postId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final FirebaseAuth _auth= FirebaseAuth.instance;
  final CollectionReference firest= FirebaseFirestore.instance.collection("Chats");

  @override
  Widget build(BuildContext context) {
    String  message='';

    return Scaffold(
      appBar:AppBar(
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("Chats").doc(_auth.currentUser!.displayName).collection("Text").orderBy("timeStamp").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(snapshot.hasError || snapshot.connectionState== ConnectionState.none){
          return const Center(child:Text('Error'));
        }
        else if(snapshot.connectionState== ConnectionState.waiting){
          return const Center(child:CircularProgressIndicator());
        }
        return Container(
          height:MediaQuery.of(context).size.height,
          width:MediaQuery.of(context).size.width,
          color: Colors.yellow[100],
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context,index){
                  final QueryDocumentSnapshot doc = snapshot.data!.docs[index];
                  final ChatModel chatModel = ChatModel.fromSnapshot(doc);
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                            onLongPress: (){
                              showDialog(context: context, builder: (context) => AlertDialog(
                                actions: [
                                  IconButton(onPressed: (){
                                   String id=getId(snapshot,index);
                                   firest.doc(_auth.currentUser!.displayName).collection("Text").doc(id).delete();
                                   Navigator.of(context).pop();
                                  }, icon: const Icon(Icons.delete))
                                ],
                              ));
                            },
                            child: Column(
                              children: [
                                ChatBubble(chatModel),
                                const SizedBox(height:10),
                              ],
                            )),
                      );
                }),
              ),
            SizedBox(
              height:50,
              child:Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 6),
                child: Row(
                  children: [
                    Expanded(child:
                    TextField(
                      decoration: const InputDecoration (
                        border:OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                        ),
                          hintText:"Enter message",
                          contentPadding: EdgeInsets.symmetric(horizontal: 8.0)
                      ),
                     onChanged: (value){
                       message=value.trim();
                     },
                    )),
                    IconButton(onPressed: (){
                      if(message.isNotEmpty){
                        FirebaseFirestore.instance.collection("Chats").doc(_auth.currentUser!.displayName).collection("Text").add(
                        {"userId": FirebaseAuth.instance.currentUser!.uid,
                          "userName": FirebaseAuth.instance.currentUser!.displayName,
                          "message": message,
                          "timeStamp": Timestamp.now()
                        });
                        setState(() {
                          message="";
                        });
                      }
                    }, icon: const Icon(Icons.arrow_forward_ios))
                  ],
                ),
              )
            )
              ]
          ),
        );
      },
        )
    );
  }

  String getId(AsyncSnapshot<QuerySnapshot<Object?>> snapshot, int index) {

    List<QueryDocumentSnapshot> snap =snapshot.data!.docs;
    return snap[index].id;
  }

}
