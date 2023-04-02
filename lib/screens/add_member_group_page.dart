import 'package:chat_app/screens/create_group_page.dart';
import 'package:chat_app/widgets/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

class AddMemberGroup extends StatefulWidget {
  AddMemberGroup({super.key});

  @override
  State<AddMemberGroup> createState() => _AddMemberGroupState();
}

class _AddMemberGroupState extends State<AddMemberGroup> {
  final _searchText = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxBool isLoading = false.obs;

  RxList<Map<String, dynamic>> memberList = <Map<String, dynamic>>[].obs;

  var userMap = Rxn<Map<String, dynamic>>();

  var isUserFound = true.obs;

  @override
  void initState() {
    super.initState();
    getCurrentUserDetail();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(title: Text('Add Member')),
        body: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              return Flexible(
                  child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: memberList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () => onRemoveUserInGroup(index),
                    leading: Icon(Icons.account_circle),
                    title: Text(memberList[index]['name']),
                    subtitle: Text(memberList[index]['email']),
                    trailing: Icon(Icons.close),
                  );
                },
              ));
            }),
            MyTextField(
                size: size,
                hintText: 'Search',
                icon: const Icon(Icons.search_outlined),
                textController: _searchText),
            Obx(() {
              if (isLoading.value) {
                return Container(
                  height: size.height / 14,
                  width: size.width / 14,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else {
                return ElevatedButton(
                    onPressed: onSearch, child: Text('Search'));
              }
            }),
            Obx(
              () {
                if (userMap.value != null) {
                  return ListTile(
                    onTap: onAddUserInGroup,
                    leading: Icon(Icons.account_circle),
                    title: Text(userMap.value!['name']),
                    subtitle: Text(userMap.value!['email']),
                    trailing: Icon(Icons.add),
                  );
                }
                return Container();
              },
            ),
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
        floatingActionButton: Obx(() {
          if (memberList.length > 2) {
            return FloatingActionButton(
              onPressed: () {
                Get.to(CreateGroup(
                  memberList: memberList.value,
                ));
              },
              child: Icon(Icons.forward),
            );
          } else {
            return Container();
          }
        }));
  }

  void onSearch() async {
    isLoading.value = true;

    await _firestore
        .collection('users')
        .where("email", isEqualTo: _searchText.text)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        userMap.value = value.docs[0].data();
        isUserFound.value = true;
      } else {
        userMap.value = null;
        isUserFound.value = false;
      }

      isLoading.value = false;

      print(userMap);
      _searchText.text = '';
    });
  }

  void getCurrentUserDetail() async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((map) {
      memberList.add({
        'name': map['name'],
        'email': map['email'],
        'id': map['id'],
        'isAdmin': true,
      });
    });
  }

  void onAddUserInGroup() {
    bool flag = false;
    for (var i = 0; i < memberList.length; i++) {
      if (memberList[i]['id'] == userMap.value!['id']) {
        flag = true;
      }
    }
    if (!flag) {
      memberList.add({
        'name': userMap.value!['name'],
        'email': userMap.value!['email'],
        'id': userMap.value!['id'],
        'isAdmin': false,
      });
      userMap.value = null;
    } else {
      Get.snackbar('User Already Existed In Group', '',
          duration: Duration(seconds: 1));
    }
  }

  void onRemoveUserInGroup(int index) {
    if (memberList[index]['id'] != _auth.currentUser!.uid) {
      memberList.removeAt(index);
    } else {
      Get.snackbar('Cannot remove admin user', '',
          duration: Duration(seconds: 1));
    }
  }
}
