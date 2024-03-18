import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_flutter/ui/auth/login_screen.dart';
import 'package:firebase_flutter/ui/firestore/firestore_add_post.dart';
import 'package:firebase_flutter/ui/posts/add_post.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../firebase_services/db_services.dart';
import '../../utils/utils.dart';
import '../splash_screen.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _auth = FirebaseAuth.instance;
  final ref = FirebaseDatabase.instance.ref('Post');
  final searchFilterController = TextEditingController();
  final editController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DbServices>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        leading: Consumer<DbServices>(builder: (context, value , child){
          return InkWell(
              onTap: (){
                value.setRealtimeDb(false);
                print(dbProvider.realtimeDb.toString());
                Navigator.push(context, MaterialPageRoute(builder: (context)=> SplashScreen()));
                setState(() {

                });
              },
              child: value.realtimeDb ? Icon(Icons.offline_bolt_outlined) : Icon(Icons.offline_bolt));
        }),
        title: Text("Realtime DB Posts Screen"),
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
          // Expanded(
          //   flex: 1,
          //   child: StreamBuilder(
          //       stream: ref.onValue,
          //       builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          //         if (!snapshot.hasData) {
          //           return CircularProgressIndicator();
          //         }
          //         else {
          //           Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as dynamic;
          //           List<dynamic> list = [];
          //           list.clear();
          //           list = map.values.toList();
          //
          //           return ListView.builder(
          //               itemCount: snapshot.data!.snapshot.children.length,
          //               itemBuilder: (context, index) {
          //                 // print(list[index]['title']);
          //                 // print(list[index]['id']);
          //                return ListTile(
          //                   title: Text(list[index]['title'].toString()),
          //                   subtitle: Text(list[index]['id'].toString()),
          //                 );
          //               });
          //         }
          //       }),
          // ),
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
          Expanded(
            child: FirebaseAnimatedList(
                query: ref,
                itemBuilder: (context, snapshot, animation, index) {
                  final title = snapshot.child('title').value.toString();
                  final image = snapshot.child('img').value.toString();
                  final id = snapshot.child('id').value.toString();
                  if (searchFilterController.text.isEmpty) {
                    return ListTile(
                      title: Text(title),
                      subtitle: Text(id),
                      leading: Image(image: NetworkImage(image.toString()),),
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
                                  ref.child(id).remove().then((value) {
                                    Utils().toastMessage("Post Deleted");
                                  }).onError((error, stackTrace){
                                    Utils().toastMessage(error.toString());

                                  });
                                },
                                leading: Icon(Icons.delete),
                                title: Text("Delete"),
                              )),
                        ],
                      ),
                    );
                  } else if (title
                      .toLowerCase()
                      .contains(searchFilterController.text.toLowerCase())) {
                    return ListTile(
                      title: Text(snapshot.child('title').value.toString()),
                      leading: Image(image: NetworkImage(image.toString()),),
                      subtitle: Text(snapshot.child('id').value.toString()),
                    );
                  } else {
                    return Container();
                  }
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddPostScreen()));
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
                    ref.child(id).update({
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
