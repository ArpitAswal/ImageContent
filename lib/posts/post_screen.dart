import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ImageContent/database_alert.dart';
import 'package:ImageContent/auth/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../chat-screen.dart';
import '../functionCalls/image_permission.dart';
import '../upload/post_content.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final searchController = TextEditingController();
  final editTextController = TextEditingController();
  final editDescriptionController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DatabaseReference reference;
  late DatabaseReference dbRef;
  late CollectionReference colRef;
  late Reference storageRef;
  late Future<String> _profileUrl;
  late Stream<QuerySnapshot> dataStream;
  final picker = ImagePicker();
  File? galleryFile;

  @override
  void initState() {
    dbRef = FirebaseDatabase.instance.ref('Database of Information');
    reference = FirebaseDatabase.instance
        .ref('Database of Information')
        .child('${_auth.currentUser?.uid}')
        .child('Content');
    colRef = FirebaseFirestore.instance
        .collection("UserContents")
        .doc(_auth.currentUser!.uid.toString())
        .collection("ContentData");
    _profileUrl = _fetchProfileImageUrl();
    storageRef = FirebaseStorage.instance
        .ref()
        .child("${_auth.currentUser?.displayName}/ProfileImages");
    searchController.addListener(_updateQuery);
    _updateQuery();
    super.initState();
  }

  Future<String> _fetchProfileImageUrl() async {
    final DataSnapshot snapshot = await dbRef
        .child(_auth.currentUser!.uid.toString())
        .child('Profile Image')
        .get();

    if (snapshot.exists) {
      return snapshot.value.toString();
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return true;
        },
        child: Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: InkWell(
                  onTap: () {
                    showPicker(context: context);
                  },
                  child: FutureBuilder<String>(
                    future: _profileUrl,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return const Icon(Icons.error);
                      } else if (snapshot.hasData) {
                        final imageUrl = snapshot.data!.toString();
                        return (imageUrl.isNotEmpty)
                            ? CircleAvatar(
                                radius: 18.0,
                                backgroundImage: NetworkImage(
                                  imageUrl,
                                ))
                            : const Icon(Icons.account_circle, size: 40.0);
                      } else {
                        return const Icon(Icons.error);
                      }
                    },
                  ),
                ),
              ),
              centerTitle: true,
              title: const Text(
                "Post Screen",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatScreen(id: '236')));
                  },
                ),
                logOut(),
                const SizedBox(
                  width: 10,
                )
              ],
            ),
            floatingActionButton: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PostContent()));
                },
                child: const Center(
                    child: Icon(
                  Icons.add_photo_alternate,
                  size: 32,
                )),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () {
                return Future.delayed(const Duration(seconds: 1), () {
                  final snackBar = SnackBar(
                    content: const Text('Screen Refreshed',
                        style: TextStyle(color: Colors.black)),
                    elevation: 4,
                    backgroundColor: Colors.blueGrey.shade50,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  setState(() {});
                });
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 12),
                    child: TextField(
                      controller: searchController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(21.0),
                              borderSide: const BorderSide(color: Colors.black)),
                          disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(21.0),
                              borderSide: const BorderSide(color: Colors.black)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(21.0),
                              borderSide: const BorderSide(color: Colors.blue)),
                          hintText: 'Search',
                          hintStyle: const TextStyle(color: Colors.black54),
                          prefixIcon: const Icon(
                            Icons.search_outlined,
                            color: Colors.black54,
                          )),
                      onEditingComplete: (){
                        setState(() {});
                      },
                    ),
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Contents-',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.w400))),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: dataStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: SizedBox(
                              height: 70,
                              width: 70,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Loading',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.black54)),
                                  CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.black54)
                                ],
                              ),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text('There is no content uploaded yet!'));
                        }

                        var docs = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            var doc = docs[index];
                            var con = doc['Content'] ?? '';
                            var image = doc['Image'] ?? '';
                            var date = doc['Date'] ?? '';
                            var docId = doc['DocID'] ?? '';

                            return _content(
                                index + 1, con, date, image, docId);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            )));
  }

  Widget richText(String key, String value) {
    return RichText(
        softWrap: true,
        text: TextSpan(
            text: '$key: ',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
                fontStyle: FontStyle.normal,
                decoration: TextDecoration.underline),
            children: <InlineSpan>[
              const WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: SizedBox(width: 6)),
              TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    decoration: TextDecoration.none,
                    color: Colors.blue,
                  )),
            ]));
  }

  Future<void> showMyDialog(String text, String docId) async {
    var editController = TextEditingController();
    editController.text = text.toString();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Update Content"),
            content: TextFormField(
              controller: editController,
              keyboardType: TextInputType.text,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'modify the content ',
                hintStyle: TextStyle(color: Colors.blue, fontSize: 14),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    String date = DateTime.now().toString();
                    colRef.doc(docId).update({
                      'Date': date,
                      'Content': editController.text,
                      'ContentLowerCase': editController.text.toLowerCase()
                    }).then((value) {
                      alert.toastmessage('New Description Saved');
                    }).onError((error, stackTrace) {
                      alert.toastmessage(error.toString());
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Update'))
            ],
          );
        });
  }

  Widget _content(
      int index, String desc, String id, String image, String docId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: Column(
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  '${index.toString()}.',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                (image == 'null' || image.isEmpty)
                    ? Expanded(
                        child: Container(
                            height: 220,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                shape: BoxShape.rectangle,
                                color: Colors.teal[50]),
                            child: Center(
                                child: InkWell(
                              onTap: () {
                                updateImage();
                              },
                              child: SizedBox(
                                height: 60,
                                width: 60,
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        side: const BorderSide(
                                            color: Colors.deepPurple,
                                            width: 2)),
                                    elevation: 7,
                                    shadowColor: Colors.purple,
                                    child: const Icon(
                                        Icons.image_search_rounded,
                                        size: 48,
                                        color: Colors.deepPurple)),
                              ),
                            ))),
                      )
                    : Expanded(
                        child: Container(
                            height: 220,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                shape: BoxShape.rectangle,
                                color: Colors.teal[50]),
                            child: Image.network(
                              image,
                              fit: BoxFit.fill,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress != null) {
                                  return const Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.deepPurple));
                                } else {
                                  return child;
                                }
                              },
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stacktrace) {
                                return const Center(
                                    child: Text(
                                        "This image can't longer be saved on storage"));
                              },
                            )),
                      ),
              ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              (desc == 'null' || desc.isEmpty)
                  ? richText('Content', 'No description of this image')
                  : Expanded(
                      child: richText('Content', desc),
                    ),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        onPressed: () {
                          showMyDialog(desc, docId);
                        },
                        icon: const Icon(Icons.edit_note_rounded)),
                    IconButton(
                        onPressed: () {
                          colRef
                              .doc(docId)
                              .delete()
                              .then((value) =>
                                  alert.toastmessage('Content Delete'))
                              .onError((error, stackTrace) =>
                                  alert.toastmessage(error.toString()));
                        },
                        icon: const Icon(Icons.delete_forever))
                  ]),
            ],
          ),
        ],
      ),
    );
  }

  void updateImage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const PostContent()));
  }

  void updateProfile(String id) {
    showPicker(context: context);
  }

  void showPicker({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () async {
                  if (await askPermission('Gallery')) {
                    getImage(ImageSource.gallery);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () async {
                  if (await askPermission('Camera')) {
                    getImage(ImageSource.camera);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future getImage(
    ImageSource img,
  ) async {
    final pickedFile = await picker.pickImage(source: img);
    XFile? filePick = pickedFile;
    setState(
      () {
        if (filePick != null) {
          galleryFile = File(pickedFile!.path);
          saveProfile();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
              const SnackBar(content: Text('Nothing is selected')));
        }
      },
    );
    Navigator.of(context).pop();
  }

  Widget logOut() {
    return PopupMenuButton(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      icon: const Icon(Icons.exit_to_app_outlined),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: ListTile(
              title: const Text('Delete Account'),
              trailing: const Icon(Icons.delete),
              onTap: () async {
                Navigator.pop(context);
                dbRef.child('${_auth.currentUser?.uid}').remove();
                colRef
                    .doc(_auth.currentUser!.displayName)
                    .delete()
                    .then((value) => debugPrint("User Deleted"))
                    .catchError(
                        (error) => debugPrint("Failed to delete user: $error"));
                await _auth.currentUser?.delete().then((value) {
                  alert.toastmessage('Deleted');
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                }).onError((error, stackTrace) {
                  alert.toastmessage(error.toString());
                });
              }),
        ),
        PopupMenuItem(
            child: ListTile(
                title: const Text("SignOut"),
                trailing: const Icon(Icons.logout_outlined),
                onTap: () async {
                  Navigator.pop(context);
                  await _auth.signOut().then((value) {
                    alert.toastmessage('Signed out');
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                  }).onError((error, stackTrace) {
                    alert.toastmessage(error.toString());
                  });
                }))
      ],
    );
  }

  void saveProfile() async {
    String date = DateTime.now().millisecondsSinceEpoch.toString();
    final TaskSnapshot uploadTask =
        await storageRef.child(date).putFile(File(galleryFile!.absolute.path));
    var imageUrl = await uploadTask.ref.getDownloadURL();
    if (imageUrl.isEmpty || imageUrl == 'null') {
      alert.toastmessage("No image Path received! Something went Wrong.");
    } else {
      dbRef
          .child('${_auth.currentUser?.uid}')
          .update({'Profile Image': imageUrl.toString()}).whenComplete(() {
        setState(() {
          _profileUrl = _fetchProfileImageUrl();
        });
      });
    }
  }

  void _updateQuery() {
    String searchText = searchController.text.trim().toLowerCase();

    if (searchText.isEmpty) {
      // Query to sort by Date
      dataStream = colRef
          .orderBy('Date', descending: true)
          .snapshots();
    } else {
      // Query to filter by Description and sort by Date
      dataStream = colRef
          .where('ContentLowerCase', isGreaterThanOrEqualTo: searchText)
          .where('ContentLowerCase', isLessThanOrEqualTo: '$searchText\uf8ff') // Using \uf8ff for range query
          .orderBy('ContentLowerCase', descending: true)
          .orderBy('Date', descending: true)
          .snapshots();
    }
  }
}
