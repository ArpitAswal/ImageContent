
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ImageContent/auth/email_verification_screen.dart';
import '../functionCalls/navigation_helper.dart';
import 'login_screen.dart';
import 'package:ImageContent/database_alert.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formkey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  bool load = false;
  bool hidden = true;
  bool obsText = true;
  String _email = "";
  String _username = "";
  String _password = "";

  late final FocusNode _emailFocusNode;
  late final FocusNode _usernameFocusNode;
  late final FocusNode _passwordFocusNode;
  late final FirebaseAuth _auth;

  @override
  void initState() {
    _emailFocusNode = FocusNode();
    _usernameFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _auth= FirebaseAuth.instance;
    super.initState();
  }

  @override
  void dispose() {
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    emailController.dispose();
    userController.dispose();
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
                            const SizedBox(height: 150),
                            const Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Sign Up",
                                    style: TextStyle(
                                        fontSize: 38,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.italic,
                                        letterSpacing: 1,
                                        wordSpacing: 2))),
                            const SizedBox(height: 70,),
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
                                  labelStyle: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                  hintText: 'E-mail Id',
                                  hintStyle: TextStyle(
                                      color: Colors.blue, fontSize: 14),
                                ),
                                onSaved: (value){
                                  _email= value!.trim();
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Please enter the E-mail Id";
                                  } else {
                                    return null;
                                  }
                                }),
                            const SizedBox(height: 10,),
                            TextFormField(
                                controller: userController,
                                focusNode: _usernameFocusNode,
                                keyboardType: TextInputType.name,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  prefixIconColor: Colors.black54,
                                  prefixIcon: Icon(Icons.person),
                                  labelText: 'Name',
                                  labelStyle: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                  hintText: 'Enter your profile name',
                                  hintStyle: TextStyle(
                                      color: Colors.blue, fontSize: 14),
                                ),
                                onSaved: (value){
                                  _username= value!.trim();
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Please enter the name";
                                  } else {
                                    return null;
                                  }
                                }),
                            const SizedBox(height: 10,),
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
                                  hintText: "please don't use space in Password",
                                  hintStyle: const TextStyle(
                                      color: Colors.blue, fontSize: 14),
                                  suffixIcon: InkWell(
                                    onTap: _togglePassword,
                                    child: Icon(
                                      hidden
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.black54,
                                    ),
                                  ),),
                                onSaved: (value){
                                  _password = value!.trim();
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Please enter the Password";
                                  } else {
                                    return null;
                                  }
                                }),

                            const SizedBox(height: 35),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  elevation: 5,
                                  shadowColor: Colors.purple,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(21)),
                                      side: BorderSide(color: Colors.white,width: 1.5)),
                                  backgroundColor: Colors.deepPurple),
                              onPressed: () async {
                                if (_formkey.currentState!.validate()) {
                                  setState(() {
                                    load = true;
                                  });
                                  _formkey.currentState!.save();
                                   await _auth
                                      .createUserWithEmailAndPassword(
                                      email: emailController.text.toString(),
                                      password: passwordController.text.toString())
                                       .then((value) async{
                                    await _auth.currentUser!.updateDisplayName(userController.text.toString());
                                    setState(() {
                                     load=false;
                                   });
                                    navigateScreen();
                                  }).onError((error, stackTrace) {
                                    if(error!=null && error.toString().contains("The email address is already in use by another account.")){
                                        showAlertMsg(this.context);
                                    }
                                    else {
                                      alert.toastmessage(error.toString());
                                    }
                                    setState(() {
                                      load=false;
                                    });
                                  });
                                }
                              },
                              child: Center(
                                  child: load
                                      ? const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  )
                                      : const Text(
                                    'Sign up',
                                    style: TextStyle(
                                        fontSize: 21, color: Colors.white),
                                  )),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Already have an account?",
                                    style: TextStyle(fontSize: 18)),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const LoginScreen()));
                                  },
                                  child:
                                  const Text("Login", style: TextStyle(fontSize: 18)),
                                ),
                              ],
                            )
                          ],
                        ),
            ),
                )
          )),
    );
  }

  void navigateScreen() {
    navigateWithSlideTransition(context, EmailVerificationScreen(username: _username, email: _email, password: _password), curve: Curves.linear, duration: const Duration(milliseconds: 800),
      navigationType: NavigationType.pushReplacement,);
  }

  void showAlertMsg(BuildContext context) {
    showDialog(context: context, builder: (context){
       return Theme(
         data: ThemeData(canvasColor: Colors.cyanAccent[300]),
         child: AlertDialog(
          title: const Text("Email Alert"),
          content: const Text("The email address is already in use by another account. Please register with a new email or do google sign in with this email"),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(21.0))
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'))
          ],
               ),
       );
    });
  }
}