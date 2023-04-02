import 'package:chat_app/models/users.dart';
import 'package:chat_app/screens/groupchat_page.dart';
import 'package:chat_app/screens/groupchatroom_page.dart';
import 'package:chat_app/widgets/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddNewMemberInGroup2 extends StatelessWidget {
  AddNewMemberInGroup2(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.memberList});
  final String groupId, groupName;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List memberList;
  final _seachEditController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Rxn<Map<String, dynamic>> userMap = Rxn<Map<String, dynamic>>();
  var isUserFound = true.obs;
  @override
  Widget build(BuildContext context) {
    print(memberList);
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text('Add Member Into $groupName')),
      body: SingleChildScrollView(
          child: Column(
        children: [
          MyTextField(
              size: size,
              hintText: 'Search',
              icon: const Icon(Icons.search_outlined),
              textController: _seachEditController),
          ElevatedButton(onPressed: onSearch, child: Text('Search')),
          Obx(() {
            return userMap.value != null
                ? ListTile(
                    leading: const Icon(
                      Icons.account_box,
                      color: Colors.black,
                    ),
                    title: Text(
                      userMap.value!['name'],
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(userMap.value!['email']),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.black,
                      ),
                      onPressed: addUserInGroup,
                    ))
                : Container();
          }),
          Obx(() {
            if (!isUserFound.value) {
              return Text(
                'User not found',
                style: TextStyle(fontSize: 20, color: Colors.red),
              );
            } else {
              return Container();
            }
          }),
        ],
      )),
    );
  }

  void onSearch() {
    _firestore
        .collection('users')
        .where('email', isEqualTo: _seachEditController.text)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        userMap.value = value.docs[0].data();
        isUserFound.value = true;
      } else {
        userMap.value = null;
        isUserFound.value = false;
      }
    });
  }

  void addUserInGroup() async {
    bool check = true;
    for (var i = 0; i < memberList.length; i++) {
      if (memberList[i]['email'] == _seachEditController.text) {
        check = false;
      }
    }
    if (check) {
      memberList.add({
        'name': userMap.value!['name'],
        'email': userMap.value!['email'],
        'id': userMap.value!['id'],
        'isAdmin': false,
      });

      await _firestore
          .collection('users')
          .doc(userMap.value!['id'])
          .collection('groups')
          .doc(groupId)
          .set({'id': groupId, "name": groupName});
      await _firestore
          .collection('groups')
          .doc(groupId)
          .update({'member': memberList});
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('chats')
          .add({
        "message":
            '${userMap.value!['name']} has been added by ${_auth.currentUser!.displayName}',
        "type": 'notify',
        "time": FieldValue.serverTimestamp(),
        "sendBy": _auth.currentUser!.displayName,
      });
      Get.snackbar('Add Successfully', '');
      userMap.value = null;
    } else {
      Get.defaultDialog(
        title: "Alert",
        content: Text('User already in group'),
      );
    }
  }
}
