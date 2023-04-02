import 'dart:io';

import 'package:chat_app/models/users.dart';
import 'package:chat_app/screens/image_detail.dart';
import 'package:chat_app/widgets/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatelessWidget {
  ChatPage({super.key, required this.myUser, required this.chatRoomId});
  final MyUser myUser;
  final String chatRoomId;
  final _messageTextController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? imageFile;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('users').doc(myUser.id).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return Container(
                child: Column(children: [
                  Text(myUser.name),
                  Text(
                    snapshot.data!['status'],
                    style: TextStyle(fontSize: 14),
                  ),
                ]),
              );
            }
            return Container();
          },
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height / 1.3,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chatroom')
                    .doc(chatRoomId)
                    .collection('chats')
                    .orderBy('time', descending: false)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: ((context, index) {
                          Map<String, dynamic> map = snapshot.data!.docs[index]
                              .data() as Map<String, dynamic>;
                          return map['type'] == 'text'
                              ? MyMessage(auth: _auth, size: size, map: map)
                              : Container(
                                  height: size.height / 2.5,
                                  width: size.width,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 5),
                                  alignment: map['sendby'] ==
                                          _auth.currentUser!.displayName
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: InkWell(
                                    onTap: (() => Get.to(
                                        ImageDetail(imageUrl: map['message']))),
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: size.height / 2.5,
                                      width: size.width / 2,
                                      child: map['message'] != ''
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              child: Image.network(
                                                map['message'],
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : const CircularProgressIndicator(),
                                    ),
                                  ),
                                );
                        }));
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Container(
              alignment: Alignment.center,
              height: size.height * 1 / 10,
              width: size.width,
              child: Container(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: size.height / 12,
                        width: size.width / 1.5,
                        child: TextField(
                          controller: _messageTextController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  getImage();
                                },
                                icon: const Icon(Icons.photo)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: onSendMessage,
                          icon: const Icon(Icons.send))
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onSendMessage() async {
    if (_messageTextController.text.isNotEmpty && _auth.currentUser != null) {
      Map<String, dynamic> messages = {
        'sendby': _auth.currentUser!.displayName,
        'message': _messageTextController.text,
        'time': FieldValue.serverTimestamp(),
        'type': 'text',
      };
      _messageTextController.clear();
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .add(messages);
    } else {
      print('Message sent unsuccessful');
    }
  }

  Future getImage() async {
    ImagePicker picker = ImagePicker();
    await picker.pickImage(source: ImageSource.gallery).then(
      (xFile) {
        if (xFile != null) {
          imageFile = File(xFile.path);
          uploadImage();
        } else {
          print('cannot get imagefile');
        }
      },
    );
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;

    await _firestore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      print(imageUrl);
    }
  }
}
