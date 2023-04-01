import 'package:chat_app/screens/homepage.dart';
import 'package:chat_app/screens/signup_page.dart';
import 'package:chat_app/services/firebase.dart';
import 'package:chat_app/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _textControllerEmail = TextEditingController();
  final TextEditingController _textControllerPassword = TextEditingController();
  var isLoading = false.obs;
  LoginPage({super.key});
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
                            'Sign In to Continue!',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 25,
                                fontWeight: FontWeight.w500),
                          )),
                      SizedBox(
                        height: size.height / 10,
                      ),
                      MyTextField(
                          size: size,
                          hintText: 'Email',
                          icon: const Icon(Icons.email),
                          textController: _textControllerEmail),
                      MyTextField(
                          size: size,
                          hintText: 'Password',
                          icon: const Icon(Icons.lock),
                          textController: _textControllerPassword),
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
                                      _textControllerPassword.text.isNotEmpty) {
                                    isLoading.value = true;

                                    signIn(_textControllerEmail.text,
                                            _textControllerPassword.text)
                                        .then((user) {
                                      if (user != null) {
                                        isLoading.value = false;
                                        Get.snackbar('Login Successfully', '');
                                        Get.to(HomePage());
                                      } else {
                                        Get.defaultDialog(
                                            content: Text(
                                                'Email or Password is not correctly!'));
                                        isLoading.value = false;
                                      }
                                    });
                                  } else {
                                    isLoading.value = false;
                                    Get.defaultDialog(
                                        content:
                                            Text('Please fullfil the field!'));
                                  }
                                },
                                child: const Text(
                                  'Login',
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
                            Get.to(SignUp());
                          }),
                          child: const Text(
                            'Create Account',
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
