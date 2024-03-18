import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_flutter/utils/utils.dart';
import 'package:firebase_flutter/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({Key? key}) : super(key: key);

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  bool loading = false;
  File? _image;
  final picker = ImagePicker();
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
  DatabaseReference databaseRef2 = FirebaseDatabase.instance.ref('Images');

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
          title: Text("Image Upload Screen"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                  title: "Upload",
                  loading: loading,
                  onTap: () async {
                    setState(() {
                      loading = true;
                    });
                    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref('/images/' + '123');
                    firebase_storage.UploadTask uploadTask = ref.putFile(_image!.absolute);
                    await Future.value(uploadTask).then((value) async {
                      var newUrl = await ref.getDownloadURL();
                      var id = DateTime.now().millisecondsSinceEpoch.toString();
                      databaseRef2.child(id).set({
                        'id' : id,
                        'image_url' : newUrl.toString()
                      }).then((value) {
                        setState(() {
                          loading = false;
                        });
                        Utils().toastMessage('Uploaded');
                      }).onError((error, stackTrace) {
                        setState(() {
                          loading = false;
                        });
                        Utils().toastMessage(error.toString());
                      });
                    }).onError((error, stackTrace) {
                      setState(() {
                        loading = false;
                      });
                      Utils().toastMessage(error.toString());
                    });
                  })
            ],
          ),
        ));
  }
}
