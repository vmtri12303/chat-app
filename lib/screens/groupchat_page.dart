import 'package:chat_app/screens/add_member_group_page.dart';
import 'package:chat_app/screens/groupchatroom_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

class GroupChatPage extends StatefulWidget {
  GroupChatPage({super.key});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  List groupList = [];

  RxBool isLoading = true.obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAvaiableGroup();
  }

  void getAvaiableGroup() async {
    String idUser = _auth.currentUser!.uid;
    await _firestore
        .collection('users')
        .doc(idUser)
        .collection('groups')
        .get()
        .then((value) {
      groupList = value.docs;
      isLoading.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Groups"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: getAvaiableGroup,
          )
        ],
      ),
      body: Column(
        children: [
          Obx(() {
            if (isLoading.value) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: groupList.length,
                  itemBuilder: ((context, index) {
                    if (groupList.isNotEmpty) {
                      return ListTile(
                        onTap: () {
                          Get.to(GroupChatRoomPage(
                              groupId: groupList[index]['id'],
                              groupName: groupList[index]['name']));
                        },
                        leading: Icon(Icons.group),
                        title: Text(groupList[index]['name']),
                      );
                    } else {
                      return Container();
                    }
                  }));
            }
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.create),
        onPressed: () {
          Get.to(AddMemberGroup());
        },
        tooltip: 'Create Group',
      ),
    );
  }
}
