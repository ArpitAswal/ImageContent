import 'dart:io';

import 'package:ImageContent/functionCalls/navigation_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ImageContent/database_alert.dart';
import 'package:flutter/material.dart';
import 'package:ImageContent/auth/login_withPhone.dart';
import 'package:ImageContent/auth/signup_screen.dart';
import '../forgot_screen.dart';
import '../posts/post_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formkey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool load = false;
  bool hidden = true;
  bool obsText = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;
  late DatabaseReference reference;
  late Reference storageRef;
  late String? photoUrl;

  bool verified = false;

  @override
  void initState() {
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    reference = FirebaseDatabase.instance.ref("Database of Information");
    storageRef = firebase_storage.FirebaseStorage.instance.ref().child("${_auth.currentUser?.displayName}/ProfileImages");
    super.initState();
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _togglePassword() {
    setState(() {
      hidden = !hidden;
      obsText = !obsText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/login.png'), fit: BoxFit.cover)),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Form(
                key: _formkey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  children: [
                    const SizedBox(
                      height: 150,
                    ),
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Sign In",
                            style: TextStyle(
                                fontSize: 36,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 1,
                                wordSpacing: 2))),
                    const SizedBox(
                      height: 70,
                    ),
                    TextFormField(
                        controller: emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          prefixIconColor: Colors.black54,
                          prefixIcon: Icon(Icons.email_rounded),
                          labelText: 'E-mail',
                          labelStyle:
                              TextStyle(color: Colors.black, fontSize: 18),
                          hintText: 'your account E-mail Id',
                          hintStyle:
                              TextStyle(color: Colors.blue, fontSize: 14),
                        ),
                        onSaved: (value) {},
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter the E-mail Id";
                          } else {
                            return null;
                          }
                        }),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                        controller: passwordController,
                        focusNode: _passwordFocusNode,
                        keyboardType: TextInputType.text,
                        obscureText: obsText,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          prefixIconColor: Colors.black54,
                          prefixIcon: const Icon(Icons.lock),
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                              color: Colors.black, fontSize: 18),
                          hintText: 'Enter your account password',
                          hintStyle:
                              const TextStyle(color: Colors.blue, fontSize: 14),
                          suffixIcon: InkWell(
                            onTap: _togglePassword,
                            child: Icon(
                              hidden ? Icons.visibility_off : Icons.visibility,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        onSaved: (value) {},
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter the Password";
                          } else {
                            return null;
                          }
                        }),
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen()));
                        },
                        child: const Text("Forgot Password?",
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          elevation: 5,
                          shadowColor: Colors.purple,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(21)),
                              side:
                                  BorderSide(color: Colors.white, width: 1.5)),
                          backgroundColor: Colors.deepPurple),
                      onPressed: () {
                        if (_formkey.currentState!.validate()) {
                          setState(() {
                            load = true;
                          });
                          signInWithEmail();
                        }
                      },
                      child: Center(
                          child: load
                              ? const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                      fontSize: 21, color: Colors.white),
                                )),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Or Sign in with',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 7,
                              shadowColor: Colors.teal[100],
                              shape: CircleBorder(
                                  side: BorderSide(
                                      color: Colors.cyan.shade100, width: 2))),
                          child: const CircleAvatar(
                            backgroundImage: AssetImage('assets/google.png'),
                            radius: 30,
                          ),
                          onPressed: () {
                            _signIn(context);
                          },
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 7,
                                shadowColor: Colors.grey,
                                shape: const CircleBorder(
                                    side: BorderSide(
                                        color: Colors.white, width: 2))),
                            child: const CircleAvatar(
                              backgroundImage: AssetImage('assets/phone.png'),
                              radius: 30,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginWithPhoneNumber(
                                            choice: 'login',
                                          )));
                            }),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?",
                            style: TextStyle(fontSize: 18)),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SignUpScreen()));
                          },
                          child: const Text("Sign up",
                              style: TextStyle(fontSize: 18)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Future<void> _signIn(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    // Sign out to force account selection every time
    await googleSignIn.signOut();

    try {
      final GoogleSignInAccount? googleAccount = await googleSignIn.signIn();
      if (googleAccount != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleAccount.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
            idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
        await _auth.signInWithCredential(authCredential);
        try {
          bool exists = await userAccountExist();
          if(exists) {
            final AuthCredential emailCredential = EmailAuthProvider.credential(
              email: googleAccount.email,
              password: "", // Ensure this is securely handled
            );

            await _auth.currentUser?.linkWithCredential(emailCredential).whenComplete(() async{
              photoUrl = await _fetchProfileImageUrl();
              if(photoUrl != null && photoUrl!.isEmpty) {
                saveProfile(googleAccount.photoUrl!);
              }
            });
            navigateScreen();
          }
          else{
            saveSignInInfo(googleAccount.email, googleAccount.displayName, "", googleAccount.photoUrl);
          }
        } catch (linkError) {
          // Show an error message to the user
          if (linkError
              .toString()
              .contains("User has already been linked to the given email")) {
            navigateScreen();
          } else if (linkError
              .toString()
              .contains("Unable to establish connection on channel")) {
            navigateScreen();
          } else {
            alert.toastmessage(linkError.toString());
          }
        }
      }
    } catch (signInError) {
      // Handle error while signing in
      alert.toastmessage("Error during Google Sign-In: $signInError");
    }
  }

  void navigateScreen() {
    navigateWithSlideTransition(
      context,
      const PostScreen(),
      curve: Curves.linear,
      duration: const Duration(milliseconds: 800),
      navigationType: NavigationType.pushReplacement,
    );
  }

  void signInWithEmail() {
    _auth
        .signInWithEmailAndPassword(
            email: emailController.text.toString(),
            password: passwordController.text.toString())
        .then((value) {
      verified = _auth.currentUser!.emailVerified;
      if (verified) {
        alert.toastmessage("Email Successfully Verified");
        navigateScreen();
      } else {
        alert.toastmessage(
            'This account is still not verified, Try again SignUp and first verify then SignIn');
      }
      setState(() {
        load = false;
      });
    }).onError((error, stackTrace) {
      setState(() {
        load = false;
      });
      alert.toastmessage(error.toString());
    });
  }

  Future<bool> userAccountExist() async{
    final DatabaseEvent event = await reference.child(_auth.currentUser!.uid.toString()).once();
    final DataSnapshot snapshot = event.snapshot;
    // Check if the snapshot has data
    if (snapshot.exists) {
      // Child exists
      return true;
    } else {
      // Child does not exist
      return false;
    }
  }

  void saveSignInInfo(String email, String? name, String password, String? photoUrl) async{

    await reference.child('${_auth.currentUser?.uid}').set({
      'User Name' : name,
      'E-mail ID': email,
      'Password' : password,
      'Profile Image' : ''
    }).whenComplete(() async{
      navigateScreen();
      await storageRef.putFile(File(photoUrl!));
      var imageUrl = await storageRef.getDownloadURL();
      if(imageUrl.isEmpty || imageUrl=='null'){
        alert.toastmessage("No image Path received! Something went Wrong.");
      } else{
        reference.child('${_auth.currentUser?.uid}').update({
          'Profile Image': imageUrl.toString()
        });
      }
    }
    ).onError((error, stackTrace) => alert.toastmessage(error.toString()));
  }

  Future<String?> _fetchProfileImageUrl() async {
    final DataSnapshot snapshot = await reference.child(_auth.currentUser!.uid.toString()).child('Profile Image').get();

    if (snapshot.exists) {
      return snapshot.value.toString();
    } else {
      return null;
    }
  }

  void saveProfile(String photoUrl) {
      reference.child('${_auth.currentUser?.uid}').update({
        'Profile Image': photoUrl.toString()
    });
      storageRef.storage.ref().child('${_auth.currentUser?.uid}/ProfileImages');
  }
}
