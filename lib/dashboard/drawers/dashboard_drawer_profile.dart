import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devio/constants/db_constants.dart';
import 'package:devio/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardDrawerProfile extends StatefulWidget {
  //const DashboardDrawerProfile({super.key});

  @override
  State<DashboardDrawerProfile> createState() => _DashboardDrawerProfileState();
}

class _DashboardDrawerProfileState extends State<DashboardDrawerProfile> {
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      Navigator.popUntil(
        context,
        ModalRoute.withName("/"),
      );
    }

    return;
  }

  Future<Map<String, dynamic>?> _getUserInfo() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance
        .collection(UsersCollection.collectionName)
        .doc(uid);
    final docSnap = await docRef.get();
    if(docSnap.exists) {
      return docSnap.data();
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserInfo(),
        builder: (context, snapshot) {
          if(snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading profile information'
              ),
            );
          }

          if(snapshot.hasData) {
            UserModel model = UserModel.fromJson(snapshot.data!);
            debugPrint("Dashboard drawer profile > Future builder > model: ${snapshot.data!.toString()}");
            return Column(
              children: [
                Expanded(
                  flex: MediaQuery.of(context).orientation == Orientation.portrait
                      ? 2
                      : 6,
                  child: DrawerHeader(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 4,
                          child: CircleAvatar(
                            minRadius: MediaQuery.of(context).size.width / 8,
                            maxRadius: MediaQuery.of(context).size.width / 4,
                            backgroundColor: const Color.fromARGB(255, 178, 175, 175),
                            foregroundImage: NetworkImage(
                              model.dpUrl ?? "https://media.istockphoto.com/id/1476170969/photo/portrait-of-young-man-ready-for-job-business-concept.webp?b=1&s=170667a&w=0&k=20&c=FycdXoKn5StpYCKJ7PdkyJo9G5wfNgmSLBWk3dI35Zw=",
                            ), //! Profile picture needed
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            "${model.firstName} ${model.lastName}", //! User name needed
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height / 30,
                              fontFamily: 'Pacifico',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: MediaQuery.of(context).orientation == Orientation.portrait
                      ? 3
                      : 4,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          logout(context);
                        },
                        child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout_outlined),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Logout"),
                            ]),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.settings),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Settings"),
                            ]), //! Other Funtionalities should be added
                      ),
                    ],
                  ),
                )
              ],
            );
          }

          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Text('Loading...')
            ],
          );
        },
      ),
    );
  }
}
