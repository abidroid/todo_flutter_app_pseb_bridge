
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {

  var taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: taskController,
              decoration: const InputDecoration(
                  hintText: 'Task Name'
              ),
            ),

            const SizedBox(height: 10,),

            ElevatedButton(onPressed: () async{

              String taskName = taskController.text.trim();

              if( taskName.isEmpty){
                Fluttertoast.showToast(msg: 'Please provide task name');
                return;
              }

              User? user = FirebaseAuth.instance.currentUser;

              if( user != null ){

                String uid = user.uid;
                int dt = DateTime.now().millisecondsSinceEpoch;

                //DatabaseReference taskRef = FirebaseDatabase.instance.reference().child('tasks').child(uid);

                FirebaseFirestore firestore = FirebaseFirestore.instance;

                var taskRef = firestore.collection('tasks').doc(uid).collection('tasks').doc();

               await taskRef.set({
                  'dt': dt,
                  'taskName': taskName,
                  'taskId': taskRef.id,
                });

                Fluttertoast.showToast(msg: 'Task Added');
                Navigator.of(context).pop();

              }

            }, child: const Text('Save')),

          ],
        ),
      ),
    );  }
}
