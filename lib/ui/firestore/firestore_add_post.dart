import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utils/utils.dart';
import '../../widgets/round_button.dart';

class FirestoreAddPostScreen extends StatefulWidget {
  const FirestoreAddPostScreen({Key? key}) : super(key: key);

  @override
  State<FirestoreAddPostScreen> createState() => _FirestoreAddPostScreenState();
}

class _FirestoreAddPostScreenState extends State<FirestoreAddPostScreen> {
  final postsController = TextEditingController();
  bool isLoading = false;
  final firestore = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Post To FireStore"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            SizedBox(height: 30,),
            TextFormField(
              controller: postsController,
              maxLines: 4,
              decoration: InputDecoration(
                  hintText: "What is in your mind..?",
                  border: OutlineInputBorder()
              ),

            ),
            SizedBox(height: 30,),
            RoundButton(
                loading: isLoading,
                title: "Add", onTap: (){
              setState(() {
                isLoading = true;
              });
              String id = DateTime.now().millisecondsSinceEpoch.toString();
              firestore.doc(id).set({
                'title' : postsController.text.toString(),
                'id' : id,
              }).then((value) {
                setState(() {
                  isLoading = false;
                });
                Utils().toastMessage("Post Added");
              }).onError((error, stackTrace) {
                setState(() {
                  isLoading = false;
                });
                Utils().toastMessage(error.toString());
              });

            })
          ],
        ),
      ),
    );
  }
}
