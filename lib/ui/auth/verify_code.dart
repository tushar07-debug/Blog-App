import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter/ui/posts/post_screen.dart';
import 'package:flutter/material.dart';

import '../../utils/utils.dart';
import '../../widgets/round_button.dart';

class VerifyCode extends StatefulWidget {
  final String verificationId;

  const VerifyCode({Key? key, required this.verificationId}) : super(key: key);

  @override
  State<VerifyCode> createState() => _VerifyCodeState();
}

class _VerifyCodeState extends State<VerifyCode> {
  bool isLoading = false;
  final otpController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OTP Verification"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: otpController,
              decoration: InputDecoration(
                  hintText: "Enter 6 Digit OTP",
                  prefixIcon: Icon(Icons.lock_clock)),
            ),
            SizedBox(
              height: 80,
            ),
            RoundButton(
                loading: isLoading,
                title: "Verify",
                onTap: () async {
                  setState(()  {
                    isLoading = true;
                  });
                  final credential = PhoneAuthProvider.credential(
                      verificationId: widget.verificationId,
                      smsCode: otpController.text.toString());

                  try{
                    await _auth.signInWithCredential(credential);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> PostScreen()));
                  }catch(e){
                    setState(() {
                      isLoading = false;
                    });
                    Utils().toastMessage(e.toString());
                  }
                })
          ],
        ),
      ),
    );
  }
}
