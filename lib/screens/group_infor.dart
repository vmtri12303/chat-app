import 'package:chat_app/screens/add_new_membergroup.dart';
import 'package:chat_app/screens/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

class GroupInfor extends StatefulWidget {
  const GroupInfor({super.key, required this.groupId, required this.groupName});
  final String groupId, groupName;

  @override
  State<GroupInfor> createState() => _GroupInforState();
}

class _GroupInforState extends State<GroupInfor> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxList memberList = [].obs;
  RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    getMemberList();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(body: Obx(() {
        if (isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(alignment: Alignment.centerLeft, child: BackButton()),
                Container(
                  height: size.height / 8,
                  width: size.width / 1.1,
                  child: Row(children: [
                    Container(
                      width: size.height / 14,
                      height: size.height / 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: Icon(
                        Icons.group,
                        color: Colors.white,
                        size: size.width / 14,
                      ),
                    ),
                    SizedBox(
                      width: size.width / 20,
                    ),
                    Expanded(
                      child: Text(
                        widget.groupName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: size.width / 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ]),
                ),
                SizedBox(
                  height: size.height / 20,
                ),
                Container(
                  width: size.width / 1.1,
                  child: Text(
                    'Number Of Members: ${memberList.length.toString()}',
                    style: TextStyle(
                      fontSize: size.width / 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 20,
                ),
                Obx(() {
                  return Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: memberList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            Get.defaultDialog(
                                content: Text("Are you sure?"),
                                onCancel: () {},
                                onConfirm: () {
                                  Get.back();
                                  removeUser(index);
                                });
                          },
                          leading: Icon(
                            Icons.account_circle,
                            size: size.width / 15,
                          ),
                          title: Text(
                            '${memberList[index]['name']}',
                            style: TextStyle(
                                fontSize: size.width / 22,
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text('${memberList[index]['email']}'),
                          trailing: Text(
                              '${memberList[index]['isAdmin'] ? 'Admin' : ''}'),
                        );
                      },
                    ),
                  );
                }),
                ListTile(
                  onTap: () {
                    Get.to(AddNewMemberInGroup2(
                      memberList: memberList,
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                    ));
                  },
                  leading: Icon(
                    Icons.add,
                    color: Colors.blue,
                  ),
                  title: Text(
                    "Add Member",
                    style: TextStyle(
                      fontSize: size.width / 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ),
                ListTile(
                  onTap: () {
                    onLeaveGroup();
                  },
                  leading: Icon(
                    Icons.logout,
                    color: Colors.redAccent,
                  ),
                  title: Text(
                    "Leave Group",
                    style: TextStyle(
                      fontSize: size.width / 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      })),
    );
  }

  void getMemberList() async {
    isLoading.value = true;
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .get()
        .then((value) {
      memberList.value = value['member'];
      isLoading.value = false;
    });
  }

  void removeUser(index) async {
    if (checkIfAdmin()) {
      if (!memberList[index]['isAdmin']) {
        String userId = memberList[index]['id'];
        String userRemoved = memberList[index]['name'];
        memberList.removeAt(index);
        await _firestore
            .collection('groups')
            .doc(widget.groupId)
            .update({'member': memberList});

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('groups')
            .doc(widget.groupId)
            .delete();
        Get.snackbar("Alert", "Member has been removed!");
        await _firestore
            .collection('groups')
            .doc(widget.groupId)
            .collection('chats')
            .add({
          "message":
              '$userRemoved has been removed by ${_auth.currentUser!.displayName}',
          "type": 'notify',
          "time": FieldValue.serverTimestamp(),
          "sendBy": _auth.currentUser!.displayName,
        });
      } else {
        Get.defaultDialog(
            title: 'Alert!', content: Text('Can\'t remove admin'));
      }
    } else {
      Get.defaultDialog(
          title: 'Alert!', content: Text('Only Admin can remove members'));
    }
  }

  bool checkIfAdmin() {
    bool flag = false;
    String currentIdUser = _auth.currentUser!.uid;
    for (var i = 0; i < memberList.length; i++) {
      if (memberList[i]['id'] == currentIdUser) {
        if (memberList[i]['isAdmin'] == true) {
          flag = true;
        }
      }
    }
    return flag;
  }

  void onLeaveGroup() async {
    String id = _auth.currentUser!.uid;
    if (checkIfAdmin()) {
      for (var i = 0; i < memberList.length; i++) {
        if (memberList[i]['id'] == id) {
          memberList.removeAt(i);
        }
      }
      await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .update({'member': memberList});

      await _firestore
          .collection('users')
          .doc(id)
          .collection('groups')
          .doc(widget.groupId)
          .delete();
      if (memberList.length > 1) {
        memberList[0]['isAdmin'] = true;
        await _firestore
            .collection('groups')
            .doc(widget.groupId)
            .update({'member': memberList});
      }
      Get.snackbar("Alert", "Leave Group!");
      Get.to(HomePage());
      await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .collection('chats')
          .add({
        "message": '${_auth.currentUser!.displayName} left this group',
        "type": 'notify',
        "time": FieldValue.serverTimestamp(),
        "sendBy": _auth.currentUser!.displayName,
      });
    } else {
      for (var i = 0; i < memberList.length; i++) {
        if (memberList[i]['id'] == id) {
          memberList.removeAt(i);
        }
      }
      await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .update({'member': memberList});

      await _firestore
          .collection('users')
          .doc(id)
          .collection('groups')
          .doc(widget.groupId)
          .delete();
      Get.snackbar("Alert", "Leave Group!");
      Get.to(HomePage());
      await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .collection('chats')
          .add({
        "message": '${_auth.currentUser!.displayName} left this group',
        "type": 'notify',
        "time": FieldValue.serverTimestamp(),
        "sendBy": _auth.currentUser!.displayName,
      });
    }
  }
}
