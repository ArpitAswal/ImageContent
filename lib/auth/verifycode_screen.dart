import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ImageContent/database_alert.dart';
import '../posts/post_screen.dart';
import 'package:pinput/pinput.dart';
import 'package:ImageContent/auth/login_withPhone.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String verificationId;
  final String choice;
  const VerifyCodeScreen({super.key, required this.verificationId, required this.choice});
  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  bool load = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  final verifyController = TextEditingController();

  static var defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(20),
    ),
  );

  final focusedPinTheme = defaultPinTheme.copyDecorationWith(
    border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
    borderRadius: BorderRadius.circular(8),
  );

  final submittedPinTheme = defaultPinTheme.copyWith(
    decoration: defaultPinTheme.decoration?.copyWith(
      color: Color.fromRGBO(234, 239, 243, 1),
    ),
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Verifycode'),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(height: 30),
              Text('Phone Verification',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 40),
              Pinput(
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                length: 6,
                showCursor: true,
                onChanged: (code) {
                  verifyController.text = code;
                },
              ),
              SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(21)),
                        side: BorderSide(color: Colors.white)),
                    backgroundColor: Colors.deepPurple),
                onPressed: () async {
                  setState(() {
                    load = true;
                  });
                  final cred = PhoneAuthProvider.credential(
                      verificationId: widget.verificationId,
                      smsCode: verifyController.text.toString());
                  try {
                    debugPrint(widget.choice);
                    if(widget.choice=='login')
                       await auth.signInWithCredential(cred);
                    else if(widget.choice=='linkin') {
                      final linkauthresult = await auth.currentUser
                          ?.linkWithCredential(cred);
                      if (linkauthresult != null)
                        alert.toastmessage('Linked with Phone Number');
                    }
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PostScreen()));
                  } catch (e) {
                    setState(() {
                      load = false;
                    });
                    alert.toastmessage('Linking error');
                  }
                },
                child: Center(
                    child: load
                        ? CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          )
                        : Text(
                            'Verify',
                            style: TextStyle(fontSize: 21, color: Colors.white),
                          )),
              ),
              SizedBox(height: 30),
              Text("Don't receive code",
                  style: TextStyle(color: Colors.lightBlueAccent)),
              SizedBox(height: 5),
              InkWell(
                  onTap: () {
                    LoginWithPhoneNumber(choice: widget.choice).verify();
                  },
                  child: Text("resend?",
                      style: TextStyle(color: Colors.lightBlueAccent))),
            ],
          ),
        ));
  }

}
