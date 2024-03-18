import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_flutter/utils/utils.dart';
import 'package:firebase_flutter/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {

  final postsController = TextEditingController();
  bool isLoading = false;
  final databaseRef = FirebaseDatabase.instance.ref('Post');

  bool loading = false;
  File? _image;
  final picker = ImagePicker();
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
  // DatabaseReference databaseRef2 = FirebaseDatabase.instance.ref('Post');

  Future getImageGallery() async {
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        Utils().toastMessage("No Image Picked");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Post To Realtime DB"),
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
            Center(
              child: InkWell(
                onTap: () {
                  getImageGallery();
                },
                child: Container(
                  decoration:
                  BoxDecoration(border: Border.all(color: Colors.red)),
                  height: 200,
                  width: 200,
                  child: _image != null
                      ? Image.file(_image!.absolute)
                      : Icon(Icons.image),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),

            RoundButton(
                loading: isLoading,
                title: "Add", onTap: () async {
              setState(() {
                isLoading = true;
              });
              String id = DateTime.now().millisecondsSinceEpoch.toString();
              var newUrl = "";

              firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref('/images/' + '123');
              firebase_storage.UploadTask uploadTask = ref.putFile(_image!.absolute);
              await Future.value(uploadTask).then((value) async {
                 newUrl = await ref.getDownloadURL();
              }).then((value) {
                setState(() {
                  loading = false;
                });
                databaseRef.child(id).set({
                  'title' : postsController.text.toString(),
                  'id' : id,
                  'img' : newUrl.toString(),
                }).then((value) {
                  Utils().toastMessage("Post Added");
                  setState(() {
                    isLoading = false;
                  });
                }).onError((error, stackTrace){
                  Utils().toastMessage(error.toString());
                  setState(() {
                    isLoading = false;
                  });
                });
                Utils().toastMessage("Image Uploaded");
              }).onError((error, stackTrace) {
                setState(() {
                  loading = false;
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
