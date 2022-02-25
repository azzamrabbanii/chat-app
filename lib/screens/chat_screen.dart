import 'package:chat_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'CHAT_SCREEN';

  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final _auth = FirebaseAuth.instance;
  late User loggedInUser;

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
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        // for user input
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
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
