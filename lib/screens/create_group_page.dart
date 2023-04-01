import 'package:chat_app/screens/homepage.dart';
import 'package:chat_app/widgets/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class CreateGroup extends StatelessWidget {
  CreateGroup({required this.memberList, super.key});

  RxBool isLoading = false.obs;
  List<Map<String, dynamic>> memberList;
  final _groupNameText = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Name'),
      ),
      body: Obx(() {
        if (!isLoading.value) {
          return Column(children: [
            MyTextField(
                size: size,
                hintText: 'Enter Group Name',
                icon: const Icon(Icons.group_add),
                textController: _groupNameText),
            ElevatedButton(onPressed: createGroup, child: Text('Create Group'))
          ]);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      }),
    );
  }

  void createGroup() async {
    isLoading.value = true;
    String groupId = Uuid().v1();
    await _firestore.collection('groups').doc(groupId).set({
      'member': memberList,
      'id': groupId,
    });
    for (int i = 0; i < memberList.length; i++) {
      String id = memberList[i]['id'];

      await _firestore
          .collection('users')
          .doc(id)
          .collection('groups')
          .doc(groupId)
          .set({
        "name": _groupNameText.text,
        "id": groupId,
      });
    }
    await _firestore.collection('groups').doc(groupId).collection('chats').add({
      "message": '${_firebaseAuth.currentUser!.displayName} Created This Group',
      "type": 'notify',
      "time": FieldValue.serverTimestamp(),
      "sendBy": _firebaseAuth.currentUser!.displayName,
    });
    Get.snackbar('Group has been created successfully', '');
    Get.to(HomePage());
  }
}
