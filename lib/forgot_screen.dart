import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ImageContent/database_alert.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final auth = FirebaseAuth.instance;
  bool load = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17.0),
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
         //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          RichText(
              text: const TextSpan(
                text: 'Reset',
            style: TextStyle(fontSize: 44,fontWeight: FontWeight.w700,color: Colors.black),
            children:<InlineSpan> [
              WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: SizedBox(width: 15)),
              TextSpan(
                text:'Password ?',style: TextStyle(color: Colors.lightBlue)
              ),
            ]
          )),
           const SizedBox(height: 8),
            const Text('Enter the e-mail address associated with your account',style: TextStyle(
                fontSize: 19,fontWeight: FontWeight.w400,color: Colors.blueGrey
            )),
            const SizedBox(height: 6,),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textCapitalization: TextCapitalization.none,
              decoration: const InputDecoration(
                prefixIconColor: Colors.black54,
                prefixIcon: Icon(Icons.email_rounded),
                labelText: 'E-mail',
                labelStyle: TextStyle(
                    color: Colors.black, fontSize: 18),
                hintText: 'your personal E-mail Id',
                hintStyle: TextStyle(
                    color: Colors.blue, fontSize: 14),
              ),
                validator: (value) {
                  if (value!.isEmpty || value==null)
                    return "Please enter the E-mail Id";
                  else
                    return null;
                }
            ),
            const SizedBox(
              height: 40,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 5,
                  shadowColor: Colors.purple,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(21)),
                      side: BorderSide(color: Colors.white,width: 1.5)),
                  backgroundColor: Colors.deepPurple),
              onPressed: () {
                setState(() {
                  load = true;
                });
                auth
                    .sendPasswordResetEmail(
                        email: emailController.text.toString())
                    .then((value) {
                  setState(() {
                    load = false;
                  });
                  alert.toastmessage(
                      'We have sent you email to recover password, please check email');
                }).onError((error, stackTrace) {
                  setState(() {
                    load = false;
                  });
                  alert.toastmessage(error.toString());
                });
              },
              child: Center(
                  child: load
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        )
                      : const Text(
                          'RESET',
                          style: TextStyle(fontSize: 21, color: Colors.white),
                        )),
            )
          ],
        ),
      ),
    );
  }
}
