import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:ImageContent/database_alert.dart';

import '../functionCalls/image_permission.dart';

class PostContent extends StatefulWidget {
  const PostContent({super.key});

  @override
  State<PostContent> createState() => _PostContentState();
}

class _PostContentState extends State<PostContent> {
  File? galleryFile;
  final picker = ImagePicker();
  bool load = false;
  bool uploading = false;
  late CollectionReference colRef;
  FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController _description = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String imageUrl;

  @override
  Widget build(BuildContext context) {
    //display image selected from gallery

    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Content Screen'),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (galleryFile == null) {
              alert.toastmessage("you didn't select any image to be upload");
            } else {
              setState(() {
                uploading = true;
              });
              uploadContent().then((_) {
                setState(() {
                  uploading = false;
                });
                alert.toastmessage("Uploaded");
                Navigator.of(context).pop();
              });
            }
          },
          child: const Icon(
            Icons.done_outlined,
            size: 30,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                height: 240.0,
                width: double.infinity,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black87)),
                child: galleryFile == null
                    ? const Icon(
                        Icons.image,
                        size: 60,
                      )
                    : Center(
                        child: Image.file(
                        galleryFile!,
                        fit: BoxFit.cover,
                      )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: TextFormField(
                    key: _formKey,
                    controller: _description,
                    style: const TextStyle(color: Colors.blue),
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                        prefixIconColor: Colors.black54,
                        prefixIcon: Icon(Icons.text_snippet),
                        labelText: 'Content',
                        labelStyle:
                            TextStyle(color: Colors.black, fontSize: 18),
                        hintText: 'write something about image',
                        hintStyle: TextStyle(color: Colors.blue, fontSize: 14)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        elevation: 7,
                        shadowColor: Colors.purple,
                        maximumSize: const Size(250, 45),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(21)),
                            side: BorderSide(color: Colors.white, width: 1.5)),
                        backgroundColor: Colors.deepPurple),
                    onPressed: () {
                      setState(() {
                        load = true;
                      });
                      _showPicker(context: context);
                    },
                    child: Center(
                        child: load
                            ? const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              )
                            : const Text(
                                'Select Image',
                                style: TextStyle(
                                    fontSize: 21, color: Colors.white),
                              ))),
              ),
              uploading == true ? const CircularProgressIndicator(color: Colors.blue,) : const SizedBox()
            ],
          ),
        ));
  }

  void _showPicker({
    required BuildContext context,
  }) {
    setState(() {
      load = false;
    });
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

  Future<void> uploadContent() async {
    String date = DateTime.now().toString();
    final reference = firebase_storage.FirebaseStorage.instance
        .ref()
        .child("${auth.currentUser?.displayName}/ContentsImages/$date");
    await reference.putFile(File(galleryFile!.path));
    imageUrl = await reference.getDownloadURL();
    if (imageUrl.isEmpty || imageUrl == 'null') {
      alert.toastmessage("No image Path received! Something went Wrong.");
    } else {
      var docId = generateDocId();
      colRef = FirebaseFirestore.instance.collection("UserContents").doc(auth.currentUser!.uid.toString()).collection("ContentData");
       await colRef.doc(docId).set({
          'Image': imageUrl.toString(),
          'Content': _description.text.toString(),
          'ContentLowerCase': _description.text.toLowerCase(),
          'Date': date,
          'DocID': docId
        });
    }
  }

  String generateDocId([int length = 10]) {
    const characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();
    return List.generate(length, (index) => characters[random.nextInt(characters.length)]).join();
  }

  Future getImage(
    ImageSource img,
  ) async {
    final pickedFile = await picker.pickImage(source: img);
    XFile? xfilePick = pickedFile;
    setState(
      () {
        if (xfilePick != null) {
          galleryFile = File(pickedFile!.path);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This imaged does not select')));
        }
      },
    );
    Navigator.of(context).pop();
  }
}
