import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter/ui/auth/verify_code.dart';
import 'package:firebase_flutter/widgets/round_button.dart';
import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class LoginWithPhoneNumber extends StatefulWidget {
  const LoginWithPhoneNumber({Key? key}) : super(key: key);

  @override
  State<LoginWithPhoneNumber> createState() => _LoginWithPhoneNumberState();
}

class _LoginWithPhoneNumberState extends State<LoginWithPhoneNumber> {
  bool isLoading = false;
  final _phoneNumberController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Number Login"),
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
              controller: _phoneNumberController,
              decoration: InputDecoration(
                  hintText: "98776 XXXXX",
                  prefixIcon: Icon(Icons.phone_iphone_outlined)),
            ),
            SizedBox(
              height: 80,
            ),
            RoundButton(
              loading: isLoading,
                title: "Login",
                onTap: () {
                  setState(() {
                    isLoading = true;
                  });
                  _auth.verifyPhoneNumber(
                      phoneNumber: "+91${_phoneNumberController.text}",
                      verificationCompleted: (_) {
                        setState(() {
                          isLoading = false;
                        });
                      },
                      verificationFailed: (e) {
                        setState(() {
                          isLoading = false;
                        });
                        Utils().toastMessage(e.toString());
                      },
                      codeSent: (String verificationId, int? token) {
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VerifyCode(
                                      verificationId: verificationId,
                                    )));
                      },
                      codeAutoRetrievalTimeout: (e) {
                        setState(() {
                          isLoading = false;
                        });
                        Utils().toastMessage(e.toString());
                      });
                }),
          ],
        ),
      ),
    );
  }
}
