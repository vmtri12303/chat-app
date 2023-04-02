import 'dart:io';
import 'package:chat_app/screens/group_infor.dart';
import 'package:chat_app/screens/image_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class GroupChatRoomPage extends StatelessWidget {
  GroupChatRoomPage(
      {super.key, required this.groupId, required this.groupName});

  final _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String groupId;
  final String groupName;
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(GroupInfor(groupId: groupId, groupName: groupName));
              },
              icon: Icon(Icons.more_vert))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.only(top: 10),
                height: size.height / 1.30,
                width: size.width,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('groups')
                      .doc(groupId)
                      .collection('chats')
                      .orderBy('time')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> chatMap =
                              snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;

                          return messageTitle(size, chatMap);
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                )),
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
                          controller: _messageController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: getImage,
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

  Widget messageTitle(Size size, Map<String, dynamic> chatMap) {
    return Builder(builder: (_) {
      if (chatMap['type'] == "text") {
        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] == _auth.currentUser!.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.blue,
              ),
              child: Column(
                children: [
                  Text(
                    chatMap['sendBy'].toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: size.height / 200,
                  ),
                  Text(
                    chatMap['message'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              )),
        );
      } else if (chatMap['type'] == "img") {
        return Container(
          height: size.height / 2.5,
          width: size.width,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          alignment: chatMap['sendBy'] == _auth.currentUser!.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(left: 16, bottom: 10),
                child: Text(chatMap['sendBy'].toString(),
                    style: TextStyle(
                      fontSize: 14,
                    )),
              ),
              Expanded(
                child: InkWell(
                  onTap: (() =>
                      Get.to(ImageDetail(imageUrl: chatMap['message']))),
                  child: Container(
                    alignment: Alignment.center,
                    width: size.width / 2,
                    child: chatMap['message'] != ''
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.network(
                              chatMap['message'],
                              fit: BoxFit.cover,
                            ),
                          )
                        : const CircularProgressIndicator(),
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (chatMap['type'] == "notify") {
        return Container(
          width: size.width,
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black38,
            ),
            child: Text(
              chatMap['message'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      } else {
        return SizedBox();
      }
    });
  }

  void onSendMessage() async {
    if (_messageController.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": _auth.currentUser!.displayName,
        "message": _messageController.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _messageController.clear();

      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('chats')
          .add(chatData);
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
        .collection('groups')
        .doc(groupId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendBy": _auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      print('Imagne: $imageUrl');
    }
  }
}
