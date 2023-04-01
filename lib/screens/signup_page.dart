import 'dart:ui';

import 'package:chat_app/screens/homepage.dart';
import 'package:chat_app/screens/login_page.dart';
import 'package:chat_app/services/firebase.dart';
import 'package:chat_app/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUp extends StatelessWidget {
  SignUp({super.key});
  final TextEditingController _textControllerEmail = TextEditingController();
  final TextEditingController _textControllerPassword = TextEditingController();
  final TextEditingController _textControllerName = TextEditingController();
  var isLoading = false.obs;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Obx(() {
      return Scaffold(
        body: isLoading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SafeArea(
                child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: size.height / 40,
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width / 35),
                        child: SizedBox(
                          height: size.height / 40,
                          child: const Icon(Icons.arrow_back_ios),
                        ),
                      ),
                      SizedBox(
                        height: size.height / 30,
                      ),
                      Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: size.width / 25),
                          child: const Text(
                            'Welcome',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          )),
                      Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: size.width / 25),
                          child: const Text(
                            'Create Account to Continue!',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 25,
                                fontWeight: FontWeight.w500),
                          )),
                      SizedBox(
                        height: size.height / 10,
                      ),
                      MyTextField(
                          textController: _textControllerName,
                          size: size,
                          hintText: 'Name',
                          icon: const Icon(Icons.nest_cam_wired_stand_sharp)),
                      MyTextField(
                          textController: _textControllerEmail,
                          size: size,
                          hintText: 'Email',
                          icon: const Icon(Icons.email)),
                      MyTextField(
                          textController: _textControllerPassword,
                          size: size,
                          hintText: 'Password',
                          icon: const Icon(Icons.lock)),
                      SizedBox(
                        height: size.height / 10,
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width / 15),
                        child: SizedBox(
                            height: size.height / 18,
                            width: size.width,
                            child: ElevatedButton(
                                onPressed: () {
                                  if (_textControllerEmail.text.isNotEmpty &&
                                      _textControllerPassword.text.isNotEmpty &&
                                      _textControllerName.text.isNotEmpty) {
                                    isLoading.value = true;
                                    createAccout(
                                            _textControllerName.text,
                                            _textControllerPassword.text,
                                            _textControllerEmail.text)
                                        .then((user) {
                                      if (user != null) {
                                        isLoading.value = false;
                                        print('Sign Up Successfully');
                                        Get.snackbar(
                                            'Sign Up Successfully', '');
                                        Get.to(HomePage());
                                      } else {
                                        isLoading.value = false;
                                        print('Sign Up Failed');
                                        Get.defaultDialog(
                                            content: Text(
                                                'The email address is badly formatted.'));
                                      }
                                    });
                                  } else {
                                    Get.defaultDialog(
                                        title: "",
                                        content:
                                            Text('Please fullfil the field!'));
                                  }
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ))),
                      ),
                      SizedBox(
                        height: size.height / 25,
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: (() {
                            Get.offAll(LoginPage());
                          }),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ]),
              )),
      );
    });
  }
}
