import 'package:chat_app/models/users.dart';
import 'package:chat_app/screens/chat_page.dart';
import 'package:chat_app/screens/groupchat_page.dart';
import 'package:chat_app/screens/login_page.dart';
import 'package:chat_app/services/firebase.dart';
import 'package:chat_app/widgets/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _searchTextController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseStore = FirebaseFirestore.instance;
  var myUser = Rxn<MyUser>();
  var isUserFound = true.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatusUser('Online');
  }

  void setStatusUser(String status) async {
    await _firebaseStore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .update({'status': status});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setStatusUser('Online');
    } else {
      setStatusUser('Offine');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(_auth.currentUser?.displayName != null
            ? 'Welcome ${_auth.currentUser!.displayName}'
            : "Welcome"),
        actions: [
          IconButton(
            onPressed: () => logOut(),
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
          child: Column(
        children: [
          MyTextField(
              size: size,
              hintText: 'Search',
              icon: const Icon(Icons.search_outlined),
              textController: _searchTextController),
          SizedBox(
            height: size.height * 1 / 30,
          ),
          ElevatedButton(onPressed: onClickSearchButton, child: Text('Search')),
          SizedBox(
            height: size.height * 1 / 20,
          ),
          Obx(() {
            return myUser.value != null
                ? ListTile(
                    leading: const Icon(
                      Icons.account_box,
                      color: Colors.black,
                    ),
                    onTap: () {
                      String roomId = chatRoomId(
                          _auth.currentUser!.displayName,
                          myUser.value!.name,
                          _auth.currentUser!.email,
                          myUser.value!.email);
                      MyUser userPass = MyUser(
                          name: myUser.value!.name,
                          id: myUser.value!.id,
                          email: myUser.value!.email,
                          password: myUser.value!.password,
                          status: myUser.value!.status);
                      Get.to(ChatPage(
                        chatRoomId: roomId,
                        myUser: userPass,
                      ));
                    },
                    title: Text(
                      myUser.value!.name,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(myUser.value!.email),
                    trailing: const Icon(
                      Icons.chat,
                      color: Colors.black,
                    ),
                  )
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
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.group), onPressed: (() => Get.to(GroupChatPage()))),
    );
  }

  String chatRoomId(
      String? user1, String user2, String? email1, String email2) {
    print(email1);
    print(email2);
    try {
      for (var i = 0; i < email1!.length; i++) {
        if (email1[i] != email2[i]) {
          if (email1[i].toLowerCase().codeUnits[0] >
              email2[i].toLowerCase().codeUnits[0]) {
            print(email1[i].toLowerCase().codeUnits[0]);
            print(email2[i].toLowerCase().codeUnits[0]);
            return '$user1$user2';
          } else {
            return '$user2$user1';
          }
        }
      }
    } catch (e) {
      print(e);
    }

    return '';
  }

  void onClickSearchButton() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      await firestore
          .collection('users')
          .where('email', isEqualTo: _searchTextController.text)
          .get()
          .then((values) {
        if (values.docs.isNotEmpty) {
          myUser.value = MyUser.fromJson(values.docs[0].data());
          isUserFound.value = true;
        } else {
          myUser.value = null;
          isUserFound.value = false;
        }
      });
    } catch (e) {
      print(e);
    }
  }
}
