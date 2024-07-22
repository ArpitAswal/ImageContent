import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ImageContent/database_alert.dart';
import 'package:ImageContent/auth/verifycode_screen.dart';

class LoginWithPhoneNumber extends StatefulWidget {
  final String choice;
  const LoginWithPhoneNumber({super.key, required this.choice});
  @override
  State<LoginWithPhoneNumber> createState() => _LoginWithPhoneNumberState();
  void verify() {
    _LoginWithPhoneNumberState()._verifyPhoneNumber();
  }
}

class _LoginWithPhoneNumberState extends State<LoginWithPhoneNumber> {
  bool load = false;
  bool check = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  final numberController = TextEditingController();
  //int? forceResendingToken;
  @override
  Future<void> _verifyPhoneNumber() async {
    auth.userChanges();
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: numberController.text.toString(),
        timeout: Duration(seconds: 7),
    //    forceResendingToken:forceResendingToken != null ? forceResendingToken : null,
        verificationCompleted: (_) {
          alert.toastmessage('verified');
          setState(() {
            load = false;
          });
        },
        verificationFailed: (e) {
          alert.toastmessage('error');
          setState(() {
            load = false;
          });
        },
        codeSent: (String verificationId, int? token) {
          //this.forceResendingToken = forceResendingToken;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VerifyCodeScreen(
                      verificationId: verificationId, choice: widget.choice)));
          setState(() {
            load = false;
          });
        },
        codeAutoRetrievalTimeout: (e) {
          alert.toastmessage('TimeOut');
          setState(() {
            load = false;
          });
        });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Login with number')),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            SizedBox(height: 80),
            Text(
              "Add your phone number. we'll send you a verification code",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black38,
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: numberController,
                    keyboardType: TextInputType.phone,
                    onChanged: (text) {
                      if (text.length == 14)
                        setState(() {
                          check = true;
                        });
                      else
                        setState(() {
                          check = false;
                        });
                    },
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: check
                            ? Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 32,
                              )
                            : Container(
                                height: 1,
                                width: 1,
                              )
                        ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          load = true;
                        });
                        _verifyPhoneNumber();
                      },
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.deepPurple),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                      ),
                      child: Center(
                          child: load
                              ? CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                )
                              : Text(
                                  'Send',
                                  style: TextStyle(
                                      fontSize: 21, color: Colors.white),
                                )),
                    ),
                  )
                ],
              ),
            ),
          ]),
        ));
  }
}
