import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter/firebase_services/db_services.dart';
import 'package:firebase_flutter/ui/firestore/firestore_add_post.dart';
import 'package:firebase_flutter/ui/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../firebase_services/splash_services.dart';
import '../../utils/utils.dart';
import '../auth/login_screen.dart';

class FirestorePostScreen extends StatefulWidget {
  const FirestorePostScreen({Key? key}) : super(key: key);

  @override
  State<FirestorePostScreen> createState() => _FirestorePostScreenState();
}

class _FirestorePostScreenState extends State<FirestorePostScreen> {
  final _auth = FirebaseAuth.instance;
  final editController = TextEditingController();
  final searchFilterController = TextEditingController();
  final firestore = FirebaseFirestore.instance.collection('users').snapshots();
  final ref = FirebaseFirestore.instance.collection('users');




  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DbServices>(context);
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: (){
              setState(() {
                dbProvider.setRealtimeDb(true);
                // print(dbProvider.realtimeDb.toString());
                Navigator.push(context, MaterialPageRoute(builder: (context)=> SplashScreen()));
              });
            },
            child: dbProvider.realtimeDb ? Icon(Icons.offline_bolt) : Icon(Icons.offline_bolt_outlined)),
        title: Text("Firestore Posts Screen"),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                _auth.signOut().then((value) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                }).onError((error, stackTrace) {
                  Utils().toastMessage(error.toString());
                });
              },
              icon: Icon(Icons.logout_outlined))
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: TextFormField(
              controller: searchFilterController,
              decoration: InputDecoration(
                  hintText: "Search", border: OutlineInputBorder()),
              onChanged: (String value) {
                setState(() {});
              },
            ),
          ),
          SizedBox(height: 10,),
          StreamBuilder(
              stream: firestore,
              builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return Shimmer.fromColors(
                      baseColor: Colors.grey.shade700,
                      highlightColor: Colors.grey.shade100,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              height: 50,
                              width: 50,
                              color: Colors.white,
                            ),
                            title: Container(
                              height: 10,
                              width: 89,
                              color: Colors.white,
                            ),
                            subtitle: Container(
                              height: 10,
                              width: 89,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ));                }
                else if (snapshot.hasError){
                  Utils().toastMessage("Some Error");
                }

                  return    Expanded(
                    flex: 1,
                    child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index){
                          String title = snapshot.data!.docs[index]['title'].toString();
                          String id = snapshot.data!.docs[index]['id'].toString();
                          if(searchFilterController.text.isEmpty){
                            return ListTile(
                              title: Text(title),
                              subtitle: Text(id),
                              trailing: PopupMenuButton(
                                icon: Icon(Icons.more_vert),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                      value: 1,
                                      child: ListTile(
                                        onTap: () {
                                          Navigator.pop(context);
                                          showMyDialog(title, id);
                                        },
                                        leading: Icon(Icons.edit),
                                        title: Text("Edit"),
                                      )),
                                  PopupMenuItem(
                                      value: 2,
                                      child: ListTile(
                                        onTap: (){
                                          Navigator.pop(context);
                                          ref.doc(id).delete();
                                        },
                                        leading: Icon(Icons.delete),
                                        title: Text("Delete"),
                                      )),
                                ],
                              ),
                            );
                          }else if(title.toLowerCase().contains(searchFilterController.text.toLowerCase())){
                            return ListTile(
                              title: Text(title),
                              subtitle: Text(id),
                            );
                          }else {
                            return Container();
                          }
                        }),
                  );

              }),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => FirestoreAddPostScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> showMyDialog(String title, String id) async {
    editController.text = title;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Update"),
            content: Container(
              child: TextFormField(
                controller: editController,
                decoration: InputDecoration(),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.doc(id).update({
                      'title' : editController.text.toString()
                    }).then((value) {
                      Utils().toastMessage("Post Updated");
                    }).onError((error, stackTrace){
                      Utils().toastMessage(error.toString());

                    });
                  },
                  child: Text("Update")),
            ],
          );
        });
  }
}
