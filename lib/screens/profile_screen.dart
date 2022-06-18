import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ndialog/ndialog.dart';
import 'package:todo_flutter_app_pseb_bridge/util/utility.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DocumentSnapshot? userSnapshot;
  File? imageFile;
  bool showLocalFile = false;

  getUserDetails() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    setState(() {});
  }

  _pickImageFrom(ImageSource imageSource) async {
    XFile? xFile = await ImagePicker().pickImage(source: imageSource);

    if (xFile == null) return;

    final tempImage = File(xFile.path);

    imageFile = tempImage;
    showLocalFile = true;
    setState(() {});

    // upload to firebase storage

    ProgressDialog progressDialog = ProgressDialog(
      context,
      title: const Text('Uploading !!!'),
      message: const Text('Please wait'),
    );
    progressDialog.show();
    try {
      var fileName = userSnapshot!['email'] + '.jpg';

      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(fileName)
          .putFile(imageFile!);

      TaskSnapshot snapshot = await uploadTask;

      String profileImageUrl = await snapshot.ref.getDownloadURL();

      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'profileImage': profileImageUrl});

      Fluttertoast.showToast(msg: 'Profile image uploaded');

      print(profileImageUrl);

      progressDialog.dismiss();
    } catch (e) {
      progressDialog.dismiss();

      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('User Details'),
        ),
        body: userSnapshot == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                            radius: 80,
                            backgroundImage: showLocalFile
                                ? FileImage(imageFile!) as ImageProvider
                                : NetworkImage(userSnapshot!['profileImage'])),
                        IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.image),
                                          title: const Text('From Gallery'),
                                          onTap: () {
                                            _pickImageFrom(ImageSource.gallery);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.camera_alt),
                                          title: const Text('From Camera'),
                                          onTap: () {
                                            _pickImageFrom(ImageSource.camera);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                userSnapshot!['fullName'],
                                style: const TextStyle(fontSize: 18),
                              ),
                              Text(
                                userSnapshot!['email'],
                                style: const TextStyle(fontSize: 18),
                              ),
                              Text(
                                'Joined ${Utility.getHumanReadableDate(userSnapshot!['dt'])}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
  }
}
