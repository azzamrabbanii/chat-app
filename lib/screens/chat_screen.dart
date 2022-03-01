import 'dart:html';
import 'dart:ui';

import 'package:chat_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _fireStore = FirebaseFirestore.instance;

class ChatScreen extends StatefulWidget {
  static const String id = 'CHAT_SCREEN';

  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final _auth = FirebaseAuth.instance;
  late User loggedInUser;

  late String message;

  void getCurrentUser(){
    try{
      final user = _auth.currentUser;
      if (user != null){
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch(e){}
  }

  @override
  void initState(){
    getCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        title: const Text('Chat'),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
              onPressed: () {
                // for logout
              },
              icon: const Icon(Icons.close))
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.black),
                      onChanged: (value) {
                        message = value;
                        // for user input
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _fireStore.collection("messages").add({'text': message, 'sender': loggedInUser.email});
                      // for send some message
                    },
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  const MessageStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _fireStore.collection("message").snapshots(),
        builder: (context, snapshot) {
      if(snapshot!.hasData){
        return Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.lightBlue,
          ),
        );
      }

      final message = snapshot.data!.docs;
      List<Text> messageWidgets = [];
      for(var message in message){
        final messageText = message['text'];
        final messageSender = message['sender'];

        final messageWidget = Text('$messageText form $messageSender');
        messageWidgets.add(messageWidget);
      }
      return Expanded(
        child: ListView(
          children: messageWidgets,
        ),
      );
    });
  }
}
