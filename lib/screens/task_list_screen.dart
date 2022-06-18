import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_flutter_app_pseb_bridge/screens/add_task_screen.dart';
import 'package:todo_flutter_app_pseb_bridge/screens/login_screen.dart';
import 'package:todo_flutter_app_pseb_bridge/screens/profile_screen.dart';
import 'package:todo_flutter_app_pseb_bridge/util/utility.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  CollectionReference? taskRef;

  @override
  void initState() {
    super.initState();

    String uid = FirebaseAuth.instance.currentUser!.uid;
    taskRef = FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('tasks');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const ProfileScreen();
                }));
              },
              icon: const Icon(Icons.person)),
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        title: const Text('Confirmation !!!'),
                        content: const Text('Are you sure to Log Out ? '),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();

                              FirebaseAuth.instance.signOut();

                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) {
                                return const LoginScreen();
                              }));
                            },
                            child: const Text('Yes'),
                          ),
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.logout)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return const AddTaskScreen();
          }));
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: taskRef!.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No Tasks Yet'),
              );
            } else {
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(snapshot.data!.docs[index]['taskName']),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(Utility.getHumanReadableDate(
                                  snapshot.data!.docs[index]['dt']))
                            ],
                          )),
                          Column(
                            children: [
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 20,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (ctx) {
                                          return AlertDialog(
                                            title:
                                                const Text('Confirmation !!!'),
                                            content: const Text(
                                                'Are you sure to delete ? '),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(ctx).pop();
                                                  },
                                                  child: const Text('No')),
                                              TextButton(
                                                  onPressed: () async {
                                                    Navigator.of(ctx).pop();

                                                    if (taskRef != null) {
                                                      await taskRef!
                                                          .doc(
                                                              '${snapshot.data!.docs[index]['taskId']}')
                                                          .delete();
                                                    }
                                                  },
                                                  child: const Text('Yes')),
                                            ],
                                          );
                                        });
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 20,
                                  )),
                            ],
                          )
                        ],
                      ),
                    );
                  });
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
