import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devio/constants/db_constants.dart';
import 'package:devio/mapview_page/mapview_page.dart';
import 'package:devio/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    if (docSnap.exists) {
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
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading profile information'),
            );
          }

          if (snapshot.hasData) {
            UserModel model = UserModel.fromJson(snapshot.data!);
            debugPrint(
                "Dashboard drawer profile > Future builder > model: ${snapshot.data!.toString()}");
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 64,
                    backgroundColor: const Color.fromARGB(255, 178, 175, 175),
                    foregroundImage: NetworkImage(
                      model.dpUrl ??
                          "https://media.istockphoto.com/id/1476170969/photo/portrait-of-young-man-ready-for-job-business-concept.webp?b=1&s=170667a&w=0&k=20&c=FycdXoKn5StpYCKJ7PdkyJo9G5wfNgmSLBWk3dI35Zw=",
                    ), //! Profile picture needed
                  ),
                  Text(
                    "${model.firstName} ${model.lastName}", //! User name needed
                    style: const TextStyle(
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'About You',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    title: Text('Username: @${model.username}'),
                  ),
                  ListTile(
                    dense: true,
                    title: Text(
                        'Date of Birth: ${DateFormat('dd/MM/yyyy').format(model.dob!.toDate())}'),
                  ),
                  ListTile(
                    dense: true,
                    title: Text('Gender: ${model.gender}'),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const MapViewPage()));
                    },
                    child: const ListTile(
                      trailing: Icon(
                        Icons.pin_drop,
                      ),
                      title: Text('Your location'),
                    ),
                  ),
                  const Expanded(
                    child: SizedBox(),
                  ),
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
                  // OutlinedButton(
                  //     onPressed: () {},
                  //     child: const Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           Icon(Icons.settings),
                  //           SizedBox(
                  //             width: 10,
                  //           ),
                  //           Text("Settings"),
                  //         ])),
                ],
              ),
            );
          }

          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [CircularProgressIndicator(), Text('Loading...')],
          );
        },
      ),
    );
  }
}
