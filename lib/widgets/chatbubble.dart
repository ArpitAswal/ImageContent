import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

import "../model/chatmodel.dart";

class ChatBubble extends StatelessWidget {
   ChatBubble(this.chatModel, {Key? key}) : super(key: key);

  final ChatModel chatModel;
  final currentUserId= FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return  Align(
      alignment: chatModel.userId==currentUserId? Alignment.centerRight:Alignment.centerLeft,
      child: Container(
        padding:const EdgeInsets.symmetric(horizontal: 12,vertical: 5),
        decoration: BoxDecoration(
            color:chatModel.userId==currentUserId? Colors.lightGreen[200]:Colors.white,
              borderRadius: BorderRadius.only(
              bottomLeft: const Radius.circular(17),
              topRight: chatModel.userId==currentUserId? Radius.zero : const Radius.circular(17),
              topLeft: chatModel.userId==currentUserId? const Radius.circular(17): Radius.zero,
              bottomRight: const Radius.circular(17),

            )
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
                alignment: Alignment.topLeft,
                child: Text(chatModel.message,style: const TextStyle(fontSize:18,fontWeight: FontWeight.w400))),
            const SizedBox(width:10),
            Column(
            children: [
              const SizedBox(height:15),
              Align(
                  alignment: Alignment.bottomRight,
                  child: Text(chatModel.userName,style: const TextStyle(fontSize:12,fontWeight: FontWeight.w300),))

            ],
          )
              ],
        )
      ),
    );
  }
}
