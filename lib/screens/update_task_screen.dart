import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UpdateTaskScreen extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  const UpdateTaskScreen({Key? key, required this.documentSnapshot})
      : super(key: key);

  @override
  State<UpdateTaskScreen> createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  var nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.documentSnapshot['taskName'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Task Name'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () async {
                  var taskName = nameController.text.trim();
                  if (taskName.isEmpty) {
                    Fluttertoast.showToast(msg: 'Please provide task name');
                    return;
                  }

                  String uid = FirebaseAuth.instance.currentUser!.uid;

                  await FirebaseFirestore.instance
                      .collection('tasks')
                      .doc(uid)
                      .collection('tasks')
                      .doc(widget.documentSnapshot['taskId'])
                      .update({'taskName': taskName});

                  Fluttertoast.showToast(msg: 'Task Updated');
                  Navigator.of(context).pop();

                },
                child: const Text('Update')),
          ],
        ),
      ),
    );
  }
}
