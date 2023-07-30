import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../components/button.dart';
import '../components/text_field.dart';

class LoginPage extends StatefulWidget {
final Function()? onTap;
  const LoginPage({
    super.key,
    required this.onTap
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

    // sign user in
void signIn() async {
  // show loading circle
  showDialog(
    context: context,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  // try sign in
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailTextController.text,
      password: passwordTextController.text,
    );

    // pop loading circle
    if (context.mounted) Navigator.pop(context);

    // Store FCM token in Firestore for the signed-in user
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? fcmToken = await messaging.getToken();
    if (fcmToken != null) {
      FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set({
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'email': emailTextController.text,
        'fcmToken': fcmToken,
      });
    }
  } on FirebaseAuthException catch (e) {
    // pop loading circle
    Navigator.pop(context);

    // display error message
    displayMessage(e.code);
  }
}


  // display a dialog message
  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
                ),
          
                //logo
                const Icon(
                  Icons.lock,
                  size: 100,
                ),
          
                const SizedBox(
                  height: 50,
                ),
          
                // welcome back message
                Text(
                  "Bienvenue, vous nous aver manquer",
                  style: TextStyle(color: Colors.grey[700]),
                ),
          
                const SizedBox(
                  height: 50,
                ),
          
                // password textfield
                MyTextField(
                  controller: emailTextController,
                  hintText: 'Email',
                  obscureText: true,
                ),
          
                const SizedBox(
                  height: 10,
                ),
          
                MyTextField(
                  controller: passwordTextController,
                  hintText: 'Mot de passe',
                  obscureText: true,
                ),
                //sign in button
          
                const SizedBox(
                  height: 25,
                ),
          
                MyButton(onTap: signIn, text: 'Se connecter'),
          
                const SizedBox(
                  height: 25,
                ),
          
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Vous n'êtes pas membre ?",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: (widget.onTap),
                      child: const Text(
                        "S'inscrire",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
