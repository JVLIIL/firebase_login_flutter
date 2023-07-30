

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../components/button.dart';
import '../components/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({
    super.key, 
     required this.onTap
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controller
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

void signUp() async {
  // show loading circle
  showDialog(
    context: context,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  // make sure the password matches
  if (passwordTextController.text != confirmPasswordTextController.text) {
    // pop loading circle
    Navigator.pop(context);

    // message error
    displayMessage("Le mot de passe ne correspond pas !");
    return;
  }

  // try creating user
  try {
    // create the user
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailTextController.text,
      password: passwordTextController.text,
    );

    // after creating the user, create a new document in the Cloud Firestore called Users
    FirebaseFirestore.instance.collection("Users").doc(userCredential.user!.email).set({
      'username': emailTextController.text.split('@')[0], // initial username
      // add any additional field as needed
    });

    // Store FCM token in Firestore for the new user
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? fcmToken = await messaging.getToken();
    if (fcmToken != null) {
      FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': emailTextController.text,
        'fcmToken': fcmToken,
      });
    }

    // pop loading circle
    if (context.mounted) Navigator.pop(context);
  } on FirebaseAuthException catch (e) {
    // pop loading circle
    Navigator.pop(context);

    // show error to user
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
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
                      "Nous allons créer un compte pour vous",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
        
                    const SizedBox(
                      height: 25,
                    ),
        
                    //email textfield
                    MyTextField(
                        controller: emailTextController,
                        hintText: 'Email',
                        obscureText: false),
        
                    const SizedBox(
                      height: 10,
                    ),
        
                    // password textfield
                    MyTextField(
                        controller: passwordTextController,
                        hintText: 'Mot de passe',
                        obscureText: true),
        
                    const SizedBox(
                      height: 10,
                    ),
        
                    //comfirme password textfield
                    MyTextField(
                        controller: confirmPasswordTextController,
                        hintText: 'Confirmer le mot de passe',
                        obscureText: true),
        
                    const SizedBox(
                      height: 10,
                    ),
                    //sign in button
        
                    MyButton(onTap: signUp, text: 'S\'inscrire'),
        
                    const SizedBox(
                      height: 25,
                    ),
                    // go to register page
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Vous avez déjà un compte ?",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            "Se connecter ici",
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
        ));
  }
}
