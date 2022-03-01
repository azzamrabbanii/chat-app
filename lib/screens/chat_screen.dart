import 'package:chat_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final _fireStore = FirebaseFirestore.instance;
late User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'CHAT_SCREEN';

  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final _auth = FirebaseAuth.instance;

  late String message;

  final _textController = TextEditingController();

  late DateTime now;
  late String formattedDate;

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
        leading: Icon(Icons.forum),
        title: const Text('Chat'),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
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
                      controller: _textController,
                      style: const TextStyle(color: Colors.black),
                      onChanged: (value) {
                        message = value;
                        // for user input
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        now = DateTime.now();
                        formattedDate = DateFormat('kk:mm:ss').format(now);

                      });
                      _textController.clear();
                      _fireStore
                          .collection("messages")
                          .add({'text': message, 'sender': loggedInUser.email, 'time': formattedDate});
                      // for send some message
                    },
                    child: const Text('Send', style: kSendButtonTextStyle,
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
        stream: _fireStore.collection("message")
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
      if(!snapshot.hasData){
        return const Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.lightBlue,
          ),
        );
      }

      final message = snapshot.data!.docs;
      List<MessageBubble> messageBubbles = [];
      for(var message in message){
        final messageText = message['text'];
        final messageSender = message['sender'];

        final currentUserEmail = loggedInUser.email;

        final messageWidget = MessageBubble(text: messageText, sender: messageSender, isMe: currentUserEmail == messageSender ,);
        messageBubbles.add(messageWidget);
      }
      return Expanded(
        child: ListView(
          children: messageBubbles,
        ),
      );
    });
  }
}

class MessageBubble extends StatelessWidget {

  final String sender;
  final String text;
  final bool isMe;

  const MessageBubble({Key? key, required this.sender, required this.text, required this.isMe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(sender, style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
        Material(
          borderRadius: BorderRadius.only(
             topLeft: isMe ? Radius.circular(30) : Radius.circular(0),
             topRight: isMe ? Radius.circular(0) : Radius.circular(30),
             bottomRight: Radius.circular(30),
             bottomLeft: Radius.circular(30),
    ),
          elevation: 5,
          color: Colors.lightBlue,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              text,
              style: TextStyle(color: isMe ? Colors.white : Colors.black54, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}
